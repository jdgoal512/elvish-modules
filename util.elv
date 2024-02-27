use str
fn unbuffer {
    var line = (read-upto "\n")
    while (not-eq $line "") {
        str:trim-right $line "\n"
        set line = (read-upto "\n")
    }
}

fn compress-pdf {|pdf-file|
    var temp = (tempfile)
    var gs-args = ['-dSAFER'
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
    gs $@gs-args '-sOutputFile='$temp $pdf-file
    mv $temp $pdf-file
}
