use list

flags = []
flags-flat = []
flag-help = [&]
opts = [&]
opts-order = []
opt-help = [&]

fn -remove-dashes [@args]{
    for arg $args {
        if (has-prefix $arg '--') {
            put $arg[2:]
        } elif (has-prefix $arg '-') {
            put $arg[1:]
        } else {
            put $arg
        }
    }
}

fn -check-if-parm [parm value]{
    if (has-prefix $value '-') {
        put (eq $parm (-remove-dashes $value))
    } else {
        put $false
    }
}

fn -check-if-opt [value]{
    put (has-key $opts (-remove-dashes $value))
}

fn -check-if-flag [value]{
    put (has-value $flags-flat (-remove-dashes $value))
}

fn clear []{
    flags = []
    flags-flat = []
    flag-help = [&]
    opts = [&]
    opts-order = []
    opt-help = [&]
}

fn add-flag [&help=$false primary-flag @rest]{
    primary-flag @rest = (-remove-dashes $primary-flag $@rest)
    if $help {
        flag-help[$primary-flag] = $help
    }
    flags = [$@flags [$primary-flag $@rest]]
    flags-flat = [$@flags-flat $primary-flag $@rest]
}

fn add-opt [&help=$false opt default]{
    opt = (-remove-dashes $opt)
    if $help {
        opt-help[$opt] = $help
    }
    opts[$opt] = $default
    opts-order = [$@opts-order $opt]
}

fn help-message []{
    if (not-eq $flags []) {
        echo "---- Flags ----"
        for flag $flags {
            primary-flag @rest = $@flag
            all-flags = (joins '/--' $flag)
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

fn getopts [@args]{
    args-no-opts = []
    #Remove opts from arguments
    new-args = []
    if (> (count $args) 1) {
        items = [(list:zip $args [(drop 1 $args) $false])]
        i = 0
        while (< $i (count $items)) {
            current next = (explode $items[$i])
            if (and $next (-check-if-opt $current)) {
                opts[(-remove-dashes $current)] = $next
                i = (+ $i 2)
            } else {
                args-no-opts = [$@args-no-opts $current]
                i = (+ $i 1)
            }
        }
    } else {
        args-no-opts = $args
    }

    #Initialize flags to false
    found-flags = [&]
    for flag $flags-flat {
        found-flags[$flag] = $false
    }
    #Find flags and remove them from the arguments
    new-args = []
    for arg $args-no-opts {
        add-arg = $true
        for flag $flags-flat {
            if (-check-if-parm $flag $arg) {
                add-arg = $false
                found-flags[$flag] = $true
                break
            }
        }
        if $add-arg {
            new-args = [$@new-args $arg]
        }
    }
    #Condense duplicate flags
    condensed-flags = [&]
    for flag-group $flags {
        primary-flag = $flag-group[0]
        value =  (or $found-flags[$@flag-group])
        condensed-flags[$primary-flag] = $value
    }
    output = [&opts=$opts &flags=$condensed-flags &args=$new-args]
    put $output
}
