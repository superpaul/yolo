%% Fetch a "Missing" Block
%% Charlie Voiselle

%% THIS IS SOME SCAB CODE >>>
%% NOT YET FULLY TESTED   >>> BE WARNED

%% Directions: Run this from `riak-cs attach`, Change configuration
%%             elements as necessary.  Paste the tuple emitted in the 
%%             {error, notfound} log event into the line
%%

%% Step 1 - Add the configuration for a single node's PB API
%%          endpoint
IpString = "10.34.0.41". Port = 8087.

%% Step 2 - Collect this information from the logged 
%%          `{error, notfound}` event.
BucketName = "gncmontecarlo",
{UUID,BlockNo} = {<<96,90,248,29,252,186,73,72,135,47,24,17,0,177,174,67>>,11},

%% These functions will get you the values necessary to do backend
%% fetches from Riak for a single block
BlockBucketName = riak_cs_utils:to_bucket_name(blocks, BucketName).
BlockKey = riak_cs_lfs_utils:block_name("",UUID,BlockNo).

%% This will do the connection to Riak and fetch the object.  If we get
%% a block back then we will get read-repair as a side effect.  If this
%% returns an error, it should spit out the reason.

{ok, RiakcPid} = riakc_pb_socket:start_link(IpString, Port),

case riakc_pb_socket:get(RiakcPid, BlockBucketName, BlockKey) of
    {ok, Block} -> io:format("Got a block.",[]);
    {error, Reason} -> io:format("Got an error -- ~p~n, [Reason])
end,

riakc_pb_socket:stop(RiakcPid).