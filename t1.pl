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

