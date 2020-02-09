##Vld. zdd = ZipDirDiff
use strict;
# use warnings;
no warnings 'redefine';
use File::Find ();
use Archive::Zip;
use List::Util qw(first);

my $Usage = "Usage:\n$0 [--long_options] [-short_options] [zipFile.zip] test_path\n  (test_path must not be a file).
Also see zdd_help.txt\n";
my $legend1 = "Legend: * = mark the newer file's version; ! = indicate that the older file's version has additional lines.";
die $Usage unless (@ARGV and -d $ARGV[$#ARGV]);
my $maxdepth = 1000;
undef my $nobinary;
undef my $verbose1;
undef my $verbose2; undef my $debug1;
undef my $zipfile;
use v5.14;
for(my $i = 0; $i < $#ARGV; $i++) {
  no warnings 'experimental';
  for ($ARGV[$i]) {
    $maxdepth = $ARGV[++$i] when /^--maxdepth$/ || /^-m$/;
    $nobinary = 1 when /^--nobinary$/ || /^-nb$/;
    $verbose1 = 1 when /^--verbose1$/ || /^-v1$/;
    $verbose2 = 1 when /^--verbose2$/ || /^-v2$/;
	$debug1 = 1 when /^--debug1$/ || /^-d1$/;
	$zipfile = $_ when /\.zip$/;
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
$zipfile = $1 . ".zip" unless $zipfile;
my $zip = Archive::Zip->new( $zipfile )
    or die "Archive::Zip was unable to read $zipfile\n"
         . "$zipfile and $1 (sub)directory must be at the same level in the hierarchy tree (both in the same directory).\n";

my ( @dir_only, @zip_only, @common, @altered );
# for the convenience of &wanted calls, including -eval statements:
# use vars qw/*name *dir *prune/;
# *name   = *File::Find::name;
# *dir    = *File::Find::dir;
# *prune  = *File::Find::prune;

# my $filesl1 = []; #Vl.empty array referrence
my @dirFileNamesL1; #filesList1 in directory ($testpath)
my @zipFileNamesL1;
sub wanted;
sub byname;

my @slashes = $testpath =~ /\//g;
# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, $testpath);
@dirFileNamesL1 = sort  byname @dirFileNamesL1;
print "\ndirectory:\n@dirFileNamesL1\n" if $verbose2;
for my $member ($zip->members) {
  my $fn = $member->fileName;
  next if $fn =~ /\.git/;
  if (not $member->isDirectory) { ##Vld.to deal with Windows FileExplorer zipArchive bug..
    $fn =~ /^(.*\/)/; #Vld.capturing greedy
	if (not $zip->memberNamed($1)) {
	  $zip->addDirectory($1);
	  push (@zipFileNamesL1, $1)
	}
  }
  my @s = $fn =~ /\//g;
  push (@zipFileNamesL1, $fn)
##    unless ($member->isBinaryFile || !($fn =~ /$testpath/) || $fn =~ /\.git/); ##Vl.isBinaryFile is not reliable..
    unless ((defined $maxdepth && @s > @slashes + $maxdepth) || !($fn =~ /$testpath/) || ($nobinary && $member->isBinaryFile));
}
# print "zipFilePreSort:\n@zipFileNamesL1\n" if $verbose2; #Vl.zipmembersList1
@zipFileNamesL1 = sort  byname @zipFileNamesL1;
print "zipFile:\n@zipFileNamesL1\n" if $verbose2; #Vl.zipmembersList1
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
print "\ndir_only:\n" . ($debug1 ? "@dir_only\n" : "");
my $cDir = "////"; #Vld.currentDir
foreach (@dir_only) {
  if (-d and not /$cDir/) { say $_; $cDir = $_; next }
  say $_ unless (/$cDir/ or not $cDir = "////")
}
print "\nzip_only:\n" . ($debug1 ? "@zip_only\n" : "");
$cDir = "////";
foreach (@zip_only) {
  if ($zip->memberNamed($_)->isDirectory and not /$cDir/) { say $_; $cDir = $_; next }
  say $_ unless (/$cDir/ or not $cDir = "////")
}
print "common_list:\n@common\n" if $verbose1 || $verbose2;
print "\nAltered files.\n"; printf("%-46s","mtime/size[B] for dir:"); printf("%-45s","mtime/size[B] for zipFile:"); print("FileName:\n");
my $tmpfile = "ttmpf".int(rand(100));
my $cmp;
foreach (@common) {
  next if -d;
  my $zipM = $zip->memberNamed($_); #Vl. zipM==zipMember
  my $dirM = $_;
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime) = lstat($dirM);
  if (-s _ == $zipM->uncompressedSize) { ##Vld.file test (perlfunc) the special filehandle "_"
    open(my $fileHandler, '<', $dirM) or die "Can't open $dirM: $!\n";
    local $/; #Vl.slurp mode
    $_ = <$fileHandler>;
    close $fileHandler;
    my $testCRC = $zip->computeCRC32($_);
    next if ($testCRC eq $zipM->crc32);
  }
  $cmp = ($mtime > $zipM->lastModTime()); ##say $cmp;
  undef my $flag; ##Vld. check if older file has additional lines
  $flag = "bin" if -B _;
  if (not $flag) {
    $zip->extractMemberWithoutPaths({memberOrZipName => $zipM, name => $tmpfile});
	my $diff1 = "\n" . $cmp ? qx(diff $dirM $tmpfile) : qx(diff $tmpfile $dirM);
	$flag = "!" if $diff1 =~ /\015?\012\d+a/;
	if (not $flag) {
	  while ($diff1 =~ /\015?\012(\d+,)?(\d+)c(\d+),?(\d+)?/g) {
	    my ($one,$four) = ($1,$4);
		$one = $2 if $1 == 0; $four = $3 if $4 == 0;
		if ($2 - $one < $four - $3) {$flag = "!"; last}
	  }
	}
  }
  unlink $tmpfile or warn "Could not delete temp file $tmpfile: $!" if -e $tmpfile;
  printf "%-27s%14s     %-27s%14s", scalar(localtime($mtime)) . ($cmp ? "*$flag" : ""), scalar($size),
    scalar(localtime($zipM->lastModTime())) . ($cmp ? "" : "*$flag"), scalar($zipM->uncompressedSize); print "    $dirM\n";
  ## print "size[B], dirFile: " . scalar(-s _) . "    zipFile: " . scalar($zipM->uncompressedSize) . "\n";
}
say defined $cmp ? $legend1 : "Common files are identical. OK!";
exit;

sub byname {
  my @aa = $a =~ /.+?\//g;
  my @bb = $b =~ /.+?\//g;
  return($a cmp $b) if (@aa == @bb);
  my $min;
  if (@aa < @bb) {$min = @aa} else {$min = @bb}
  for (my $i = 0; $i < $min; $i++) {
    next if ($aa[$i] eq $bb[$i]);
    return 1 if ($aa[$i] gt $bb[$i]);
    return -1;
  }
  return 1 if (@aa > @bb);
  return -1;
}
sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);
    my @s = $File::Find::name =~ /\//g;
    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    ((defined $maxdepth && -d _ && @s >= @slashes + $maxdepth) || $File::Find::name =~ /\/\.git\z/s) &&
    ($File::Find::prune = 1)
    ||
##    -B _ || push(@dirFileNamesL1, $name); ##Vl. some .htm files are seen as binary..
    ($nobinary && -B _) || push(@dirFileNamesL1, $File::Find::name . (-d ? '/' : ""));
}

=begin comment1

batwings@VladiLaptopWXP /home/batwings/projects/perl/cmp1
$ perl -e '1 && 1 && 0 || print "A ajuns aici\n";'
A ajuns aici
batwings@VladiLaptopWXP /home/batwings/projects/perl/cmp1
$ perl -e '1 && 1 && 0 || 1 || print "A ajuns aici\n";

(minimum) width
                Arguments are usually formatted to be only as wide as required
                to display the given value. You can override the width by
                putting a number here, or get the width from the next argument
                (with "*") or from a specified argument (e.g., with "*2$"):
                 printf "<%s>", "a";       # prints "<a>"
                 printf "<%6s>", "a";      # prints "<     a>"
                 printf "<%*s>", 6, "a";   # prints "<     a>"
                 printf '<%*2$s>', "a", 6; # prints "<     a>"
                 printf "<%2s>", "long";   # prints "<long>" (does not truncate)
                If a field width obtained through "*" is negative, it has the
                same effect as the "-" flag: left-justification.

=end comment1

=cut


