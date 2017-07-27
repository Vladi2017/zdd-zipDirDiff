#! /usr/bin/perl -w
    eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell

use strict;
use warnings;
use File::Find ();
use Archive::Zip;

my $Usage = "$0 file.zip [test_path]\n  (default test_path is '.')\n";
die $Usage unless ( @ARGV and -f $ARGV[0] );

my $zipfile = shift;
my $testpath = shift || '.';

my $zip = Archive::Zip->new( $zipfile )
    or die "Archive::Zip was unable to read $zipfile\n";

my ( @missing_from_path, @altered );
# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

# my $filesl1 = []; #Vl.empty array referrence
my @filesl1; #filesList1 in directory ($testpath)
my @zipFileNamesL1;
sub wanted;



# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, $testpath);
print "directory:\n@filesl1\n";
for my $member ($zip->members) {
  push (@zipFileNamesL1, $member->fileName) unless $member->isBinaryFile;
}
print "zipFile:\n@zipFileNamesL1\n"; #Vl.zipmembersList1
exit;


sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    $File::Find::name =~ /\/\.git\z/s &&
    ($File::Find::prune = 1)
    ||
    -B _ || push(@filesl1, $name); 
}

