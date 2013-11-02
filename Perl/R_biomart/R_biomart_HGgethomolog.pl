#!/usr/bin/perl
# This script is to get human homolog ID from all organism on biomart ensembl 
# and save it to $org.ID

use strict; use warnings; use mitochy; use FAlite; use R_biomart;

die "usage: R_biomart_HGgethomolog.pl geneID_list.\n" unless @ARGV;
my ($input) = @ARGV;
my @datasets = R_biomart::process_ensembl_dataset('ensembl');

#Processing gene ID that you want
my $geneid;
open (my $in2, "<", $input) or die "Cannot read from $input: $!\n";
while (my $line = <$in2>) {
	chomp($line);
	$geneid .= "\"$line\", " if $line !~ /^\"/;
	$geneid .= "$line, "     if $line =~ /^\"/;
}
close $in2;

foreach my $datasets (@datasets) {
	open (my $out, ">", "$input.$datasets.R") or die "Cannot write to $input.dataset.R: $!\n";
	#Load library biomaRt
	my $biomart = "library(biomaRt)\n\n";

	#Load human mart
	$biomart .= "hsapiens <-useMart(\"ENSEMBL_MART_ENSEMBL\", host=\"feb2012.archive.ensembl.org\", dataset = \"hsapiens_gene_ensembl\")\n";

	#Load requested human gene ID
	$biomart .= "hsapiens.geneid <- c($geneid)\n\n";
	$biomart =~ s/, \)/\)/i;

	#Make R script for each dataset
	#Get homolog gene ID of all ensembl organism for each human gene ID
	#Get sequence for each organism gene ID
	#next if $datasets =~ /hsapiens/i;
	my ($org) = $datasets =~ /^(\w+)_gene_ensembl$/i;
	die "$datasets\norganism not defined (doesn't match org_gene_ensembl?)\n" unless defined($org);
	
	#Get Mart of each datasets
	$biomart .= "$org.mart <- useMart(\"ENSEMBL_MART_ENSEMBL\", host=\"feb2012.archive.ensembl.org\", dataset = \"$datasets\")\n";

	#Get ID for each dataset homolog to human
	$biomart .= "$org.ID <- getLDS(attributes=c(\"ensembl_transcript_id\"), filters = \"ensembl_transcript_id\", values = hsapiens.geneid, mart = hsapiens, attributesL = c(\"ensembl_transcript_id\", \"chromosome_name\", \"strand\", \"transcript_start\", \"transcript_end\"), martL = $org.mart)\n";

	#Write all human IDs and homolog IDs to table
	$biomart .= "write.table($org.ID, \"$input.$org.ID\")\n\n";

	print $out $biomart;
	close $out;

}

#Write R script to file $input.R
#open (my $out, ">", "$input.R") or die "Cannot write to $input.R: $!\n";
#print $out "$biomart\n";
#close $out;

#Run R
#my $Rthis = "R --vanilla --no-save < $input.R";
#system($Rthis) == 0 or die "Failed to run R: $!\n";

__END__
