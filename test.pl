#!/usr/bin/env perl

use strict;
use warnings;

our $thumb_dir      = 'thumb';
our $download_dir   = 'uploads_tiny';
my $image_dir 		= "uploads";
my $filename 		= "10-our_own_waterfall.jpg";
our $api_key        = 'uKgMjIpeqXWPbVqdJXPFVdro4LUeXEvk';

my $result = `tinypng -k $api_key $image_dir/$filename ` ;
my @values = split('\n', $result);

print $values[6];

#my $JSON = `curl -i --user api:$api_key --data-binary @"$image_dir/$filename" https://api.tinypng.com/shrink`;
#print "ok\n";
#my $URL  = `echo $JSON | grep -o 'http[s]*:[^"]*'`;
#print "two\n";
#exec( `curl $URL>"$image_dir/$filename" 2>/dev/null`);