# Ghostscript
Ghostscript is a great tool for compressing PDFs. In our tests it delivered the best compression ratio. Simply run:
```bash
$ gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf

$ gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf

$ gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf
```

> -dPDFSETTINGS can be any of: \
> /screen : low-resolution output, lowest output size \
> /ebook : medium-resolution output, medium output size \
> /printer OR /prepress : high-resolution with maximum output size

## Scripts
Convert all files with `screen` settings in a folder
> WARNING: This will overwrite the original file
```bash
find -type f -name "*.pdf" -exec bash -c 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dBATCH -dQUIET -sOutputFile="new.pdf" "{}"; rm "{}"; mv "new.pdf" "{}";' {} \;
```

Convert all files with `ebook` settings in a folder
> WARNING: This will overwrite the original file
```bash
find -type f -name "*.pdf" -exec bash -c 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -dQUIET -sOutputFile="new.pdf" "{}"; rm "{}"; mv "new.pdf" "{}";' {} \;
```

Convert all files with `printer` settings in a folder
> WARNING: This will overwrite the original file
```bash
find -type f -name "*.pdf" -exec bash -c 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH -dQUIET -sOutputFile="new.pdf" "{}"; rm "{}"; mv "new.pdf" "{}";' {} \;
```

Convert all files with `prepress` settings in a folder
> WARNING: This will overwrite the original file
```bash
find -type f -name "*.pdf" -exec bash -c 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dBATCH -dQUIET -sOutputFile="new.pdf" "{}"; rm "{}"; mv "new.pdf" "{}";' {} \;
```