#About

These are my solutions written in Erlang for the tasks from [Advent of Code][http://adventofcode.com]

I am still learning Erlang, so some solutions might not be optimal both code and performance wise.
Also there is some code duplication in my solutions of similar tasks. I made it on purpose for anybody
who is interested in any specific solution to be able to see easily the whole picture in one file
with no missing or extra bits of code. Although code duplication makes it difficult to maintain the
code, I don't really plan on doing that anyway.

Hope you find it helpful!

#Development

If you are planning on improving the solutions, I've setup a test suite. It is located in **ct** folder.
To run it just do the following:

    cd ct
    ct_run -suite test_SUITE [-case day1 day2 ... dayN]

Be careful to run the whole suite at once, as it might take considerable time to finish (test **day20** is the worst).
