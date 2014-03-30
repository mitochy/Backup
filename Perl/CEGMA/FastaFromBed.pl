#!/usr/bin/perl
use strict; use warnings; use Getopt::Std; use FAlite;
use vars qw($opt_c);
getopts("c");

my ($input) = @ARGV;
die "
usage: $0 [options: -c] <bed (cegma only)>

-c: Test if genome exists for the organism. If Input:Blahblah shows up, it's good!

" unless @ARGV;
#die if $input !~ /Chordate/i;
# Get organism name
my $org = getOrgname($input);

# Get bedfile
my ($bed, $chrominfo) = process_bed($input);
my %bed = %{$bed};

# Get fasta
my @genome = </data/genome/dna/*.fa>;
foreach my $genome (@genome) {

	# Get correct Genome from /data/genome/dna/
	my ($name1, $name2, $name3) = $genome =~ /genome\/dna\/(\w)(\w+)\_(\w+)\./;
	print "Weird name at genome $genome\n" and next unless defined($name1);
	my $name = lc($name1 . $name2 . "_" . $name3);
	my $shortname = lc("$name1$name3");
	next if not defined($name);

	# Get dna from genome
	if ($shortname eq $org) {
		print "$input: Genome is $genome\n" and exit if ($opt_c);
		open (my $out, ">", "$shortname.fa") or die "Cannot write to $shortname.fa: $!\n";
		open (my $outNot, ">", "$shortname\_NOT.fa") or die "Cannot write to $shortname\_NOT.fa: $!\n";
		print "Input: $input\nGenome: $genome\nOutput: $shortname.fa\n";

		my %fasta = %{getFasta($genome, $chrominfo)};
		print "$input: Writing output\n";
		foreach my $chr (keys %bed) {
			foreach my $name (keys %{$bed{$chr}}) {
				my $ID = $bed{$chr}{$name}{ID};
				$fasta{$ID}{def} = $name if not defined($fasta{$ID}{def});
				$fasta{$ID}{seq} = "NA" if not defined($fasta{$ID}{seq});
			}
		}
		foreach my $ID (sort {$a <=> $b} keys %fasta) {
			print $outNot "$fasta{$ID}{def}\n" and next if not defined($fasta{$ID}{seq}) or $fasta{$ID}{seq} eq "NA";
			my $def = $fasta{$ID}{def};
			my $seq = $fasta{$ID}{seq};
			print $out ">$def\n$seq\n";
		}
		close $out;
		exit;
	}
}

print "$input: Genome for org $org is NOT defined\n";

sub getOrgname {
	my ($input) = @_;
	my ($org1, $org2) = $input =~ /\w+\_\w+\.(\w)(\w+)\.bed/;
	if ($input =~ /\/\w+\_\w+\_\w+\.bed/) {
		($org1, $org2)    = $input =~ /\/(\w)\w+\_(\w+)\_\w+.bed/ if not defined($org2);
	}
	elsif ($input =~ /\/\w+\_\w+\.bed/) {
		($org1, $org2)    = $input =~ /(\w)\w+\_(\w+)\.bed/ if not defined($org2);
	}
	die "$input: Undefined organism name\n" if not defined($org1);
	my $org = lc("$org1$org2");
	return($org);
}

sub process_bed {
        my ($bedfile) = @_;
        my %bed;
	my @chr;

        open (my $in, "<", $bedfile) or die;
	my $ID;
        while (my $line = <$in>) {
                chomp($line);
                next if $line =~ /track/;
                my ($chr, $start, $end, $name, $dot, $strand) = split("\t", $line);
                $ID++;
		$bed{$chr}{$name}{ID}     = $ID;
		$bed{$chr}{$name}{start}  = $start;
		$bed{$chr}{$name}{end}    = $end;
		$bed{$chr}{$name}{strand} = $strand;
		push(@chr, $chr) if not grep(/^$chr$/, @chr);
        }
        close $in;
        return(\%bed, \@chr);
}

sub revcomp {
	my ($seq) = @_;
	$seq = reverse($seq);
	$seq =~ tr/ATGCatgc/TACGtacg/;
	return($seq);
}

sub getFasta {
	my ($genome, $chrominfo) = @_;
	my @chr = @{$chrominfo};
	my $chrnum = @chr;
	print "$input Chrom = $chrnum\n";
	my ($def, $SEQ);
	my %fasta;
	my $total = (keys %bed);
	my $count = 0;

	open (my $in, "<", $genome) or die "Cannot read from $genome: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		if ($line =~ />/) {
			if (defined($SEQ)) {
				my %tempfasta = %{getDNA(\%bed, $SEQ, $def)};
				%fasta = (%fasta, %tempfasta);
			}
			undef $SEQ;
			($def) = $line =~ />(.+)$/;
			if (not grep(/^$def$/, @chr)) {
				undef($def);
			}
		}
		else {
			if (not defined($def)) {
				next;
			}
			else {
				$SEQ .= "$line";
			}
		}
	}

	if (defined($def)) {
		my %tempfasta = %{getDNA(\%bed, $SEQ, $def)};
		%fasta = (%fasta, %tempfasta);
	}
	return(\%fasta);
}

sub getDNA {
	my ($bed, $SEQ, $def) = @_;
	my %bed = %{$bed};
	my %fasta;
	my $count = 0;
	my $total = (keys %{$bed{$def}});
	my $chr = $def;
	next if not defined($bed{$chr});
	foreach my $name (sort keys %{$bed{$chr}}) {
		my $seq;
		my $start  = $bed{$chr}{$name}{start};
		my $end    = $bed{$chr}{$name}{end};
		my $strand = $bed{$chr}{$name}{strand};
		my $ID     = $bed{$chr}{$name}{ID};
		$count++;
		if ($start < 0 and $end < 0) {
			print "Malformed BED entry at $bed{$ID}{name} (start $start and end $end less than 0)\n";
			next;
		}
		if ($start > length($SEQ) and $end > length($SEQ)) {
			print "Malformed BED entry at $bed{$ID}{name} (start $start and end $end more than length sequence)\n";
			next;
		}
		if ($start < 0) {
			for (my $i = $start; $i < 0; $i++) {
				$seq .= "N";
			}
			if ($end > length($SEQ)) {
				$seq .= $SEQ;
				for (my $i = length($SEQ); $i < $end; $i++) {
					$seq .= "N";
				}
			}
			else {
				$seq .= substr($SEQ, 0, $end);
			}
		}
		else {
			if ($end > length($SEQ)) {
				$seq .= substr($SEQ, $start, length($SEQ)-$start);
				for (my $i = length($SEQ); $i < $end; $i++) {
					$seq .= "N";
				}
			}
			else {
				$seq .= substr($SEQ, $start, $end-$start);
			}
		
		}
		print "Strand for CADAFUAG00006548 is $strand\n" if $name =~ /CADAFUAG00006548/i;
		print "Sequence before = $seq\n" if $name =~ /CADAFUAG00006548/i;
		$seq = revcomp($seq) if $strand eq "-";
		print "Sequence now = $seq\n" if $name =~ /CADAFUAG00006548/i;
		$fasta{$ID}{def} = $name;
		$fasta{$ID}{seq} = $seq;
	}
	return(\%fasta);
}
