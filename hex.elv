fn fromhex [@args]{
    for value $args {
        put (perl -e "print(hex('"$value"'));")
    }
}

fn tohex [@args]{ put (base 16 $@args) }
