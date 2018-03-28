# -*- coding: utf-8 -*-
'''
Katello Runner
==============

.. versionadded: 2017.7.4

Runner to interact with Katello using the API. You're welcome.

:codeauthor: Louis Abel <tucklesepk@gmail.com>
:maintainer: Louis Abel <tucklesepk@gmail.com>

To use this runner, set up the Katello URL, username, password, and CA certificate in
the master configuration in ``/etc/salt/master`` or ``/etc/salt/master.d/katello.conf``:

.. code-block:: yaml

    katello:
      katello01.domain.com:
        username: 'admin'
        password: 'secret'
        protocol: 'https'
        certificate: '/etc/rhsm/ca/katello-server-ca.pem'

.. note::

    Certificate is for the CA certificates. If your katello instance certificate was
    signed by another CA and/or you have the certificate in a different location,
    specify the location. The default is ``/etc/rhsm/ca/katello-server-ca.pem``.

    The ``protocol`` option can be specified if needed, but it should be ``https`` in
    most cases.

'''
from __future__ import absolute_import

# Import python libs
import logging
import requests
import json

# Import third party libs
import salt.ext.six as six

log = logging.getLogger(__name__)

_sessions = {}

def __virtual__():
    '''
    Check for katello/foreman configuration in master
    or directory and load runner if called.
    '''
    if not _get_katello_configuration():
        return False, 'No katello/foreman configuration found.'
    return True

def _get_katello_configuration(katello_url=''):
    '''
    Return configuration read from the master configuration file.

    '''
    katello_config = __opts__['katello'] if 'katello' in __opts__ else None

    if katello_config:
        try:
            for katello_server, service_config in six.iteritems(katello_config):
                username = service_config.get('username', None)
                password = service_config.get('password', None)
                protocol = service_config.get('protocol', 'https')
                certificate = service_config.get('certificate', '/etc/rhsm/ca/katello-default-ca.pem')

                if not username or not password:
                    log.error('Username or Password has not been set on the master configuration for {0}'.format(katello_server))
                    return False

                ret = {
                    'api_url': '{0}://{1}/api/v2'.format(protocol, katello_server),
                    'api_url_katello': '{0}://{1}/katello/api'.format(protocol, katello_server),
                    'username': username,
                    'password': password,
                    'certificate': certificate
                }

                if (not katello_url) or (katello_url == katello_server):
                    return ret

        except Exception as exc:
            log.error(
                'Exception encountered: {0}'.format(exc)
            )

        if katello_url:
            log.error('Configuration for {0} has not been specified in the master configuration'.format(katello_url))
            return False

    return False

def _open_session_test(server):
    config = _get_katello_configuration(server)
    r = requests.get(config['api_url'], auth=(config['username'], config['password']), verify=config['certificate'])
    if r.status_code == '401':
        raise Exception('Incorrect username or password found on master for {0}'.format(server))
    elif r.status_code == '404':
        raise Exception('Is this a satellite server? {0}'.format(server))
    elif r.status_code == '200':
        return True

def _get_json(server, api, url):
    config = _get_katello_configuration(server)
    param = {'per_page': '1000'}
    r = requests.get(config[api] + url, auth=(config['username'], config['password']), verify=config['certificate'], params=param)
    return r.json()

def _get_results(server, api, url):
    '''
    Loosely borrowed from Red Hat's example. This will attempt to get json returns. In the case there's an error,
    it will report it. In other cases, it will return the json results from the request.
    '''
    jsn = _get_json(server, api, url)
    if jsn.get('error'):
        print "Error: " + jsn['error']['message']
    else:
        if jsn.get('results'):
            return jsn['results']
        elif 'results' not in jsn:
            return jsn
        else:
            print "No results available."
    return None

def _get_all_results(server, api, url):
    results = _get_results(server, api, url)
    if results:
        return results

def _get_collection_id(hostCollections, name):
    for i in hostCollections:
        for values in i.values():
            if values == name:
                id = i['id']
                return id

def _put_json(server, api, url, payload):
    '''
    api is the thing that says: is it api/ or katello/api
    url is the thing that comes after the api part of the url
    '''
    config = _get_katello_configuration(server)
    r = requests.put(config[api] + url, auth=(config['username'], config['password']), verify=config['certificate'], headers={'Content-Type': 'application/json', 'Accept': 'text/plain'}, data=payload)
    return r.json()

def _post_json(server, api, url, payload):
    '''
    api is the thing that says: is it api/ or katello/api
    url is the thing that comes after the api part of the url
    '''
    config = _get_katello_configuration(server)
    r = requests.post(config[api] + url, auth=(config['username'], config['password']), verify=config['certificate'], headers={'Content-Type': 'application/json'}, data=payload)
    return r.json()

def _delete_json(server, api, url, payload):
    '''
    api is the thing that says: is it api/ or katello/api
    url is the thing that comes after the api part of the url
    '''
    config = _get_katello_configuration(server)
    r = requests.delete(config[api] + url, auth=(config['username'], config['password']), verify=config['certificate'], headers={'Content-Type': 'application/json'}, data=payload)
    return r.json()

def addToHostCollections(host, name, server):
    '''
    Adds a host to host collections. This is especially useful for grouping up hosts to apply errata or perform other operations from Katello to the bulk of the hosts.
    '''
    try:
        _open_session_test(server)
    except Exception as exc:
        err_msg = 'Exception raised when connecting to Katello server ({0}): {1}'.format(server, exc)
        log.error(err_msg)
        return err_msg

    hostCollections = _get_all_results(server, 'api_url_katello', '/host_collections/')
    hostCollectionID = _get_collection_id(hostCollections, name)

    hostData = _get_all_results(server, 'api_url', '/hosts/' + host)
    if hostData == None:
        return {host: 'Host {0} does not exist on {1}.'.format(host, server)}

    ids = []
    ids.append(hostData['id'])
    hostPayload_dict = {"host_ids": ids}
    hostPayload = json.dumps(hostPayload_dict)
    addHostResult = _put_json(server, 'api_url_katello', '/host_collections/' + str(hostCollectionID) + '/add_hosts', hostPayload)

    # I don't know why, but katello returns either displayMessage or displayMessages. Love it.
    if addHostResult.keys()[0] == 'displayMessage':
        return {host: 'Host Collection "{0}" does not exist on {1}'.format(collection, server)}

    keys = addHostResult['displayMessages'].keys()
    error = addHostResult['displayMessages']['error']
    if keys[0] == 'success':
        if keys[1] == 'error' and error == []:
            return {host: 'Successfully added to host group "{0}" on {1} instance'.format(name, server)}
        else:
            return {host: 'Host already in "{0}" group on {1} instance'.format(name, server)}
    else:
        return {host: 'There was an error adding to "{0}" on {1}'.format(name, server)}

def deleteHost(host, server):
    '''
    Deletes a host from Katello. If a host does not exist or the incorrect name is provided, the 
    functions above (get_all_results) will return None. Because of this, it is assumed the host
    does not exist or was already removed.
    '''
    try:
        _open_session_test(server)
    except Exception as exc:
        err_msg = 'Exception raised when connecting to Katello server ({0}): {1}'.format(server, exc)
        log.error(err_msg)
        return err_msg
    
    hostData = _get_all_results(server, 'api_url', '/hosts/' + host)
    if hostData == None:
       return {host: 'Host {0} already deleted or does not exist on {1}.'.format(host, server)}

    ids = []
    ids.append(hostData['id'])
    hostPayload_dict = {"host_ids": ids}
    hostPayload = json.dumps(hostPayload_dict)
    deleteHostResult = _delete_json(server, 'api_url', '/hosts/' + str(hostCollectionID), hostPayload)
    deleteJson = deleteHostResult.json()

    keys = deleteJson.keys()
    if keys[0] == 'comment':
        return {host: 'Host {0} has been successfully deleted from {1}'.format(host, server)}

def getErrata(host, server):
    '''
    Reports applicable errata for a given host.

    Note: This only works for Satellite 6 or Katello instances that contain the necessary errata ID's for a given package.
    '''
    try:
        _open_session_test(server)
    except Exception as exc:
        err_msg = 'Exception raised when connecting to Katello server ({0}): {1}'.format(server, exc)
        log.error(err_msg)
        return err_msg

    hostData = _get_all_results(server, 'api_url', '/hosts/' + host)
    if hostData == None:
        return {host: 'Host {0} does not exist on {1}.'.format(host, server)}

    hostID = str(hostData['id'])

    getHostResults = _get_json(server, 'api_url', '/hosts/' + hostID + '/errata')

    i = []

    for x in getHostResults['results']:
        errata = x['errata_id'] + " " + x['title']
        i.append(errata)

    return {host: i}
