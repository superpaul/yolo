#!/usr/bin/env python

import boto.ec2

# connect to region
conn = boto.ec2.connect_to_region("eu-west-1")

# launch instances
conn.run_instances(
	image_id='ami-ce7b6fba',
	min_count=1,
	max_count=1,
	key_name='dbrown_aws',
	security_groups=['default','riak','riak-training'],
	instance_type='m1.large')

# get reservations
reservations = conn.get_all_reservations()

# list reservations
reservations

# get public dns names and instance ids
for instance in reservations[0].instances:
	print instance.public_dns_name
	print instance.id

# stop instances
conn.stop_instances(instance_ids=['instance-id-1','instance-id-2', ...])

# terminate instances
conn.terminate_instances(instance_ids=['instance-id-1','instance-id-2', ...])

# modify instance termination protection
conn.modify_instance_attribute('instance-id','disableApiTermination',False)

# terminate instances through individual calls
for instance in reservations[1].instances:
    conn.terminate_instances(instance_ids=[instance.id])