-module(one).
-compile(export_all).

calc(Deers, TravelTime) ->
    lists:max(lists:map(fun({_, Speed, Time, Rest}) ->
                  D1 = (TravelTime div (Time + Rest)) * Speed * Time,
                  D2 = case TravelTime rem (Time + Rest) > Time of
                           true -> Speed * Time;
                           false -> 0
                  end,
                  D1 + D2
              end, Deers)).

to_list(Strings) ->
    lists:map(fun(X) ->
                [Name, _, _, Speed, _, _, Time, _, _, _, _, _, _, Rest, _] = string:tokens(X, " "),
                {Name, list_to_integer(Speed), list_to_integer(Time), list_to_integer(Rest)}
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
