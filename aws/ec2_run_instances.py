#!/usr/bin/env python
# AWS Access Key and AWS Secret Key must be set as environment variables in ENV

import boto.ec2

# set some variables
# move these to arguments
REGION='eu-west-1'
#AMI='ami-ce7b6fba' # amazon ubuntu AMI
#AMI='ami-e3e73394' # Bryan's Riak Ops Training AMI
#AMI='ami-3804aa4f' # William Hill OPS AMI
AMI='ami-84a802f3' # William Hill DEV AMI
MIN_COUNT=13
MAX_COUNT=13
KEY_NAME='training'
SECURITY_GROUPS=''
INSTANCE_TYPE='m3.medium'

# connect to region
conn = boto.ec2.connect_to_region(REGION)

# launch instances
conn.run_instances(
	image_id=AMI,
	min_count=MIN_COUNT,
	max_count=MAX_COUNT,
	key_name=KEY_NAME,
	security_groups=['default','riak'],
	instance_type=INSTANCE_TYPE)
