#!/usr/bin/env escript 

-export([main/1]).

main([]) -> 
Par = rpc:call('riak@127.0.0.1',erlang,processes,[]), 
lists:foreach(fun(E) -> run_pids(E) end, Par).

run_pids(B) -> 
io:format("Process: ~p~n",[B]), 
R = rpc:call('riak@127.0.0.1',erlang,process_info,[B,[message_queue_len,registered_name]]), 
io:format("Process: ~w~n",[R]).