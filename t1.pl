#!/usr/bin/perl
use strict;
use warnings;
use v5.14;

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

=test5 DESCRIPTION
use v5.14;  #21:18 2/26/2023
my $zipfile;
my $testpath = $ARGV[$#ARGV];
print "1. $testpath\n";
($testpath) = ($testpath =~ /(\w.*)$/); #{dst0000.: Trying to understand why I wrote my:.\zdd.pl#37 , 01:17 2/28/2023;; see note1.;;}
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
vladi@VladiLaptop1W10 ~/projects/perl/cmp1$ ./t1.pl "arg1 arg2"
# note1.: Now is not at line 37 anymore. As it dst0000 experession, the matching result $1 is assigned (again) to $testpath., 12:52 9/16/2023;;
=cut

=test4 DESCRIPTION
vladi@VladiLaptop1W10 ~/projects/perl/cmp1$ ./t1.pl "arg1 arg2"
=cut

=test6
#22:35 Saturday, September 9, 2023
my @zip_only = ('tmp1/TradingView Chart \x{2014} TradingView.mhtml', 'tmp1/V2tmp1, \x{021A}¦r\x{0103}.pl', 'tmp1/fi\x{0219}ier \x{0103}¦\x{021B}¦., f1_all2.txt', 'tmp1/fost f1_\x{0219}\x{0103},sa¦a\x{0219}s\x{021B} B¦rc\x{0103}', 'tmp1/logs/Corpul numerelor complexe. \x{0218}iruri \x{0219}i serii de numere complexe-Curs + Seminar 1.pdf', 'tmp1/logs/a fost tmp1 \x{0219}i acum ¦\x{021B}\x{0219}\x{0103}¦ diacrit,, \x{0219}i virgul\x{0103}', 'tmp1/logs/fost V2.exe dd¦a\x{0219}¦d.exe');
foreach (@zip_only) { say $_ }
say;
# foreach (@zip_only) { $_ = eval qq/"$_"/ }  #see ref1.
my $tmp;
foreach (@zip_only) {
  $tmp = eval qq/"$_"/;
  $_ = sprintf("%s", $tmp)
}
foreach (@zip_only) { say $_ }
# ref1.: there we only interpolate $_ between double quotes.. We'll still have hex chars (like \x{0103}). See https://perldoc.perl.org/5.32.1/perlop#%5B1%5D, 02:55 9/10/2023.
=cut

# test7 DESCRIPTION: error handling, exceptions handling, tag.dst0001, 21:27 Saturday, September 16, 2023:
local $SIG{__WARN__} = \&hwarn;
my $var = shift;
# eval { scalar $var == 0 };  # compile warning displayed also at run-time: "Useless use of numeric eq (==) in void context at ./t1.pl line 104."
eval { say "argument is: ", $var == 0 ? "zero" : "other number" };
if (my $err = $@) { say "Warning turned into exception is: " . $err }
else { say "No exception." }
sub hwarn { # warnings handler
  die "hwarn sub said: ".$_[0] if $_[0] =~ "numeric"  # raises an exception., https://perldoc.perl.org/5.32.1/functions/die
}