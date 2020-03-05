# Zips togther several lists (like in python). If one is shorter than the
# other it is truncated to the shorter list
# ex) a = [1 2 3]
#     b = [a b]
#     zip $a $b
#     -> [1 a]
#     -> [2 b]
fn zip [@rest]{
    if (eq $rest []) {
        return
    }
    n = (count $rest[0])
    for list $rest[1:] {
        if (> $n (count $list)) {
            n = (count $list)
        }
    }
    for i [(range $n)] {
        put [$@rest[$i]]
    }
}

# Takes a list and returns an index with each item in the list
fn enumerate [list]{
    i = 0
    for item $list {
        put [$i $item]
        i = (+ $i 1)
    }
}

# Reshapes a 1D list into a 2D list with the given number of columns
fn reshape [&cols=2 list]{
    i = 0
    new_list = []
    row = []
    i = 1
    for x $list {
        row = [$@row $x]
        if (== (% $i $cols) 0) {
            new_list = [$@new_list $row]
            row = []
        }
        i = (+ $i 1)
    }
    put $new_list
}

# Helper function for taking a product of lists
fn -product [list @rest]{
    # Base case with single list
    if (eq $rest []) {
        put $list
        return
    }
    next = $rest[0]
    rest = $rest[1:]
    # Recursively take product
    for a $list {
        for b $next {
            put [$@a $b]
        }
    } | -product [(all)] $@rest
}

# Takes several lists and takes the product of them
# ex) a = [1 2 3]
#     b = [a b]
#     product $a $b
#     -> [[1 a] [1 b] [2 a] [2 b] [3 a] [3 b]]
fn product [list @rest]{
    new_list = [(for a $list { put [$a] })]
    -product $new_list $@rest
}
