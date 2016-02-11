-module(one).
-compile(export_all).

perms([]) -> [[]];
perms(L) -> [[H|T] || H <- L, T <- perms(L -- [H])].

happiness(Person, {Prev, Sum, Dict}) ->
    {Person, Sum + hd(dict:fetch({Person, Prev}, Dict)) + hd(dict:fetch({Prev, Person}, Dict)), Dict}.

mymax(Perms, Dict) ->
    L = lists:map(fun(X) -> lists:foldl(fun happiness/2, {lists:last(X), 0, Dict}, X) end, Perms),
    lists:foldl(fun({_, X, _}, Acc) -> max(X, Acc) end, -1, L).

calc(Dict) ->
    Keys = dict:fetch_keys(Dict),
    Persons = lists:foldl(fun({X, _}, Acc) -> sets:add_element(X, Acc) end, sets:new(), Keys),
    mymax(perms(sets:to_list(Persons)), Dict).

to_dict(Strings) ->
    lists:foldl(fun(X, Dict) ->
                    [A, _, Sign, Score, _, _, _, _, _, _, B] = string:tokens(X, " "),
                    S = case Sign =:= "gain" of
                            true -> list_to_integer(Score);
                            false -> -list_to_integer(Score)
                        end,
                    dict:append({A,lists:sublist(B, length(B) - 1)}, S, Dict)
                end, dict:new(), Strings).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(to_dict(string:tokens(get_all_lines(Device), "\n"))).
