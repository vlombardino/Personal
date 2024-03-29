# ffmpeg
Convert m4a to mp4
```bash
for i in *.m4a; do ffmpeg -i "$i" -c:a copy "${i%.*}.mp4"; done
```

Convert ts to mp4
```bash
IFS=$(echo -en "\n\b"); for i in *.ts; do ffmpeg -i "$i" -ss 3 -vcodec copy -sn -acodec copy "$i.mp4"; done
```

Convert mts to mp4
```bash
IFS=$(echo -en "\n\b"); for i in *.MTS; do ffmpeg -i "$i" -c:v copy -c:a aac -strict experimental -b:a 128k "$i.mp4"; done
```

## Subtitles
```bash
ffmpeg -i input.mp4 -vf subtitles=sub.srt output.mp4
```
```bash
ffmpeg -i input.mp4 -filter:v subtitles=subtitles.srt output.mp4
```
```bash
mencoder -oac copy -ovc copy -sub sub.srt input.mp4 -o output.mp4
```

# Handbrake
## Compress large video file
Version 1 (mp4)
```
$ handbrake-cli -i /file/input.mp4 -o /file/out.mp4 -E fdk_faac -B 96k -6 stereo -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all
```
Version 2 (mkv)
```
$ handbrake-cli -i input.mkv -o output.mkv -E ffaac -B 128k --all-subtitles --all-audio --mixdown 5point1 -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all
```
Version 3 (mp4)
```
$ handbrake-cli -i ./Project-1.mp4 -o ./Project-1-yifi.mp4 -E ffaac -B 96k -6 stereo -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all
```

## Refrences
* https://gist.github.com/kuntau/a7cbe28df82380fd3467
* https://superuser.com/questions/882425/hardcoding-ffmpeg-subtitles-on-mp4-mkv