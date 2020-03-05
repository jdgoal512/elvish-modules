libs = []
preamble = []
document = []
doc_class = '\documentclass[11pt]{article}'
doc_title = $false

# Adds each item to the docuemnt
fn -add [@lines]{
    document = [$@document $@lines]
}

# Creates an environment around the given contents
fn -env [&args=[] tag @contents]{
    if (eq $args []) {
        put '\begin{'$tag'}'
    } else {
        put '\begin{'$tag'}{'(joins ', ' $args)'}'
    }
    for line $contents {
        put $line
    }
    put '\end{'$tag'}'
}

# Creates a command
fn -cmd [&opts=[] &args=[] command]{
    cmd = '\'$command
    if (not (eq $opts [])) {
        cmd = $cmd'['(joins ', ' $opts)']'
    }
    cmd = $cmd'{'
    if (not (eq $args [])) {
        cmd = $cmd(joins ', ' $args)
    }
    put $cmd'}'
}

# Adds a line to the document with a newline
fn add [@lines]{
    for line $lines {
        -add $line' \\'
    }
}

# Sets the document class type
fn documentclass [&opts=[] class]{
    doc_class = (-cmd &opts=$args &args=[$class] documentclass)
}

# Imports a package
fn usepackage [&opts=[] package]{
    libs = [$@libs (-cmd &opts=$opts &args=[$package] usepackage)]
}

# Adds a section
fn section [section]{
    -add '\section*{'$section'}'
}

# Adds a subsection
fn subsection [section]{
    -add '\subsection*{'$section'}'
}

# Adds a subsubsection
fn subsubsection [section]{
    -add '\subsubsection*{'$section'}'
}

# Sets the document title
fn title [title]{
    doc_title = $title
}

# Adds a page break
fn newpage []{
    -add '\newpage'
}

# Numbers the given items
fn enumerate [@items]{
    for item $items {
        put '  \item '$item
    } | -env enumerate (all) | -add (all)
}

# Creates a centered table with the given contents (provided as a 2D array)
fn table [&width=$false table_contents]{
    if (not $width) {
        # Get table width
        width = 1
        for row $table_contents {
            if (> (count $row) $width) {
                width = (count $row)
            }
        }
    }
    for row $table_contents {
        put '  '(joins ' & ' $row)' \\'
    } | -env &args=[' '(joins ' ' [(repeat $width c)])' '] tabular (all) | -env center (all) | -add (all)
}

# Builds and prints the document
fn build []{
    echo $doc_class
    for lib $libs {
        echo $lib
    }
    for line $preamble {
        echo $line
    }
    if $doc_title {
        document = ['\title{\textbf{'$doc_title'}}'
                    '\date{}'
                    '\maketitle'
                    $@document]
    }
    for line [(-env document $@document)] {
        echo $line
    }
}

# Writes the document to a file
fn write [filename]{
    build > $filename
}

# Clears the document
fn clear []{
    libs = []
    preamble = []
    document = []
    doc_class = '\documentclass[11pt]{article}'
    doc_title = $false
}
