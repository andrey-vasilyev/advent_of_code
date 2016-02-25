-module(test_SUITE).
-include_lib("common_test/include/ct.hrl").

-export([all/0,    init_per_testcase/2, end_per_testcase/2,
         groups/0, init_per_group/2,    end_per_group/2]).
-export([day1/1,  day2/1,  day3/1,  day4/1,  day5/1,
         day6/1,  day7/1,  day8/1,  day9/1,  day10/1,
         day11/1, day12/1, day13/1, day14/1, day15/1,
         day16/1, day17/1, day18/1, day19/1, day20/1,
         day21/1, day22/1, day23/1, day24/1, day25/1]).

all() -> [{group, days}].

groups() -> [{days,
             [parallel],
             [day1,
              day2,
              day3,
              day4,
              day5,
              day6,
              day7,
              day8,
              day9,
              day10,
              day11,
              day12,
              day13,
              day14,
              day15,
              day16,
              day17,
              day18,
              day19,
              day20,
              day21,
              day22,
              day23,
              day24,
              day25]}].

root_dir_path() -> "../../".

num_from_day(Day) ->
    string:substr(atom_to_list(Day), length("day") + 1).

input(Day, Config) ->
    {One, Two} = ?config(Day, Config),
    [_, _, _, {_, ModPath}] = One:module_info(compile),
    Input = filename:dirname(ModPath) ++ "/input.txt",
    {One, Two, Input}.

init_per_group(_, Config) ->
    Config.

end_per_group(_, _) -> ok.

init_per_testcase(Day, Config) when Day =:= day25 ->
    [{Day, {load_task1(num_from_day(Day)), nothing}} | Config];

init_per_testcase(Day, Config) ->
    [{Day, {load_task1(num_from_day(Day)), load_task2(num_from_day(Day))}} | Config].

load_task1(Num) -> load_mod(Num, one).
load_task2(Num) -> load_mod(Num, two).

load_mod(Num, Part) ->
    InputFile = root_dir_path() ++ Num ++ "/" ++ atom_to_list(Part) ++ ".erl",
    TaskModName =  list_to_atom("day" ++ Num ++ "_" ++ atom_to_list(Part)),
    [Filename] = igor:merge(TaskModName, [InputFile], [{stubs, false}, {dir, root_dir_path() ++ Num}]),
    {ok, Mod, Bin} = compile:file(Filename, [binary]),
    code:load_binary(Mod, [], Bin),
    TaskModName.

end_per_testcase(Day, Config) ->
    {Task1ModName, Task2ModName} = ?config(Day, Config),
    Dir = root_dir_path() ++ "/" ++ num_from_day(Day) ++ "/",
    file:delete(Dir ++ atom_to_list(Task1ModName) ++ ".erl"),
    file:delete(Dir ++ atom_to_list(Task1ModName) ++ ".erl.bak"),
    file:delete(Dir ++ atom_to_list(Task2ModName) ++ ".erl"),
    file:delete(Dir ++ atom_to_list(Task2ModName) ++ ".erl.bak").

day1(Config) ->
    ct:print("~p~n", [day1]),
    {One, Two, Input} = input(day1, Config),
    74 = One:start(Input),
    1795 = Two:start(Input).

day2(Config) ->
    ct:print("~p~n", [day2]),
    {One, Two, Input} = input(day2, Config),
    1588178 = One:start(Input),
    3783758 = Two:start(Input).

day3(Config) ->
    ct:print("~p~n", [day3]),
    {One, Two, Input} = input(day3, Config),
    2572 = One:start(Input),
    2631 = Two:start(Input).

day4(Config) ->
    ct:print("~p~n", [day4]),
    {One, Two, Input} = input(day4, Config),
    282749 = One:start(Input),
    9962624 = Two:start(Input).

day5(Config) ->
    ct:print("~p~n", [day5]),
    {One, Two, Input} = input(day5, Config),
    258 = One:start(Input),
    53 = Two:start(Input).

day6(Config) ->
    ct:print("~p~n", [day6]),
    {One, Two, Input} = input(day6, Config),
    569999 = One:start(Input),
    17836115 = Two:start(Input).

day7(Config) ->
    ct:print("~p~n", [day7]),
    {One, Two, Input} = input(day7, Config),
    16076 = One:start(Input),
    2797 = Two:start(Input).

day8(Config) ->
    ct:print("~p~n", [day8]),
    {One, Two, Input} = input(day8, Config),
    1342 = One:start(Input),
    2074 = Two:start(Input).

day9(Config) ->
    ct:print("~p~n", [day9]),
    {One, Two, Input} = input(day9, Config),
    207 = One:start(Input),
    804 = Two:start(Input).

day10(Config) ->
    ct:print("~p~n", [day10]),
    {One, Two, Input} = input(day10, Config),
    360154 = One:start(Input),
    5103798 = Two:start(Input).

day11(Config) ->
    ct:print("~p~n", [day11]),
    {One, Two, Input} = input(day11, Config),
    "vzbxxyzz" = One:start(Input),
    "vzcaabcc" = Two:start(Input).

day12(Config) ->
    ct:print("~p~n", [day12]),
    {One, Two, Input} = input(day12, Config),
    156366 = One:start(Input),
    96852 = Two:start(Input).

day13(Config) ->
    ct:print("~p~n", [day13]),
    {One, Two, Input} = input(day13, Config),
    733 = One:start(Input),
    725 = Two:start(Input).

day14(Config) ->
    ct:print("~p~n", [day14]),
    {One, Two, Input} = input(day14, Config),
    2660 = One:start(Input),
    1256 = Two:start(Input).

day15(Config) ->
    ct:print("~p~n", [day15]),
    {One, Two, Input} = input(day15, Config),
    222870 = One:start(Input),
    117936 = Two:start(Input).

day16(Config) ->
    ct:print("~p~n", [day16]),
    {One, Two, Input} = input(day16, Config),
    373 = One:start(Input),
    260 = Two:start(Input).

day17(Config) ->
    ct:print("~p~n", [day17]),
    {One, Two, Input} = input(day17, Config),
    1638 = One:start(Input),
    17 = Two:start(Input).

day18(Config) ->
    ct:print("~p~n", [day18]),
    {One, Two, Input} = input(day18, Config),
    1061 = One:start(Input),
    1006 = Two:start(Input).

day19(Config) ->
    ct:print("~p~n", [day19]),
    {One, Two, Input} = input(day19, Config),
    535 = One:start(Input),
    212 = Two:start(Input).

day20(Config) ->
    ct:timetrap({hours, 6}),
    ct:print("~p~n", [day20]),
    {One, Two, Input} = input(day20, Config),
    ParentPid = self(),
    spawn(fun() -> ParentPid ! {one, One:start(Input)} end),
    spawn(fun() -> ParentPid ! {two, Two:start(Input)} end),
    receive
        {one, X} -> 786240 = X;
        {two, X} -> 831600 = X
    end,
    receive
        {one, Y} -> 786240 = Y;
        {two, Y} -> 831600 = Y
    end.

day21(Config) ->
    ct:print("~p~n", [day21]),
    {One, Two, Input} = input(day21, Config),
    91 = One:start(Input),
    158 = Two:start(Input).

day22(Config) ->
    ct:print("~p~n", [day22]),
    {One, Two, Input} = input(day22, Config),
    953 = One:start(Input),
    1289 = Two:start(Input).

day23(Config) ->
    ct:print("~p~n", [day23]),
    {One, Two, Input} = input(day23, Config),
    170 = One:start(Input),
    247 = Two:start(Input).

day24(Config) ->
    ct:print("~p~n", [day24]),
    {One, Two, Input} = input(day24, Config),
    11846773891 = One:start(Input),
    80393059 = Two:start(Input).

day25(Config) ->
    ct:print("~p~n", [day25]),
    {One, _Two, Input} = input(day25, Config),
    19980801 = One:start(Input).
