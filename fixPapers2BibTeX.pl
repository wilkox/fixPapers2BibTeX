#!/usr/bin/perl

#Fixes a BibTeX file exported from Papers2 by restoring \emph
# tags

#written by David Wilkins <david@wilkox.org>

#this script lives at https://github.com/wilkox/fixPapers2BibTeX

#this software is released into the public domain. To the extent 
# possible under law, all copyright and related or neighboring
# rights are waived and permission is explicitly and irrevocably
# granted to copy, modify, adapt, sell and distribute this software
# in any way you choose.

$USAGE = q/USAGE:

  This script requires that you export your Papers2 library as a "Reference List" in the IEEE style - it uses this file to figure out where the \emph tags belong. Once you have your .bib and .html files ready, run the script with the following options:

  -h <filename> HTML file, produced by Papers2 exporting a Reference List in IEEE style
  -b <filename> BibTeX file you wish to repair tags for
/;

use Getopt::Long;
GetOptions (
  'h=s' => \$HTMLFile,
  'b=s' => \$BibTeXFile,
);
die $USAGE if ! $HTMLFile or ! $BibTeXFile;

#get titles from HTML output
die ("ERROR - could not open HTML file $HTMLFile") unless open(HTML, "<$HTMLFile");

my %title;
while (my $line = <HTML>) {
  if ($line =~ /“(.+)”/) {

    my $title = $1;

    #chop the comma off the end
    chop $title;

    #ignore unless title contains HTML tags
    next unless $title =~ />/;

    #strip tags from title so we know what to
    # match in the BibTeX file
    # what's that you say? I can't use a regex
    # to parse HTML? MUAUAUAHHAHAH just try to stop me!
    my $stripped = $title;
    $stripped =~ s/<[^>]+>//g;

    #substitute <i> tags for \emphs
    $title =~ s/<i>/\\emph\{/g;
    $title =~ s/<\/i>/\}/g;

    #substitute <sub> tags for $_{}$s
    $title =~ s/<sub>/\$_\{/g;
    $title =~ s/<\/sub>/\}\$/g;

    #warn if there are tags not substituted
    print STDERR "\nWARNING - title contains HTML tags not substituted for LaTeX equivalents [$title]" if $title =~ /</;

    #substitute smart quotes for plain quotes
    $stripped =~ s/[‘’“”]/"/g;
    $stripped =~ s/"+/"/g;
    $title =~ s/[‘’“”]/"/g;
    $title =~ s/"+/"/g;

    #warn if this stripped title has already been stored
    print STDERR "\nWARNING - duplicate titles [$stripped]" if exists $title{$stripped};

    #store the stripped and corrected titles
    $title{$stripped} = $title;
  }
}

close HTML;

#fix BibTeX file
die ("ERROR - could not open BibTeX file $BibTeXFile") unless open(BIBTEX, "<$BibTeXFile");
my $outputFile = $BibTeXFile . ".fixed";
die ("ERROR - could not write to output file $outputFile") unless open(OUT, ">$outputFile");

while (my $line = <BIBTEX>) {

  if ($line =~ /^title/) {
    die "ERROR - could not parse BibTeX title line - are there line breaks in the title? [$line]" unless $line =~ /^title\s=\s\{\{(.+)\}\},\n/;
    my $title = $1;
    my $rawTitle = quotemeta($title);
    $title =~ s/\{//g;
    $title =~ s/\}//g;
    $title =~ s/_//g;

    #skip unless the title was stored with a substitute
    unless (exists $title{$title}) {
      print OUT $line;
      next;
    }

    #replace the title with the substitute
    if ($line =~ /$rawTitle/) {
      $line =~ s/$rawTitle/$title{$title}/;
      print OUT $line;
    } else {
        die "\nSomething went horribly wrong at $line\nrawTitle = $rawTitle";
    }

  } else {
    print OUT $line;
  }
  
}

close BIBTEX;
close OUT;

print "\nFixed BibTeX file created at $outputFile\n";
