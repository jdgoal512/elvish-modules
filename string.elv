fn lpad [&sep=" " chars @rest]{
    for line $rest {
        pad_length = (- $chars (count $line))
        put (joins "" [(repeat $pad_length $sep)])$line
    }
}

fn rpad [&sep=" " chars @rest]{
    for line $rest {
        pad_length = (- $chars (count $line))
        put $line(joins "" [(repeat $pad_length $sep)])
    }
}

fn reverse [@strings]{
    for line $strings {
        output = ""
        for c $line {
            output = $c""$output
        }
        put $output
    }
}

fn trim [@strings]{
    for line $strings {
        put (echo $line | sed 's/^[[:blank:]]\+//g;s/[[:blank:]]\+$//g')
    }
}

fn pretty [@strings]{
    for line $strings {
        put (echo $line | tr '_' ' ' | tr '-' ' '  | awk '{print toupper(substr($0,0,1))tolower(substr($0,2))}')
    }
}
