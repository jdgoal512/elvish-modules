use list
use str

var flags = []
var flags-flat = []
var flag-help = [&]
var opts = [&]
var opts-order = []
var opt-help = [&]

fn -remove-dashes {|@args|
    for arg $args {
        if (str:has-prefix $arg '--') {
            put $arg[2..]
        } elif (str:has-prefix $arg '-') {
            put $arg[1..]
        } else {
            put $arg
        }
    }
}

fn -check-if-parm {|parm value|
    if (str:has-prefix $value '-') {
        put (eq $parm (-remove-dashes $value))
    } else {
        put $false
    }
}

fn -check-if-opt {|value|
    put (has-key $opts (-remove-dashes $value))
}

fn -check-if-flag {|value|
    put (has-value $flags-flat (-remove-dashes $value))
}

fn clear {
    set flags = []
    set flags-flat = []
    set flag-help = [&]
    set opts = [&]
    set opts-order = []
    set opt-help = [&]
}

fn add-flag {|&help=$false primary-flag @rest|
    set primary-flag @rest = (-remove-dashes $primary-flag $@rest)
    if $help {
        set flag-help[$primary-flag] = $help
    }
    set flags = [$@flags [$primary-flag $@rest]]
    set flags-flat = [$@flags-flat $primary-flag $@rest]
}

fn add-opt {|&help=$false opt default|
    set opt = (-remove-dashes $opt)
    if $help {
        set opt-help[$opt] = $help
    }
    set opts[$opt] = $default
    set opts-order = [$@opts-order $opt]
}

fn help-message {
    if (not-eq $flags []) {
        echo "---- Flags ----"
        for flag $flags {
            var primary-flag @rest = $@flag
            var all-flags = (str:join '/--' $flag)
            if (has-key $flag-help $primary-flag) {
                echo "  --"$all-flags":\t"$flag-help[$primary-flag]
            } else {
                echo "  --"$all-flags
            }
        }
    }
    if (not-eq $opts [&]) {
        echo "---- Opts ----"
        for opt $opts-order {
            if (has-key $opt-help $opt) {
                echo "  --"$opt" ["$opts[$opt]"]:\t"$opt-help[$opt]
            } else {
                echo "  --"$opt" ["$opts[$opt]"]"
            }
        }
    }
    put $flags-flat

}

fn getopts {|@args|
    var args-no-opts = []
    #Remove opts from arguments
    var new-args = []
    if (> (count $args) 1) {
        var items = [(list:zip $args [(drop 1 $args) $false])]
        var i = 0
        while (< $i (count $items)) {
            var current next = (all $items[$i])
            if (and $next (-check-if-opt $current)) {
                set opts[(-remove-dashes $current)] = $next
                set i = (+ $i 2)
            } else {
                set args-no-opts = [$@args-no-opts $current]
                set i = (+ $i 1)
            }
        }
    } else {
        set args-no-opts = $args
    }

    #Initialize flags to false
    var found-flags = [&]
    for flag $flags-flat {
        set found-flags[$flag] = $false
    }
    #Find flags and remove them from the arguments
    set new-args = []
    for arg $args-no-opts {
        var add-arg = $true
        for flag $flags-flat {
            if (-check-if-parm $flag $arg) {
                set add-arg = $false
                set found-flags[$flag] = $true
                break
            }
        }
        if $add-arg {
            set new-args = [$@new-args $arg]
        }
    }
    #Condense duplicate flags
    var condensed-flags = [&]
    for flag-group $flags {
        var primary-flag = $flag-group[0]
        var value =  (or $found-flags[$@flag-group])
        set condensed-flags[$primary-flag] = $value
    }
    var output = [&opts=$opts &flags=$condensed-flags &args=$new-args]
    put $output
}
