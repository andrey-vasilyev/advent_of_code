-module(two).
-compile(export_all).

calc(X) -> calc(X, [], [], 0).

calc(_, OAcc, CAcc, Count) when length(OAcc) < length(CAcc) -> Count;
calc([$(|T], OAcc, CAcc, Count) ->
    calc(T, "(" ++ OAcc, CAcc, Count + 1);
calc([$)|T], OAcc, CAcc, Count) ->
    calc(T, OAcc, ")" ++ CAcc, Count + 1).

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(io:get_line(Device, "")).
