#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::DZil;

my $tzil = Builder->from_config({ dist_root => 'corpus/vDZT' });

$tzil->build;

my $lib = $tzil->slurp_file('build/lib/vDZT.pm');

my $expected_lib = <<'END LIB';
package vDZT;
our $VERSION = 'v0.1.0'; # VERSION
1;
# ABSTRACT: my abstract
END LIB

is ( $lib, $expected_lib, 'check vDZT.pm' );

done_testing;
