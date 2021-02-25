use math
use str

fn lpad [&pad=' ' chars @rest]{
    for line $rest {
        pad-length = (- $chars (count $line))
        put (str:join "" [(repeat (math:floor (/ $pad-length (count $pad))) $pad)])$line
    }
}

fn rpad [&pad=' ' chars @rest]{
    for line $rest {
        pad-length = (- $chars (count $line))
        put $line(str:join "" [(repeat (math:floor (/ $pad-length (count $pad))) $pad)])
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
        # put (echo $line | tr '_' ' ' | tr '-' ' '  | awk '{print toupper(substr($0,0,1))tolower(substr($0,2))}')
        echo $line | tr '_' ' ' | tr '-' ' '  | str:title (all)
    }
}

#  Imported functions from str module

fn to-upper [@args]{ str:to-upper $@args }
fn to-lower [@args]{ str:to-lower $@args }
#  Capitalize the first letter of each word
fn title [@args]{ str:title $@args }
#  Capitalize all letters
fn to-title [@args]{ str:to-title $@args }
fn contains [@args]{ str:contains $@args }
fn contains-any [@args]{ str:contains-any $@args }
fn index [@args]{ str:index $@args }
fn last-index [@args]{ str:last-index $@args }
fn index-any [@args]{ str:index-any $@args }
fn count [@args]{ str:count $@args }
fn compare [@args]{ str:compare $@args }
#  Case insensive version of eq
fn equal-fold [@args]{ str:equal-fold $@args }
fn has-prefix [@args]{ str:has-prefix $@args }
fn has-suffix [@args]{ str:has-suffix $@args }
# fn trim [@args]{ str:trim $@args }
fn trim-prefix [@args]{ str:trim-prefix $@args }
fn trim-space [@args]{ str:trim-space $@args }
fn trim-left [@args]{ str:trim-left $@args }
fn trim-right [@args]{ str:trim-right $@args }
fn trim-suffix [@args]{ str:trim-suffix $@args }
