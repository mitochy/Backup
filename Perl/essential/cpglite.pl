#!/usr/bin/perl
##############################################################
#
#		This script calculates cpg o/e, cg content,
#		and the gc skew, then make graph in R
#
#		Author: Stella Hartono
#
#
############################################################################

BEGIN {
	if ($ENV{'HOME'} =~ m/^\/Users\/stella$/i || $ENV{'HOME'} =~ m/^\/home\/mitochi$/i) {
		my $libdir;
		$libdir = "/Users/stella/Desktop/Work/Codes/perl/lib" if $ENV{'HOME'} =~ m/^\/Users\/stella$/i;
		$libdir = "/home/mitochi/Desktop/Work/Codes/perl/lib" if $ENV{'HOME'} =~ m/^\/home\/mitochi$/i;
		push (@INC, ("$libdir"));
	}
}

use strict; use warnings; 
use Getopt::Std;
use FAlite;

use vars qw($opt_h $opt_v $opt_e $opt_f $opt_r $opt_c $opt_w $opt_x $opt_y $opt_o $opt_g $opt_s $opt_b $opt_a $opt_p $opt_k $opt_q $opt_n $opt_m);
getopts("hvferbcw:x:y:o:g:s:a:p:k:qn:m:");

# Global Variables #
my $version = "3/28/2012";
my $count = 0;
my $header_count = 0;
my $location_count = 0;
my ($nuc1, $nuc2)		   = defined($opt_n) ? $opt_n =~ m/(\w)(\w)/i : ('C', 'G');
print "Nucleotides: dinucleotide ($nuc1, $nuc2)\n";
my ($nucleotide) = defined($opt_m) ? uc($opt_m) : 0;
$opt_m = defined($opt_m) ? $opt_m : 0;
print "Nucleotides: multinucleotide ($nucleotide)\n" if $opt_m !~ /^0$/i;

my $window_size 	   = defined($opt_w) ? $opt_w : 100;
my $cpg_size   		   = defined($opt_x) ? $opt_x : 200;
my $step_size   	   = defined($opt_y) ? $opt_y : 1;
my $exp_CpGoe   	   = defined($opt_o) ? $opt_o : 0.6;
my $exp_GC		   = defined($opt_g) ? $opt_g : 0.5;
my $exp_skew    	   = defined($opt_s) ? $opt_s : "-2000to-501skew-0.015to0,-500to0skew-0.01to0.01,0to500skew0.09to0.1,501to2000skew0.07to0.09";
my $exp_pvalue 		   = defined($opt_p) ? $opt_p : 0.05;
my ($win_min, $win_max)    = defined($opt_a) ? $opt_a =~ m/^(-*\d+)to(\d+)$/i : (-2000,2000);
my ($kmer_min, $kmer_max)  = defined($opt_k) ? $opt_k =~ m/^(\d+)to(\d+)$/i : (4,7);
$win_min += 2000;
$win_max += 2000;
my @input = @ARGV;

my @temp = split(",",$exp_skew);
my @skew;
for (my $i = 0; $i < @temp; $i++) {
	my (@temp2) = $temp[$i] =~ m/^(-*\d+)to(-*\d+)skew(-*\d+\.*\d*)to(-*\d+\.*\d*)$/i;
	$skew[$i][0] = $temp2[0];
	$skew[$i][1] = $temp2[1];
	$skew[$i][2] = $temp2[2];
	$skew[$i][3] = $temp2[3];
}

if ($opt_s) {
	for ( my $i = 0; $i < @skew; $i++) {
		for (my $j = 0; $j < @{$skew[$i]}; $j++) {
			print "$skew[$i][$j]\t";
		}
		print "\n";
	}
}

# Check if R is installed, args are ok, usage, etc #
paranoid_check();
my $home = $ENV{"HOME"};

my %probabilities = %{make_prob_table()};
##############################################################
#
#				MAIN
#
############################################################################

my (%chrom, %gene);

if ($opt_r) {
	my ($input_chrom, $input_ref) = @input;
	
	(print_usage() and die "\nPlease specify chromosome size file and refseq genes file (UCSC format)!\n\n") if not defined($input_chrom) or not defined($input_ref);

	# Process chr info (chr start and end coordinates) #
	%chrom = %{process_chrom($input_chrom)};

	# Process TSS info on each gene #
	%gene = %{process_refseq($input_ref)};

	# Process refseq file into BED 6 file #
	open (my $out, ">", "$input_ref.bed") or die "Cannot write into $input_ref.out: $!\n";
	
	foreach my $chr (sort {$a <=> $b} keys %gene) {
		
		# Print start (TSS - 2000) and end (TSS + 2000) of Positive Strand #	
		foreach my $pos_name (sort {$gene{$chr}{'+'}{$a}{'start'} <=> $gene{$chr}{'+'}{$b}{'start'}} keys %{$gene{$chr}{'+'}}) {
			my $start = $gene{$chr}{'+'}{$pos_name}{'start'} - 1000;
			my $end   = $gene{$chr}{'+'}{$pos_name}{'start'} + 1000;
			
			# If start coor is less than 0, make it 0 #
			$start = $start < 0 	    ? 0 		    : $start;
			
			# Similarly, if end coor is more than chr length, make it coor of chr end #
			$end   = $end > $chrom{$chr} ? $chrom{$chr}-1 : $end  ;
			
			# Also, do some minor formatting according to genome chr format #
			# Make subroutines? #
			my $chr_temp = $chr;
			
			# Human #
			
			# C_elegans #
	
			print $out "chr$chr_temp\t$start\t$end\t$pos_name\t0\t+\n";
		}
		
		
		# Print start (TSS - 2000) and end (TSS + 2000) of Negative Strand #	
		foreach my $pos_name (sort {$gene{$chr}{'-'}{$a}{'start'} <=> $gene{$chr}{'-'}{$b}{'start'}} keys %{$gene{$chr}{'-'}}) {
			my $start = $gene{$chr}{'-'}{$pos_name}{'start'} - 1000;
			my $end = $gene{$chr}{'-'}{$pos_name}{'start'} + 1000;

			# If start coor is less than 0, make it 0 #
			$start = $start < 0 ? 0 : $start;

			# Similarly, if end coor is more than chr length, make it coor of chr end #
			$end   = $end > $chrom{$chr} ? $chrom{$chr}-1 : $end  ;

			# Also, do some minor formatting according to genome chr format #
			# Make subroutines? #
			my $chr_temp = $chr;
			
			# Human #

			# C_elegans #
		
			print $out "chr$chr_temp\t$start\t$end\t$pos_name\t0\t-\n";
		}
		
		# In the future: -2000 and +2000 of 3' end to get 3' end skew etc #
		# Using gene end coordinate ($gene{$chr}{'-'}{$pos_name}{'end'})  #
	}
	close $out;	
}

if ($opt_c or $opt_b) {
	my ($input_geneseq) = @input;
	(print_usage() and die "\nPlease specify fasta file containing (genes info+sequence) (UCSC format)!\n\n") if not defined($input_geneseq);
	process_gene($input_geneseq);
}

if ($opt_q) {
	my ($input_geneID, $input_geneseq) = @input;
	my ($input_name, $suffix) = $input_geneseq =~ m/^(.+geneseq_chr\w+_\w+).(\w+)$/i;
	my ($input_ID) = $input_geneID =~ m/^.+\/(.+)\.\w+$/i;

	$input_name .= $input_ID . ".$suffix";
	(print_usage() and die "\nPlease specify gene ID list and fasta file containing (genes info+sequence) (UCSC format)!\n\n") if not defined($input_geneID) or not defined ($input_geneseq);
	
	open (my $in, "<", $input_geneID) or die "Cannot read from $input_geneID\n";
	my @genes = <$in>;
	close $in;
	
	open (my $in2, "<", $input_geneseq) or die "Cannot read from $input_geneseq\n";
	my %geneseq;
	my @header;
	my $fasta_file = new FAlite($in2);
	while (my $entry = $fasta_file -> nextEntry) {
		my $header = $entry->def;
		my $seq    = $entry->seq;
		$geneseq{$header} = $seq;
	}
	close $in2;
	my $count2;
	
	open (my $out, ">", $input_name) or die "Cannot write to $input_name\n";
	foreach my $genes(@genes) {
		chomp($genes);
		foreach my $header (keys %geneseq) {
			chomp($header);
			if ($header =~ /$genes/i) {
				print $out "$header\n$geneseq{$header}\n";
				last;
			}
		}
	}	
	close $out;
}
	
##############################################################
#				o
# 			    .    ##					<><:
# 			     .   #   
# 			  ###################  +
# 			#####SUBROUTINES######+++
# 			 ###################   +
#
############################################################################

sub paranoid_check {
	print_version() if ($opt_v);
	print_format() and exit if ($opt_f);
	print_usage() and exit if ($opt_h);
	print_examples() and exit if ($opt_e);
	print_usage() and print "\nPlease only specify either -r or -c!\n\n" and exit if ($opt_c and $opt_r);
	check_OS();
	check_R();
	(print_usage() and die "\nWindow size format must be N-N format! (e.g. 1000to2000)\n\n") if not defined($win_min) or not defined($win_max);
(print_usage() and die "\nKmer Threshold must be N-N format! (e.g. 4to7)!\n\n") if not defined($kmer_min) or not defined($kmer_max);
(print_usage() and die "\nThreshold minimum of kmer must be smaller than maximum! ($kmer_min is smaller than $kmer_max)\n") if $kmer_min > $kmer_max;
	if (@ARGV == 0) {
		print_usage() and die "\n" if (not $opt_b and not $opt_c and not $opt_r and not $opt_q);
	}
}

sub print_version {	
	print "\n********************  VERSION  **********************\n\n";
	print "	Version: $version\n";
	print "\n*****************************************************\n\n";
	exit;
}

sub print_usage {
	my $usage = "
***************** QUICK   MANUAL ********************

USAGE: $0 [options] <arguments…>
OUTPUT: define output

options:
-v: version
-h: this Help
-f: format
-e: examples
-r: Make .Bed file from chromosome info file and refseq file [args: <chrom_info> <ref_seq>]
-c: Graph cpg profile from list of gene sequences [args: <gene_seq>], with the following options:
-b: Analyze CG boxes on CpG island 
-n: Analyze dinucleotide [default: CG]
-m: Analyze multinucleotide [default: Not used]

-w: window size [default: 100]
-x: CpG filter window size [default: 200]
-y: step size [default: 1]
-o: CpG o/e filter minimum [default: 0.6]
-g: GC content filter minimum [default: 0.5]
-s: skew filter minimum [default: 0.08] (not implemented)
CG box related:
-p: define p-value for CG box anlaysis [default: 0.05]
-a: define window to be analyzed from TSS [default: -2000to2000] (format: NtoM)
-k: defined kmer size of CG box [default: 4to7] (format: NtoM)

*****************************************************
";
	print $usage;
}

sub print_format {
	print "

******************	Format	************************
- chrom_info: go to ucsc table, select all table on group, then select chrominfo, then output format \"all table etc\"
- ref_seq: go to ucsc table, select genes and gene prediction on group, select refseq on track, then output format \"all table etc\"
- gene_seq: go to ucsc table, select custom track and upload chrominfo.bed, then intersect with ref gene, and output format \"sequence\", with output file (geneseq.txt) and file type text. geneseq.txt is the geneseq file.

1) Naming file:
	<chrom_info> filename can be anything.
	<ref_seq> filename can be anything
	<gene_seq> filename MUST be (anything)_geneseq_chr(anything)_(anything).(anything)
		But it's better to name it (your organism)_geneseq_chr(chr name)_(other info).(anything)
		E.g.: human_geneseq_chrall_all.cookie
2) Format inside file:
	<chrom_info>: UCSC chromInfo file (all tables). 
	<ref_seq> : UCSC refseq file (all tables)
	*For refseq and chrominfo:
		relevant chr must be manually named as \"chr\" and \"number\" (e.g. chr1)
		E.g C.elegans has chrI -> rename chrI as chr1 (be careful to not rename chrIII to chr1II when renaming)
		or Bee (a. mellifera) has Group1 -> rename Group to chr
	<gene_seq> : UCSC sequence file (fasta format, also doubel check if
		the header sequence has strand info (+ or -)

*****************************************************

";
}

sub print_examples {
	print "
****************	Examples	***********************
How To get <chrom_info>, <ref_seq>, and <gene_seq> file:
	1. Look at format (cpglite.pl -f) to make sure you have the correct format
	2. make .bed file from human.chrom and human.refseq: cpglite.pl -r human.chrom human.refseq
	3. make user custom track using the .bed file
	4. obtain gene sequence list file from all human chr UCSC by intersecting custom track

Examples on graphing and analyzing cg box
1. graph with 200bp cpg check (default)
	cpglite.pl -c (gene sequence file)
2. graph with 750bp cpg check
	cpglite.pl -x 750 -c (gene sequence file)
3. graph with 750bp cpg check on 50bp window size and 100bp step size: 
	cpglite.pl -w 50 -x 750 -y 100 -c (gene sequence file)
4. graph with 1000bp cpg check on 100bp window size and 1bp step size, with CpG o/e > 0.3 and GC > 0.5:
	cpglite.pl -w 100 -x 1000 -y 1 -o 0.3 -g 0.5 -c (gene sequence file)
5. analyze CG boxes on default CpG Island threshold on -1000 to 1000 bp from TSS and p value of 0.001 and kmer size of 5 only: 
	cpglite.pl -a -1000to1000 -p 0.001 -k 5to5 -b (gene sequence file)
6. graph and analyze CG boxes on:
   CpG Island check: 1250bp cpg check on 100bp window size and 1bp step size
   Cpg o/e bigger than 1 and GC content bigger than 0.5
   Analyze CG box on -500 to 750bp from TSS and p value of 0.05 and kmer size of 5-10
	cpglite.pl -w 100 -x 1250 -y 1 -o 1 -g 0.5 -a -500to750 -p 0.05 -k 5to10 -b -c (gene sequence file)

*****************************************************
";
}

sub check_OS {
	
	my $osname = $^O;
	warn "OS is not OSX/Linux ($osname); there might be compatibility issues.\n" if ($osname !~ m/darwin/i and $osname !~ m/linux/i);
}

sub check_R {	
	print "R check failed: Please install R from cran.r-project.org\n\n" if not -e "/usr/bin/R";
}

sub is_defined {
	my (@check) = (@_);
	foreach my $var (@check) {
		die "header not defined: @check\n" if not defined($var);
	}
}

sub process_chrom {
	my ($input) = @_;
	
	open (my $in, "<", $input) or die "Cannot read chromosome info from $input: $!\n";
	
	# Chrom hash #
	my %chrom;
	
	# Variables #
	my ($chr_pos, $size_pos);
	
	while (my $line = <$in>) {
		chomp($line);
		
		# Split line into array (tab-delimited) $
		my @arr = split("\t",$line);
		
		# Define location of each array #
		if ($line =~ m/#/i) {
			for (my $i = 0; $i < @arr; $i++) {
				$chr_pos   = $i if $arr[$i] =~ m/^\#chrom$/i;
				$size_pos  = $i if $arr[$i] =~ m/^size$/i;
			}
			# Check if position is defined #
			is_defined($chr_pos, $size_pos);
			next;
		}
		
		# Rename chr into numbers #

		($arr[$chr_pos]) = $arr[$chr_pos] =~ m/^chr(\d+)$/i;
		next if not defined($arr[$chr_pos]); # Next if not number (or ambiguous)
		
		# Put position into chrom hash #
		$chrom{$arr[$chr_pos]} = $arr[$size_pos];
	}
	close $in;
	return(\%chrom);

}
sub process_refseq {
	my ($input) = @_;
	
	open (my $in, "<", $input) or die "Cannot read refseq genes from $input: $!\n";
	
	# Gene hash #
	my (%gene);
	
	# Variables #
	my (@check, $name_pos, $chr_pos, $strand_pos, $start_pos, $end_pos);
	
	# Double Gene Hash #
	my (%double);
	while (my $line = <$in>) {
		chomp($line);

		# Split line into array (tab-delimited) #		
		my @arr = split("\t",$line);

		# Define location of each array #
		if ($line =~ m/#/i) {
			for (my $i = 0; $i < @arr; $i++) {
				$name_pos   = $i if $arr[$i] =~ m/name$/i;
				$chr_pos    = $i if $arr[$i] =~ m/^chrom$/i;
				$strand_pos = $i if $arr[$i] =~ m/^strand$/i;
				$start_pos  = $i if $arr[$i] =~ m/^txStart$/i;
				$end_pos    = $i if $arr[$i] =~ m/^txEnd$/i;
			}
			# Check if position is defined #
			is_defined($name_pos, $chr_pos, $strand_pos, $start_pos, $end_pos);
			next;
		}
		
		# Rename chr into numbers #

		($arr[$chr_pos]) = $arr[$chr_pos] =~ m/^chr(\d+)$/i;
		next if not defined($arr[$chr_pos]); # Next if not number (or ambiguous)
		
		# Skip if double start position #
		next if exists($double{$arr[$start_pos]});
		$double{$arr[$start_pos]} ++ if (not exists $double{$arr[$start_pos]});

		# Put position into gene hash #
		$gene{$arr[$chr_pos]}{$arr[$strand_pos]}{$arr[$name_pos]}{'start'} = $arr[$strand_pos] =~ m/^\+$/i ? $arr[$start_pos] : $arr[$end_pos]  ;
		$gene{$arr[$chr_pos]}{$arr[$strand_pos]}{$arr[$name_pos]}{'end'}   = $arr[$strand_pos] =~ m/^\+$/i ? $arr[$end_pos]   : $arr[$start_pos];
	}
	close $in;
	
	return(\%gene);
}

sub process_gene {
	my ($input) = @_;
	print "input = $input\n";
	my ($org, $chr, $reg) = $input =~ m/^[.+\/]{0,1}(\w+)_geneseq_chr(\w+)_(\w+)\..+$/i;
	my $file_name = $org . " chr " . $chr . " region " . $reg;
	print "warning: name not defined!\n" if not defined($file_name);
	my ($total_gene, $gene_count) = (0,0);	
	print "\n$nuc2$nuc1 Boxing\n" if ($opt_b and not $opt_c);
	print "\n$nuc1\_p\_$nuc2\_counting\n" if ($opt_c and not $opt_b);
	print ">$nuc1\_p\_$nuc2\_oe $exp_CpGoe\t$nuc2$nuc1\_content $exp_GC\n" if ($opt_c and not $opt_b);
	print "\n$nuc2$nuc1\_boxing and $nuc1\_p\_$nuc2\_counting\n" if ($opt_b and $opt_c);

	# gene hash #
	my %gene_data_ave; # hash only averaged points from all genes
	my %gcbox; #hash all points from all genes
	my %gchead;
	# R script #
	my $Rscript_x_ave;

	open (my $in, "<", $input) or die "Cannot read gene fasta file from $input: $!\n";
	
	# FAlite to process stuff #

	my $fasta_file = new FAlite($in);

	while (my $entry = $fasta_file -> nextEntry) {
		my $header = $entry->def;
		my $seq    = $entry->seq;
		#next if length($seq) < 4000;
		my $header2 = $header;

		# Reverse complement sequence if strand is negative #
		#$seq = revcomp($seq) if $header2 =~ m/strand=-/i;
		($header) = $header2 =~ m/^>(.+) range/i;
		($header) = $header2 =~ m/^>(\w+\.*\w*) \|/i if not defined($header);
		($header) = $header2 =~ m/^>(\w+)/i if not defined($header);
		die "not defined header: $header2\n" if not defined($header);
		die "not defined seq: $header2\n" if not defined($seq);
		my ($cpg, $skew_check) = cpg_count($seq, $cpg_size, "false");
		my %cpg = %{$cpg};
		$total_gene++;

		# Now check each position of the gene. If the gene has cpg > threshold and gc content > threshold, then #
		# the particular gene promoter has a "cpg island". Then we graph cpg, gc, and gc skew       		    #
		foreach my $pos1 (sort {$a <=> $b} keys %cpg) {			
			# cpg island = has cpg o/e > expected CpGoe, gc content > expected GC over some filter bp window #
			if ($cpg{$pos1}{'cpg'} > $exp_CpGoe and $cpg{$pos1}{'gc'} > $exp_GC) {
				if ($opt_c) {
					# Re do calculation with window size of 100
					my ($cpg, $skew_check) = cpg_count($seq, $window_size, "true");
					last if $skew_check == 1;
					%cpg = %{$cpg};
					
					my $number_of_x = (keys %cpg);
					#print "x = $number_of_x\n";
	
					foreach my $pos (sort {$a <=> $b} keys %cpg) {
						$gene_data_ave{$pos}{'cpg'} += $cpg{$pos}{'cpg'}; # CpG = CG/(C*G)*window
						$gene_data_ave{$pos}{'gc'}  += $cpg{$pos}{'gc'};  # GC = (C+G)/100
						$gene_data_ave{$pos}{'skew'}  += $cpg{$pos}{'skew'};  # skew = (G-C)/(G+C)
					}
				}
				
				if ($opt_b) {
					my ($gcbox, $gchead) = GCbox_type(\%gcbox, \%gchead, $seq, $header);
					%gcbox = %{$gcbox};
					%gchead = %{$gchead};
				}
				
				$gene_count++;
#				print "at pos $pos1: $header\t$cpg{$pos1}{'cpg'} > $exp_CpGoe\t$cpg{$pos1}{'gc'} > $exp_GC\n"; # make this into /dev/null for faster
				last;
			}
		}

		# Multi Nucleotide
		if ($opt_m !~ /^0$/i) {
			my $multi = multinucleotide_count($seq, $window_size, $nucleotide);
			my %multi = %{$multi};
			foreach my $pos1 (sort {$a <=> $b} keys %multi) {			
				# cpg island = has cpg o/e > expected CpGoe, gc content > expected GC over some filter bp window #
				if ($multi{$pos1}{'ratio'} >= 0 and $multi{$pos1}{'count'} >= 0) {
					if ($opt_c) {
						# Re do calculation with window size of 100
						$multi = multinucleotide_count($seq, $window_size, $nucleotide);
						%multi = %{$multi};
						my $number_of_x = (keys %multi);
						#print "x = $number_of_x\n";
		
						foreach my $pos (sort {$a <=> $b} keys %multi) {
							$gene_data_ave{$pos}{'ratio'} += $multi{$pos}{'ratio'}; # CpG = CG/(C*G)*window
							$gene_data_ave{$pos}{'count'} += $multi{$pos}{'count'};  # GC = (C+G)/100
						}
					}
#					print "at pos $pos1: $header\t$cpg{$pos1}{'cpg'} > $exp_CpGoe\t$cpg{$pos1}{'gc'} > $exp_GC\n"; # make this into /dev/null for faster
					last;
				}
			}
		}
	}

	gene_data_Rscript($input, $file_name, \%gene_data_ave, $gene_count, $total_gene) if ($opt_c);
	gcbox_Rscript($input, $file_name, \%gcbox, \%gchead) if ($opt_b);

}

sub gcbox_Rscript {
	my ($input, $file_name, $gcbox, $gchead) = @_;
	my %gcbox = %{$gcbox};
	my %gchead = %{$gchead};
	open (my $gcbox_out, ">", "$input.$nuc2$nuc1\_BOX.$cpg_size.$exp_CpGoe.$exp_GC.$win_min.$win_max.$kmer_min.$kmer_max.$exp_pvalue.txt") or die "Cannot write into $input.$nuc2$nuc1\_BOX.$cpg_size.$exp_CpGoe.$exp_GC.$win_min.$win_max.$kmer_min.$kmer_max.$exp_pvalue.txt: $!\n";
	foreach my $gcbox (sort {$gcbox{$b}{'amount'} <=> $gcbox{$a}{'amount'}} keys %gcbox) {
		print $gcbox_out "$gcbox\t$gcbox{$gcbox}{'amount'}\n";
		foreach my $header_count (sort keys %{$gchead{$gcbox}{'header'}}) {
			print $gcbox_out "\t$gchead{$gcbox}{'header'}{$header_count}\n";
		}
		no warnings;
		foreach my $location (sort {$a <=> $b} keys %{$gcbox{$gcbox}}) {
			if ($location !~ /amount/i) {
				my $loc_TSS = -2000+$location;
				print $gcbox_out "\t$loc_TSS\t$gcbox{$gcbox}{$location}\n";
				foreach my $loc (sort keys %{$gchead{$gcbox}{'location'}{$location}}) {
					print $gcbox_out "\t\t$gchead{$gcbox}{'location'}{$location}{$loc}\n";
				}
			}
		}
		use warnings;
	}
	close $gcbox_out;
	
	# Add Rscript Code here #
	
	print "GCbox profiling done!\n";
	exit(0) if ($opt_b and not $opt_c);
}

sub gene_data_Rscript {
	my $scale = 1;
	my ($input, $file_name, $gene_data_ave, $gene_count, $total_gene) = @_;
	print "no gene found!\n" and exit(0) if $gene_count == 0;
	my %gene_data_ave = %{$gene_data_ave};
	# R script for average cpg island and gc #
	open (my $out_file,  ">", "$input.$nuc1\_p\_$nuc2.$cpg_size.$exp_CpGoe.$exp_GC.$win_min.$win_max.$kmer_min.$kmer_max.$exp_pvalue.R")  or die "Cannot write into $input.CPG.$cpg_size.$exp_CpGoe.$exp_GC.$win_min.$win_max.$kmer_min.$kmer_max.$exp_pvalue.R: $!\n";
	print "Out file: $out_file\n";
	my $Rscript_gc_y_ave   = "y.gc<-c(";
	my $Rscript_cpg_y_ave  = "y.cpg<-c(";
	my $Rscript_skew_y_ave = "y.skew<-c(";
	my $Rscript_ratio_y_ave = "y.ratio<-c(" if($opt_m !~ /^0$/i);
	my $Rscript_count_y_ave = "y.count<-c(" if($opt_m !~ /^0$/i);
	
	my $x_axis_count = (keys %gene_data_ave)/2;
	$scale = 2000/$x_axis_count;
	my ($max_ratio, $max_cpg, $min_gc, $max_gc, $min_count, $max_count, $min_skew,$max_skew) = (0, 0,1,0,1,0,1,0);

	# Process Gene Data Average
	foreach my $pos (sort {$a <=> $b} keys %gene_data_ave) {
		my $cpg   = $gene_data_ave{$pos}{'cpg'}   / $gene_count;
		my $gc    = $gene_data_ave{$pos}{'gc'}    / $gene_count;
		my $skew  = $gene_data_ave{$pos}{'skew'}  / $gene_count;
		my $ratio = $gene_data_ave{$pos}{'ratio'} / $total_gene if($opt_m !~ /^0$/i);
		my $count = $gene_data_ave{$pos}{'count'} / $total_gene if($opt_m !~ /^0$/i);

		$max_skew = $skew if $max_skew < $skew;
		$min_skew = $skew if $min_skew > $skew;
		
		$min_gc = $gc if $min_gc > $gc;
		$max_gc = $gc if $max_gc < $gc;
		
		$max_cpg = $cpg if $max_cpg < $cpg;

		if ($opt_m !~ /^0$/i) {
			$max_ratio = $ratio if $max_ratio < $ratio;
			$min_count = $count if $min_count > $count;
			$max_count = $count if $max_count < $count;
		}
		
		$Rscript_cpg_y_ave .= "$cpg,";
		$Rscript_gc_y_ave  .= "$gc," ;
		$Rscript_skew_y_ave .= "$skew,";
		$Rscript_ratio_y_ave .= "$ratio," if($opt_m !~ /^0$/i);
		$Rscript_count_y_ave .= "$count," if($opt_m !~ /^0$/i);
		
	}
	
	($Rscript_cpg_y_ave) = $Rscript_cpg_y_ave =~ m/^(.*),$/i;
	$Rscript_cpg_y_ave .= ")";
	($Rscript_gc_y_ave) = $Rscript_gc_y_ave =~ m/^(.*),$/i;
	$Rscript_gc_y_ave .= ")";
	($Rscript_skew_y_ave) = $Rscript_skew_y_ave =~ m/^(.*),$/i;
	$Rscript_skew_y_ave .= ")";
	($Rscript_ratio_y_ave) = $Rscript_ratio_y_ave =~ m/^(.*),$/i if($opt_m !~ /^0$/i);
	$Rscript_ratio_y_ave .= ")" if($opt_m !~ /^0$/i);
	($Rscript_count_y_ave) = $Rscript_count_y_ave =~ m/^(.*),$/i if($opt_m !~ /^0$/i);
	$Rscript_count_y_ave .= ")" if($opt_m !~ /^0$/i);

	# Scaling on Plot #
	
	$max_skew = 0.4;
	$min_skew = -0.4;
		
	my $skew_dis = $max_skew - $min_skew;
	my $gc_dis = $max_gc - $min_gc;
	my $cpg_dis = $max_cpg;
	my $ratio_dis = $max_ratio if($opt_m !~ /^0$/i);
	my $count_dis = $max_count - $min_count if($opt_m !~ /^0$/i);

	
	print $out_file "
	pdf(\"$input.$nuc1\_p\_$nuc2.$cpg_size.$exp_CpGoe.$exp_GC.$win_min.$win_max.$kmer_min.$kmer_max.$exp_pvalue.pdf\")
	" if $opt_m =~ /^0$/i;
	
	print $out_file "
	pdf(\"$input.$nuc1\_p\_$nuc2.$cpg_size.$nucleotide.pdf\")
	" if $opt_m !~ /^0$/i;
	

	print $out_file "	
	x <- seq(from = -$x_axis_count*$scale, to = ($x_axis_count-1)*$scale, by = $scale)
	
	$Rscript_cpg_y_ave
	$Rscript_gc_y_ave
	$Rscript_skew_y_ave
	";
	my $max_multi_count_text = 0.02;
	my $max_multi_ratio_text = 5;
	if ($opt_m !~ /^0$/i) {
		print $out_file "
		$Rscript_ratio_y_ave
		$Rscript_count_y_ave
		y.ratio <- (y.ratio - 0) / ($max_multi_ratio_text-0)  * 100
		y.count  <- (y.count - 0) / ($max_multi_count_text-0) * 100
		";
	}

	print $out_file "
	y.cpg <- (y.cpg - 0) / (1.2-0)  * 100
	y.gc  <- (y.gc - 0.3) / (0.7-0.3) * 100
	y.skew <- (y.skew - $min_skew) / $skew_dis * 100
	";
	
	# CpG #
	my $cpg_text;
	for (my $i = 0; $i <= 1.2; $i+=0.1) {
		$cpg_text .= "text(2460,($i-0)*100/(1.2-0),\"$i\",cex=0.5)\nlines(c(2375,2400),c(($i-0)*100/(1.2-0),($i-0)*100/(1.2-0)),lwd=1)\n";
	}
	
	# GC #
	my $gc_text;
	for (my $i = 0.30; $i <= 0.70; $i+=0.10) {
		my $text_gc = $i * 100;
		$gc_text .= "text(2150,($i-0.3)/(0.7-0.3)*100,\"$text_gc\",cex=0.5)\nlines(c(2050,2075),c(($i-0.3)/(0.7-0.3)*100,($i-0.3)/(0.7-0.3)*100),lwd=1)\n";
	}
	
	# Skew #
	my $skew_text;
	#$min_skew = -0.15;
	#$max_skew = 0.15;
	#$min_skew = twodec($min_skew);
	#$max_skew = twodec($max_skew);
	for (my $i = $min_skew; $i <= $max_skew; $i+=0.01) {
		$i = 0 if $i =~ m/e/i;
		my $skew_text_float = $i;
		if ($skew_text_float =~ m/^-*\d.\d\d\d\d*$/i) {
			$skew_text_float = int(($skew_text_float-0.00000001) * 100)/100;
			
		}
		$skew_text .= "text(-2250,($i-$min_skew)/($max_skew-$min_skew)*100,\"$skew_text_float\",cex=0.5)\nlines(c(-2055,-2075),c(($i-$min_skew)/($max_skew-$min_skew)*100,($i-$min_skew)/($max_skew-$min_skew)*100),lwd=1)\n" if $i != $min_skew;
		$skew_text .= "text(-2250,0,\"$skew_text_float\",cex=0.5)\nlines(c(-2055,-2075),c(0,0),lwd=1)\n" if $i == $min_skew;
	}

	my $multi_count_text;
	if ($opt_m !~ /^0$/i) {

		# Count multinucleotide #
		for (my $i = 0; $i <= $max_multi_count_text; $i+=$max_multi_count_text/10) {
			my $text_gc = $i * 100;
			$multi_count_text .= "text(2800,($i-0)/($max_multi_count_text-0)*100,\"$text_gc\",cex=0.5,col=\"orange\")\nlines(c(2700,2725),c(($i-0)/($max_multi_count_text-0)*100,($i-0)/($max_multi_count_text-0)*100),lwd=1,col=\"orange\")\n";
		}
		# Ratio multinucleotide #
		for (my $i = 0; $i <= $max_multi_ratio_text; $i+=$max_multi_ratio_text/10) {
			my $text_gc = $i;
			$multi_count_text .= "text(3175,($i-0)/($max_multi_ratio_text-0)*100,\"$text_gc\",cex=0.5,col=\"black\")\nlines(c(3075,3100),c(($i-0)/($max_multi_ratio_text-0)*100,($i-0)/($max_multi_ratio_text-0)*100),lwd=1,col=\"black\")\n";
		}
	}


	# X Axis #
	my $xaxis_text;
	for (my $i = -2000; $i <= 2000; $i+=500) {
		my $text_x_axis = int($i*$step_size/$scale);
		$xaxis_text .= "lines(c($i,$i),c(0,-0.5),lwd=1)\ntext($i,-1.5,\"$text_x_axis\",cex=0.7)\n";
	}
	
	my $exp_GC_percent = 100 * $exp_GC;
	my ($scaleint) = $scale =~ /^(\d+\.\d\d)\d+$/i;
	$scaleint = $scale if not defined($scaleint);
	print $out_file "
	par(oma=c(0,0,0,0),mar=c(0,0,0,0))
	
	# Plot WIDTH #
	plot(NA,type=\"n\",xlim=c(-2400,3400),ylim=c(-5,110), yaxt=\"n\",bty=\"n\",xaxt=\"n\", ylab=NA, xlab=NA)

	lines(x,y.cpg,type=\"l\",col=\"blue3\",lwd=2)		# CpG O/E #
	lines(x,y.gc,type=\"l\",col=\"green3\",lwd=2)		# GC Cont #
	lines(x,y.skew,type=\"l\",col=\"red3\",lwd=2)		# GC Skew #
	";
	
	if($opt_m !~ /^0$/i) {
		print "Has Multinucleotide\n";
		print $out_file "
		lines(x,y.ratio,type=\"l\",col=\"black\",lwd=2)		# multinuc ratio #
		lines(x,y.count,type=\"l\",col=\"orange\",lwd=2)	# multinuc count #
		";
	}	
	print $out_file "
	 # X axis
	lines(c(min(x),max(x)),c(0,0),lwd=1)
	text(0,-5,\"Coordinates in relation to TSS (bp)\",cex=0.8)
	
	# CpG O/E
	lines(c(2375,2375),c(0,105),lwd=2,col=\"blue4\") 
	text(2600, 50, \"$nuc1\_p\_$nuc2 (or $nucleotide) obs/exp\", srt=270, cex=0.7,col=\"blue4\")

	# GC%
	lines(c(2050,2050),c(0,105),lwd=2,col=\"green4\") 
	text(2250, 50, \"$nuc2$nuc1 %\", srt=270, cex=0.7,col=\"green4\")

	# GC Skew
	lines(c(-2050,-2050),c(0,105),lwd=2,col=\"red4\") 
	text(-2400, 50, \"$nuc2$nuc1 skew\", srt=90, cex=0.7,col=\"red4\")
	";
	
	if ($opt_m !~ /^0$/i) {
		print $out_file "
			# Multi Nucleotide Count
			lines(c(2700,2700),c(0,105),lwd=2,col=\"orange\") 
			text(2900, 50, \"$nucleotide %\", srt=270, cex=0.7,col=\"orange\")
			# Multi Nucleotide Ratio
			lines(c(3075,3075),c(0,105),lwd=2,col=\"black\") 
			text(3275, 50, \"$nucleotide obs/exp\", srt=270, cex=0.7,col=\"black\")
		";
	}

	print $out_file "
	# Title
	text(0,107,\"$file_name ($gene_count of $total_gene genes, $cpg_size bp filter, $exp_CpGoe $nuc1\_p\_$nuc2 o/e, $exp_GC_percent % $nuc2$nuc1)\",cex=0.7)


	$cpg_text
	$gc_text
	$skew_text
	$xaxis_text
	";

	if ($opt_m !~ /^0$/i) {
		print $out_file "
		$multi_count_text
		";
	}
	
	print $out_file "
	# CpG Island dashed lines
	lines(c(-2050,2050),c(50,50),lty=2,lwd=1)
	
	# TSS Line
	lines(c(0,0),c(0,100),lty=3,lwd=3)
	lines(c(0,600),c(100,100),lty=3,lwd=3)
	lines(c(600,800),c(101,100),lty=1,lwd=1)
	lines(c(600,800),c(99,100),lty=1,lwd=1)
	lines(c(600,600),c(99,101),lty=1,lwd=1)
	
	
	# Legend lines
	lines(c(-1950,-1850),c(95,95),col=\"red3\")
	text(-1850+200,95,\"$nuc2$nuc1 Skew\",cex=0.6,col=\"red3\")
	lines(c(-1950,-1850),c(90,90),col=\"blue3\")
	text(-1850+200,90,\"$nuc1\_p\_$nuc2 o/e\",cex=0.6,col=\"blue3\")
	lines(c(-1950,-1850),c(85,85),col=\"green3\")
	text(-1850+150,85,\"$nuc2$nuc1%\",cex=0.6,col=\"green3\")
	dev.off()
	";
	
	
	close $out_file;
	my $R_run;
	$R_run  = "R --vanilla --no-save < $input.$nuc1\_p\_$nuc2.$cpg_size.$exp_CpGoe.$exp_GC.$win_min.$win_max.$kmer_min.$kmer_max.$exp_pvalue.R";
	#$R_run  = "R --vanilla --no-save < $input.$nuc1\_p\_$nuc2.$cpg_size.$exp_CpGoe.$exp_GC.$win_min.$win_max.$kmer_min.$kmer_max.$exp_pvalue.R" if $home =~ m/^\/Users\/stella$/i;
	#$R_run = "/home/mitochi/R-2.14.2/bin/R --vanilla --no-save < $input.$nuc1\_p\_$nuc2.$cpg_size.$exp_CpGoe.$exp_GC.$win_min.$win_max.$kmer_min.$kmer_max.$exp_pvalue.R" if $home =~ m/^\/home\/mitochi$/i;

	system($R_run)  == 0 or die "R failed to run: $!\n";
	
	return (0);
}
	
sub skew_check {
	my ($gcskew, $skew_loc) = @_;
	my $is_skew = 0;
	for (my $i = 0; $i < @skew; $i++) {
		my $sk_min = $skew[$i][0] + 2000;
		my $sk_max = $skew[$i][1] + 2000;
		next if ($skew_loc < $sk_min or $skew_loc > $sk_max);
		my $sk_num_min = $skew[$i][2];
		my $sk_num_max = $skew[$i][3];
		$is_skew = 1 if ($gcskew > $sk_num_max or $gcskew < $sk_num_min);
		print "at $sk_min: last if ($gcskew > $sk_num_max or $gcskew < $sk_num_min)\n" if ($gcskew > $sk_num_max or $gcskew < $sk_num_min);
		last if ($gcskew > $sk_num_max or $gcskew < $sk_num_min);
	}
	return ($is_skew);
}
sub multinucleotide_count {
	my ($sequence, $window_size, $nucleotide) = @_;
	die "Cannot run multinucleotide count: multi nucleotide size must be larger than 1 (-m $nucleotide is only 1)!\n" unless length($nucleotide) > 1;
	my $nucsize = length($nucleotide);
	my %oddratio;
	
	# Obs and Exp count

	# Expected denominator
	my %denom;
	my %nom;
	my @singles = split("", $nucleotide);
	my %singles;
	foreach my $single(@singles) {
		next if defined($singles{'buffer'}{$single});
		$singles{'buffer'}{$single}++;
	}
	for (my $i = 0; $i < 2; $i++) {
		$nom{$i}{'name'} = substr($nucleotide, $i, $nucsize-1);
	}
	for (my $i = 0; $i < 3; $i++) {
		$denom{$i}{'name'} = substr($nucleotide, $i, $nucsize-2);
	}

	for (my $i = 0; $i < length($sequence)-$window_size; $i+= $step_size) {
	
		my $seq_part = substr($sequence, $i, $window_size);
		my ($oddratio, $nucleotide_count) = (0,0);
		
		foreach my $single (keys %{$singles{'buffer'}}) {
			$singles{'count'}{$single} = $seq_part =~ tr/A/A/ if $single =~ /A/;
			$singles{'count'}{$single} = $seq_part =~ tr/T/T/ if $single =~ /T/;
			$singles{'count'}{$single} = $seq_part =~ tr/G/G/ if $single =~ /G/;
			$singles{'count'}{$single} = $seq_part =~ tr/C/C/ if $single =~ /C/;
		}

		my $totalnom;
		for (my $i = 0; $i < @singles; $i++) {
			$totalnom *= $singles{'count'}{$singles[$i]} if $i != 0;
			$totalnom = $singles{'count'}{$singles[0]} if $i == 0;
		}
		$totalnom /= ($window_size**(@singles-1));
		# Markov Model Max
		#my $totaldenom = 0;
		#for (my $j = 0; $j < 3; $j++) {
		#	while ($seq_part =~ /$denom{$j}{'name'}/ig) {
		#		$denom{$j}{'count'}++;
		#	}
		#
		#	$denom{$j}{'count'} = 0 if not defined($denom{$j}{'count'});
		#	$totaldenom = $j != 0 ? $totaldenom * $denom{$j}{'count'} : $denom{$j}{'count'};
		#}
		#my $totalnom = 0;
		#for (my $j = 0; $j < 2; $j++) {
		#	while ($seq_part =~ /$nom{$j}{'name'}/ig) {
		#		$nom{$j}{'count'}++;
		#	}
		#$nom{$j}{'count'} = 0 if not defined($nom{$j}{'count'});
		#	$totalnom = $j != 0 ? $totalnom * $nom{$j}{'count'} : $nom{$j}{'count'};
		#}
		#$totalnom = $totaldenom == 0 ? 0 : $totalnom/$totaldenom;
		# #############
		
		while ($seq_part =~ /$nucleotide/ig) {
			$nucleotide_count++;
		}
		$oddratio{$i}{'ratio'} = $totalnom == 0 ? 0 : $nucleotide_count / $totalnom;
		$oddratio{$i}{'count'} = $nucleotide_count / $window_size;
		die if not defined($oddratio{$i}{'ratio'});
		die if not defined($oddratio{$i}{'count'});

	}
	return(\%oddratio);			
	

}

sub cpg_count {
	my ($sequence, $window_size, $bool_skew) = @_;
	my %cpg;
	my $skew_check = 0;
	# Variables #

	# Sliding window #
	for (my $i = 0; $i < length($sequence)-$window_size; $i += $step_size) { # change i to 1 for 1 bp window step
		
		my $seq_part = substr($sequence, $i, $window_size);
		my ($cpg_count, $nuc1_count, $nuc2_count) = (0, 0, 0);
		
		# Count by Transliterate #
		$nuc2_count = $seq_part =~ tr/A/A/ if $nuc1 =~ /A/;
		$nuc2_count = $seq_part =~ tr/T/T/ if $nuc1 =~ /T/;
		$nuc2_count = $seq_part =~ tr/G/G/ if $nuc1 =~ /G/;
		$nuc2_count = $seq_part =~ tr/C/C/ if $nuc1 =~ /C/;
								
		$nuc1_count = $seq_part =~ tr/A/A/ if $nuc2 =~ /A/;
		$nuc1_count = $seq_part =~ tr/T/T/ if $nuc2 =~ /T/;
		$nuc1_count = $seq_part =~ tr/G/G/ if $nuc2 =~ /G/;
		$nuc1_count = $seq_part =~ tr/C/C/ if $nuc2 =~ /C/;
		
		while ($seq_part =~ /$nuc1$nuc2/g) {
			$cpg_count++;
		}
		
		if ($opt_s and $bool_skew =~ m/true/) {
			my $gcskew = (($nuc1_count + $nuc2_count) != 0) ? ($nuc1_count-$nuc2_count)/($nuc1_count+$nuc2_count) : 0;
			$skew_check = skew_check($gcskew, $i);
			print "lasted at $i\n" if $skew_check == 1;
			last if $skew_check == 1;
		}
		
		$cpg{$i}{'cpg'}  = ($nuc2_count > 0 and $nuc1_count > 0) ? $cpg_count/($nuc2_count*$nuc1_count) * $window_size : 0;
		$cpg{$i}{'gc'}   = ($nuc1_count+$nuc2_count)/$window_size;
		$cpg{$i}{'skew'} = (($nuc1_count + $nuc2_count) != 0) ? ($nuc1_count-$nuc2_count)/($nuc1_count+$nuc2_count) : 0;
		die if not defined($cpg{$i}{'cpg'});
		die if not defined($cpg{$i}{'gc'});
		die if not defined($cpg{$i}{'skew'});
		#print "at $i: C = $nuc1_count, G = $nuc2_count, GCskew = $cpg{$i}{'skew'}\n";
	}
	return(\%cpg, $skew_check);
}

#	in a 4000bp, a 6 has a chance to appear once at
#	
#
#
#

sub GCbox_type {
	my ($gcbox, $gchead, $sequence, $header) = @_;

	my %temp_gcbox;
	my %temp_header;
	$header_count++;
	my %gcbox = %{$gcbox};
	my %gchead = %{$gchead};
	for (my $i = $kmer_max; $i > $kmer_min-1; $i--) {
		my $exp_gcbox = $probabilities{$i};
		my $length = length($sequence);
		for (my $j = $win_min; $j < $win_max-$i; $j++) {
			my $seq_part = substr($sequence, $j, $i);
			my $checkseq = 0;
			if ($seq_part =~ m/CG/i) {
				#foreach my $seq_part_check (keys %gcbox) {
					#if ($seq_part_check =~ m/^$seq_part$/i) {
					#}

					#elsif ($seq_part_check =~ m/$seq_part/i) {
					#	print "$seq_part_check =~ m/$seq_part/i\n";
					#	$checkseq = 1;
					#	last;
					#}
				#}
				#last if ($checkseq == 1);
				$location_count++;
				$temp_gcbox{$seq_part}{'amount'}++;
				$temp_gcbox{$seq_part}{$j}++; 
				$temp_header{$seq_part}{'header'}{$header_count} = $header;
				$temp_header{$seq_part}{'location'}{$j}{$location_count} = $header;
			}
		}
		
		foreach my $seq_part(keys %temp_gcbox) {
			if ($temp_gcbox{$seq_part}{'amount'} < $exp_gcbox) {
				delete $temp_gcbox{$seq_part}; 
				delete $temp_header{$seq_part};
			}
		}
	}
	
	foreach my $seq_part(keys %temp_gcbox) {
		foreach my $j (keys %{$temp_gcbox{$seq_part}}) {
			$gcbox{$seq_part}{$j} += $temp_gcbox{$seq_part}{$j};
			foreach my $loc (keys %{$temp_header{$seq_part}{'location'}{$j}}) {
				$gchead{$seq_part}{'location'}{$j}{$loc} = $temp_header{$seq_part}{'location'}{$j}{$loc};
			}
		}
		foreach my $header_count (keys %{$temp_header{$seq_part}{'header'}}) {
			$gchead{$seq_part}{'header'}{$header_count} = $temp_header{$seq_part}{'header'}{$header_count};
		}
	}
	

	return (\%gcbox, \%gchead);
}


sub twodec {
	my ($number0) = @_;
	my ($number) = $number0 == 0 ? 0 : $number0 =~ m/^(-*\d+.\d\d)/i;
	die "number = $number0\n" if not defined($number);
	return($number);
}

sub revcomp {
	my ($sequence) = @_;
	$sequence =~ tr/[ATGC]/[TACG]/;
	$sequence = reverse($sequence);
	return ($sequence);
}

sub prob {
	my ($number) = @_;	
	my $prob = 1-(1-(0.25**$number))**($win_max - $win_min);
	$number = $prob/$exp_pvalue < 2 ? 2 : $prob/$exp_pvalue;
	return($number);
}

sub make_prob_table {
	my %probabilities;
	for (my $i = $kmer_min; $i < $kmer_max+1; $i++) {
		$probabilities{$i} = prob($i);
	}
	return(\%probabilities);
}

__END__

Need to work on chromosome of different organism
Human has 1-23,X,Y
Cat has A1, B1, etc
Celegans has roman numeral
