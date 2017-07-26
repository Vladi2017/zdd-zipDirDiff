#! /usr/bin/perl -w
    eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell

use strict;
use warnings;
use File::Find ();

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

# my $filesl1 = []; #Vl.empty array referrence
my @filesl1;
sub wanted;



# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, shift);
print @filesl1;
exit;


sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    $File::Find::name =~ /^\.\/\.git\z/s &&
    ($File::Find::prune = 1)
    ||
    -B _ || push(@filesl1, $name); 
}

