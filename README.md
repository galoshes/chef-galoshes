galoshes
=============

![galoshes](http://www.whistlestopgrill.com/site/wp-content/uploads/Don-t-forget-you-galoshes-flora-and-fauna-18590881-500-357.jpg)

This cookbook manages AWS services including: Autoscaling Groups, DNS Zones and Records, Elastic Load Balancers, Security Groups, VPC's and Subnets.

[![Build Status](https://secure.travis-ci.org/galoshes/galoshes.svg?branch=master)](http://travis-ci.org/galoshes/galoshes)
[![Code Climate](https://codeclimate.com/github/galoshes/galoshes.svg)](https://codeclimate.com/github/galoshes/galoshes)
[![Test Coverage](https://codeclimate.com/github/galoshes/galoshes/badges/coverage.svg)](https://codeclimate.com/github/galoshes/galoshes)

## Getting Started

See [Quick Start](https://github.com/galoshes/galoshes/wiki/Quick-Start) for an introduction to using galoshes.

## Attributes

Attributes have default values set in `attributes/default.rb`. The aws_access_key_id 
and aws_secret_access_key are set to the values in `databag('aws', 'main')` to reduce
duplication for users of the aws cookbook.

General attributes:

* `node['galoshes']['aws_access_key_id']`: AWS credentials to use if they are not
  specified for the individual resources.
* `node['galoshes']['aws_secret_access_key']`: AWS credentials to use if they are not
  specified for the individual resources.
* `node['galoshes']['region']`: AWS region to use if not specified for the
  individual resources.

## Resources

### Servers

* `security_group`
* `server`

### Autoscaling Groups

* `autoscaling_group`
* `launch_configuration`

### DNS

* `dns_record`
* `dns_zone`

### VPC

* `dhcp_options`
* `subnet`
* `vpc`

### Elastic Load Balancers

* `load_balancer`

## Recipes

This cookbook intended to be used primarily with a wrapper cookbook.  

The `default` recipe should be included wherever galoshes is used to ensure
dependencies like `fog` are available.

### default

Primarily ensures dependencies are met.

## Usage

This cookbook is intended to be used with a wrapper cookbook.  An example
is in the works.

## License and Authors

- Author: Benjamin Pillet <ben_pillet@yahoo.com>
- Copyright 2014, Benjamin Pillet

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
