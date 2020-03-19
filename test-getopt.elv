#!/usr/bin/env elvish
use getopt

fn testgroup []{
    testnumber = 1
    fn check-parm [received expected name]{
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
    put [opts expected-opts flags expected-flags args expected-args]{
        echo (styled "Test "$testnumber bold)
        testnumber = (+ $testnumber 1)
        if (not-eq $opts [&]) {
            for opt [(keys $opts)] {
                getopt:add-opt $opt $opts[$opt]
            }
        }
        if (not-eq $flags []) {
            for flag $flags {
                getopt:add-flag $flag
            }
        }
        parms = (getopt:getopts $@args)
        put $parms
        check-parm $parms[opts] $expected-opts "OPTS"
        check-parm $parms[flags] $expected-flags "FLAGS"
        check-parm $parms[args] $expected-args "ARGS"
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
getopt:add-flag --verbose -v
getopt:add-flag --single
getopt:add-flag -help h &help="This is a help message for a flag"
getopt:add-opt opt default
getopt:add-opt help-opt default &help="This is a help message for an opt"
getopt:help-message
echo ""
getopt:getopts hello --help-opt jkl -v world --opt NEW-VALUE

