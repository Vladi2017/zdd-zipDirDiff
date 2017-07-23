#!/usr/bin/env perl
###  !/usr/bin/perl
use strict;
use warnings;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
#read a Zip file
my $zipFile1 = Archive::Zip->new();
unless ( $zipFile1->read( shift(@ARGV) ) == AZ_OK ) { die 'read error Vladi';}
my @list1 = $zipFile1->memberNames();
print $_ . "\n" foreach(@list1);

