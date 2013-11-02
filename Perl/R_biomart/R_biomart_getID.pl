#!/usr/bin/perl
# This script is to get sequence from requested ID from biomart ensembl 
# Then download the gene plus 500bp upstream of promoter

use strict; use warnings; use mitochy; use FAlite;

die "usage: R_biomart_getID <leader.id> <ensembl database (print_database for list) def: ensembl> <1 organism list file>\n" unless @ARGV;
my ($input, $data, $database) = @ARGV;
my ($org) = $input =~ /^.+\/(\w+)\.\d*\.*id$/i;
($org) = $input =~ /^(\w+)\.\d*\.*id$/i if not defined($org);
die "leader organism not defined!\n" unless defined($org);
$database = "/home/mitochi/Desktop/Work/newcegma/eukaryotes.dat" if not defined($database);

$data = "ensembl" if not defined($data);
print_database() if $data =~ /print_database/i;

my $leader;
my %datasets = process_database($database);
foreach my $dataset (sort keys %datasets) {
	$leader = $dataset if $dataset =~ /$org/i;
}
die "leader organism not found in dataset!\n" unless defined($leader);

#Processing gene ID that you want
my $geneid;
open (my $in2, "<", $input) or die "Cannot read from $input: $!\n";
while (my $line = <$in2>) {
	chomp($line);
	$geneid .= "\"$line\", " if $line !~ /^\"/;
	$geneid .= "$line, "     if $line =~ /^\"/;
}
close $in2;

print "organism = $org\n";
print "leader = $leader\n";
print "database = $data\n";

#Make R script for each dataset
#Get homolog gene ID of all ensembl organism for each human gene ID
#Get sequence for each organism gene ID

my @failures;

for (my $i = 0; $i < @{$datasets{$leader}}; $i++) {
	my $datasets = $datasets{$leader}[$i];
	
	my $biomart_getid = "library(biomaRt)\n\n";

	#Load human mart
	#$biomart_getid .= "leader <-useMart(\"$data\", dataset = \"$leader\")\n";
	$biomart_getid .= "leader <-useMart(\"ENSEMBL_MART_ENSEMBL\", \"$leader\", host=\"feb2012.archive.ensembl.org\")\n";

	#Load requested human gene ID
	$biomart_getid .= "leader.geneid <- c($geneid)\n\n";
	$biomart_getid =~ s/, \)/\)/i;

	print "processing datasets and making .id of homologs $datasets\n";
	my ($org) = $datasets =~ /^(\w+)_gene_ensembl$/i;
	($org) = $datasets =~ /^(\w+)_eg_gene$/i if not defined($org);

	die "processing $datasets\norganism not defined (doesn't match org_gene_ensembl or org_eg_gene?)\n" unless defined($org);
	
	#Get Mart of each datasets
	#$biomart_getid .= "$org.mart <- useMart(\"$data\", dataset = \"$datasets\")\n";
	$biomart_getid .= "$org.mart <- useMart(\"ENSEMBL_MART_ENSEMBL\", \"$datasets\", \"feb2012.archive.ensemble.org\")\n";

	#Get ID for each dataset homolog to human
	$biomart_getid .= "$org.ID <- getLDS(attributes=c(\"ensembl_transcript_id\"), filters = \"ensembl_transcript_id\", values = leader.geneid, mart = leader, attributesL = c(\"ensembl_gene_id\", \"ensembl_transcript_id\", \"chromosome_name\", \"start_position\", \"end_position\", \"strand\"), martL = $org.mart)\n";

	#Write all human IDs and homolog IDs to table
	$biomart_getid .= "write.table($org.ID, \"$input.$org.ID\")\n\n";

	#Write R script to file $input.id.R
	open (my $out, ">", "$input.$org.R") or die "Cannot write to $input.$org.R: $!\n";
	print $out "$biomart_getid\n";
	close $out;

	#Run R
	my $Rthis = "R --vanilla --no-save < $input.$org.R";
	system($Rthis) == 0 or push(@failures, $Rthis);
}

print "Failed to run:\n";
foreach my $fail (@failures) {
	print "$fail\n";
}

sub print_database {
	die "\n\ndatabase\n\tmetazoa_mart_14\n\tplants_mart_14\n\tprotists_mart_14\n\tfungi_mart_14\n\n";
	
}

sub process_database {
	my ($database) = @_;
        open (my $in, "<", $database) or die "Cannot read from $database: $!\n";
        my %dataset;
        my $leader;
        while (my $line = <$in>) {
                chomp($line);
                if ($line =~ />/) {
                        $leader = $line;
                        $leader =~ s/>//ig;
			next;
                }
                push(@{$dataset{$leader}}, $line);
        }
        return(%dataset);
}

