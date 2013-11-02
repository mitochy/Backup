#!/usr/bin/perl
# This script is to get sequence from requested ID from biomart ensembl 
# Then download the gene plus 500bp upstream of promoter

use strict; use warnings; use mitochy; use FAlite;

die "usage: R_biomart_getdesc.pl <description> <R1 to run R>\n" unless @ARGV;
my ($desc, $opt) = @ARGV;
my @datasets = mitochy::get_biomart_dataset();

my @srna_list = qw(S16 16S S18 18S);
#Make R script for each dataset
#Get homolog gene ID of all ensembl organism for each human gene ID
#Get sequence for each organism gene ID

my @failures;
foreach my $datasets (@datasets) {

	print "processing datasets and getting dataset of description from $datasets\n";
	my ($org) = $datasets =~ /^(\w+)_gene_ensembl$/i;
	die "$datasets\norganism not defined (doesn't match org_gene_ensembl?)\n" unless defined($org);
	
	#Get Mart of each datasets
	my $biomart_getdesc .= "library('biomaRt')\n$org.mart <- useMart(\"ensembl\", dataset = \"$datasets\")\n";

	#Get ID for each dataset homolog to human
	$biomart_getdesc .= "$org.desc <- getBM(attributes=c(\"ensembl_gene_id\", \"description\"), mart=$org.mart)\n";

	#Write all human IDs and homolog IDs to table
	$biomart_getdesc .= "write.table($org.desc, \"$org.desc\")\n\n";

	#Write R script to file $input.id.R
	open (my $out, ">", "$org.desc.R") or die "Cannot write to $org.desc.R: $!\n";
	print $out "$biomart_getdesc\n";
	close $out;
	
	#Run R
	if (defined($opt) and $opt =~ /^R1$/) {
		my $Rthis = "R --vanilla --no-save < $org.desc.R";
		system($Rthis) == 0 or die "Failed to run R: $!\n";
	}
	
	#next if (defined($opt) and $opt =~ /^R1$/);

	my @srna;
	open (my $in, "<", "$org.desc") or die "Cannot read from $org.desc: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		$line =~ s/\" \"/\"\t\"/ig;
		my @arr = split("\t", $line);
		die "wrong file read\n" if not defined($arr[1]);
		#print "$arr[2]\n";
		foreach my $srna_list (@srna_list) {
			push (@srna, $arr[1]) if $arr[2] =~ /$srna_list/i;
		}
	}
	close $in;
	print ">>>>>>>Warning: srna not exist!\n" unless @srna;
	#Get Mart of each datasets
	my $biomart_getseq .= "library(biomaRt)\n$org.mart <- useMart(\"ensembl\", dataset = \"$datasets\")\n";
		
	#Get sequence for each ID of gene
	$biomart_getseq .= "$org.seq <- c(";

	foreach my $srna (@srna) {
		$biomart_getseq .= "$srna,";
	}
	$biomart_getseq .= ")\n";
	$biomart_getseq =~ s/,\)/\)/i;

	$biomart_getseq .= "$org.seq <- getSequence(id = $org.seq, type = \"ensembl_gene_id\", seqType = \"transcript_exon_intron\", mart=$org.mart)\n";

	#Write all the sequence to fast
	$biomart_getseq .= "\n\nexportFASTA($org.seq,file=\"$org.seq.fa\")\n";

	open (my $out2, ">", "$org.seq.R") or die "Cannot write to $org.seq.R: $!\n";
	print $out2 "$biomart_getseq";
	close $out2;

	if (defined($opt) and $opt =~ /^R1$/) {
		my $Rthis = "R --vanilla --no-save < $org.seq.R";
		system($Rthis) == 0 or push(@failures, "$org.seq.R");
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
__END__

