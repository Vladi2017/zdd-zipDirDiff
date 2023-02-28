#!/usr/bin/perl
use strict;
use warnings;

=test1
# while ("\n" ne <STDIN>) { # is not valid for $_ assigment
while (<>) {
@_ = /\//g;
print "number of matches of \/ is: " . scalar @_ . "\n";
}
# Vl.be aware that $_ gets assigment from STDIN only in while like constructs..
=cut

=test2
# perldoc -q array list
# Found in /usr/lib/perl5/5.22/pods/perlfaq4.pod; How can I remove duplicate elements from a list or array?
my @array = qw/unu doi trei unu cinci patru trei sapte trei noua sapte opt trei doi/; 
my @unique = ();
my %seen   = ();
foreach my $elem ( @array ) {
  next if $seen{ $elem }++;
  push @unique, $elem;
}
print "array : @array\n";
print %seen;
print "\n%seen: " . %seen . "\n";
my @keys1 = keys %seen;
print "keys %seen: @keys1\n";
my @values1 = values %seen;
print "vales %seen: @values1\n";
print "unique array/list : @unique\n";
=cut

=test3
use List::Util qw(first);
my @array = qw( Apples Oranges Brains Toes Kiwi);
my $search = "Toes";
my $index = first { $array[$_] eq $search } 0 .. $#array; ##this is OK. returns the searched index
## my $index = first { $array[$_] eq $search } @array; Vl.this is not ok.. Argument "Apples" isn't numeric in array element at ./t1.pl line 38.
print "List::Util::first method, index of $search = $index\n";
$index = $search ~~ @array;
print "Smart matching approach, index of $search = $index\n"; ##Vl.Smartmatch just return a boolean value, we can't use for (1st) index.
$search = "nuEste";
$index = $search ~~ @array;
print "Smart matching approach, index of $search = $index\n";
=cut

=ignore1 tr - Transliterates all occurrences of the characters found in the search list with the corresponding character in the replacement list.
sub byalphabetic {
  $a =~ tr/\//~/;
  $b =~ tr/\//~/;
  return $a cmp $b;
}
my @list1 = qw(compare1/dir1/dir11/f2 compare1/dir2/f1 compare1/dir2/df compare1/dir2/dir21/fuser compare1/V4.pl
  compare1/try1.pl compare1/dir1/dir11/f1 compare1/dirzipCompare.pl compare1/t1.pl);
print "@list1\n";
my @list2 = sort byalphabetic @list1;
print "@list2\n";
=cut

use v5.14;  #21:18 2/26/2023
my $zipfile;
my $testpath = $ARGV[$#ARGV];
print "1. $testpath\n";
($testpath) = ($testpath =~ /(\w.*)$/); #{dst0000.: Trying to understand why I wrote my:.\zdd.pl#37 , 01:17 2/28/2023}
print "2. $testpath\n";
for ($testpath) {
  no warnings 'experimental';
  $testpath = $_ when /\/$/;
  default {$testpath = $_ . "/";}
}
print "3. $testpath\n";
$testpath =~ /^([\s\w]+)/;  #{to support (.zip) file names with blanks, 01:34 2/28/2023}
$zipfile = $1 . ".zip" unless $zipfile;
print "$zipfile\n";
=test4 DESCRIPTION
vladi@VladiLaptop1W10 ~/projects/perl/cmp1$ ./t1.pl "arg1 arg2"
=cut