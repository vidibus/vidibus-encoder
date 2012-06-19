# Vidibus::Encoder

This is a framework for creating custom encoders.

This gem is part of [Vidibus](http://vidibus.org), an open source toolset for building distributed (video) applications.

**Beware:** Work in progress!


## Notes

Use FFMpeg's cropdetect to cut off black bars:
```
ffmpeg -ss 600 -t 100 -i [input video] -vf "select='isnan(prev_selected_t)+gte(t-prev_selected_t,1)',cropdetect=24:2:0" -an -y null.mp4
```

Create an audio encoder that may be used as filter for other encoders to
process the audio stream:
```
# Normalize audio:
ffmpeg -i input.mp4 -f wav input.wav
sox -v `sox input.wav -n stat -v 2>&1` input.wav normalized.wav
ffmpeg -i input.mp4 -i normalized.wav -map 0:0 -map 1:0 normalized.mp4
```

## Copyright

&copy; 2012 André Pankratz. See LICENSE for details.
