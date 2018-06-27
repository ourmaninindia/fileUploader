#!/usr/bin/env perl

use strict;
use warnings;

use Dancer2;
use Data::Dumper;
use Imager::File::JPEG;
use Util::Underscore;

set 'session'      => 'Simple';
set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'log'          => 'debug';
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;
set 'layout'       => 'main';

our $api_key        = 'uKgMjIpeqXWPbVqdJXPFVdro4LUeXEvk';
our $root           = config->{appdir}.'/public';
our $image_dir      = 'uploads';
our $thumb_dir      = 'thumb';
our $website        = 'http://upload.travellers-palm.com';
our $compression    = 1;

hook before_template_render => sub 
{
    my $tokens = shift;

    $tokens->{css} = 'css';
    $tokens->{js}  = 'js';
};

get '/' => sub {

    template 'index.tt';
};

del '/:deletes' => sub 
{   
    my $deletes = param('deletes');

    unlink path("root/$image_dir", $deletes);
    unlink path("$root/$image_dir/$thumb_dir", $deletes);

    my %response;
    $response{'files'} = { $deletes => 1 };

    return encode_json(\%response);
};

get '/upload' => sub 
{
    my ($json, @array, $error);

    if ( opendir( DIR, "$root/$image_dir" ) ) 
    {
        while ( my $filename = readdir(DIR) ) 
        {
            next if ( $filename =~ m/^\./ );
            next if ( $filename =~ m/thumb/); 

            $json = 
            {
                name            => $filename,
                size            => (-s $filename),
                url             => path("../$image_dir", $filename),
                thumbnailUrl    => path("../$image_dir/$thumb_dir", $filename),
                deleteUrl       => $filename,
                deleteType      => "DELETE"
            };
            
            push( @array, $json );   
        };
        closedir(DIR);
    }
    else 
    {
        return template 'index.tt' => { $error => "The directory $image_dir is not on file" };
    };

    my %response;
    $response{'files'} = \@array;
    return encode_json(\%response);
};

post '/upload' => sub 
{
    my $uploads = request->uploads('files[]');
    my @array;
    my $json;
    my @uploads;
    
    mkdir path( $image_dir) if not -e path(  $image_dir );
    mkdir path("$image_dir/$thumb_dir") if not -e path( "$image_dir/$thumb_dir");

    unless (_::is_array_ref $uploads->{'files[]'})
    {
        push(@uploads,$uploads->{'files[]'});
        $uploads->{'files[]'} = \@uploads;
    } 

    for my $data ( @{ $uploads->{'files[]'} } ) {

        my $filename = $data->{filename};
       
        if (-e "$image_dir/$filename") 
        {
            $json = 
            {
                name  => $filename,
                size  => $data->{size},
                error => "$filename already exists in $image_dir"
            };
        } 
        else 
        {
            $json = 
            {
                name            => $filename,
                size            => $data->{size},
                url             => "../$image_dir/$filename",
                thumbnailUrl    => path("../$image_dir/$thumb_dir", $filename),
                deleteUrl       => $filename,
                deleteType      => "DELETE"
            };

debug to_dumper("$website/$image_dir/$filename");

            $data->copy_to("$root/$image_dir/$filename");

            if ($compression)
                {
                my $compressed = `curl https://api.tinify.com/shrink \
                                         --user api:$api_key \
                                         --header "Content-Type: application/json" \
                                         --data '{"source": {"url": "$website/$image_dir/$filename"} }' \
                                         --dump-header /dev/stdout`;

                debug to_dumper($compressed);
        
                if ( $compressed =~ m/error/ )
                {
                    $json = 
                    {
                        name  => $filename,
                        size  => $data->{size},
                        error => "Issue compressing: $compressed"
                    };
                }
            }
            # generate the thumbbnail
            my $img = Imager->new;
               $img->read(file => "$root/$image_dir/$filename") 
                        or die "Cannot read $filename from file: ", $img->{errstr};
            my $thumbnail = $img->scale(xpixels=>80,ypixels=>80);
               $thumbnail->write(file => "$root/$image_dir/$thumb_dir/$filename") 
                        or die "Cannot save thumbnail $filename: ",$img->{errstr};
            
        };
        push( @array, $json );
    }
    
    my %response;
    $response{'files'} = \@array;

    return encode_json(\%response);
};

start;