#!/usr/bin/perl
# This script is to get sequence from requested ID from biomart ensembl 
# Then download the gene plus 500bp upstream of promoter

use strict; use warnings; use mitochy; use FAlite;

die "usage: R_biomart_gethumanhomolog.pl human_geneID_list.ssv <type (cdna, peptide, gene_flank, 3utr, 5utr, genomic, transcript_exon_intron)> <upstream need to get in bp> <R1 = get ID, R2 = get sequence>\n" unless @ARGV;
my ($input, $type, $upstream, $opt) = @ARGV;
my @datasets = mitochy::get_biomart_dataset();
$type = "transcript_exon_intron" unless defined($type);
$upstream = 500 if not defined($upstream);

#Processing gene ID that you want
my $geneid;
open (my $in2, "<", $input) or die "1. Cannot read from $input: $!\n";
while (my $line = <$in2>) {
	chomp($line);
	$geneid .= "\"$line\", " if $line !~ /^\"/;
	$geneid .= "$line, "     if $line =~ /^\"/;
}
close $in2;

#Load library biomaRt
my $biomart_getid = "library(biomaRt)\n\n";

#Load human mart
$biomart_getid .= "hsapiens <-useMart(\"ensembl\", dataset = \"hsapiens_gene_ensembl\")\n";

#Load requested human gene ID
$biomart_getid .= "hsapiens.geneid <- c($geneid)\n\n";
$biomart_getid =~ s/, \)/\)/i;

#Make R script for each dataset
#Get homolog gene ID of all ensembl organism for each human gene ID
#Get sequence for each organism gene ID


foreach my $datasets (@datasets) {
	print "processing datasets and making .id of homologs $datasets\n";
	my ($org) = $datasets =~ /^(\w+)_gene_ensembl$/i;
	die "$datasets\norganism not defined (doesn't match org_gene_ensembl?)\n" unless defined($org);
	
	#Get Mart of each datasets
	$biomart_getid .= "$org.mart <- useMart(\"ensembl\", dataset = \"$datasets\")\n";

	#Get ID for each dataset homolog to human
	$biomart_getid .= "$org.ID <- getLDS(attributes=c(\"ensembl_gene_id\"), filters = \"ensembl_gene_id\", values = hsapiens.geneid, mart = hsapiens, attributesL = c(\"ensembl_gene_id\"), martL = $org.mart)\n";

	#Write all human IDs and homolog IDs to table
	$biomart_getid .= "write.table($org.ID, \"$input.$org.ID\")\n\n";

}

if (defined($opt) and $opt =~ /^R1$/) {
#Write R script to file $input.id.R
	open (my $out, ">", "$input.id.R") or die "Cannot write to $input.id.R: $!\n";
	print $out "$biomart_getid\n";
	close $out;

	print "opt = $opt\n";
	#Run R
	my $Rthis = "R --vanilla --no-save < $input.id.R";
	system($Rthis) == 0 or die "Failed to run R: $!\n";
}

############GET SEQUENCE############

#Now get hash of IDs
#ID homolog taken is the first one. I'm skipping the 2nd one.
my %homolog;

foreach my $datasets (@datasets) {
	my ($org) = $datasets =~ /^(\w+)_gene_ensembl$/i;
	die "$datasets\norganism not defined (doesn't match org_gene_ensembl?)\n" unless defined($org);
	my $switch = 0;
	open (my $in, "<", "$input.$org.ID.new.ID") or die "Cannot read from $input.$org.ID.new.ID\n";
	while (my $line = <$in>) {
		chomp($line);
		next if $line =~ /^\"V1\"/i;
		my @arr = split(" ", $line);
		next if exists ($homolog{$org}{$arr[1]}{'id'});
		$homolog{$org}{$arr[1]}{'id'} = $arr[2];
	}
}

my $biomart_getseq = "library(biomaRt)\n\n";
my @failures;
foreach my $org (sort keys %homolog) {
	my $biomart_org_getseq = $biomart_getseq;

	#Get Mart of each datasets
	$biomart_org_getseq .= "$org.mart <- useMart(\"ensembl\", dataset = \"$org\_gene_ensembl\")\n";

	#Get sequence for each ID of gene
	$biomart_org_getseq .= "$org.ID <- c(";

	foreach my $human_id (sort keys %{$homolog{$org}}) {
		$biomart_org_getseq .= "$homolog{$org}{$human_id}{'id'},";
		#print "$human_id\t$org\t$homolog{$org}{$human_id}{'id'}\n";
	}
	
	#Fix end of id
	$biomart_org_getseq .= ")\n";
	$biomart_org_getseq =~ s/,\)/\)/i;

	#Get real sequence of each ID
	$biomart_org_getseq .= "$org.up.seq <- getSequence(id = $org.ID, type = \"ensembl_gene_id\", seqType = \"$type\", upstream=$upstream, mart=$org.mart)\n";

	#Write all the sequence to fast
	$biomart_org_getseq .= "\n\nexportFASTA($org.up.seq,file=\"$org.up.seq.fa\")\n";

	open (my $out2, ">", "$input.$org.seq.R") or die "Cannot write to $input.$org.seq.R: $!\n";
	print $out2 "$biomart_org_getseq";
	close $out2;

	if (defined($opt) and $opt =~ /^R2$/) {
		my $Rthis = "R --vanilla --no-save < $input.$org.seq.R";
		system($Rthis) == 0 or push(@failures, "$input.$org.seq.R");
	}
}

print "Failed to run:\n";
foreach my $failed (@failures) {
	print "$failed\n";
}

print "Trying to download the 2nd time...\n";
my @failure2;
foreach my $failed (@failures) {
	print "Trying $failed...\n";
	my $Rthis = "R --vanilla --no-save < $failed";
	system($Rthis) == 0 or push (@failure2, $failed);
}

print "Trying to download the 3rd time...\n";
my @failure3;
foreach my $failed (@failure2) {
        print "Trying $failed...\n";
        my $Rthis = "R --vanilla --no-save < $failed";
        system($Rthis) == 0 or push (@failure3, $failed);
}

print "Failed download after 3 tries:\n";
foreach my $failed (@failure3) {
	print "$failed\n";
}
#print "$biomart_getseq\n";

#Write R script to file $input.seq.R
#open (my $out2, ">", "$input.seq.R") or die "Cannot write to $input.seq.R: $!\n";
#print $out2 "$biomart_getseq\n";
#close $out2;

#Run R
#if (defined($opt) and $opt =~ /^R2$/) {
#	my $Rthis = "R --vanilla --no-save < $input.seq.R";
#	system($Rthis) == 0 or die "Failed to run R: $!\n";
#}
__END__
