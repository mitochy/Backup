#!/usr/bin/perl

use strict; use warnings FATAL => 'all';
use Cache::FileCache;
use seq_calculator;
use FAlite;

# takes up a whole fasta file in a directory
my ($fasta) = @ARGV;
die "usage: $0 <fasta>\n" unless @ARGV == 1;
my ($folder, $name) = $fasta =~ /^(.+)\/(\w+\..+)$/;
die "Init: folder not defined\n" unless defined($folder);

#my @list = qw(A T G C AA AT AG AC TA TT TG TC GA GT GG GC CA CT CG CC);
my @list = qw(CG);
my $WINDOW = 200;
my $STEP = 10;
# creates a folder that is called "data" to store in tab delimited format the result of calculations
if (not -d "$folder\/data") {
	system("mkdir $folder\/data") == 0 or die "Init: Cannot create $folder\/data: $!\n";
}

# open fasta and creates dat file where our calculation for that particular fasta is stored
open (my $in, "<", $fasta) or die "Cannot read from $fasta: $!\n";

# Create 3 bed files for cpg density, gc content, and gc skew
open (my $cpgdens_out, ">", "$folder\/data\/$name.cpg_dens.dat") or die "Cannot write to $cpgdens_out: $!\n";
open (my $gccont_out, ">", "$folder\/data\/$name.gc_cont.dat") or die "Cannot write to $gccont_out: $!\n";
open (my $gcskew_out, ">", "$folder\/data\/$name.gc_skew.dat") or die "Cannot write to $gcskew_out: $!\n";

print $cpgdens_out "track type=wiggle_0 name=\"cpg_density\" description=\"cpg density of $name\" visibility=full color=0,0,255\n";
print $gccont_out "track type=wiggle_0 name=\"gc_content\" description=\"gc content of $name\" visibility=2 color=0,255,0\n";
print $gcskew_out "track type=wiggle_0 name=\"gc_skew\" description=\"gc skew of $name\" visibility=2 color=255,0,0\n";

my ($def, $chr, $seq);
while (my $line = <$in>) {
	chomp($line);
	if ($line =~ /^>/) {$def = $line;next;)
	$seq = $line;
	($chr) = $def =~ /^(\d+)/;
	$chr = $def if not defined($chr);

	my %count;
	# Calculate dinucleotide content, density, skew
	for (my $i = 0; $i < @list; $i++) {
		my $type = $list[$i];
		# Per Step size = 1
		
		my ($first, $last) = (".");
		for (my $j = 0; $j < length($seq)-$WINDOW; $j+=$STEP) {
			my $seq_chunk = substr($seq, $j, $WINDOW);
			if ($j == 0) {
				$count{$j}{$type} = seq_calculator::count_nuc($type, $seq_chunk);
			}
			else {
				# Otherwise, all we need to do is add the last nucleotide
				# and subtract the previous nucleotide from count
				# Get last nucleotide
				$last  = substr($seq_chunk, ($WINDOW-length($type)), length($type));
				
				# Add the last and subtract the first to %count
				$count{$j}{$type} = $count{$j-1}{$type};
				$count{$j}{$type} -- if $first eq $type;
				$count{$j}{$type} ++ if $last eq $type;
				$first = substr($seq_chunk, 0, length($type));
			}
		}
	}

	#print nucleotide content
	for (my $i = 0; $i < @list; $i++) {
		my $type = $list[$i];
		for (my $j = 0; $j < (keys %count); $j++) {
			my $pos = $j+50;
			my $content = $count{$j}{$type}/$WINDOW;
			
			print $gccont_out "$chr\t
		
			if (length($type) > 1) {
				my ($first, $last) = $type =~ /^(\w)(\w)$/;
				#calculate density and print
				my $density = $count{$j}{$first}*$count{$j}{$last} == 0 ? 0 : $count{$j}{$type}/($count{$j}{$first}*$count{$j}{$last});
				#calculate skew and print
				my $skew = $count{$j}{$first}+$count{$j}{$last} == 0 ? 0 : ($count{$j}{$first}-$count{$j}{$last})/($count{$j}{$first}+$count{$j}{$last});
				print $out "_density_$density\_skew_$skew";
			}
			print $out "\t";
		}
		print $out "\n";
	}
}
close $in;

# takes up a whole fasta file in a directory

# creates a folder that is called "calculation"

# calculate :
# mononucleotides
# dinucleotides, including gc
# cpg o/e
# mononucleotide skew


