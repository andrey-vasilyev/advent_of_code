-module(two).
-compile(export_all).

add_leader_point(Deers) ->
    {L, _} = lists:foldl(fun({Name, _, _, _, _, _, _, X}, {_, Dist}) when X > Dist ->
                             {[Name], X};
                            ({Name, _, _, _, _, _, _, X}, {Names, Dist}) when X =:= Dist ->
                             {[Name] ++ Names, X};
                            (_, Acc) -> Acc
                         end, {[], 0}, Deers),
    lists:map(fun({Name, Speed, Run, Rest, Score, State, StateTime, Dist}) ->
                  case lists:member(Name, L) of
                      true -> {Name, Speed, Run, Rest, Score + 1, State, StateTime, Dist};
                      false -> {Name, Speed, Run, Rest, Score, State, StateTime, Dist}
                  end
              end, Deers).

calc(Deers, TravelTime) when TravelTime =:= 0 ->
    lists:foldl(fun({_, _, _, _, X, _, _, _}, Acc) when X > Acc -> X; (_, Acc) -> Acc end, 0, Deers);
calc(Deers, TravelTime) ->
    TmpDeers = lists:map(fun({Name, Speed, Run, Rest, Score, State, StateTime, Dist}) ->
                             case {State, StateTime} of
                                {rest, X} when X > 0 -> {Name, Speed, Run, Rest, Score, rest, StateTime - 1, Dist};
                                {rest, _} -> {Name, Speed, Run, Rest, Score, run, Run - 1, Dist + Speed};
                                {run, X} when X > 0 -> {Name, Speed, Run, Rest, Score, run, StateTime - 1, Dist + Speed};
                                {run, _} -> {Name, Speed, Run, Rest, Score, rest, Rest - 1, Dist}
                             end
                         end, Deers),
    NewDeers = add_leader_point(TmpDeers),
    calc(NewDeers, TravelTime - 1).

to_list(Strings) ->
    lists:map(fun(X) ->
                [Name, _, _, Speed, _, _, Run, _, _, _, _, _, _, Rest, _] = string:tokens(X, " "),
                {Name, list_to_integer(Speed), list_to_integer(Run), list_to_integer(Rest), 0, run, list_to_integer(Run), 0}
              end, Strings).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(to_list(string:tokens(get_all_lines(Device), "\n")), 2503).
