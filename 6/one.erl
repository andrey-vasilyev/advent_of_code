-module(one).
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

apply_on_off(Cells, Table) -> ets:insert(Table, Cells), Table.
apply_toggle(Cells, Table) ->
    lists:foldl(fun(Coords, Tab) ->
                    [{_, State}] = ets:lookup(Tab, Coords),
                    ets:update_element(Tab, Coords, {2, not State}),
                    Tab
                end, Table, Cells).

apply({Cmd, {X1, Y1}, {X2, Y2}}, Table) ->
    case Cmd of
        on ->  apply_on_off([{{X, Y}, true}  || X <- lists:seq(X1, X2), Y <- lists:seq(Y1, Y2)], Table);
        off -> apply_on_off([{{X, Y}, false} || X <- lists:seq(X1, X2), Y <- lists:seq(Y1, Y2)], Table);
        toggle -> apply_toggle([{X, Y} || X <- lists:seq(X1, X2), Y <- lists:seq(Y1, Y2)], Table)
    end.

calc(Strings) ->
    Table = lists:foldl(fun({X, Y}, Tab) -> ets:insert(Tab, {{X, Y}, false}), Tab end,
                        ets:new(table, []),
                        [{X, Y} || X <- lists:seq(0, 999), Y <- lists:seq(0, 999)]),
    Cmds = lists:map(fun commands/1, lists:map(fun preprocess/1, Strings)),
    ets:select_count(lists:foldl(fun apply/2, Table, Cmds), ets:fun2ms(fun({_, Z}) when Z =:= true -> Z end)).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:tokens(get_all_lines(Device), "\n")).
