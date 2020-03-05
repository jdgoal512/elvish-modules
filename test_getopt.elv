#!/usr/bin/env elvish
use getopt

fn testgroup []{
    testnumber = 1
    fn check_parm [received expected name]{
        if (eq $received $expected) {
            echo (styled $name" PASSED" green)
        } else {
            echo (styled $name" FAILED" red)
            echo "Expected:"
            echo $expected
            echo "Got:"
            echo $received
        }
    }
    put [opts expected_opts flags expected_flags args expected_args]{
        echo (styled "Test "$testnumber bold)
        testnumber = (+ $testnumber 1)
        if (not-eq $opts [&]) {
            for opt [(keys $opts)] {
                getopt:add_opt $opt $opts[$opt]
            }
        }
        if (not-eq $flags []) {
            for flag $flags {
                getopt:add_flag $flag
            }
        }
        parms = (getopt:getopts $@args)
        put $parms
        check_parm $parms[opts] $expected_opts "OPTS"
        check_parm $parms[flags] $expected_flags "FLAGS"
        check_parm $parms[args] $expected_args "ARGS"
        getopt:clear
    }
}

test~ = (testgroup)

test [&] [&] [] [&] [] []
test [&] [&] [f] [&f=$false] [] []
test [&] [&] [f] [&f=$true] [-f] []
test [&] [&] [f flag] [&f=$false &flag=$false] [] []
test [&opt="DEFAULT"] [&opt="DEFAULT"] [] [&] [] []
test [&opt="DEFAULT"] [&opt="SET"] [] [&] [-opt SET] []
test [&opt="DEFAULT"] [&opt="DEFAULT"] [f] [&f=$false] [] []
test [&opt="DEFAULT"] [&opt="DEFAULT"] [f] [&f=$true] [-f] []
test [&opt="DEFAULT"] [&opt="DEFAULT"] [f] [&f=$false] [.] [.]
test [&] [&] [f] [&f=$true] [-f] []
test [&] [&] [f] [&f=$true] [-f a b] [a b]
test [&opt="DEFAULT"] [&opt="DEFAULT"] [f] [&f=$true] [-f] []
test [&opt="DEFAULT"] [&opt="DEFAULT"] [f] [&f=$true] [-f .] [.]
test [&opt="DEFAULT"] [&opt="SET"] [] [&] [-opt SET ARG] [ARG]
echo ""
getopt:add_flag --verbose -v
getopt:add_flag --single
getopt:add_flag -help h &help="This is a help message for a flag"
getopt:add_opt opt default
getopt:add_opt help_opt default &help="This is a help message for an opt"
getopt:help_message
echo ""
getopt:getopts hello --help_opt jkl -v world --opt NEW_VALUE

