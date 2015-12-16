%% Fold over a list of vnodes and check for data in them by bucket/key hash
%%

f(). % Reset the shell
Nval=3.
{ok, R} = riak_core_ring_manager:get_my_ring(), ok.
Owners = riak_core_ring:all_owners(R), ok.

%% If you want to grab a parttion from the 'Owners' list you can do this
%%[P1|_] = Owners, % take partition 1 (P1) from head of list
%%{P,N} = P1, % assign partition and node to P and N

%% You can pass in a bucket as an option to fold/4 rather than fold/3
%%Bucket = riak_cs_utils:to_bucket_name(blocks, <<"testbucket">>).

lists:foldl(fun(PN, _) ->
  {P,_N} = PN,
  Final = riak_kv_vnode:fold(PN, fun(BK, _O, Acc) ->
    DocIdx = riak_core_util:chash_key(BK), % get the hash of the bucket key 
    AllPref = riak_core_ring:preflist(DocIdx, R), % get full preflist for hash
    {Pref,_} = lists:split(Nval, AllPref), % split the list to {primary,other}
    case [Partition || {Partition, _Node} <- Pref, Partition =:= P] of
      [] -> % not owner
        [BK|Acc];
      _ ->
        %%[BK|Acc] % uncomment for debug
        Acc % return empty accumulator
    end
  end, []),
  case Final of
      [] ->
        io:format("vnode ~p ok~n", [P]);
      _ ->
        io:format("misplaced keys found in ~p~n", [P]),
        file:write_file("/tmp/partition_" ++ integer_to_list(P), io_lib:format("~w.", [Final]))
  end
end, [], Owners).