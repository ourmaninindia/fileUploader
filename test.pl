#!/usr/bin/env perl

use strict;
use warnings;

our $thumb_dir      = 'thumb';
our $download_dir   = 'uploads_tiny';
my $image_dir 		= "uploads";
my $filename 		= "10-our_own_waterfall.jpg";
our $api_key        = 'uKgMjIpeqXWPbVqdJXPFVdro4LUeXEvk';

my $result 	= `tinypng -k $api_key $image_dir/$filename ` ;
my $ok = ($result =~ /Found 1 image/)?1:0;
if ($ok)
{
	my @values 	= split('\n', $result);
	my @text 	= split('\)' , $values[6]);
	my $msg     = $text[0];
	print "$msg)";
}
else
{
	print 'Unable to compress';
}