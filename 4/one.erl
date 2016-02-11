-module(one).
-compile(export_all).

predicate([$0,$0,$0,$0,$0|_]) -> true;
predicate(_) -> false.

check(Key) ->
    predicate(lists:flatten([io_lib:format("~2.16.0b", [B]) || <<B>> <= erlang:md5(Key)])).

calc(Key) -> calc(Key, 1).

calc(Key, Salt) ->
    case check(lists:concat([Key, integer_to_list(Salt)])) of
        true -> Salt;
        false -> calc(Key, Salt + 1)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:strip(io:get_line(Device, ""), right, $\n)).
