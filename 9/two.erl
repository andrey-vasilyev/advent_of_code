-module(two).
-compile(export_all).

perms([]) -> [[]];
perms(L) -> [[H|T] || H <- L, T <- perms(L -- [H])].

route_dist(A, {false, _, Dict}) -> {A, 0, Dict};
route_dist(B, {A, Sum, Dict}) -> {B, Sum + hd(dict:fetch({A, B}, Dict)), Dict}.

mymin(Perms, Dict) ->
    D = lists:map(fun(X) -> lists:foldl(fun route_dist/2, {false, 0, Dict}, X) end, Perms),
    lists:foldl(fun({_, X, _}, Acc) -> max(X, Acc) end, 0, D).

calc(Dict) ->
    Keys = dict:fetch_keys(Dict),
    Cities = lists:foldl(fun({X, _}, Acc) -> sets:add_element(X, Acc) end, sets:new(), Keys),
    mymin(perms(sets:to_list(Cities)), Dict).

to_dict(Strings) ->
    lists:foldl(fun(X, Dict) ->
                    [A, _, B, _, Dist] = string:tokens(X, " "),
                    D = list_to_integer(Dist),
                    dict:append({B,A}, D, dict:append({A,B}, D, Dict))
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
