#!/usr/bin/perl

use strict; use warnings; use mitochy;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use Cache::FileCache;
use Statistics::Multtest qw(:all);
use Getopt::Std;
use Thread::Queue;
use Text::NSP::Measures::2D::Fisher::twotailed;
use vars qw($opt_v);
getopts("v");

my ($wt, $db, $wt_bed, $db_bed) = @ARGV;
die "
usage: $0 [options] <wt_point_bed> <db_point_bed> <wt_meth_bed> <db_meth_bed>

*_point_bed is result from point_map_wig_to_bed.pl
*_meth_bed is result from bismark_pileup_CpG.pl

options: 
-v: Verbose on/off (default: on)

" unless @ARGV == 4;

my $cache = new Cache::FileCache();
$cache -> set_cache_root("/data/mitochi/Work/Cache/");

# Process point/per position methylation bed files
my %data;
printv("Processing $wt\n");
%data = %{process_point_meth_bedfile($wt, "wt", \%data)};
printv("Processing $db\n");
%data = %{process_point_meth_bedfile($db, "db", \%data)};

# Process methylation bed files for reference for first statistics filter
# Are C at position X differ from the other? If no, filter out
my %bed;

printv("Processing $wt_bed\n");
my $wtcache = $cache -> get($wt_bed);
if (not defined($wtcache)) {
	$wtcache = process_meth_bedfile($wt_bed);
	$cache -> set($wt_bed, $wtcache);
}
%{$bed{wt}} = %{$wtcache};

printv("Processing $db_bed\n");
my $dbcache = $cache -> get($db_bed);
if (not defined($dbcache)) {
	$dbcache = process_meth_bedfile($db_bed);
	$cache -> set($db_bed, $dbcache);
}
%{$bed{db}} = %{$dbcache};

# Open output file
my ($folder1, $namewt) = mitochy::get_filename($wt);
my ($folder2, $namedb) = mitochy::get_filename($db);

open (my $out_ALL, ">", "$namewt\_$namedb\_ALL.bed") or die;
open (my $out_SIG_POS, ">", "$namewt\_$namedb\_SIGPOS.bed") or die;
open (my $out_SIG_NEG, ">", "$namewt\_$namedb\_SIGNEG.bed") or die;


my $Q = new Thread::Queue;

foreach my $name (sort keys %data) {

	# Delete gene name if values are NA
	# Only compare the comparable:
	# This can be deleted because if the other data is not present, then they can't be compared
	delete($data{$name}) and next if defined($data{$name}{db}) or defined($data{$name}{wt});

	foreach my $pos (sort {$a <=> $b} keys %{$data{$name}{pos}}) {

		# Delete/don't include gene name if the other data is not present and vice verse
		next if not defined($data{$name}{pos}{$pos}{val}{wt});
		next if not defined($data{$name}{pos}{$pos}{val}{db});

		#check for significance using Fisher's exact test
		my $chr = $data{$name}{chr};
		die "Probably used wrong info bed file\n" if (not defined($bed{wt}{$chr}{$pos}{covs}) or not defined($bed{db}{$chr}{$pos}{covs}));
		my $wt_covs = $bed{wt}{$chr}{$pos}{covs};
		my $wt_meth = $bed{wt}{$chr}{$pos}{meth};
		my $db_covs = $bed{db}{$chr}{$pos}{covs};
		my $db_meth = $bed{db}{$chr}{$pos}{meth};
		printv ("chr $chr pos $pos: ");
		my @job = ($wt_meth, $wt_covs, $db_meth, $db_covs, $name, $pos);
		$Q -> enqueue(\@job);
	}
}
$Q -> end;

while ($Q -> pending) {
	my $job_count = $Q->pending();
	my ($wt_meth, $wt_covs, $db_meth, $db_covs, $name, $pos) = @{$Q->dequeue};
	#my $p = fisher_exact_test($wt_meth, $wt_covs, $db_meth, $db_covs);

	#########################
	#	#   WT	#  DB	#
	#########################
	#   C	#  n11	#  n12	# n1p
	#########################
	#   T	#  n21	#  n22	# n2p
	#########################
		#  np1	#  np2	# npp

	my $n11 = int(($wt_meth/100) * $wt_covs+0.01);
	my $n12 = int(($db_meth/100) * $db_covs+0.01);
	my $n21 = $wt_covs - $n11;
	my $n22 = $db_covs - $n12;
	my $n1p = $n11 + $n12;
	my $np1 = $n11 + $n21;
	my $npp = $n11 + $n12 + $n21 + $n22;

	my $p = int(100*calculateStatistic( n11=>$n11, n1p=>$n1p, np1 =>$np1, npp=>$npp))/100;
	# If pass fisher exact test, then print the difference
	my $diff_db = $data{$name}{pos}{$pos}{val}{db}; die "Undef diff_db\n" unless defined($diff_db);
	my $diff_wt  = $data{$name}{pos}{$pos}{val}{wt} ; die "Undef diff_wt\n" unless defined($diff_wt);
	my $diff = $diff_db - $diff_wt;
		

	$data{$name}{diff}{count} = 1 if not defined($data{$name}{diff}{count});
	$data{$name}{diff}{total} = 0 if not defined($data{$name}{diff}{total});
	$data{$name}{diff}{data} .= "$pos,$diff,NS($p)\_" if $p > 0.05;
	$data{$name}{diff}{data} .= "$pos,$diff,S($p)\_"  if $p <= 0.05;
	$data{$name}{diff}{sigdata} .= "$pos,$diff,S($p)\_"  if $p <= 0.05;
	$data{$name}{diff}{count} ++ if $p <= 0.05;
	$data{$name}{diff}{total} += $diff if $p <= 0.05;
	print "$job_count jobs left\n" if $job_count % 50000 == 0;
}

foreach my $name (keys %data) {
	delete($data{$name}) if not defined($data{$name}{diff}{data});
}

foreach my $name (sort {$data{$b}{diff}{count} <=> $data{$a}{diff}{count} or $data{$b}{diff}{total}/$data{$b}{diff}{count} <=> $data{$a}{diff}{total}/$data{$a}{diff}{count}} keys %data) {
	my $diff   = $data{$name}{diff}{data};
	my $sigdiff   = $data{$name}{diff}{sigdata} if defined($data{$name}{diff}{sigdata});
	my $type   = $data{$name}{type};
	my $chr    = $data{$name}{chr} ;
	my $start  = $data{$name}{start};
	my $end    = $data{$name}{end};
	my $strand = $data{$name}{strand};
	my $count;
	my $ratio;
	if (defined($sigdiff)) {
		$count = $data{$name}{diff}{count} - 1;
		print "Error at $name count = $count total = $data{$name}{diff}{total}\n" if $count == 0;
		$ratio = $data{$name}{diff}{total} / $count;
	}
	print $out_ALL "$chr\t$start\t$end\t$name\_$type\t$diff\t$strand\n";
	print $out_SIG_POS "$chr\t$start\t$end\t$name\_$type\_$count\_$ratio\t$sigdiff\t$strand\n"if defined($sigdiff) and $ratio >= 0;
	print $out_SIG_NEG "$chr\t$start\t$end\t$name\_$type\_$count\_$ratio\t$sigdiff\t$strand\n"if defined($sigdiff) and $ratio < 0;
}

print "Output: $namewt\_$namedb\_ALL.bed (All result)\n$namewt\_$namedb\_SIG.bed (Only significant)\n";

sub process_meth_bedfile {
	my ($input) = @_;
	my %bed;
	open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		next if $line =~ /track/ or $line =~ /\#/;
		my ($chr, $pos, $end, $value) = split("\t", $line);
		my ($context, $covs, $meth) = split("_", $value);
		$bed{$chr}{$pos}{meth} = $meth;
		$bed{$chr}{$pos}{covs} = $covs;
	}
	close $in;
	return(\%bed);
}

sub process_point_meth_bedfile {
	my ($input, $types, $data) = @_;

	my %data = %{$data};
	open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		my ($chr, $start, $end, $values, $name, $type, $strand) = split("\t", $line);
		die "Died at chr = $chr, start = $start, line = $line\n" unless defined($name);
		$data{$name}{start}  = $start;
		$data{$name}{end}    = $end;
		$data{$name}{chr}    = $chr;
		$data{$name}{strand} = $strand;
		$data{$name}{type}   = $type;
		
		if ($values ne "NA") {
			my @val = split("_", $values);
			foreach my $group (sort @val) {
				my ($pos, $val) = split(",", $group);
				$data{$name}{pos}{$pos}{val}{$types} = $val;
			}
		}
		else {
			$data{$name}{$type} = "NA";
		}
	}
	close $in;
	return(\%data);
}

sub fisher_exact_test {
	my ($wt_meth, $wt_covs, $db_meth, $db_covs) = @_;
	
	#########################
	#	#   WT	#  DB	#
	#########################
	#   C	#   a	#   b	#
	#########################
	#   T	#   c	#   d	#
	#########################
	
	my $A = int(($wt_meth/100) * $wt_covs);
	my $B = int(($db_meth/100) * $db_covs);
	my $C = $wt_covs - $A;
	my $D = $db_covs - $B;
	my $N = $A + $B + $C + $D;
	my $prob = 1;

	my $A_exp = ($A+$B) / $N * ($A+$C);
	my $B_exp = ($A+$B) / $N * ($B+$D);
	my $C_exp = ($C+$D) / $N * ($A+$C);
	my $D_exp = ($C+$D) / $N * ($B+$D);

	# If numbers are smaller than 20, then calculate factorial directly
	if ($A < 50 and $B < 50 and $C < 50 and $D < 50) {
		printv ("\tA = $A, B = $B, C = $C, D = $D, N = $N: Using factorial: ");
		my $fact_A = factorial($A);
		my $fact_B = factorial($B);
		my $fact_C = factorial($C);
		my $fact_D = factorial($D);
		my $fact_N = factorial($N);
		my $fact_AB = factorial($A+$B);
		my $fact_CD = factorial($C+$D);
		my $fact_AC = factorial($A+$C);
		my $fact_BD = factorial($B+$D);
		printv("\tfact of A $A = $fact_A
	fact of B $B = $fact_B
	fact of C $C = $fact_C
	fact of D $D = $fact_D
	fact of E $N = $fact_N

	fact of A+B $A+$B = $fact_AB
	fact of C+D $C+$D = $fact_CD
	fact of A+C $A+$C = $fact_AC
	fact of B+D $B+$D = $fact_BD");# if $B > 10;

		$prob *= factorial($A+$B) / factorial($A);
		$prob *= factorial($C+$D) / factorial($B);
		$prob *= factorial($A+$C) / factorial($C);
		$prob *= factorial($B+$D) / factorial($D);
		$prob /= factorial($N);
		
		my $final_prob = 0;
		my $AB = $A+$B;
		for (my $i = 0; $i <= ($A+$B); $i++) {
			my $hyperdist = 1;
			$hyperdist *= factorial($A+$B) / factorial($i);
			$hyperdist *= factorial($C+$D) / factorial($A+$B-$i);
			$hyperdist *= factorial($A+$C) / factorial($A+$C-$i);
			$hyperdist *= factorial($B+$D) / factorial(($B+$D)-($A+$B)+$i);
			$hyperdist /= factorial($N);
			printv("\thyperdist = $hyperdist: ");
			$final_prob += $hyperdist if $hyperdist < $prob*1.00001;
			printv("Added\n") if $hyperdist < $prob*1.00001;
			printv("Not added\n") if $hyperdist >= $prob*1.00001;
		}
		$prob = $final_prob;
	}
	

	else {
		printv("\tA = $A, B = $B, C = $C, D = $D, N = $N: Using list: ");# if $B > 10;

		# nominator
		my %AB = %{list($A+$B)};
		my %CD = %{list($C+$D)};
		my %AC = %{list($A+$C)};
		my %BD = %{list($B+$D)};

		# denominator
		my %A = %{list($A)};
		my %B = %{list($B)};
		my %C = %{list($C)};
		my %D = %{list($D)};
		my %N = %{list($N)};
		
		my @denom_list = (\%A, \%B, \%C, \%D, \%N);
		my $denom_list = \@denom_list;
		my ($AB_hash, $CD_hash, $AC_hash, $BD_hash);
		($AB_hash, $denom_list) = remove_list(\%AB, $denom_list);
		%AB = %{$AB_hash};
		($CD_hash, $denom_list) = remove_list(\%CD, $denom_list);
		%CD = %{$CD_hash};
		($AC_hash, $denom_list) = remove_list(\%AC, $denom_list);
		%AC = %{$AC_hash};
		($BD_hash, $denom_list) = remove_list(\%BD, $denom_list);
		%BD = %{$BD_hash};
		@denom_list = @{$denom_list};
		%A = %{$denom_list[0]};
		%B = %{$denom_list[1]};
		%C = %{$denom_list[2]};
		%D = %{$denom_list[3]};
		%N = %{$denom_list[4]};


		my @nominator = (1);
		foreach my $AB (keys %AB) {
			push(@nominator, $AB);
		}
		foreach my $CD (keys %CD) {
			push(@nominator, $CD);
		}
		foreach my $AC (keys %AC) {
			push(@nominator, $AC);
		}
		foreach my $BD (keys %BD) {
			push(@nominator, $BD);
		}

		my @denominator = (1);
		foreach my $A (keys %A) {
			push(@denominator, $A);
		}
		foreach my $B (keys %B) {
			push(@denominator, $B);
		}
		foreach my $C (keys %C) {
			push(@denominator, $C);
		}
		foreach my $D (keys %D) {
			push(@denominator, $D);
		}
		foreach my $N (keys %N) {
			push(@denominator, $N);
		}
		
		printv("P-value: 1 (both)\n") and return(1) if @nominator == 1 and @denominator == 1;

		#print "\nNominator:\n";
		#print "@nominator\n";
		#print "\nDenominator:\n";
		#print "@denominator\n";

		my $max = scalar(@nominator) >  scalar(@denominator) ? scalar(@nominator) : scalar(@denominator);
		for (my $i = 0; $i < $max; $i++) {
			if (defined($nominator[$i]) and defined($denominator[$i])) {
				$prob *= $nominator[$i] / $denominator[$i];
			}
			elsif (not defined($nominator[$i])) {
				$prob *= 1 / $denominator[$i];
			}
			elsif (not defined($denominator[$i])) {
				$prob *= $nominator[$i];
			}
			else {
				die "Died at i = $i, max = $max, A = $A, B = $B, C = $C, D = $D, N = $N, prob = $prob\n";
			}
		}

		my $final_prob = 0;
		my $AB = $A+$B;


		for (my $i = 0; $i <= ($A+$B); $i++) {

			# nominator
			my %AB2 = %{list($A+$B)};
			my %CD2 = %{list($C+$D)};
			my %AC2 = %{list($A+$C)};
			my %BD2 = %{list($B+$D)};
	
			# denominator
			my %A2 = %{list($i)};
			my %B2 = %{list($A+$B-$i)};
			my %C2 = %{list($A+$C-$i)};
			my %D2 = %{list(($B+$D)-($A+$B)+$i)};
			my %N2 = %{list($N)};
			
			my @denom_list2 = (\%A2, \%B2, \%C2, \%D2, \%N2);
			my $denom_list2 = \@denom_list2;
			my ($AB_hash2, $CD_hash2, $AC_hash2, $BD_hash2);
			($AB_hash2, $denom_list2) = remove_list(\%AB2, $denom_list2);
			%AB2 = %{$AB_hash2};
			($CD_hash2, $denom_list2) = remove_list(\%CD2, $denom_list2);
			%CD2 = %{$CD_hash2};
			($AC_hash2, $denom_list2) = remove_list(\%AC2, $denom_list2);
			%AC2 = %{$AC_hash2};
			($BD_hash2, $denom_list2) = remove_list(\%BD2, $denom_list2);
			%BD2 = %{$BD_hash2};
			@denom_list2 = @{$denom_list2};
			%A2 = %{$denom_list2[0]};
			%B2 = %{$denom_list2[1]};
			%C2 = %{$denom_list2[2]};
			%D2 = %{$denom_list2[3]};
			%N2 = %{$denom_list2[4]};
	
	
			my @nominator2 = (1);
			foreach my $AB2 (keys %AB2) {
				push(@nominator2, $AB2);
			}
			foreach my $CD2 (keys %CD2) {
				push(@nominator2, $CD2);
			}
			foreach my $AC2 (keys %AC2) {
				push(@nominator2, $AC2);
			}
			foreach my $BD2 (keys %BD2) {
				push(@nominator2, $BD2);
			}
	
			my @denominator2 = (1);
			foreach my $A2 (keys %A2) {
				push(@denominator2, $A2);
			}
			foreach my $B2 (keys %B2) {
				push(@denominator2, $B2);
			}
			foreach my $C2 (keys %C2) {
				push(@denominator2, $C2);
			}
			foreach my $D2 (keys %D2) {
				push(@denominator2, $D2);
			}
			foreach my $N2 (keys %N2) {
				push(@denominator2, $N2);
			}
		
			my $hyperdist = 1;
			my $max2 = scalar(@nominator2) >  scalar(@denominator2) ? scalar(@nominator2) : scalar(@denominator2);
			for (my $i = 0; $i < $max2; $i++) {
				if (defined($nominator2[$i]) and defined($denominator2[$i])) {
					$hyperdist *= $nominator2[$i] / $denominator2[$i];
				}
				elsif (not defined($nominator[$i])) {
					$hyperdist *= 1 / $denominator[$i];
				}
				elsif (not defined($denominator[$i])) {
					$hyperdist *= $nominator[$i];
				}
				else {
					$hyperdist = 1;#die "Died at i = $i, max = $max, A = $A, B = $B, C = $C, D = $D, N = $N, prob = $prob\n";
				}
			}

			printv("\thyperdist = $hyperdist: ");
			$final_prob += $hyperdist if $hyperdist < $prob*1.00001;
			printv("Added\n") if $hyperdist < $prob*1.00001;
			printv("Not added\n") if $hyperdist >= $prob*1.00001;
		}
		$prob = $final_prob;
	}

	printv ("\tP-value: $prob\n");
	return($prob);

}
sub printv {
	my ($text) = @_;
	print $text if not defined($opt_v);
}

sub factorial {
	my ($number) = @_;
	return(-1) if $number < 0;
	return(1) if $number == 0;

	my $result = 1;
	#print "Factorial of $number:\n");
	for (my $i = 0; $i < $number; $i++) {
		my $prev = $result;
		my $time = $number - $i;
		# $number: 10. 
		# min $i = 0: $result = 10 - 0 = 10.
		# max $i = $number-1 = 9: $result = 10-9 = 1

		$result *= ($number - $i);
		#print "\tResult of $prev * $time = $result\n");
	}
	return($result);
}

sub list {
	my ($number) = @_;
	my %list;

	for (my $i = 1; $i <= $number; $i++) {
		
		# $number: 10.
		# min $i = 1: push = 1.
		# max $i = 10: push = 10.

		$list{$i} = 1;
	}
	return(\%list);

}

sub remove_list {
	my ($nom, $denom) = @_;
	my %nom = %{$nom};
	
	my $print = 1;
	#if (defined($nom{421})) {
	#	$print = 1;
	#}
	#print "\nNominator Before\n" if $print == 1;
	#foreach my $nom (sort {$a <=> $b} keys %nom) {
	#	print "$nom " if $print == 1;
	#}
	#print "\n" if $print == 1;
	#print "\nDenominator Before\n" if $print == 1;
	my @denom = @{$denom};
	#foreach my $denomhash (@denom) {
	#	print "$denomhash: " if $print == 1;
	#	my %denomhash = %{$denomhash};
	#	foreach my $denom (sort {$a <=> $b} keys %denomhash) {
	#		print "$denom " if $print == 1;
	#	}
	#	print "\n" if $print == 1;
	#}

	foreach my $nom (sort {$a <=> $b} keys %nom) {
		my $denom_num = 0;
		
		for (my $i = 0; $i < @denom; $i++) {
			foreach my $denom (sort {$a <=> $b} keys %{$denom[$i]}) {
				next if not defined($nom{$denom}) or not defined($denom[$i]{$nom});

				if ($nom{$denom} == 1 and $denom[$i]{$nom} == 1) {
					delete($nom{$nom}) and delete($denom[$i]{$denom});
				}
			}
			$denom_num++;
		}
	}

	#print "\nNominator Before\n" if $print == 1;
	#foreach my $nom (sort {$a <=> $b} keys %nom) {
	#	print "$nom " if $print == 1;
	#}
	#print "\n" if $print == 1;
	#print "\nDenominator After\n" if $print == 1;
	#foreach my $denomhash (@denom) {
	#	print "$denomhash: " if $print == 1;
	#	my %denomhash = %{$denomhash};
	#	foreach my $denom (sort {$a <=> $b} keys %denomhash) {
	#		print "$denom " if $print == 1;
	#	}
	#	print "\n" if $print == 1;
	#}

	return(\%nom, \@denom);

	
}

__END__

p = (a+b)!(c+d)!(a+c)!(b+d)!/(a!b!c!d!n!)

=comment
		# For each array, remove those that exists in denominator
		foreach my $AB (sort keys %AB) {
			foreach my $A (sort keys %A) {
				next if not defined($AB{$A}) or not defined($A{$AB});
				delete($AB{$AB}) and delete($A{$A}) if $AB{$A} == 1 and $A{$AB} == 1;
			}
			foreach my $B (sort keys %B) {
				next if not defined($AB{$B}) or not defined($B{$AB});
				delete($AB{$AB}) and delete($B{$B}) if $AB{$B} == 1 and $B{$AB} == 1;
			}
			foreach my $C (sort keys %C) {
				next if not defined($AB{$C}) or not defined($C{$AB});
				delete($AB{$AB}) and delete($C{$C}) if $AB{$C} == 1 and $C{$AB} == 1;
			}
			foreach my $D (sort keys %D) {
				next if not defined($AB{$D}) or not defined($D{$AB});
				delete($AB{$AB}) and delete($D{$D}) if $AB{$D} == 1 and $D{$AB} == 1;
			}
		}


		foreach my $CD (sort keys %CD) {
			foreach my $A (sort keys %A) {
				next if not defined($CD{$A}) or not defined($A{$CD});
				delete($CD{$CD}) and delete($A{$A}) if $CD{$A} == 1 and $A{$CD} == 1;
			}
			foreach my $B (sort keys %B) {
				next if not defined($CD{$B}) or not defined($B{$CD});
				delete($CD{$CD}) and delete($B{$B}) if $CD{$B} == 1 and $B{$CD} == 1;
			}
			foreach my $C (sort keys %C) {
				next if not defined($CD{$C}) or not defined($C{$CD});
				delete($CD{$CD}) and delete($C{$C}) if $CD{$C} == 1 and $C{$CD} == 1;
			}
			foreach my $D (sort keys %D) {
				next if not defined($CD{$D}) or not defined($D{$CD});
				delete($CD{$CD}) and delete($D{$D}) if $CD{$D} == 1 and $D{$CD} == 1;
			}
		}

		foreach my $AC (sort keys %AC) {
			foreach my $A (sort keys %A) {
				next if not defined($AC{$A}) or not defined($A{$AC});
				delete($AC{$AC}) and delete($A{$A}) if $AC{$A} == 1 and $A{$AC} == 1;
			}
			foreach my $B (sort keys %B) {
				next if not defined($AC{$B}) or not defined($B{$AC});
				delete($AC{$AC}) and delete($B{$B}) if $AC{$B} == 1 and $B{$AC} == 1;
			}
			foreach my $C (sort keys %C) {
				next if not defined($AC{$C}) or not defined($C{$AC});
				delete($AC{$AC}) and delete($C{$C}) if $AC{$C} == 1 and $C{$AC} == 1;
			}
			foreach my $D (sort keys %D) {
				next if not defined($AC{$D}) or not defined($D{$AC});
				delete($AC{$AC}) and delete($D{$D}) if $AC{$D} == 1 and $D{$AC} == 1;
			}
		}

		foreach my $BD (sort keys %BD) {
			foreach my $A (sort keys %A) {
				next if not defined($BD{$A}) or not defined($A{$BD});
				delete($BD{$BD}) and delete($A{$A}) if $BD{$A} == 1 and $A{$BD} == 1;
			}
			foreach my $B (sort keys %B) {
				next if not defined($BD{$B}) or not defined($B{$BD});
				delete($BD{$BD}) and delete($B{$B}) if $BD{$B} == 1 and $B{$BD} == 1;
			}
			foreach my $C (sort keys %C) {
				next if not defined($BD{$C}) or not defined($C{$BD});
				delete($BD{$BD}) and delete($C{$C}) if $BD{$C} == 1 and $C{$BD} == 1;
			}
			foreach my $D (sort keys %D) {
				next if not defined($BD{$D}) or not defined($D{$BD});
				delete($BD{$BD}) and delete($D{$D}) if $BD{$D} == 1 and $D{$BD} == 1;
			}
		}
=cut
