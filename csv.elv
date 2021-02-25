use str
fn read-csv [&field=',' &use-headers=$true filename]{
    lines = [(cat $filename | ^
              each [line]{
                if (not-eq $line '') {
                    put [(str:split $field $line)]
                }
            })]
    data = [&]
    headers = [(range (count $lines[0]))]
    if $use-headers {
        headers = $lines[0]
        lines = $lines[1:]
    }
    for index [(range (count $headers))] {
        header = $headers[$index]
        data[$header] = [$@lines[$index]]
    }
    put $data
}
