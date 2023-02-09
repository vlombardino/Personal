### Convert image from one format to another
Required package
```
sudo apt install imagemagick
```
Convert one jpg image png
```
convert image.jpg image.png
```
Convert all jpg to png
```
mogrify -format png *.jpg
```
Avoid errors by hitting the limit on a command line.
```
find -name '*.jpg' -print0 | xargs -0 -r mogrify -format png
```
