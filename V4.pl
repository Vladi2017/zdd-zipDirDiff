#!/usr/bin/env perl
###  !/usr/bin/perl
use strict;
use warnings;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
#read a Zip file
my $zipFile1 = Archive::Zip->new();
my $arg1 = shift(@ARGV);
unless ( $zipFile1->read($arg1) == AZ_OK ) { die 'read error Vladi';}
my @list1 = $zipFile1->memberNames();
print $_ . "\n" foreach(@list1);
$arg1 =~ /(^\W*\w+)/; #Vl.tthe directory name must not have non-word character
print "####Vladi, associated directoy is $1\n";
opendir(my $dh, $1) || die 'Vl.opendir error';
while(readdir $dh) {print "$1/$_\n";}
closedir $dh;
print "####Vladi, the same dir. recursive in a perl var as output of an external commandusing backticks eg: `ls`\n";
my $dir1 = `ls -R $1`;
print $dir1;

