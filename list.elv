# Zips togther several lists (like in python). If one is shorter than the
# other it is truncated to the shorter list
# ex) a = [1 2 3]
#     b = [a b]
#     zip $a $b
#     -> [1 a]
#     -> [2 b]
fn zip {|@rest|
    if (eq $rest []) {
        return
    }
    var n = (count $rest[0])
    for list $rest[1..] {
        if (> $n (count $list)) {
            set n = (count $list)
        }
    }
    for i [(range $n)] {
        put [$@rest[$i]]
    }
}

# Takes a list and returns an index with each item in the list
fn enumerate {|list|
    var i = 0
    for item $list {
        put [$i $item]
        set i = (+ $i 1)
    }
}

# Reshapes a 1D list into a 2D list with the given number of columns
fn reshape {|&cols=2 list|
    var i = 0
    var new_list = []
    var row = []
    var i = 1
    for x $list {
        set row = [$@row $x]
        if (== (% $i $cols) 0) {
            set new_list = [$@new_list $row]
            set row = []
        }
        set i = (+ $i 1)
    }
    put $new_list
}

# Helper function for taking a product of lists
fn -product {|list @rest|
    # Base case with single list
    if (eq $rest []) {
        put $list
        return
    }
    var next = $rest[0]
    set rest = $rest[1..]
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
fn product {|list @rest|
    var new_list = [(for a $list { put [$a] })]
    -product $new_list $@rest
}


fn avg {|data|
    / (+ $@data) (count $data)
}

fn max {|data|
    var first @rest = $@data
    var max = $first
    for value $rest {
        if (< $max $value) {
            set max = $value
        }
    }
    put $max
}

fn min {|data|
    var first @rest = $@data
    var min = $first
    for value $rest {
        if (> $min $value) {
            set min = $value
        }
    }
    put $min
}

