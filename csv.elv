use str
fn read-csv {|&field=',' &use-headers=$true &skip-lines=0 filename|
    var lines = [(cat $filename | ^
              each {|line|
                if (not-eq $line '') {
                    put [(str:split $field $line)]
                }
            })]
    set lines = $lines[$skip-lines..]
    var data = [&]
    var headers = [(range (count $lines[0]))]
    if $use-headers {
        set headers = $lines[0]
        set lines = $lines[1..]
    }
    for index [(range (count $headers))] {
        var header = $headers[$index]
        set data[(str:trim-space $header)] = [$@lines[$index]]
    }
    put $data
}

fn print-csv {|data|
    var headers = [(keys $data)]
    echo (str:join ',' $headers)
    for i [(range (count $data[$headers[0]]))] {
        var line = []
        for header $headers {
            set line = [$@line $data[$header][$i]]
        }
        echo (str:join ',' $line)
    }
}
