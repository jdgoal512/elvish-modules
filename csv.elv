fn read_csv [&field=',' &use_headers=$true filename]{
    lines = [(cat $filename | each [line]{ put [(splits $field $line)] })]
    data = [&]
    headers = [(range (count $lines[0]))]
    if $use_headers {
        headers = $lines[0]
        lines = $lines[1:]
    }
    for index [(range (count $headers))] {
        header = $headers[$index]
        data[$header] = [$@lines[$index]]
    }
    put $data
}
