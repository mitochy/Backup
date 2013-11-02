#!/usr/bin/perl

use strict; use warnings; use mitochy; use FAlite;

my ($input, $substr, $length) = @ARGV;
die "usage: R_biomart_flankadd.pl <fasta> <start substr> <substr how much>\n" unless @ARGV == 3;

my ($org) = $input =~ /id.(\w+).ID.transcript_exon_intron.\w+.0_flanktxt.fa/i;
($org) = $input =~ /(\w+).table.gene_exon_intron.0_flank/i if not defined($org);
die "please make sure name is org.table.<query>...\n" unless defined($org);

print "Processing kogIDDB\n";
my %kogid = mitochy::process_kogIDdb();
print "Processing input fasta\n";
my %fasta = %{mitochy::process_fasta($input, "yes")};
print "Processing database flank up fasta\n";
#my %flank_up = mitochy::process_biomart_fasta("/home/mitochi/Desktop/Work/SkewClassGene/sequence/flank4000/$org.table.gene_exon_intron.4000_flank.txt");
my %flank_up = mitochy::process_biomart_fasta("/home/mitochi/Desktop/Work/newcegma/database/dna/up4000/$org.table.gene_exon_intron.4000_flank.txt");
print "Processing database flank down fasta\n";
#my %flank_down = mitochy::process_biomart_fasta("/home/mitochi/Desktop/Work/SkewClassGene/sequence/flank-4000/$org.table.gene_exon_intron.-4000_flank.txt");
my %flank_down = mitochy::process_biomart_fasta("/home/mitochi/Desktop/Work/newcegma/database/dna/down4000/$org.table.gene_exon_intron.-4000_flank.txt");
my %yeastid;
if ($org =~ /scerevisiae/) {
	my $data = "/home/mitochi/Desktop/Work/newcegma/additional/yeastutr.txt";
	open (my $in, "<", $data) or die "Cannot read from $data: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		my ($id, $utr) = split("\t", $line);
		$yeastid{$id} = $utr;
	}
}

open (my $out, ">", "$input.TSS$substr\_$length") or die "Cannot write to $input.TSS4000: $!\n";
my $count = 0;
my $count_def = 0;
my $total = 0;
foreach my $kogid (sort keys %kogid) {
	my $id = $kogid{$kogid}{$org};
	my $fastaid = ">$kogid\_$id";

	my $flank_up = $flank_up{$id}{'seq'};
	my $strand = $flank_up{$id}{'strand'};
	my $flank_down = $flank_down{$id}{'seq'};

	#if ($org !~ /scerevisiae/) {
		next if not defined($fasta{$fastaid}{'seq'});
		next if (not defined($flank_up) or length_check($flank_up) == 0);
	#}
	$total++;
	my $TSS = $fasta{$fastaid}{'seq'};
	print "$fastaid\n";
	print "$TSS\n" if $fastaid =~ /BGIBMGA001232/i;
	print "$flank_up\n" if $fastaid =~ /BGIBMGA001232/i;
	$flank_down = "" if not defined($flank_down);
	my $seq = $flank_up . $TSS . $flank_down;
	my $old_substr = $substr;
	if ($org =~ /scerevisiae/) {
		$count++ and print "undefined yeast id at id = $id\n" if not defined($yeastid{$id});
		next if not defined($yeastid{$id});
		$count_def++ and print "defined yeast id at id = $id\n" if defined($yeastid{$id});
		$substr = defined($yeastid{$id}) ? $substr - $yeastid{$id} : $substr;
	}
	my $seq4000 = substr($seq, $substr, $length);
	print "substr from $old_substr to now $substr\n";
	$substr = $old_substr;
	next if length_check($seq) == 0;

	print $out ">$id\_strand_=_$strand\n$seq4000\n";
}

print "undefined = $count\ndefined=$count_def\ntotal=$total\n";
close $out;
print "Output file is $input.TSS$substr\_$length\n";
sub length_check {
	my ($seq) = @_;
	return(0) if length($seq) < 4000;
	#return(0) if $seq =~ /N{50,2000}/i;
	return(1) if length($seq) >=4000;
}
