
aws = Chef::DataBagItem.load('aws', 'main')

default['galoshes']['aws_access_key_id'] = aws['aws_access_key_id']
default['galoshes']['aws_secret_access_key'] = aws['aws_secret_access_key']

default['build_essential']['compiletime'] = true
default['build-essential']['compile_time'] = true
