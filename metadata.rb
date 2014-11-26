name 'galoshes'
maintainer 'Ben Pillet'
maintainer_email 'ben_pillet@yahoo.com'
license 'Apache 2.0'
description 'Manage AWS services with Chef'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'build-essential'

recipe 'galoshes::default', 'Installs and configures dependencies'
