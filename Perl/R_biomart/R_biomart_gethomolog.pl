#!/usr/bin/perl
# This script is to get human homolog ID from all organism on biomart ensembl 
# and save it to $org.ID

use strict; use warnings; use mitochy; use FAlite;

die "usage: R_biomart_gethumanhomolog.pl <ENSEMBL_GENE_ID> <mart>
\#Ensembl ID format:
  ENSG000000001
  ENSG000000002
  etc

\#MART:
  - ensembl (use hsapiens as core)
  - plants (use athaliana as core)
  - fungi (use scerevisiae as core)
  - metazoa (use dmelanogaster as core)
  - protists (use ddiscoideum as core)
" unless @ARGV == 2;
my ($input, $mart) = @ARGV;
my @datasets = mitochy::get_biomart_dataset($mart);

#Processing gene ID that you want
my $geneid;
open (my $in2, "<", $input) or die "Cannot read from $input: $!\n";
while (my $line = <$in2>) {
	chomp($line);
	$geneid .= "\"$line\", " if $line !~ /^\"/;
	$geneid .= "$line, "     if $line =~ /^\"/;
}
close $in2;

#Load library biomaRt
my $biomart_core = "library(biomaRt)\n\n";

my $marts;
$marts = "ensembl" if $mart eq "ensembl";
$marts = "$mart\_mart\_19" if $mart ne "ensembl";
#Load human mart
$biomart_core .= "core.mart <-useMart(\"$marts\", dataset = \"hsapiens_gene_ensembl\")\n" if $mart eq "ensembl";
#$biomart_core .= "core.mart <-useMart(\"ensembl\", dataset = \"hsapiens_gene_ensembl\")\n" if $mart eq "ensembl"; #Does not work bug at ensembl
$biomart_core .= "core.mart <-useMart(\"$marts\", dataset = \"athaliana_eg_gene\")\n" if $mart eq "plants";
$biomart_core .= "core.mart <-useMart(\"$marts\", dataset = \"scerevisiae_eg_gene\")\n" if $mart eq "fungi";
$biomart_core .= "core.mart <-useMart(\"$marts\", dataset = \"dmelanogaster_eg_gene\")\n" if $mart eq "metazoa";
$biomart_core .= "core.mart <-useMart(\"$marts\", dataset = \"ddiscoideum_eg_gene\")\n" if $mart eq "protists";

#Load requested human gene ID
$biomart_core .= "core.geneid <- c($geneid)\n\n";
$biomart_core =~ s/, \)/\)/i;

#Make R script for each dataset
#Get homolog gene ID of all ensembl organism for each human gene ID
#Get sequence for each organism gene ID
foreach my $datasets (@datasets) {
	#next if $datasets =~ /hsapiens/i;
	my ($org) = $datasets =~ /^(\w+)_gene_ensembl$/i;
	($org) = $datasets =~ /^(\w+)_eg_gene$/i if not defined($org);
	die "$datasets\norganism not defined (doesn't match org_gene_ensembl or org_eg_gene?)\n" unless defined($org);
	
	my $biomart = $biomart_core;

	#Get Mart of each datasets
	$biomart .= "$org.mart <- useMart(\"$marts\", dataset = \"$datasets\")\n";# if $marts ne "ensembl";
	#$biomart .= "$org.mart <- useMart(\"ENSEMBL_MART_ENSEMBL\", dataset = \"$datasets\", host=\"jul2012.archive.ensembl.org\")\n" if $marts eq "ensembl"; #delete this when bug cleared

	#Get ID for each dataset homolog to human
	my $identity_name = "$org\_eg_homolog_perc_id" if $mart ne "ensembl";
	$identity_name    = "$org\_homolog_perc_id" if $mart eq "ensembl";
	$biomart .= "$org.ID <- getLDS(attributes=c(\"ensembl_gene_id\",\"$identity_name\"), filters = \"ensembl_gene_id\", values = core.geneid, mart = core.mart, attributesL = c(\"ensembl_gene_id\"), martL = $org.mart)\n";

	#Write all human IDs and homolog IDs to table
	$biomart .= "write.table($org.ID, \"$input.$org.ID\")\n\n";

	#Write R script to file $input.R
	open (my $out, ">", "$input.$org.homolog.R") or die "Cannot write to $input.$org.homolog.R: $!\n";
	print $out "$biomart\n";
	close $out;
}


#Run R
#my $Rthis = "run_Rscript.pl *.homolog.R";
#system($Rthis);# "Failed to run R: $!\n";

__END__
