#!/usr/bin/perl

$USAGE = q/USAGE:

  -h <filename> HTML file, produced by Papers2 exporting a Reference List in IEEE style
  -b <filename> BibTeX file you wish to repair \emph tags for
/;

use Getopt::Long;
GetOptions (
  'h=s' => \$HTMLFile,
  'b=s' => \$BibTeXFile,
);
die $USAGE if ! $HTMLFile or ! $BibTeXFile;

#get titles from HTML output
#while ()
