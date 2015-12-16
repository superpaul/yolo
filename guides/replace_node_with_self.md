##Replacing a node with a machine of the same name
###Objective
The goal is to replace a Riak instance with a new Riak instance of the same name
so that the application environment does not need to have instance-name related 
changes. 

###Scenario

Riak is running in a cluster of five nodes.

 * `riak@node1.localdomain` on `node1.localdomain` (10.0.0.11)
 * `riak@node2.localdomain` on `node2.localdomain` (10.0.0.12)
 * `riak@node3.localdomain` on `node3.localdomain` (10.0.0.13)
 * `riak@node4.localdomain` on `node4.localdomain` (10.0.0.14)
 * `riak@node5.localdomain` on `node5.localdomain` (10.0.0.15)

The load-balancer being used performs periodic checks on the Riak nodes to
determine if they are suitable for servicing requests. 

A hard failure has occurred on `node2.localdomain` and it will not receive
requests until it is replaced with a node of the same name.  

The goal is to replace `riak@node2.localdomain` with a new Riak instance
named `riak@node2.localdomain` so that the application environment does not
need to have instance-name related changes.

### The Process tl;dr
This process can be accomplished in three steps, the details of which will
be discussed below.  

 * [Down the Node](#down)
 * [Build the new Node](#build)
 * [Join the new Node](#join)



----
### The Process
#### [Down the Node](id:down)
1. Stop riak on `riak@node2.localdomain` if the node is still running in any way.
    >**riak stop**

    ```
    node2> riak stop
    ok
    node2>
    ```

1. Shutdown `node2.localdomain`, using any means, from `shutdown -h now` to 
   hitting the power button.


1. Mark `riak@node2` down from `node1.localdomain`
	>**riak-admin down riak@node2.localdomain**
		
    ```
    node1> riak-admin down riak@node2.localdomain
    Success: "riak@node2.localdomain" marked as down
    node1>
    ```
    This will tell the cluster that this node is offline and ring-state 
    transtions should be allowed, and can be run from any running cluster node.


#### [Build the new Node](id:build)
1. Reformat `node2.localdomain` or start with clean hardware and install Riak.  

1. Edit the `/etc/riak/riak.conf` file on the new node and use the same settings
   as all other nodes apart from nodename and IP addresses:
    
    **Note: Using a temporary, yet resolvable, name for the Riak instance is important**  

    ```
    -name riak@192.168.17.12
    ``` 
    

1. Start `riak@192.168.17.12` on `node2.localdomain`.
    > **riak start**
    
    ```
    node2> riak start
    Attempting to restart script through sudo -H -u riak    
    node2>
    ```

1. Join the newly created node to the cluster.

    >**riak-admin cluster join riak@node1.localdomain**
 
    ```
    node2> riak-admin cluster join riak@node1.localdomain
    Attempting to restart script through sudo -H -u riak
    Success: staged join request for 'riak@192.168.17.12' to 'riak@node1.localdomain'
    node2>
    ```

1. Use `force-replace` to change all ownership references from `riak@node2.localdomain` to `riak@192.168.17.12`.
>    **riak-admin cluster force-replace riak@node2.localdomain riak@192.168.17.12**

    ```
    node2> riak-admin cluster force-replace riak@node2.localdomain riak@192.168.17.12
    Attempting to restart script through sudo -H -u riak
    Success: staged forced replacement of 'riak@node2.localdomain' with 'riak@192.168.17.18'
    node2>
    ```

1. Show the planned cluster changes.
    > **riak-admin cluster plan**
    
    ```
    node2> riak-admin cluster plan
    Attempting to restart script through sudo -H -u riak
    =========================== Staged Changes ============================
    Action         Nodes(s)
    -----------------------------------------------------------------------
    join           'riak@192.168.17.12'
    force-replace  'riak@node2.localdomain' with 'riak@192.168.17.12'
    -----------------------------------------------------------------------
    
    WARNING: All of 'riak@node2.localdomain' replicas will be lost
    
    NOTE: Applying these changes will result in 1 cluster transition
    
    #######################################################################
                         After cluster transition 1/1
    #######################################################################
    
    ============================= Membership ==============================
    Status     Ring    Pending    Node
    -----------------------------------------------------------------------
    valid      20.3%      --      'riak@192.168.17.12'
    valid      20.3%      --      'riak@node1.localdomain'
    valid      20.3%      --      'riak@node3.localdomain'
    valid      20.3%      --      'riak@node4.localdomain'
    valid      18.8%      --      'riak@node5.localdomain'
    -----------------------------------------------------------------------
    Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0
    
    Partitions reassigned from cluster changes: 13
      13 reassigned from 'riak@node2.localdomain' to 'riak@192.168.17.12'
    
    node2>
    ```

1. Commit the changes to the cluster.
    > **riak-admin cluster commit**
    
    ```
    node2> riak-admin cluster commit
    Attempting to restart script through sudo -H -u riak
    Cluster changes committed
    node2>
    ```
1. Check that everything connected and functioning as expected
	>**riak-admin member-status**
	
    ```
    node2> riak-admin member-status
    Attempting to restart script through sudo -H -u riak
    ============================= Membership ==============================
    Status     Ring    Pending    Node
    -----------------------------------------------------------------------
    valid      20.3%      --      'riak@192.168.17.18'
    valid      20.3%      --      'riak@node1.localdomain'
    valid      20.3%      --      'riak@node3.localdomain'
    valid      20.3%      --      'riak@node4.localdomain'
    valid      18.8%      --      'riak@node5.localdomain'
    -----------------------------------------------------------------------
    Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0
    ```

#### [Rename the Node to the Original Name](id:rename)

1. Stop `riak@192.168.17.12` on `node2.localdomain`.
    >**riak stop**

    ```
    node2> riak stop
    ok
    node2>
    ```


1. Mark `riak@192.168.17.12` down from `node1.localdomain`.

    >**riak-admin down riak@192.168.17.12**

    ```
    node1> riak-admin down riak@192.168.17.12
    Attempting to restart script through sudo -H -u riak
    Success: "riak@192.168.17.12" marked as down
    node1>
    ```

1. Edit the `vm.args` file on the new node and set the `-name` argument as follows:
    
    ```
    -name riak@node2.localdomain
    ``` 


1. Back up the `riak@192.168.17.12` ring folder by renaming it to ring_192.186.17.12.  The ring files location can be determined by inspecting the `app.config` file, and are usually found in `/var/lib/riak/ring/`.
    >**mv /var/lib/riak/ring /var/lib/riak/ring_192.186.17.12**
    
    ```
    node2> mv /var/lib/riak/ring /var/lib/riak/ring_192.186.17.12
    node2>
    ```
    Moving the ring files will cause the node to "forget" that it was a member of a cluster and allow the node to start up with the new name.

1. Start riak on `node2.localdomain`.

    >**riak start**
    
    ```
    node2> riak start
    Attempting to restart script through sudo -H -u riak
    node2>
    ```

1. Join the `riak@node2.localdomain` to the cluster.
	>**riak-admin cluster join riak@node1.localdomain**
	
    ```
    node2> riak-admin cluster join riak@node2.localdomain
    Attempting to restart script through sudo -H -u riak
    Success: staged join request for 'riak@node2.localdomain' to 'riak@node1.localdomain'
    node2>
    ```

1. Use `force-replace` to change all ownership references from `riak@192.168.17.12` to `riak@node2`.
	>**riak-admin cluster force-replace riak@192.168.17.12 riak@node2.localdomain**
	
    ```
    node2> riak-admin cluster force-replace riak@192.168.17.12 riak@node2.localdomain
    Attempting to restart script through sudo -H -u riak
    Success: staged forced replacement of 'riak@192.168.17.18' with 'riak@node2.localdomain'
    node2>
    ```

1. Show the planned changed to the cluster.
	>**riak-admin cluster plan**
	
    ```
    node2> riak-admin cluster plan
    ```

1. Commit the changes.
	>**riak-admin cluster commit**
	
    ```
    node2> riak-admin cluster commit
    ```

1. Check that everything is running as expected
	>**riak-admin member-status**
	
    ```
    node2> riak-admin member-status
    Attempting to restart script through sudo -H -u riak
    =========================== Staged Changes ============================
    Action         Nodes(s)
    -----------------------------------------------------------------------
    force-replace  'riak@192.168.17.12' with 'riak@node2.localdomain'
    join           'riak@node2.localdomain'
    -----------------------------------------------------------------------
    
    WARNING: All of 'riak@192.168.17.12' replicas will be lost
    
    NOTE: Applying these changes will result in 1 cluster transition
    
    #######################################################################
                         After cluster transition 1/1
    #######################################################################
    
    ============================= Membership ==============================
    Status     Ring    Pending    Node
    -----------------------------------------------------------------------
    valid      20.3%      --      'riak@node1.localdomain'
    valid      20.3%      --      'riak@node2.localdomain'
    valid      20.3%      --      'riak@node3.localdomain'
    valid      20.3%      --      'riak@node4.localdomain'
    valid      18.8%      --      'riak@node5.localdomain'
    -----------------------------------------------------------------------
    Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0
    
    Partitions reassigned from cluster changes: 13
      13 reassigned from 'riak@192.168.17.12' to 'riak@node2.localdomain'
    
    node2>
    ```

1. Remove the backed-up ring folder from `node2.localdomain`

	>**rm -rf /var/lib/riak/ring_192.186.17.12**
	
    ```
    node2> rm -rf /var/lib/riak/ring_192.186.17.12
    node2>
    ```


