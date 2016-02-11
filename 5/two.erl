-module(two).
-compile(export_all).

to_pairs(X, []) -> [{X}];
to_pairs(X, [{H}|T]) -> [{H, X}] ++ T;
to_pairs(X, [{Y,Z}|T]) -> [{Z,X}] ++ [{Y,Z}] ++ T.

has_pairs([]) -> false;
has_pairs([_]) -> false;
has_pairs([_,_]) -> false;
has_pairs([X, Y|T]) when X =:= Y -> has_pairs([Y] ++ T);
has_pairs([X, Y|T]) ->
    case lists:member(X, T) of
        true -> true;
        false -> has_pairs([Y] ++ T)
    end.

check_pairs(String) ->
    has_pairs(lists:foldl(fun to_pairs/2, [], String)).

to_triplets(X, []) -> [{X}];
to_triplets(X, [{Y}|T]) -> [{Y, X}] ++ T;
to_triplets(X, [{Z,Y}|T]) -> [{Z, Y, X}] ++ T;
to_triplets(W, [{X,Y,Z}|T]) -> [{Y, Z, W}] ++ [{X, Y, Z}] ++ T.

check_repeats(String) ->
    lists:any(fun({X, _, Z}) -> X =:= Z end, lists:foldl(fun to_triplets/2, [], String)).

calc(Strings) ->
    length(lists:filter(fun check_repeats/1, lists:filter(fun check_pairs/1, Strings))).

get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof -> [];
        Line -> Line ++ get_all_lines(Device)
    end.

start() -> start("input.txt").

start(Filename) ->
    {ok, Device} = file:open(Filename, [read]),
    calc(string:tokens(get_all_lines(Device), "\n")).
