#!/usr/bin/perl

use strict; use warnings; use R_toolbox;

my $command = "grep \"Max Individual\" screenlog.0 \| cut \-f2,5,7 \-d \" \" \| perl \-pi \-e \'s\/\tMax\/\/ig\' \| perl \-pi \-e 's\/ \/\t\/ig' \> acctable.tsv";
print "$command\n";
system($command) == 0 or die;

open (my $in, "<", "acctable.tsv") or die;
my (@x, @pop, @max);
while (my $line = <$in>) {
	chomp($line);
	$line =~ s/\r//ig;
	my ($x, $pop, $max) = split("\t", $line);
	push(@x, $x);
	push(@pop, $pop);
	push(@max, $max);
}
close $in;

my $xaxis = R_toolbox::newRArray(\@x, "x");
my $pop = R_toolbox::newRArray(\@pop, "pop");
my $max = R_toolbox::newRArray(\@max, "max");

my $Rscript = "pdf(\"accresult.pdf\")
$xaxis
$pop
$max
miny = min(pop)
maxX = max(x)
plot(x, max, type=\"l\", col=\"red\",xlab=\"Generations\",ylab=\"Accuracy\",ylim=c(miny,1))
lines(x,pop,col=\"blue\")
lines(c(0,maxX),c(0.9,0.9),col=\"green\",lty=2)
text(0,0.92,\"0.9\")
dev.off()
";
open (my $out, ">", "acctable.R") or die;
print $out $Rscript;
close $out;

system("run_Rscript.pl acctable.R");
