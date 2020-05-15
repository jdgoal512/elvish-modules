use string

libs = []
preamble = []
document = []
doc-class = '\documentclass[11pt]{article}'

fn -escape [@lines]{
    for line $lines {
        replaces '%' '\%' $line |\
            replaces '&' '\&' (all) |\
            replaces '$' '\$' (all) |\
            replaces '#' '\#' (all)
        # replaces '_' '\_' (all) |\
        # replaces '{' '\{' (all) |\
        # replaces '|' '\}' (all)
    }
}

# Adds each item to the docuemnt
fn -add [@lines]{
    new-document = [$@document $@lines]
    document = $new-document
}

fn -add-preamble [@lines]{
    new-preamble = [$@preamble $@lines]
    preamble = $new-preamble
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
        -add (-escape $line)' \\'
    }
}

# Sets the document class type
fn documentclass [&opts=[] class]{
    doc-class = (-cmd &opts=$args &args=[$class] documentclass)
}

# Imports a package
fn usepackage [&opts=[] package]{
    libs = [$@libs (-cmd &opts=$opts &args=[$package] usepackage)]
}

# Adds a section
fn section [section]{
    -add '\section*{'(-escape $section)'}'
}

# Adds a subsection
fn subsection [section]{
    -add '\subsection*{'(-escape $section)'}'
}

# Adds a subsubsection
fn subsubsection [section]{
    -add '\subsubsection*{'(-escape $section)'}'
}

# Sets the document title
fn title [title]{
    document = ['\title{\textbf{'$title'}}'
                '\date{}'
                '\maketitle'
                $@document]
}

# Adds a page break
fn newpage []{
    -add '\newpage'
}

# Numbers the given items
fn enumerate [@items]{
    for item $items {
        if (has-prefix $item '\subitem') {
            put $item
        } else {
            put '  \item '(-escape $item)
        }
    } | -env enumerate (all) | -add (all)
}

# Creates a centered table with the given contents (provided as a 2D array)
fn table [&width=$false &align='center' &borders=$false table-contents]{
    if (eq $align left) {
        align = 'flushleft'
    } elif (eq $align right) {
        align = 'flushright'
    }
    if (not $width) {
        # Get table width
        width = 1
        for row $table-contents {
            if (> (count $row) $width) {
                width = (count $row)
            }
        }
    }
    col-sep = ' '
    if $borders {
        col-sep = '|'
    }
    for row $table-contents {
        if (eq $row ['\hline']) {
            put '\hline'
        } else {
            put '  '(joins ' & ' $row)' \\'
        }
    } | -env &args=[' '(joins $col-sep [(repeat $width c)])' '] tabular (all) | -env $align (all) | -add (all)
}

# Adds in boilerplate for importing SVG files
fn enable-svg []{
    preamble = [$@preamble
                '\newcommand{\executeiffilenewer}[3]{%'
                '\ifnum\pdfstrcmp{\pdffilemoddate{#1}}%'
                '{\pdffilemoddate{#2}}>0%'
                '{\immediate\write18{#3}}\fi%'
                '}'
                '\newcommand{\includesvg}[1]{%'
                '\executeiffilenewer{#1.svg}{#1.pdf}%'
                '{inkscape -z -D --file=#1.svg %'
                '--export-pdf=#1.pdf --export-latex}%'
                '\input{#1.pdf_tex}%'
                '}']
}

fn includesvg [&width='' name]{
    put '\def\svgwidth{'$width'\textwidth}\includesvg{'$name'}'
}

fn include-pdf [&width='' &page='1' pdf-file]{
    put '\includegraphics[width='$width'\textwidth,page='$page']{'$pdf-file'}'
}

fn verbatim [line]{
    put '\begin{verbatim}'$line'\end{verbatim}'
}

fn includegraphics [&width=$false &height=$false image]{
    opts = []
    if $width {
        opts = ['width='$width'\textwidth']
    }
    if $height {
        opts= [$@opts 'height='$height]
    }
    -cmd &opts=$opts &args=[$image] includegraphics
}


# Builds and prints the document
fn build []{
    echo $doc-class
    for lib $libs {
        echo $lib
    }
    for line $preamble {
        echo $line
    }
    for line [(-env document $@document)] {
        echo $line
    }
}

# Writes the document to a file
fn write [filename]{
    build > $filename
}

# Writes the document to a file
fn write-pdf [&compress=$false filename]{
    # Check if pdflatex is installed
    if (not (has-external pdflatex)) {
        fail 'Could not find pdflatex'
    }
    # Check if ghostscript is installed
    if (and $compress (not (has-external gs))) {
        fail 'Could not find gs'
    }
    filename = (string:rstrip '.pdf' $filename)
    # Make temp dir for intermediate files
    temp = (mktemp -d latex-XXXXX)
    try {
        build > $temp'/'$filename'.tex'
        pdflatex -output-directory $temp $temp'/'$filename'.tex'
        if $compress {
            gs-args = ['-dSAFER'
                       '-dBATCH'
                       '-dPrinted=false'
                       '-dNOPAUSE'
                       '-dNOCACHE'
                       '-sDEVICE=pdfwrite'
                       '-sColorConversionStrategy=/LeaveColorUnchanged'
                       '-dAutoFilterColorImages=true'
                       '-dAutoFilterGrayImages=true'
                       '-dDownsampleMonoImages=true'
                       '-dDownsampleGrayIma ges=true'
                       '-dDownsampleColorImages=true'
                       '-dPDFSETTINGS=/printer']
            gs $@gs-args '-sOutputFile='$filename'.pdf' $temp/$filename'.pdf'
        } else {
            mv $temp/$filename'.pdf' .
        }
    } finally {
        # Clean up intermediate files
        rm -rf $temp
    }
}

# Clears the document
fn clear []{
    libs = []
    preamble = []
    document = []
    doc-class = '\documentclass[11pt]{article}'
}
