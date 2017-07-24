#!/usr/bin/perl

use strict;
use warnings;
use Archive::Zip;

my $Usage = "$0 file.zip [test_path]\n  (default test_path is '.')\n";
die $Usage unless ( @ARGV and -f $ARGV[0] );

my $zipfile = shift;
my $testpath = shift || '.';

my $zip = Archive::Zip->new( $zipfile )
    or die "Archive::Zip was unable to read $zipfile\n";

my ( @missing_from_path, @altered );

for my $member ( $zip->members ) {
    next if ( $member->isDirectory );
    my $filepath = $member->fileName;
    if ( ! -f "$testpath/$filepath" ) {
        push @missing_from_path, $filepath;
        next;
    }
    if ( -s _ == $member->uncompressedSize ) {
        if ( open( my $testfile, '<', "$testpath/$filepath" )) {
            local $/;
            $_ = <$testfile>;
            close $testfile;
            my $testCRC = $zip->computeCRC32( $_ );
            next if ( $testCRC eq $member->crc32 );
        }
        else {
            warn "Unable to read $testpath/$filepath: $!\n";
        }
    }
    push @altered, $filepath;
}

print "Comparing $zipfile to $testpath:\n";
if ( @missing_from_path ) {
    print " Missing files:\n";
    print "  $testpath/$_\n" for ( sort @missing_from_path );
}
else {
    print " No files missing\n";
}
if ( @altered ) {
    print " Altered files:\n";
    print "  $testpath/$_\n" for ( sort @altered );
}
else {
    print " No altered files\n";
}

=head1 NAME

zip-check -- check zip file against directory contents

=head1 SYNOPSIS

 zip-check [path/to/]file.zip [test_path]
   (default test_path is '.')

=head1 DESCRIPTION

This script will compare the contents of a given zip file against the
contents of a given directory (current working directory by default).

We check for two types of differences:

 - Files in the zip archive that are not found in the directory
 - Files found in both places, but having different contents
   (based on comparing their CRC32 values)

(We do not report cases where the directory contains files that are
not found in the zip archive.)

=head1 AUTHOR

David Graff <graff at ldc dot upenn dot edu>

=cut
