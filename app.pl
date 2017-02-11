#!/usr/bin/env perl

use Dancer2;
use DBI;
use File::Spec;
use Template;

use strict;
use warnings;

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

};

start;
