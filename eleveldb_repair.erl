-module(repair).
-compile(export_all).

main([Dir]) ->
  Opts = [{max_open_files, 2000},
            {use_bloomfilter, true},
            {write_buffer_size, 45 * 1024 * 1024},
            {compression,false}], 

  {Time,_} = timer:tc(eleveldb,repair,[Dir, Opts]),
  io:format("Done took ~p seconds~n", [Time / 1000000]);

main(_) ->
  usage().

usage() ->
  io:format("usage: repair PATH_TO_PARTITION \n"),
  halt(1).