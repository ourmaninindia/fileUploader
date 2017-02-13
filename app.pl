#!/usr/bin/env perl

use strict;
use warnings;

use Dancer2;
use DBI;
use Template;
use Data::Dumper;

set 'session'      => 'Simple';
set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'log'          => 'debug';
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;
set 'layout'       => 'main';

hook before_template_render => sub {

    my $tokens = shift;

    $tokens->{css_url} = request->base . 'css/';
    $tokens->{js_url}  = request->base . 'js/';
    $tokens->{img_url} = request->base . 'img/';
};

get '/' => sub {
    template 'index.tt';
};

any '/upload' => sub {

    my $uploads         = request->uploads('files[]');
    my $directory       = 'public/uploads';
    my $path            = path( config->{appdir}, $directory );
    my $thumbnail_path  = path( $path, 'thumb');
    my @array;
    my $json;

    mkdir $path if not -e $path;
    mkdir $thumbnail_path if not -e $thumbnail_path;

    for my $file ( @{ $uploads->{'files[]'} } ) {

        my $path = path($path,$file->basename);
      
        if (-e $path) {
            $json = {
                name  => $file->basename,
                size  => $file->size,
                error => " File already exists in $directory"
            };
        } 
        else {
            $json = {
                name            => $file->basename,
                size            => $file->size,
                url             => $file->filename,
                thumbnailUrl    => '',#$file->thumbnail_url,
                deleteUrl       => $file->filename,
                deleteType      => "DELETE"
            };
            $file->copy_to($path);
        };
        push( @array, $json );
    }
    
    # make your json response here
    my %json_array;
    $json_array{'files'} = \@array;

       debug to_dumper(\%json_array);
    return encode_json(\%json_array);
};

start;
