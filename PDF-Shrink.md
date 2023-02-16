# Ghostscript
Ghostscript is a great tool for compressing PDFs. In our tests it delivered the best compression ratio. Simply run:
```bash
$ gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf

$ gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf

$ gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf
```

> -dPDFSETTINGS can be any of: \
> /screen : lowest output size (screen-view-only quality, 72 dpi images) \
> /ebook : medium output size (low quality, 150 dpi images) \
> /printer: high output size (high quality, 300 dpi images) \
> /prepress: maximum output size (high quality, color preserving, 300 dpi imgs) \
> /default: (almost identical to /screen)

## Batch Conversions
Batch conversion all files with `screen` setting:
> WARNING: This will overwrite the original file
```bash
find -type f -name "*.pdf" -exec bash -c 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dBATCH -dQUIET -sOutputFile="new.pdf" "{}"; rm "{}"; mv "new.pdf" "{}";' {} \;
```

Batch conversion all files with `ebook` setting:
> WARNING: This will overwrite the original file
```bash
find -type f -name "*.pdf" -exec bash -c 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -dQUIET -sOutputFile="new.pdf" "{}"; rm "{}"; mv "new.pdf" "{}";' {} \;
```

Batch conversion all files with `printer` setting:
> WARNING: This will overwrite the original file
```bash
find -type f -name "*.pdf" -exec bash -c 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH -dQUIET -sOutputFile="new.pdf" "{}"; rm "{}"; mv "new.pdf" "{}";' {} \;
```

Batch conversion all files with `prepress` setting:
> WARNING: This will overwrite the original file
```bash
find -type f -name "*.pdf" -exec bash -c 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dBATCH -dQUIET -sOutputFile="new.pdf" "{}"; rm "{}"; mv "new.pdf" "{}";' {} \;
```

Batch conversion renaming all files with `screen` setting:
> Makes a copy renaming the file with `new`
```bash
for file in *pdf; do gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile="new_${file}" -- "$file"; done
```

Batch conversion renaming all files with `ebook` setting:
> Makes a copy renaming the file with `new`
```bash
for file in *pdf; do gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="new_${file}" -- "$file"; done
```

Batch conversion renaming all files with `printer` setting:
> Makes a copy renaming the file with `new`
```bash
for file in *pdf; do gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile="new_${file}" -- "$file"; done
```

Batch conversion renaming all files with `prepress` setting:
> Makes a copy renaming the file with `new`
```bash
for file in *pdf; do gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile="new_${file}" -- "$file"; done
```