#!/usr/bin/perl

use strict; use warnings; use Getopt::Std; use mitochy;
use vars qw($opt_c);
getopts("c");

my (@input) = @ARGV;

die "
usage: $0 [option: -c] <input>

-c: checksum all fasta (.fa) files in genome folder (/data/genome/)

Input: 
1. Chordate
2. Metazoa
3. Fungi
4. Plant
5. Protists
6. Bacteria
\n" if (not defined($opt_c) and (@ARGV == 0));

my %sum = %{getCurrentChecksum($opt_c)};

my $chordates	= "ftp://ftp.ensembl.org/pub/";
my $metazoa	= "ftp://ftp.ensemblgenomes.org/pub/current/metazoa/"; 
my $fungi 	= "ftp://ftp.ensemblgenomes.org/pub/current/fungi/";
my $plants	= "ftp://ftp.ensemblgenomes.org/pub/current/plants/";
my $protists	= "ftp://ftp.ensemblgenomes.org/pub/current/protists/";
my $bacteria	= "ftp://ftp.ensemblgenomes.org/pub/current/bacteria/";

my $fa   = "fasta/";
my $faC  = "current_fasta/";
my $gtf  = "gtf/";
my $gtfC = "current_gtf/";
my $dna  = "dna";
my $pep  = "pep";

# DNA: */dna/*.dna.toplevel.fa.gz
# Checksum: */dna/CHECKSUMS
# PEP: */pep/*.pep.all.fa.gz
# Checksum: */pep/CHECKSUMS

my @list;
for (my $i = 0; $i < @input; $i++) {
	my $input = $input[$i];
	push(@list, $chordates) if $input[$i] =~ /chor/i;
	push(@list, $metazoa) 	if $input[$i] =~ /meta/i;
	push(@list, $fungi) 	if $input[$i] =~ /fung/i;
	push(@list, $plants) 	if $input[$i] =~ /plan/i;
	push(@list, $protists) 	if $input[$i] =~ /prot/i;
	push(@list, $bacteria) 	if $input[$i] =~ /bact/i;
}

die "usage: $0 <input [chordate | metazoa | fungi | plants | protists | bacteria]>\n" if @list == 0;

my $time = scalar localtime(time()); # adjust time zone to EST

my $genome = "/data/genome/";
open (my $out, ">>", "$genome/update.txt") or die "Cannot write to $genome/update.txt: $!\n";
print $out "#TIME $time\n";

my %data;
for (my $h = 0; $h < @list; $h++) {
	my $list  = $list[$h];
	my $input = $input[$h];
	print $out "#KINGDOM $list\n";
	my $orgDNA = $list =~ /ensembl.org/ ? "$list$faC"  : "$list$fa";
	my $orgPEP = $list =~ /ensembl.org/ ? "$list$faC"  : "$list$fa";
	my $orgGTF = $list =~ /ensembl.org/ ? "$list$gtfC" : "$list$gtf";
	print "

DEBUG for $input:
Main = $list

DNA  = $orgDNA
PEP  = $orgPEP
GTF  = $orgGTF

";

	#DNA
	print "Curl $orgDNA\n";
	my @orgDNACurl = `curl $orgDNA`;
	for (my $i = 0; $i < @orgDNACurl; $i++) {
		chomp($orgDNACurl[$i]);
		my ($org) = $orgDNACurl[$i] =~ / (\w+_\w+)$/i;
		chomp($org);

		next if $org =~ /ancestral/;
		if ($list =~ /ensembl.org/) {
			next if $org =~ /saccharomyces_cerevisiae/;
			next if $org =~ /drosophila_melanogaster/;
			next if $org =~ /caenorhabditis_elegans/;
		}

		$sum{$org}{DNA} = "NA" if not defined($sum{$org}{DNA});
		my $sum = $sum{$org}{DNA};
		$data{$org}{DNA}{CHK} = getChecksum("$orgDNA$org/$dna/CHECKSUMS", "dna");
		if (not defined($sum{$org}{DNA}) or $data{$org}{DNA}{CHK} ne $sum{$org}{DNA}) {
			my $sum = defined($sum{$org}{DNA}) ? $sum{$org}{DNA} : "UNDEF";
			print "CURRENT DNA SUM: $sum NE $data{$org}{DNA}{CHK}\n";
			$data{$org}{DNA}{URL} = "$orgDNA$org/$dna/*.dna.toplevel.fa.gz";
		}
	}

	# PEP
	print "Curl $orgPEP\n";
	my @orgPEPCurl = `curl $orgPEP`;
	for (my $i = 0; $i < @orgPEPCurl; $i++) {
		chomp($orgPEPCurl[$i]);
		my ($org) = $orgPEPCurl[$i] =~ / (\w+_\w+)$/i;
		chomp($org);

		next if $org =~ /ancestral/;
		if ($list =~ /ensembl.org/) {
			next if $org =~ /saccharomyces_cerevisiae/;
			next if $org =~ /drosophila_melanogaster/;
			next if $org =~ /caenorhabditis_elegans/;
		}

		$sum{$org}{PEP} = "NA" if not defined($sum{$org}{PEP});
		my $sum = $sum{$org}{PEP};
		$data{$org}{PEP}{CHK} = getChecksum("$orgPEP$org/$pep/CHECKSUMS", "pep");
		if (not defined($sum{$org}{PEP}) or $data{$org}{PEP}{CHK} ne $sum{$org}{PEP}) {
			my $sum = defined($sum{$org}{PEP}) ? $sum{$org}{PEP} : "UNDEF";
			print "CURRENT PEP SUM: $sum NE $data{$org}{PEP}{CHK}\n";
			$data{$org}{PEP}{URL} = "$orgPEP$org/$pep/*pep.all.fa.gz";
		}
	}

	# GTF
	print "Curl $orgGTF\n";
	my @orgGTFCurl = `curl $orgGTF`;
	for (my $i = 0; $i < @orgGTFCurl; $i++) {
		chomp($orgGTFCurl[$i]);
		my ($org) = $orgGTFCurl[$i] =~ / (\w+_\w+)$/i;
		chomp($org);

		next if $org =~ /ancestral/;
		if ($list =~ /ensembl.org/) {
			next if $org =~ /saccharomyces_cerevisiae/;
			next if $org =~ /drosophila_melanogaster/;
			next if $org =~ /caenorhabditis_elegans/;
		}

		$sum{$org}{GTF} = "NA" if not defined($sum{$org}{GTF});
		my $sum = $sum{$org}{GTF};
		$data{$org}{GTF}{CHK} = getChecksum("$orgGTF/$org/CHECKSUMS", "gtf");
		if ($data{$org}{GTF}{CHK} ne $sum{$org}{GTF}) {
			print "CURRENT GTF SUM: $sum NE $data{$org}{GTF}{CHK}\n";
			$data{$org}{GTF}{URL} = "$orgGTF$org/*gtf.gz";

		}
	}
}

print "\n\n";
print $out "#DNA\n";
foreach my $org (keys %data) {
	my $def = defined($data{$org}{DNA}{URL}) ? $data{$org}{DNA}{URL} : "NA";
	print "DNA $org: $def\t$data{$org}{DNA}{CHK} = current $sum{$org}{DNA}?\n";
	print $out "wget $def\n" if $def ne "NA";
}
print $out "#PEP\n";
foreach my $org (keys %data) {
	my $def = defined($data{$org}{PEP}{URL}) ? $data{$org}{PEP}{URL} : "NA";
	print "PEP $org: $def\t$data{$org}{PEP}{CHK} = current $sum{$org}{PEP}?\n";
	print $out "wget $def\n" if $def ne "NA";
}
print $out "#GTF\n";
foreach my $org (keys %data) {
	my $def = defined($data{$org}{GTF}{URL}) ? $data{$org}{GTF}{URL} : "NA";
	print "GTF $org: $def\t$data{$org}{GTF}{CHK} = current $sum{$org}{GTF}?\n";
	print $out "wget $def\n" if $def ne "NA";
}
print $out "#END\n\n";

sub getCurrentChecksum {
	my ($option) = @_;

	my $genome = "/data/genome/";
	my %sum;

	if ($option) {
		if ($option ne "NEW") {
			print "Are you sure to overwrite $genome/CURRENT_CHECKSUM and create new one (might take a while)? (ENTER to continue, CTRL+C to cancel)\n";
			<STDIN>;
		}
		my @dna = <$genome/dna/*.fa.gz>;
		my @pep = <$genome/pep/*.fa.gz>;
		my @gtf = <$genome/gtf/*.gtf.gz>;

		getNewChecksum(\@dna, "dna");
		getNewChecksum(\@pep, "pep");
		getNewChecksum(\@gtf, "gtf");

		exit if ($option eq "NEW");
	}


	#DNA
	open (my $dnaIn, "<", "$genome/dna/CURRENT_CHECKSUMS") or die "Cannot read from $genome/dna/CURRENT_CHECKSUMS: $!\n";
	while (my $line = <$dnaIn>) {
		chomp($line);
		my ($org, $sum) = split("\t", $line);
		$sum =~ s/\s+/ /;
		$sum{$org}{DNA} = $sum;
	}
	close $dnaIn;
	#PEP
	open (my $pepIn, "<", "$genome/pep/CURRENT_CHECKSUMS") or die "Cannot read from $genome/pep/CURRENT_CHECKSUMS: $!\n";
	while (my $line = <$pepIn>) {
		chomp($line);
		my ($org, $sum) = split("\t", $line);
		$sum =~ s/\s+/ /;
		$sum{$org}{PEP} = $sum;
	}
	close $pepIn;
	#GTF
	open (my $gtfIn, "<", "$genome/gtf/CURRENT_CHECKSUMS") or die "Cannot read from $genome/gtf/CURRENT_CHECKSUMS: $!\n";
	while (my $line = <$gtfIn>) {
		chomp($line);
		my ($org, $sum) = split("\t", $line);
		$sum =~ s/\s+/ /;
		$sum{$org}{GTF} = $sum;
	}
	close $gtfIn;
	return(\%sum);
}

sub getNewChecksum {
	my ($arr, $type) = @_;
	my @arr = @{$arr};
	my $genome = "/data/genome/";
	open (my $out, ">", "$genome/$type/CURRENT_CHECKSUMS") or die "Cannot write to $genome/$type/CURRENT_CHECKSUMS: $!\n";
	for (my $i = 0; $i < @arr; $i++) {
		print "Checksum on $arr[$i]\n";
		my $name = lc(mitochy::getFilename($arr[$i]));
		die "Undefined organism name at $arr[$i] for $genome/$type/CURRENT_CHECKSUMS\n" unless defined($name) and $name !~ /^$/;
		my $CHECKSUM = `sum $arr[$i]`;
		chomp($CHECKSUM);
		print $out "$name\t$CHECKSUM\n";
	}
	close $out;
}
sub getChecksum {
	my ($Curl, $type) = @_;

	print "curl $Curl\n";
	my @Curl = `curl $Curl`;
	for (my $i = 0; $i < @Curl; $i++) {
		chomp($Curl[$i]);
		my ($num1, $num2) = $Curl[$i] =~ /^(\d+)\s+(\d+)\s+/;
		if ($type =~ /dna/ and $Curl[$i] =~ /dna.toplevel/) {
			return("$num1 $num2");
		}
		elsif ($type =~ /pep/ and $Curl[$i] =~ /pep/) {
			return("$num1 $num2");
		}
		if ($type =~ /gtf/ and $Curl[$i] =~ /gtf/) {
			return("$num1 $num2");
		}
	}
	print "\n\nFATAL ERROR: Cannot determine checksum at link $Curl type $type\n\n";
}
__END__


# DNA: */dna/*.dna.toplevel.fa.gz
# Checksum: */dna/CHECKSUMS
# PEP: */pep/*.pep.all.fa.gz
# Checksum: */pep/CHECKSUMS
