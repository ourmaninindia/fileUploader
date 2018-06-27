# fileUploader
A Perl version of the jQuery File Upload from https://blueimp.github.io/jQuery-File-Upload/ which is based on PHP

# Installation

The program uses Dancer2 and template toolkit. Of course the script can be modified to do wiithout these two or exchange it for say Mojolicious.

Apart from the few cpan modules you need to install libjpeg library
On Yum based Linux systems this means 
```
yum install libjpeg-devel
```
on Ubuntu it is slightly different
```
apt install libjpeg-dev
```

# Compression 
This can be set using the API from TinyPNG.com  You can obtain an API key from tinypng.com without even having to register.
