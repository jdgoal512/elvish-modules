# Executes a function over and over until the given number
# of seconds have passed
fn for [seconds function]{
    end-time = (+ (date +%s) $seconds)
    while (< (date +%s) $end-time) {
        $function
    }
}
