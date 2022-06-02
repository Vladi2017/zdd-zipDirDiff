# zdd-zipDirDiff
zdd is a Perl CLI utility which compares one zipped folder (zippedDir.zip) against his directory counterpart (dir).

### NAME
  zdd - ZipDirDiff.., compare zippedDir.zip	archive against dir (sub)directory.
  
### SYNOPSIS
  zdd [-m k -nb -g -v1 -v2] [--longoption ...] [zippedDir.zip] dir
  
### DESCRIPTION
This app is useful especially when you write on the same project on different machines and sometimes you need somehow to synchronize your work. zdd compare one zipped folder (zippedDir.zip) against his directory counterpart (dir). By default zdd prints founded differences in terms of dir_only files, zip_only files and altered files (also please see note_6).

Both zippedDir.zip and dir must reside in the same directory. If there is no zippedDir.zip parameter in the command line, dir is compared against dir.zip file. For .git subdirs please see note_2 below. If two files (in the zip archive and dir (sub)directory, including relative paths) have same size, computeCRC32 is done to establish similarity.

To assist your synchronization process:
  - the most recently altered files are "\*" marked.      
  - the most recently altered text files are "\*!" marked if the older file counterpart has additional lines which was deleted in the new file's version. (note_1)

Switches (OPTIONS) are in nmap-style (e.g. "$zdd -nbm 2 dir" will not work). Please use  "$zdd -nb -m 2 dir" instead.

### NOTES:
  note_1. Even though the new version has more lines than the older one.
  
  note_2. .git treatment: .git subdirs scanning is triggered by -g switch but in this case --maxdepth has no effect for .git position(s) in dir / zippedDir directory hierarchy. All .git  subdirs will be scanned. Furthermore, in order to prevent excessive cluttering, only .git/logs/ subdirs differences will be reported. This should be sufficient in order to evaluate similarities in git archives inside dir / zippedDir. In this respect to see (mostly) .git subdirs status please use "zdd -m 0 -g zippedDir.zip dir". Additionally in this mode all the process is faster. Otherwise, if -g switch is used (without -m 0), .git logs are interleaved between other "ordinary" files (obviously if there are differences which need to be emphasized).
  
  note_3. Please be aware that for -nb switch, files such as .doc, .xls .docx, .pdf, executable scripts (those with -x mode flag enabled) are treated as binaries and excluded from the report. Also please note that zip archiving tool integrated in Windows File Explorer set the binary flag for text Unicode files. So, using -nb switch could be tricky..
  
  note_4. zdd don't deal with encrypted zip archives.
  
  note_5. If an entire subdir is missing in the counterpart only the "subdir/" entry is listed to avoid to much cluttering.
  
  note_6: Even if two text files have different mtime (modification time) those are not reported if they are identical. This could be useful since git checkout / restore does not have (file) timestamp tracking.
  
### OPTIONS
-m k, --maxdepth k
	Comparison depth into dir (sub)directory hierarchy, k>=0, natural number. If k=0 no dir subdirs are searched.
  
-nb, --nobinary
	Ignore binaries. Also please see note_3.
  
-g, --git
  Also scan .git/ subdirectories.
  
-v1, --verbose1
	Also prints the common_list of files.
  
-v2, --verbose2
	Also prints directory and zippedDir files.

### OSs:
  Linux, Cygwin or Msys2 (MINGW) virtual environment over WXP - W11.

### DEPENDENCIES
  Perl min. v5.14 with File::Find(\*1), Archive::Zip, List::Util(\*1) modules.
  
  (\*1) usually preinstalled Perl modules.
  
  Install Archive::Zip module using pacman/MINGW, perl-Archive-Zip package using setup.exe/Cygwin or:
  
    cpanm:
        $ cpanm Archive::Zip

    CPAN shell:
        $ perl -MCPAN -e shell
        cpan[3]> install Archive::Zip
  Please see the module at https://metacpan.org/pod/Archive::Zip.

### INSTALATION
  Clone the repo or just download zdd.pl.
  
  $ chmod a+x zdd.pl
  
  $ ln -s /path_to/zdd.pl /dir_in_$PATH/zdd


### EXAMPLES
  1. $zdd -nb -m 2 dir		#assume there is dir.zip archive as well
  2. $zdd zippedDir.zip dir
  3. Real test:
```
        vladi@VladiLaptop1W10 ~/projects/perl$ ls -l .|grep cmp1        
        drwxr-xr-x+ 1 vladi mvman       0 May 31 12:29 cmp1        
        -rwxr-xr-x  1 vladi mvman 2842592 Jun  1 21:33 packed_cmp1.zip
        
        vladi@VladiLaptop1W10 ~/projects/perl$ tree cmp1/
        cmp1/
        +-- b1.txt
        +-- dir0
        ¦   +-- f1.txt
        +-- dir1
        ¦   +-- dir11
        ¦   ¦   +-- f1
        ¦   ¦   +-- f1.txt
        ¦   ¦   +-- f2
        ¦   ¦   +-- IDs.db
        ¦   ¦   +-- Unicode1.txt
        ¦   +-- dir12
        ¦   ¦   +-- dir123
        ¦   ¦   ¦   +-- f2
        ¦   ¦   +-- f1.txt
        ¦   +-- dt1Test.pl
        +-- dir2
        ¦   +-- df
        ¦   +-- dir21
        ¦   ¦   +-- Adresa catre DGL_10.02.2020_v1.doc
        ¦   ¦   +-- dir211
        ¦   ¦   ¦   +-- dir2111
        ¦   ¦   ¦   ¦   +-- utf8_2.txt
        ¦   ¦   ¦   +-- utf8_1.txt
        ¦   ¦   +-- fuser
        ¦   ¦   +-- test_diffFile1.txt
        ¦   ¦   +-- Vutils1.pm
        ¦   ¦   +-- zDGL_Stulz_3v1.doc
        ¦   +-- dir22
        ¦   ¦   +-- f1.txt
        ¦   ¦   +-- f2.txt
        ¦   +-- f1
        ¦   +-- raport_co.docx
        +-- dir2COPY
        ¦   +-- df
        ¦   +-- dir21
        ¦   ¦   +-- fuser
        ¦   ¦   +-- test_diffFile1.txt
        ¦   +-- dir22
        ¦   ¦   +-- f1.txt
        ¦   ¦   +-- f2.txt
        ¦   +-- f1
        +-- dirzipCompare.exe
        +-- foo.c
        +-- t1.pl
        +-- test1
        ¦   +-- t1.pl
        ¦   +-- Vld1.txt
        +-- try1.pl
        +-- V4.pl
        +-- Vtest1.c
        +-- Vtest1.exe
        +-- Vtest1.pl
        +-- zdd
        +-- zdd.pl
        +-- zdd_help.txt
        +-- zddtmp1.pl
        14 directories, 42 files

        vladi@VladiLaptop1W10 ~/projects/perl$ zdd packed_cmp1.zip cmp1

        dir_only:
        cmp1/Vtest1.c
        cmp1/Vtest1.exe
        cmp1/Vtest1.pl
        cmp1/b1.txt
        cmp1/foo.c
        cmp1/zddtmp1.pl
        cmp1/dir0/
        cmp1/dir1/dir11/Unicode1.txt
        cmp1/dir1/dir11/f1.txt
        cmp1/dir1/dir12/
        cmp1/dir2/raport_co.docx
        cmp1/dir2/dir21/Adresa catre DGL_10.02.2020_v1.doc
        cmp1/dir2/dir21/test_diffFile1.txt
        cmp1/dir2/dir22/
        cmp1/dir2COPY/
        cmp1/test1/

        zip_only:
        cmp1/dir1/SocketClass/
        cmp1/dir1/dir11/SMS/
        cmp1/dir2/poza1.jpg
        cmp1/dir2/dir21/dir211/dir2111/zipLog.txt

        Altered files.
        mtime/size[B] for dir:                            mtime/size[B] for zipFile:                        FileName:
        Tue May 31 12:29:10 2022*                78       Thu Nov  8 18:41:10 2018                 26       cmp1/zdd
        Tue May 31 19:59:14 2022*!             8851       Sat Dec  7 22:04:52 2019               6093       cmp1/zdd.pl
        Wed Jun  1 20:38:25 2022*!             4129       Sun Jun 23 19:30:12 2019               1290       cmp1/zdd_help.txt
        Tue Sep 24 12:21:08 2019                686       Wed Jun  1 21:18:26 2022*!              685       cmp1/dir1/dt1Test.pl
        Wed Jun  1 20:13:54 2022*               726       Wed Jun  1 20:10:58 2022                726       cmp1/dir1/dir11/IDs.db
        Sun Jul 23 18:49:33 2017                 11       Mon Sep 11 14:44:28 2017*                11       cmp1/dir2/f1
        Mon Jul 23 18:49:33 2018               1088       Sat Sep 28 18:40:28 2019*               956       cmp1/dir2/dir21/Vutils1.pm
        Wed Jun  1 21:36:57 2022*bin          95744       Mon Feb 10 12:51:00 2020              95232       cmp1/dir2/dir21/zDGL_Stulz_3v1.doc
        Legend: * = mark the newer file's version; ! = indicate that the older file's version has additional lines; bin = file detected as binary.

        vladi@VladiLaptop1W10 ~/projects/perl$ zdd -m 0 -g packed_cmp1.zip cmp1

        dir_only:
        cmp1/Vtest1.c
        cmp1/Vtest1.exe
        cmp1/Vtest1.pl
        cmp1/b1.txt
        cmp1/foo.c
        cmp1/zddtmp1.pl

        zip_only:

        Altered files.
        mtime/size[B] for dir:                            mtime/size[B] for zipFile:                        FileName:
        Wed Jun  1 17:38:12 2022*              1248       Mon Jul 24 13:40:08 2017                713       cmp1/V4.pl
        Tue May 31 12:29:10 2022*                78       Thu Nov  8 18:41:10 2018                 26       cmp1/zdd
        Tue May 31 19:59:14 2022*!             8851       Sat Dec  7 22:04:52 2019               6093       cmp1/zdd.pl
        Wed Jun  1 20:38:25 2022*!             4129       Sun Jun 23 19:30:12 2019               1290       cmp1/zdd_help.txt
        Wed Jan 12 00:32:58 2022*             15021       Thu Nov 28 17:05:14 2019              11080       cmp1/.git/logs/HEAD
        Wed Jan 12 00:32:58 2022*             15021       Thu Nov 28 17:05:14 2019              11080       cmp1/.git/logs/refs/heads/master
        Legend: * = mark the newer file's version; ! = indicate that the older file's version has additional lines; bin = file detected as binary.
        vladi@VladiLaptop1W10 ~/projects/perl$
	        Where we observe that there are differences in the Git repo(s).
```
### AUTHORS
  Vladimir Manolescu, Bucharest, Romania, 2022, mvmanol@yahoo.com
