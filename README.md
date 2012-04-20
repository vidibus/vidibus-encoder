# Vidibus::Encoder 

This is a framework for creating custom encoders.

This gem is part of [Vidibus](http://vidibus.org), an open source toolset for building distributed (video) applications.

**Beware:** Work in progress!


## Notes

Use FFMpeg's cropdetect to cut off black bars:
ffmpeg -ss 600 -t 100 -i [input video] -vf "select='isnan(prev_selected_t)+gte(t-prev_selected_t,1)',cropdetect=24:2:0" -an -y null.mp4


## Copyright

&copy; 2012 André Pankratz. See LICENSE for details.
