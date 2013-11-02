#!/usr/bin/perl
# IT IS HIGHLY ADVISABLE TO MAKE SURE EXON OF EACH GENE ARE GROUPED NEXT TO EACH OTHER
#
use strict; use warnings;

my ($input, $output) = @ARGV;
die "usage: $0 <gtf from Ensembl> <output name (will create two files: bed and gtf)>\nWARNING: MAKE SURE EXON ARE GROUPED NEXT TO EACH OTHER\n" unless @ARGV == 2;
my %bed;
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
open (my $out, ">", "$output\.bed") or die "Cannot write to $output.bed: $!\n";
open (my $out2, ">", "$output\.gtf") or die "Cannot write to $output.gtf: $!\n";
my $curr_id = "INIT";
my $curr_chr;
my $curr_val;
my $curr_strand;
my %curr_ex;
while (my $line = <$in>) {
	chomp($line);
	my ($chr, $junk0, $feature, $start, $end, $dot, $strand, $dot2, $name) = split("\t", $line);
	next if $feature ne "exon";
	my @name = split(";", $name);
	my $gene_id;
	my $type;
	foreach my $names (@name) {
		$names =~ s/^\s{1,10}//;
		($gene_id) = $names =~ /^gene_id "(.+)"$/ if $names =~ /^gene_id/;
		($type)    = $names =~ /^gene_biotype "(.+)"$/ if $names =~ /^gene_biotype/;
	}
	die "Undef type at $line\n" if not defined($type);
	die "Undef gene_id at $line\n" if not defined($gene_id);
	die "Undef gene_id at $line\n" if $gene_id =~ /^$/;
	my $chr_type;
	if ($chr =~ /^\d+$/) {
		$chr_type = "numeric";
	}
	else {
		$chr_type = "alphabet";
	}
	die if not defined($chr_type);

	if ($curr_id ne $gene_id and $curr_id ne "INIT") {
		my %exon = %curr_ex;
		%curr_ex = ();
		my %ignore;

		#print "$curr_id\n" if $curr_id eq "ENSG00000237613";
		while (1) {
			my $check = 0;
			foreach my $start (sort {$a <=> $b} keys %exon) {
				my $end = $exon{$start};
				foreach my $start2  (sort {$a <=> $b} keys %exon) {
					my $end2 = $exon{$start2};
					next if $start == $start2 and $end == $end2;
					#print "Checking start $start end $end vs start2 $start2 end2 $end2\n";# if $curr_id eq "ENSG00000237613";
					if (between($start, $end, $start2, $end2) == 1) {
						$check = 1;
						my $newstart = $start < $start2 ? $start : $start2 ;
						my $newend   = $end   > $end2   ? $end   : $end2   ;
						delete($exon{$start});
						delete($exon{$start2});
						#print "Overlap! Deleted and replaced by $newstart and $newend\n";# if $curr_id eq "ENSG00000237613";
						$exon{$newstart} = $newend;
						last;
					}
					
				}
				last if $check == 1;
			}
			last if $check == 0;
		}
		my $curr_exon = 0;
		foreach my $start2 (sort {$a <=> $b} keys %exon) {
			my $end2 = $exon{$start2};
			$bed{$chr_type}{$curr_chr}{$curr_id}{start} = $start2 if not defined($bed{$chr_type}{$curr_chr}{$curr_id}{start}) or $start2 < $bed{$chr_type}{$curr_chr}{$curr_id}{start};
			$bed{$chr_type}{$curr_chr}{$curr_id}{exon}{$curr_exon}{start}  = $start2      ;
			$bed{$chr_type}{$curr_chr}{$curr_id}{exon}{$curr_exon}{end}    = $end2        ;
			$bed{$chr_type}{$curr_chr}{$curr_id}{exon}{$curr_exon}{val}    = $curr_val    ;
			$bed{$chr_type}{$curr_chr}{$curr_id}{exon}{$curr_exon}{strand} = $curr_strand ;
			$curr_exon++;
		}
	}
	$curr_id = $gene_id;
	if (defined($curr_ex{$start})) {
		$curr_ex{$start} = $end if $end > $curr_ex{$start};
		
	}
	else {
		$curr_ex{$start} = $end;
	}
	$curr_chr = $chr;
	$curr_val    = $type   ;
	$curr_strand = $strand ;
}
close $in;
#my $count = 0;
foreach my $chr (sort {$bed{numeric}{$a} <=> $bed{numeric}{$b}} keys %{$bed{numeric}}) {
	foreach my $gene_id (sort {$bed{numeric}{$chr}{$a}{start} <=> $bed{numeric}{$chr}{$b}{start}} keys %{$bed{numeric}{$chr}}) {
		foreach my $exon_num (sort {$a <=> $b} keys %{$bed{numeric}{$chr}{$gene_id}{exon}}) {
			my $start   = $bed{numeric}{$chr}{$gene_id}{exon}{$exon_num}{start};
			my $end     = $bed{numeric}{$chr}{$gene_id}{exon}{$exon_num}{end};
			my $val     = $bed{numeric}{$chr}{$gene_id}{exon}{$exon_num}{val};
			my $strand  = $bed{numeric}{$chr}{$gene_id}{exon}{$exon_num}{strand};
			print $out "$chr\t$start\t$end\t$gene_id\t$val\t$strand\n";
			print $out2 "$chr\thg19_ensembl_$val\texon\t$start\t$end\t0.000000\t$strand\t.\tgene_id \"$gene_id\"\;\n";
			#$count++ if $val eq "protein_coding";
		}
	}
}
foreach my $chr (sort {$bed{alphabet}{$a} cmp $bed{alphabet}{$b}} keys %{$bed{alphabet}}) {
	foreach my $gene_id (sort {$bed{alphabet}{$chr}{$a}{start} <=> $bed{alphabet}{$chr}{$b}{start}} keys %{$bed{alphabet}{$chr}}) {
		foreach my $exon_num (sort {$a <=> $b} keys %{$bed{alphabet}{$chr}{$gene_id}{exon}}) {
			my $start   = $bed{alphabet}{$chr}{$gene_id}{exon}{$exon_num}{start};
			my $end     = $bed{alphabet}{$chr}{$gene_id}{exon}{$exon_num}{end};
			my $val     = $bed{alphabet}{$chr}{$gene_id}{exon}{$exon_num}{val};
			my $strand  = $bed{alphabet}{$chr}{$gene_id}{exon}{$exon_num}{strand};
			next if $chr ne "X" and $chr ne "Y";
			print $out "$chr\t$start\t$end\t$gene_id\t$val\t$strand\n";
			print $out2 "$chr\thg19_ensembl_$val\texon\t$start\t$end\t0.000000\t$strand\t.\tgene_id \"$gene_id\"\;\n";
			#$count++ if $val eq "protein_coding";
		}
	}
}
close $out;
close $out2;
sub between {
        my ($start1, $end1, $start2, $end2) = @_;
        return 1 if $start1 >= $start2 and $start1 <= $end2;
        return 1 if $start2 >= $start1 and $start2 <= $end1;
        return 0;
}
#print "Count = $count\n";

__END__
		foreach my $start (sort {$a <=> $b} keys %curr_ex) {
			my $end = $curr_ex{$start};
			my $ignore = 0;
			foreach my $start_ignore (sort {$a <=> $b} keys %ignore) {
				my $end_ignore = $ignore{$start_ignore};
				$ignore = 1 if $start == $start_ignore and $end == $end_ignore;
			}
			next if $ignore == 1;
			foreach my $start2 (sort {$a <=> $b} keys %curr_ex) {
				my $end2 = $curr_ex{$start};
				next if $start == $start2 and $end == $end2; #Same exon
				my ($stats, $start3, $end3) = @{within($start, $end, $start2, $end2)};
				$ignore{$start3} = $end3 if $stats == 1;
			}
		}
		foreach my $start (sort {$a <=> $b} keys %curr_ex) {
			my $end = $curr_ex{$start};
			my $ignore = 0;
			foreach my $start_ignore (sort {$a <=> $b} keys %ignore) {
				my $end_ignore = $ignore{$start_ignore};
				$ignore = 1 if $start == $start_ignore and $end == $end_ignore;
			}
			next if $ignore == 1;

			foreach my $start2 (sort {$a <=> $b} keys %curr_ex) {
				my $end2 = $curr_ex{$start};
				next if $start == $start2 and $end == $end2; #Same exon
				my ($stats, $start3, $end3) = @{overlap($start, $end, $start2, $end2)};
				$exon{$start3} = $end3 if $stats == 1;
				if ($stats == 0) {
					$exon{$start, $end}
				}
			}
		}

