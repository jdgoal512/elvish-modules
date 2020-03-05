use list

flags = []
flags_flat = []
flag_help = [&]
opts = [&]
opts_order = []
opt_help = [&]

fn -remove_dashes [@args]{
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

fn -check_if_parm [parm value]{
    if (has-prefix $value '-') {
        put (eq $parm (-remove_dashes $value))
    } else {
        put $false
    }
}

fn -check_if_opt [value]{
    put (has-key $opts (-remove_dashes $value))
}

fn -check_if_flag [value]{
    put (has-value $flags_flat (-remove_dashes $value))
}

fn clear []{
    flags = []
    flags_flat = []
    flag_help = [&]
    opts = [&]
    opts_order = []
    opt_help = [&]
}

fn add_flag [&help=$false primary_flag @rest]{
    primary_flag @rest = (-remove_dashes $primary_flag $@rest)
    if $help {
        flag_help[$primary_flag] = $help
    }
    flags = [$@flags [$primary_flag $@rest]]
    flags_flat = [$@flags_flat $primary_flag $@rest]
}

fn add_opt [&help=$false opt default]{
    opt = (-remove_dashes $opt)
    if $help {
        opt_help[$opt] = $help
    }
    opts[$opt] = $default
    opts_order = [$@opts_order $opt]
}

fn help_message []{
    if (not-eq $flags []) {
        echo "---- Flags ----"
        for flag $flags {
            primary_flag @rest = $@flag
            all_flags = (joins '/--' $flag)
            if (has-key $flag_help $primary_flag) {
                echo "  --"$all_flags":\t"$flag_help[$primary_flag]
            } else {
                echo "  --"$all_flags
            }
        }
    }
    if (not-eq $opts [&]) {
        echo "---- Opts ----"
        for opt $opts_order {
            if (has-key $opt_help $opt) {
                echo "  --"$opt" ["$opts[$opt]"]:\t"$opt_help[$opt]
            } else {
                echo "  --"$opt" ["$opts[$opt]"]"
            }
        }
    }
    put $flags_flat

}

fn getopts [@args]{
    args_no_opts = []
    #Remove opts from arguments
    new_args = []
    if (> (count $args) 1) {
        items = [(list:zip $args [(drop 1 $args) $false])]
        i = 0
        while (< $i (count $items)) {
            current next = (explode $items[$i])
            if (and $next (-check_if_opt $current)) {
                opts[(-remove_dashes $current)] = $next
                i = (+ $i 2)
            } else {
                args_no_opts = [$@args_no_opts $current]
                i = (+ $i 1)
            }
        }
    } else {
        args_no_opts = $args
    }

    #Initialize flags to false
    found_flags = [&]
    for flag $flags_flat {
        found_flags[$flag] = $false
    }
    #Find flags and remove them from the arguments
    new_args = []
    for arg $args_no_opts {
        add_arg = $true
        for flag $flags_flat {
            if (-check_if_parm $flag $arg) {
                add_arg = $false
                found_flags[$flag] = $true
                break
            }
        }
        if $add_arg {
            new_args = [$@new_args $arg]
        }
    }
    #Condense duplicate flags
    condensed_flags = [&]
    for flag_group $flags {
        primary_flag = $flag_group[0]
        value =  (or $found_flags[$@flag_group])
        condensed_flags[$primary_flag] = $value
    }
    output = [&opts=$opts &flags=$condensed_flags &args=$new_args]
    put $output
}
