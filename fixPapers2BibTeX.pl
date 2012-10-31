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

    #warn if this stripped title has already been stored
    print STDERR "\nWARNING - duplicate titles [$stripped]" if exists $title{$stripped};

    #substitute <i> tags for \emphs
    $title =~ s/<i>/\\emph\{/g;
    $title =~ s/<\/i>/\}/g;

    #substitute <sub> tags for $_{}$s
    $title =~ s/<sub>/\$_\{/g;
    $title =~ s/<\/sub>/\}\$/g;

    #warn if there are tags not substituted
    print STDERR "\nWARNING - title contains HTML tags not substituted for LaTeX equivalents [$title]" if $title =~ /</;

    #store the stripped and corrected titles
    $title{$stripped} = $title;
  }
}

close HTML;
