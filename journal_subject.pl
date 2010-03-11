#!/usr/bin/perl -w
# INPUT: PMID | PUBYEAR | MEDLINETA | DESCRIPTORS
use strict;

my %stat;
my %dat;
open(FH, "< $ARGV[0]") or die("Can't read $ARGV[0]: $!\n");
while (<FH>) {
  chomp;
  my ($pmid, $pubyear, $medlineta, @desc) = split /\t/;
  ++$stat{pubyear}->{$pubyear};
  ++$stat{journal}->{$medlineta};
  foreach my $d (@desc) {
    ++$stat{subject}->{$d};
    ++$dat{$medlineta}->{$pubyear}->{$d} if $pubyear;
  }
  print STDERR $pmid, "\n" unless $pubyear;
}
close FH;

foreach my $i (sort keys %stat) {
  my $s = $stat{$i};
  open(FH, "> $i.txt") or die("Can't write $i.txt: $!\n");
  foreach my $j (sort { $s->{$b} <=> $s->{$a} } keys %$s) {
    print FH join("\t", $j, $s->{$j}), "\n";
  }
  close FH;
}

my $file = "journal.year.subject.txt";
open(FH, "> $file") or die("Can't write $file: $!\n");
foreach my $j (sort keys %dat) {
  foreach my $y (sort keys %{ $dat{$j} }) {
    foreach my $d (sort { $dat{$j}->{$y}->{$b} <=> $dat{$j}->{$y}->{$a} } keys %{ $dat{$j}->{$y} }) {
      print FH join("\t", $j, $y, $d, $dat{$j}->{$y}->{$d}), "\n";
    }
  }
}
close FH;
