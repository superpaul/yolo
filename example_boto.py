#!/usr/bin/env python

import boto.ec2

# connect to region
conn = boto.ec2.connect_to_region("eu-west-1")

# launch instances
conn.run_instances(
	image_id='ami-07cb2670',
	min_count=3,
	max_count=3,
	key_name='dbrown_aws',
	security_groups=['default'],
	instance_type='m1.small',
	dry_run=True)

# stop instances
conn.stop_instances(instance_ids=['instance-id-1','instance-id-2', ...])

# terminate instances
conn.terminate_instances(instance_ids=['instance-id-1','instance-id-2', ...])
