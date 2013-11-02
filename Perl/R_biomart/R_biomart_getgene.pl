#!/usr/bin/perl
# This script is to get the 
# chromosome name, start, end, and strand
# From a list of human gene ID

use strict; use warnings; use mitochy; use FAlite; use R_toolbox;

die "usage: R_biomart_getsequence.pl <Ensembl id list>\n" unless @ARGV == 1;
my ($input) = @ARGV;

open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
my @id;
while (my $line = <$in>) {
	chomp($line);
	my ($id) = split("\t", $line);
	push(@id, $id);
}
close $in;

my $geneid = R_toolbox::newRArray(\@id, "core.geneid", "with_quote");
run_query("hsapiens", "hsapiens", "ensembl", $geneid);
sub run_query {
	my ($core, $org, $mart, $geneid) = @_;
	exit if not defined($geneid);
	#Load library biomaRt
	my $biomart = "library(biomaRt)\n\n";
	#print "GENEID\n$geneid\n";
	$biomart .= "core.mart <-useMart(\"ensembl\", dataset = \"$org\_gene_ensembl\")\n" if $core =~ /hsapiens/;
	$biomart .= "core.mart <-useMart(\"plants_mart_19\", dataset = \"$org\_eg_gene\")\n" if $core =~ /athaliana/;
	$biomart .= "core.mart <-useMart(\"fungi_mart_19\", dataset = \"$org\_eg_gene\")\n" if $core =~ /scerevisiae/;
	$biomart .= "core.mart <-useMart(\"metazoa_mart_19\", dataset = \"$org\_eg_gene\")\n" if $core =~ /celegans/;
	$biomart .= "core.mart <-useMart(\"protists_mart_19\", dataset = \"$org\_eg_gene\")\n" if $core =~ /tgondii/;
	
	#Load requested human gene ID
	$biomart .= "$geneid\n";
	
	#my $biomart = "library(biomaRt)\n\n";
	$biomart .= "$org.TSS <- getBM(mart = core.mart, attributes = c(\"chromosome_name\", \"start_position\", \"end_position\", \"ensembl_gene_id\", \"strand\"), checkFilters=FALSE, filters = c(\"ensembl_gene_id\") ,values = list(core.geneid))\n" if $geneid =~ /\w+/;
	$biomart .= "\n\nwrite.table($org.TSS, file=\"$input.TSS.txt\", sep=\"\t\")\n";
		#Write all the sequence to fast

	R_toolbox::execute_Rscript($biomart);	
	#open (my $out, ">", "$input.$org.TSS.R") or die "Cannot write to $input.$org.TSS.R: $!\n";
	#print $out "$biomart";
	#close $out;
}
