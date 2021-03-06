-module(one).
-compile(export_all).

get_divs(N) ->
   [N] ++ [X || X <- lists:seq(1, N div 2 + 1), N rem X =:= 0].

num_of_presents(HouseNum) -> lists:sum(get_divs(HouseNum)).

calc(Limit) ->
    run(Limit, {1, 1}).

run(Limit, {HouseNum, NumOfPresents}) when NumOfPresents >= Limit -> HouseNum;
%run(Limit, {HouseNum, _}, Cache) when HouseNum rem 1 =:= 0 ->
%    io:format("~p ~p~n", [HouseNum]),
%    run(Limit, {HouseNum + 1, num_of_presents(HouseNum + 1, Cache)}, Cache);
run(Limit, {HouseNum, _}) ->
    run(Limit, {HouseNum + 1, num_of_presents(HouseNum + 1)}).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(list_to_integer(hd(string:tokens(get_all_lines(Device), "\n"))) div 10).
