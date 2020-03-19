fn from-hex [@args]{
    for value $args {
        put (perl -e "print(hex('"$value"'));")
    }
}

fn to-hex [@args]{ put (base 16 $@args) }
