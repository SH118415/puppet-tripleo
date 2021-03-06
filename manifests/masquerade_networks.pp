# Copyright 2018 Red Hat, Inc.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: tripleo::masqueraded_networks
#
# Configure masqueraded_networks
#
# [*masquerade_networks*]
#   (Optional) Hash of masquerade networks to manage.
#   Defaults to Defaults to hiera('masquerade_networks', false)
#
class tripleo::masquerade_networks (
  $masquerade_networks = hiera('masquerade_networks', false)
){
  if $masquerade_networks {
    $masquerade_networks.each |$source, $destinations| {
      $destinations.each |$destination| {
        create_resources('tripleo::firewall::rule', {
          "137 routed_network return src ${source} dest ${destination}" => {
            'table'       => 'nat',
            'source'      => $source,
            'destination' => $destination,
            'jump'        => 'RETURN',
            'chain'       => 'POSTROUTING',
            'proto'       => 'all',
            'state'       => ['ESTABLISHED', 'NEW', 'RELATED'],
          },
        })
      }
      create_resources('tripleo::firewall::rule', {
        "138 routed_network masquerade ${source}" => {
          'table'       => 'nat',
          'source'      => $source,
          'jump'        => 'MASQUERADE',
          'chain'       => 'POSTROUTING',
          'proto'       => 'all',
          'state'       => ['ESTABLISHED', 'NEW', 'RELATED'],
        },
        "139 routed_network forward source ${source}" => {
          'source'      => $source,
          'chain'       => 'FORWARD',
          'proto'       => 'all',
          'state'       => ['ESTABLISHED', 'NEW', 'RELATED'],
        },
        "140 routed_network forward destinations ${source}" => {
          'destination' => $source,
          'chain'       => 'FORWARD',
          'proto'       => 'all',
          'state'       => ['ESTABLISHED', 'NEW', 'RELATED'],
        },
      })
    }
  }
}
