#! /usr/bin/perl -w
    eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell
use strict;
use warnings;
use File::Find ();
use Archive::Zip;
use List::Util qw(first);

my $Usage = "Usage:\n$0 [--long_options] [-short_options] test_path\n  (test_path must not be a file)\n";
die $Usage unless (@ARGV and -d $ARGV[$#ARGV]);
my $maxdepth = 1000;
undef my $nobinary;
use v5.14;
for(my $i = 0; $i < $#ARGV; $i++) {
  no warnings 'experimental';
  for ($ARGV[$i]) {
    $maxdepth = $ARGV[++$i] when /^--maxdepth$/ || /^-m$/;
    $nobinary = 1 when /^--nobinary$/ || /^-nb$/;
  }
}

undef $maxdepth if ($maxdepth == 1000);
my $testpath = $ARGV[$#ARGV];
($testpath) = ($testpath =~ /(\w.*)$/);
for ($testpath) {
  no warnings 'experimental';
  $testpath = $_ when /\/$/;
  default {$testpath = $_ . "/";}
}
$testpath =~ /^(\w+)/;
my $zipfile = $1 . ".zip";
my $zip = Archive::Zip->new( $zipfile )
    or die "Archive::Zip was unable to read $zipfile\n"
         . "$zipfile and $1 (sub)directory must be at the same level in the hierarchy tree (both in the same directory).\n";

my ( @dir_only, @zip_only, @common, @altered );
# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

# my $filesl1 = []; #Vl.empty array referrence
my @dirFileNamesL1; #filesList1 in directory ($testpath)
my @zipFileNamesL1;
sub wanted;

my @slashes = $testpath =~ /\//g;
# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, $testpath);
print "\ndirectory:\n@dirFileNamesL1\n";
for my $member ($zip->members) {
  my $fn = $member->fileName;
  my @s = $fn =~ /\//g;
  push (@zipFileNamesL1, $fn)
##    unless ($member->isBinaryFile || !($fn =~ /$testpath/) || $fn =~ /\.git/); ##Vl.isBinaryFile is not reliable..
  unless ((defined $maxdepth && @s > @slashes + $maxdepth) || $member->isDirectory || !($fn =~ /$testpath/) || $fn =~ /\.git/ ||
    ($nobinary && $member->isBinaryFile));
}
@zipFileNamesL1 = sort {
  my @aa = $a =~ /.+?\//g;
  my @bb = $b =~ /.+?\//g;
  if (@aa == @bb) {print scalar @aa, scalar @bb, "\n"; return($a cmp $b)};
  my $min;
  if (@aa < @bb) {$min = @aa} else {$min = @bb}
  for (my $i = 0; $i < $min; $i++) {
    next if ($aa[$i] eq $bb[$i]);
    return 1 if ($aa[$i] gt $bb[$i]);
    return -1;
  }
  return 1 if (@aa > @bb);
  return -1;
} @zipFileNamesL1;
print "zipFile:\n@zipFileNamesL1\n"; #Vl.zipmembersList1
no warnings 'experimental';
foreach (@dirFileNamesL1) {
  if ($_ ~~ @zipFileNamesL1) { #Vl.Smartmatch is experimental
    my $common = $_;
    push @common, $common;
    my $offset = first {$zipFileNamesL1[$_] eq $common} 0..$#zipFileNamesL1;
    splice @zipFileNamesL1, $offset, 1;
  } else { push @dir_only, $_ }
}
@zip_only = @zipFileNamesL1;
print "dir_only:\n@dir_only\n";
print "zip_only:\n@zip_only\n";
print "common_list:\n@common\n";
print "\nAltered files:\n";
my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime);
foreach (@common) {
  my $zipM = $zip->memberNamed($_); #Vl. zipM==zipMember
  my $dirM = $_;
  ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime) = lstat($dirM);
  if (-s _ == $zipM->uncompressedSize) {
    open(my $fileHandler, '<', $dirM) or die "Can't open $dirM: $!\n";
    local $/; #Vl.slurp mode
    $_ = <$fileHandler>;
    close $fileHandler;
    my $testCRC = $zip->computeCRC32($_);
    next if ($testCRC eq $zipM->crc32);
  }
  print "    $dirM\n";
  print "mtime/size[B], dirFile: " . scalar(localtime($mtime)) . " / " . scalar(-s _)
    . "    zipFile: " . scalar(localtime($zipM->lastModTime())) . " / " . scalar($zipM->uncompressedSize) . "\n";
  ## print "size[B], dirFile: " . scalar(-s _) . "    zipFile: " . scalar($zipM->uncompressedSize) . "\n";
}
exit;

sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);
    my @s = $name =~ /\//g;
    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    ((defined $maxdepth && -d _ && @s >= @slashes + $maxdepth) || $File::Find::name =~ /\/\.git\z/s) &&
    ($File::Find::prune = 1)
    ||
##    -B _ || push(@dirFileNamesL1, $name); ##Vl. some .htm files are seen as binary..
    -d _ || ($nobinary && -B _) || push(@dirFileNamesL1, $name);
}

