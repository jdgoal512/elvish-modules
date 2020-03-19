use math
fn lpad [&pad=' ' chars @rest]{
    for line $rest {
        pad-length = (- $chars (count $line))
        put (joins "" [(repeat (math:floor (/ $pad-length (count $pad))) $pad)])$line
    }
}

fn rpad [&pad=' ' chars @rest]{
    for line $rest {
        pad-length = (- $chars (count $line))
        put $line(joins "" [(repeat (math:floor (/ $pad-length (count $pad))) $pad)])
    }
}

fn lstrip [prefix @rest]{
    for line $rest {
        while (has-prefix $line $prefix) {
            line = $line[(count $prefix):]
        }
        put $line
    }
}

fn rstrip [suffix @rest]{
    for line $rest {
        while (has-suffix $line $suffix) {
            line = $line[:-(count $suffix)]
        }
        put $line
    }
}

fn strip [text @rest]{
    lstrip $text (rstrip $text $@rest)
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
