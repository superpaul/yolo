#!/usr/bin/env python
# AWS Access Key and AWS Secret Key must be set as environment variables in ENV

import boto.ec2

# set some variables
# move these to arguments
REGION='eu-west-1'
AMI='ami-ce7b6fba'
MIN_COUNT=1
MAX_COUNT=1
KEY_NAME='dbrown_aws'
SECURITY_GROUPS
INSTANCE_TYPE='m1.small'

# connect to region
conn = boto.ec2.connect_to_region(REGION)

# launch instances
conn.run_instances(
	image_id=AMI,
	min_count=MIN_COUNT,
	max_count=MAX_COUNT,
	key_name=KEY_NAME,
	security_groups=['default'],
	instance_type=INSTANCE_TYPE)