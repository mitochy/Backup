#!/usr/bin/perl

use strict; use warnings; use mitochy;

my ($input, $mode) = @ARGV;

die "usage: R_biomart_HGTSSvalidator.pl fasta\n" unless @ARGV;
print "Forcing to print $input into its fasta file without TSS validation\n" if defined($mode);
my %kogdb = mitochy::process_kogIDdb();

my ($org) = $input =~ /(\w+).table/i;
die "undefined organism: make sure name is org.table.<query>...\n" unless defined($org);
my %fasta = mitochy::process_biomart_fasta($input);
my %protein = mitochy::process_biomart_fasta("/home/mitochi/Desktop/Work/newcegma/database/protein/$org.table.peptide.0_flank.txt");
#open (my $out, ">", "$input.bad") or die;
#open (my $out2, ">", "$input.good") or die;
my $count = 0;

my %good;
foreach my $id (sort keys %fasta ) {

	#my ($id, $oldstart, $oldend, $strand, $start, $end, $flank, $lengthseq) = $fasta =~ />(.+)_(\d+)_to_(\d+)_strand=(-{0,1}\d)_(\d+)_to_(\d+)_flank=(\d+)_lengthseq=(\d+)$/i;
	#my $l_seq = length($fasta{$fasta}{'seq'});
	#die "$l_seq of $fasta $input is less than 2000?\n" if $l_seq < 2000;
	
	my $protein = substr(mitochy::translate($fasta{$id}{'seq'},0), 0, 8);
	$protein =~ s/\*/0/ig;
	my $proteincheck = 0;
	foreach my $protein2 (@{$protein{$id}{'seq'}}) {
		next if defined($mode);
		$count++ if ($protein2 =~ /^$protein/i) and not defined($mode);
		$proteincheck = 1 if ($protein2 =~ /^$protein/i) and not defined($mode);
		last if ($protein2 =~ /^$protein/i) and not defined($mode);
	}
	#print "$protein{$id}{'seq'} =~ /^$protein/i\n" if ($protein{$id}{'seq'} =~ /^$protein/i);
	#print "$protein{$id}{'seq'} =~ /^$protein/i\n" if ($protein{$id}{'seq'} !~ /^$protein/i);
	next if ($proteincheck == 1);
	foreach my $kogid (sort keys %kogdb) {
		my $idcomp = $kogdb{$kogid}{$org};
		$good{$id}{'seq'} = $fasta{$id}{'seq'} if $idcomp =~ /^$id$/i;
		$good{$id}{'kog'} = $kogid if $idcomp =~ /^$id$/i;
		last if $idcomp =~ /^$id$/i;
	}
	die "sequence used is not listed in KOG database? at $org $id\n" unless defined($good{$id}{'kog'});
}

#close $out;
#close $out2;
my $totalgene = (keys %fasta);
print "$input: BAD ($count/$totalgene)\n" if $count > 300;
print "$input: GOOD ($count/$totalgene)\n" if $count <= 300;

if ((keys %good) > 100 ) {
	open (my $out3, ">", "$input.good.only") or die;

	foreach my $id (sort keys %good) {
		print $out3 ">$good{$id}{'kog'}\_$id\n$good{$id}{'seq'}\n";
	}
	close $out3;
}
