-module(two).
-compile(export_all).
-include_lib("stdlib/include/ms_transform.hrl").

preprocess(String) ->
    case lists:nth(2, String) of
        $u -> String;
        $o -> "turn " ++ String
    end.

commands(String) ->
    Cmd = case lists:nth(2, string:tokens(String, " ")) of
             "on" -> on;
             "off" -> off;
             "toggle" -> toggle
           end,

    {match, MatchList} = re:run(String, "\\d+", [global]),
    [X1, Y1, X2, Y2] = lists:map(fun([{Start, Len}]) ->
                                     list_to_integer(string:substr(String, Start + 1, Len))
                                 end, MatchList),
    {Cmd, {X1, Y1}, {X2, Y2}}.

on(V) -> V + 1.
off(V) -> max(0, V - 1).
toggle(V) -> V + 2.

apply_cmd(Cells, Table, Fun) ->
    lists:foldl(fun(Coords, Tab) ->
                    [{_, V}] = ets:lookup(Tab, Coords),
                    ets:update_element(Tab, Coords, {2, Fun(V)}),
                    Tab
                end, Table, Cells).

apply_cmd({Cmd, {X1, Y1}, {X2, Y2}}, Table) ->
    Cells = [{X, Y} || X <- lists:seq(X1, X2), Y <- lists:seq(Y1, Y2)],

    case Cmd of
        on -> apply_cmd(Cells, Table, fun on/1);
        off -> apply_cmd(Cells, Table, fun off/1);
        toggle -> apply_cmd(Cells, Table, fun toggle/1)
    end.

calc(Strings) ->
    Table = lists:foldl(fun({X, Y}, Tab) -> ets:insert(Tab, {{X, Y}, 0}), Tab end,
                        ets:new(table, []),
                        [{X, Y} || X <- lists:seq(0, 999), Y <- lists:seq(0, 999)]),
    Cmds = lists:map(fun commands/1, lists:map(fun preprocess/1, Strings)),
    ets:foldl(fun({_, Value}, Acc) -> Acc + Value end, 0, lists:foldl(fun apply_cmd/2, Table, Cmds)).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:tokens(get_all_lines(Device), "\n")).
