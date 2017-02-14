#!/usr/bin/env perl

use strict;
use warnings;

use Dancer2;
use DBI;
use Template;
use Data::Dumper;
#use Image::Magick::Thumbnail 0.06;

set 'session'      => 'Simple';
set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'log'          => 'debug';
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;
set 'layout'       => 'main';

our $image_path = 'uploads';
our $thumb_path = 'uploads/thumb';
our $root       =  config->{appdir}.'/public/';

hook before_template_render => sub {

    my $tokens = shift;

    $tokens->{css_url} = request->base . 'css/';
    $tokens->{js_url}  = request->base . 'js/';
    $tokens->{img_url} = request->base . 'img/';
};

get '/' => sub {

    my ($json, @array, $error);

    if ( opendir( DIR, $root.$image_path ) ) {
    
        while ( my $file = readdir(DIR) ) {
            next if ( $file =~ m/^\./ );
            next if ( $file =~ m/thumb/); 

            $json = {
                name            => $file,
                size            => 0, #$file->size,
                url             => $image_path.$file,
                thumbnailUrl    => path($thumb_path, $file),
                deleteUrl       => $file,
                deleteType      => "DELETE"
            };
            
            push( @array, $json );   
        };
        closedir(DIR);
    }
    else {
        my $error = "The directory $image_path is not on file";
    };

    return template 'index.tt' => {
        error => $error,
        file  => \@array,
    };

    my %response;
    $response{'files'} = \@array;
    return encode_json(\%response);
};

del '/:deletes' => sub {
   
    my $deletes = param('deletes');

    unlink path($root.$image_path, $deletes);
    unlink path($root.$thumb_path, $deletes);

    my %response;
    $response{'files'} = { $deletes => 1 };

    return encode_json(\%response);
};

any '/upload' => sub {

    my $uploads = request->uploads('files[]');
    my @array;
    my $json;

    mkdir path( $root,$image_path) if not -e path( $root,$image_path);
    mkdir path( $root,$thumb_path) if not -e path( $root,$thumb_path);

    for my $file ( @{ $uploads->{'files[]'} } ) {

        my $path = path($root.$image_path, $file->basename);
      
        if (-e $path) {
            $json = {
                name  => $file->basename,
                size  => $file->size,
                error => " File already exists in $image_path"
            };
        } 
        else {
            $json = {
                name            => $file->basename,
                size            => $file->size,
                url             => $file->filename,
                thumbnailUrl    => path($thumb_path, $file->basename),
                deleteUrl       => $file->filename,
                deleteType      => "DELETE"
            };
            $file->copy_to($path);

            # create thumbnail where the biggest side is 80px
            #my $src = Image::Magick->new;
            #   $src->Read($path);
            #my ($thumb, $x, $y) = Image::Magick::Thumbnail::create($src, 80);
            #$path( $Thumbnail_path, $thumb );
            #$thumb->Write($path);
        };
        push( @array, $json );
    }
    
    my %response;
    $response{'files'} = \@array;

    return encode_json(\%response);
};

start;
