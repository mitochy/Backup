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

use strict; use warnings; 
use Getopt::Std;
use FAlite;
use mitochy;
use R_toolbox;
use Cache::FileCache;

# Getopts #
use vars qw($opt_f $opt_g $opt_o $opt_c $opt_m $opt_d $opt_a $opt_k $opt_r $opt_s $opt_l);
getopts("f:g:o:cd:ma:klrs:");

# -g: Graph param. It is pc,CGCGC.add.pc,GCGCG.add etc OR could be any file ending with .kmer IF you want the score to be listed as well.
my $kmerscorecheck = 1 if defined($opt_g) and $opt_g =~ /.kmer$/i;

# -c: Combine each type of kmer graph (o/e for example) int one nomatter what kmer it is
## GCCG percent: 0.5 at TSS-150, CGC percent: 1.2 at TSS_200. Combine = (1.2+0.5/)2 = 0.85

# -m: Combine bunch of fasta file lines into one graph
## Input is a bunch of fasta files from organisms but distinct
## Output is a single R graph containing lines(org1)

# -k: Make a kmer map based on where each kmer highest oe (and if there exists another location where the score is similar)
# -s: Score that will be displayed beside each kmer map

# Time #
my @timedata = localtime(time);
$timedata[4] += 1;
$timedata[5] += 1900;
my $time = "$timedata[2]:$timedata[1]:$timedata[0] $timedata[4]/$timedata[3]/$timedata[5]";

# Cache #
my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
my $exon_db = $cache -> get("exondb");

# Input #
print_usage() if not ($opt_a) and not defined(@ARGV);
#print_usage() and print "Cannot use both -m and -k at the same time\n" if ($opt_m) and ($opt_k);
my ($input) = @ARGV if not ($opt_m);
my (@input) = @ARGV if $opt_m and not ($opt_a);
if ($opt_a and $opt_m) {
	@input = <*$opt_a*.fa>;
}

my $number_of_input = @input if ($opt_m);
$number_of_input = 1 if not $opt_m;
die "Please enter at least 1 input!\n" if @input == 0 and ($opt_m);

# Output #
my $output = $opt_o if defined($opt_o);
if (not defined($opt_o)) {
	$output = defined($opt_a) ? "$opt_a.cpgheavy" : "$ARGV[0].cpgheavy";
}

# Global Variables #
my @bigOrg = mitochy::return_org();
my $unk_count = 0;
my $ORG = define_org($input) if not ($opt_m);
$ORG = "multiple" if ($opt_m);
my @COLOR = ("rgb(0,0,255,maxColorValue=255)","rgb(255,0,0,maxColorValue=255)","rgb(0,100,0,maxColorValue=255)","rgb(139,0,139,maxColorValue=255)");
my @COLOR_LIGHT = ("rgb(150,150,255,maxColorValue=255)","rgb(255,150,150,maxColorValue=255)","rgb(150,255,150,maxColorValue=255)","rgb(255,150,255,maxColorValue=255)");
#my @COLOR_OPTK = qw(antiquewhite4 aquamarine4 azure4 bisque4 blue4 brown4 burlywood4 cadetblue4 chartreuse4 chocolate4 coral4 cornsilk4 cyan4 darkgoldenrod4 darkolivegreen4 darkorange4 darkorchid4 darkseagreen4 darkslategray4 deeppink4 deepskyblue4 dodgerblue4 firebrick4 gold4 goldenrod4 gray4 gray14 gray24 gray34 gray40 gray41 gray42 gray43 gray44 gray45 gray46 gray47 gray48 gray49 gray54 gray64 gray74 gray84 4color name color name gray94 green4 honeydew4 hotpink4 indianred4 ivory4 khaki4 lavenderblush4 lemonchiffon4 lightblue4 lightcyan4 lightgoldenrod4 lightpink4 lightsalmon4 lightskyblue4 lightsteelblue4 lightyellow4 magenta4 maroon4 mediumorchid4 mediumpurple4 mistyrose4 navajowhite4 olivedrab4 orange4 orangered4 orchid4 palegreen4 paleturquoise4 palevioletred4 peachpuff4 pink4 plum4 purple4 red4 rosybrown4 royalblue4 salmon4 seagreen4 seashell4 sienna4 skyblue4 slateblue4 slategray4 snow4 springgreen4 steelblue4 tan4 thistle4 tomato4 turquoise4 violetred4 wheat4 yellow4);
my @COLOR_OPTK;
for (my $i = 0; $i < 99999; $i+=10) {
	for (my $j = 0 ; $j < 10; $j++) {
		$COLOR_OPTK[$i+$j] = "red4" if $j == 0; 
		$COLOR_OPTK[$i+$j] = "darkorange" if $j == 1; 
		$COLOR_OPTK[$i+$j] = "chocolate" if $j == 2; 
		$COLOR_OPTK[$i+$j] = "blue" if $j == 3; 
		$COLOR_OPTK[$i+$j] = "blue4" if $j == 4; 
		$COLOR_OPTK[$i+$j] = "magenta" if $j == 5; 
		$COLOR_OPTK[$i+$j] = "purple" if $j == 6; 
		$COLOR_OPTK[$i+$j] = "azure4" if $j == 7; 
		$COLOR_OPTK[$i+$j] = "darkolivegreen4" if $j == 8; 
		$COLOR_OPTK[$i+$j] = "green4" if $j == 9; 
	}
}
my $SCORE;
my %MARKOV;

#my @COLOR_OPTK = qw(black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray black gray);

# Main #

## Filter Param ##
print "Processing filter parameters...\n";
my $filter = process_filter_param() if defined($opt_f);
print "Done!\n";

## Graph Param ##
print "Processing graph parameters...\n";
my $graph  = process_graph_param() if ($opt_g !~ /.kmer$/i);
$graph  = process_kmerfile($opt_g) if ($opt_g =~ /.kmer$/i);
my %graph = %{$graph};
my $STEP_SIZE   = defined($graph{'step'})   ? $graph{'step'}   : 1  ; #Default
my $WINDOW_SIZE   = defined($graph{'window'})   ? $graph{'window'}   : 200  ; #Default
print "Done!\n";

## Commands (for file name) ##
my $command = $opt_f . $opt_g if defined($opt_f) and defined($opt_g);
$command = $opt_f if defined($opt_f) and not defined($opt_g);
$command = $opt_g if defined($opt_g) and not defined($opt_f);
print "$command\n";

## Processing Fasta Single File ##
print "Processing fasta...\n";
my ($gene, $gene_count, $total_gene);
my $numberofinput = 0;
if (not $opt_m) {
	if (defined($opt_d) and $opt_d > -1) {
		print "\tProcessing Cache...\n";
		print "\t\tGetting cache from $input.$command\n";
		my $genedata = $cache -> get("$input.$command");
			if (not defined($genedata) or $opt_d == 1) {
			print "\t\teither requested or cache does not exists, creating\n";
			($gene, $gene_count, $total_gene) = process_fasta_single($input, $filter, $graph);
			my @genedata = ($gene, $gene_count, $total_gene);
			$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
			$cache -> set("$input.$command", \@genedata);
			print "\t\tsetting cache at $input.$command\n";
		}
		$genedata = $cache -> get("$input.$command");
		print "\t\tGetting recently saved cache from $input.$command\n";
		($gene, $gene_count, $total_gene) = @{$genedata};
		print "\t\tDone!\n";
	}
	
	# Processing Fasta without Cache #
	($gene, $gene_count, $total_gene) = process_fasta_single($input, $filter, $graph) if (not defined($opt_d) or $opt_d < 0);
	print "Done!\n";
	print "Fatal: no gene found!\n" and exit(0) if $gene_count == 0;
	$numberofinput = 1;
}

# Processing Fasta and graphing with multiple inputs
my @line;
my ($total_gene_multi, $gene_count_multi) = (0,0);
$input = $opt_a if not defined($input);
if ($opt_m) {
	my %totalgene;
	my $totalgene = 0;
	my $org_count = 0;
	my $cache_check = 1;
	if (defined($opt_d) and $opt_d == 0) {
		print "\tProcessing Cache...\n";
		print "\t\tGetting cache from $input.$command\n";
		my @totalgene = @{$cache -> get("$input.$command")};
		if (defined($totalgene[0])) {
			($gene, $gene_count, $total_gene, $numberofinput) = @totalgene;
			die "Cache error!\n" if not defined($gene) or not defined($gene_count);
			print "GENE COUNT = $gene_count, TOTAL GENE = $total_gene\n";
			$cache_check = 0;
		}
	}
	elsif ($cache_check == 1) {
		print "\t\teither requested or cache does not exists, creating\n";
		foreach my $input (@input) {
			my ($org) = $input =~ /\w+\.(\w+)\.fa$/i;
			($org) = $input =~ /\w+\.(\w+)\..+\.fa$/i if not defined($org);
			die "Define file as {family}.{org}.fa\n" unless defined($org);
			($gene, $gene_count, $total_gene) = process_fasta_single($input, $filter, $graph);
			print "Nexted due to no gene\n" and $number_of_input -= 1 and next if $gene =~ /^0$/;
			my %gene = %{$gene};
			$org_count++ if ($opt_m);
			foreach my $param (keys %{$gene{0}}) {
				foreach my $type (keys %{$gene{0}{$param}}) {
					print "$type\n";
					for (my $i = 0; $i < @{$gene{0}{$param}{$type}}; $i++) {
						if (not $opt_k) {
							$totalgene{$org_count}{$param}{"$type.$org"}[$i] = defined($gene{0}{$param}{$type}[$i]) ? $gene{0}{$param}{$type}[$i] : 0;
							$totalgene{0}{$param}{"$type.optm"}[$i] += defined($gene{0}{$param}{$type}[$i]) ? $gene{0}{$param}{$type}[$i] : 0;
							my $value = $totalgene{$org_count}{$param}{"$type.$org"}[$i];
							#$line[$i]{$param}{high} = $value if not defined($line[$i]{$param}{high});
							#$line[$i]{$param}{low} = $value if not defined($line[$i]{$param}{low});
							#$line[$i]{$param}{high} = $value if $value > $line[$i]{$param}{high};
							#$line[$i]{$param}{low} = $value if $value < $line[$i]{$param}{low};
							push(@{$line[$i]{$param}{values}}, $value);
							#print "value = $value\t$line[$i]{$param}{high}\n" if $i % 100 == 0;
						}
						if ($opt_k) {
							my $type2 = defined($gene{0}{$param}{$type}[$i]) ? $gene{0}{$param}{$type}[$i] : "NA";
							$totalgene{0}{$param}{"optk"}[$i]{$type2}++;
							
						}
					}
				}
			}
			$gene_count_multi += $gene_count;
			$total_gene_multi += $total_gene;

			
		}
		foreach my $param (keys %{$totalgene{0}}) {
			foreach my $type (keys %{$totalgene{0}{$param}}) {
				for (my $i = 0; $i < @{$totalgene{0}{$param}{$type}}; $i++) {
					if (not $opt_k) {
						#print "$type\n";# if $type =~ /optm$/;
						if ($type =~ /optm$/) {
							$totalgene{0}{$param}{$type}[$i] /= $number_of_input if $type =~ /optm$/; #THIS IS AVERAGE
							my $average = $totalgene{0}{$param}{$type}[$i];
							foreach my $values (@{$line[$i]{$param}{values}}) {
								$line[$i]{$param}{dev} += (($average - $values) **2) / @{$line[$i]{$param}{values}};
							}
							$line[$i]{$param}{dev} = sqrt($line[$i]{$param}{dev});
							$line[$i]{$param}{high} = $average + $line[$i]{$param}{dev};
							$line[$i]{$param}{low} = $average - $line[$i]{$param}{dev} == 0 ? 0 : $average - $line[$i]{$param}{dev};
						}
					}
					if ($opt_k) {
						if (not $opt_l) { #Get the highest
							foreach my $type2 (sort {$totalgene{0}{$param}{'optk'}[$i]{$b} <=> $totalgene{0}{$param}{'optk'}[$i]{$a}} keys %{$totalgene{0}{$param}{'optk'}[$i]}) {
								next if $type2 =~ /NA/;
								$totalgene{0}{$param}{'optk'}[$i]{'type'} = $type2; #type is nucleotide (TGC)
								$totalgene{0}{$param}{'optk'}[$i]{'score'} = $totalgene{0}{$param}{'optk'}[$i]{$type2}; #score is pc
								last;
							}
						}
						if ($opt_l) { #Get the lowest
						
							foreach my $type2 (sort {$totalgene{0}{$param}{'optk'}[$i]{$a} <=> $totalgene{0}{$param}{'optk'}[$i]{$b}} keys %{$totalgene{0}{$param}{'optk'}[$i]}) {
								next if $type2 =~ /NA/;
								$totalgene{0}{$param}{'optk'}[$i]{'type'} = $type2; #type is nucleotide (TGC)
								$totalgene{0}{$param}{'optk'}[$i]{'score'} = $totalgene{0}{$param}{'optk'}[$i]{$type2}; #score is pc
								last;
							}
						}
					}
				}
			}
		}
		$gene = \%totalgene;
		$gene_count = int($gene_count_multi/$number_of_input) == 0 ? 1 : int($gene_count_multi/$number_of_input);
		$total_gene = int($total_gene_multi/$number_of_input);
		$numberofinput = $org_count+1;
		print "NUM OF INPUT = $numberofinput, totalgene = $total_gene, genecount = $gene_count\n";
		print "\t\tsetting cache at $input.$command\n" if defined($opt_d) and $opt_d == 1;
		my @totalgene = ($gene, $gene_count, $total_gene, $numberofinput) if defined($opt_d) and $opt_d == 1;
		$cache -> set("$input.$command", \@totalgene) if defined($opt_d) and $opt_d == 1;
	}


}

if (keys (%MARKOV) != 0) {
	print "markov defined, number of input; $number_of_input\n";
	foreach my $param (keys %MARKOV) {
		foreach my $type (keys %{$MARKOV{$param}}) {
			$MARKOV{$param}{$type} /= $gene_count;
		}	
	}
}
				

if ($opt_m and $opt_k) {

}

my %gene = %{$gene};
if ($opt_k) {
foreach my $num (keys %gene) {
	foreach my $param (keys %{$gene{$num}}) {
		my @array = @{$gene{$num}{$param}{'optk'}};
		for (my $i = 0; $i < @array; $i++) {
			next if not defined($array[$i]{'type'});
			my $kmer = $array[$i]{'type'};
			my $score = $array[$i]{'score'};
			print "at $i: $kmer $score\n";
		}
	}
}
}
print "Making R script graph...\n";
my $pdffile = R_graph_single($output, $gene, $gene_count, $total_gene, \@line);
print "Done!\n";

# Running R Script #
print "Running R script...\n";
R_toolbox::execute_Rscript("$pdffile.R") if ($opt_r);
print "PDF IS AT $pdffile.pdf\n" if ($opt_r);
print "output is at $pdffile.R\n" if not ($opt_r);
print "PDF (not created) IS AT $pdffile.pdf\n" if not($opt_r);


##############################################################
#				o
# 			    .    ##					<><:
# 			     .   #   
# 			  ###################  +
# 			#####SUBROUTINES######+++
# 			 ###################   +
#
############################################################################

sub print_usage {
	die "usage: cpgheavy.pl <fasta file>\nExample:cpgheavy.pl -f oe_cg_0.6_200_add_dinuc_cg_0.5_200 -g oe\.TA\.add\.oe\.CG\.add\.pc\.CCGCC\.add\.dinuc\.GC\.add\.skew\.CT\.add\.oe\.CCGCC\.add\.skew\.CG hsapiens_geneseq_chrCEGMA_all.fa T\n";
}
sub define_org {
	my ($input) = @_;
	my $ORG;
	foreach my $bigOrg (@bigOrg) {
		my ($bigOrg_lastname) = $bigOrg =~ /^\w(\w+)$/;
		$ORG = $bigOrg if $input =~ /$bigOrg_lastname/i;
	}
	if (not defined($ORG)) {
		print "Organism not defined from filename. Make sure file name has organism name in it\n";
		$ORG = "Unknown_$unk_count";
		$unk_count++;
	}
	return($ORG);
}

sub process_filter_param {
	my @filter = split("\.add\.", $opt_f);
	my %filter;
	print "\tFilter Parameters:\n";
	my $count = 0;
	foreach my $filter (@filter) {
		my ($param, $type, $val, $window) = $filter =~ /(.+)\,(.+)\,(.+)\,(.+)/;
		$type = uc($type);
		die "Undefined filter input at $filter\n" unless defined($param) and defined($val) and defined($window);
		$filter{'nuc'}{$param}{$type}{'val'} = $val if $param =~ /^oe$/ or $param =~ /^pc$/ or $param =~ /^skew$/ or $param =~ /dinuc/;
		$filter{'nuc'}{$param}{$type}{'window'} = $window if $param =~ /^oe$/ or $param =~ /^pc$/ or $param =~ /^skew$/ or $param =~ /dinuc/;
		$filter{'intron'}++ if $param =~ /^intron$/i;
		$filter{'nointron'}++ if $param =~ /^nointron$/i;

		$count++;
		print "\t$count $param:$type ($val)\n";
	}
	return(\%filter);
}

## Window Size and Step Size #
sub process_graph_param {
	print "\tUsing default graph parameter of CpG Island, GC Percent, and GC skew\n" unless defined($opt_g);

	my @graph;
	if (defined($opt_g)) {
		@graph = split(".add.", $opt_g);
		my $check = 0;
		foreach my $graph (@graph) {
			next if $graph =~ /window/ or $graph =~ /step/;
			$check++;
		}
		push (@graph, "oe,CG", "dinuc,GC", "skew,GC") if $check == 0;
	}
	if (not defined($opt_g)) {
		$opt_g = "oe,CG.add.dinuc,GC.add.skew,GC";
		push (@graph, "oe,CG", "dinuc,GC", "skew,GC");
	}

	my %graph;
	print "\tGraph Parameters:\n";
	my $count = 0;
	if (not $opt_k) {
		foreach my $graph (@graph) {
			my ($param, $type, $score) = split(",",$graph) ;
			$type = uc($type);
			die "\tUndefined graph parameter at $graph\n" unless defined($param) and defined($type);
			$graph{'nuc'}{$param}{$type}++ if $param =~ /^oe$/ or $param =~ /^pc$/ or $param =~ /^skew$/ or $param =~ /dinuc/;
			$graph{'window'} = $type if $param =~ /window/;
			$graph{'step'} = $type if $param =~ /step/;
			$graph{'score'}{$type} = $score if defined($score);
			$SCORE = $score if defined($score);
			$count++;
			print "\t$count $param:$type\n";
		}
	}
	elsif ($opt_k) {
		die "\tFATAL: Please input at least 1 pc kmer (e.g. -g pc,AT) \n" unless grep(/pc/, @graph);
		foreach  my $graph (@graph) {
			my ($param, $type, $score) = split(",",$graph) ;
			next if $param !~ /window/ and $param !~ /step/ and $param !~ /pc/;
			$type = uc($type);
			die "\tUndefined graph parameter at $graph\n" unless defined($param) and defined($type);
			$graph{'window'} = $type if $param =~ /window/;
			$graph{'step'} = $type if $param =~ /step/;
			$graph{'nuc'}{$param}{$type}++ if $param =~ /^pc$/;
			$graph{'score'}{$type} = $score if defined($score);
			print "\tGraph param $count $param:$type score = $score\n" if defined($score);
			print "\tGraph param $count $param:$type\n" if not defined($score);
		}
	}
		
	return(\%graph);
}

sub process_fasta_single {
	my ($input, $filter, $graph) = @_;
	print "\tinput = $input\n";
	my ($total_gene, $gene_count) = (0,0);	
	my %gene;
	my %filter = %{$filter} if defined($opt_f);

	# 2. FAlite to process each sequence (fasta formatted) #
	open (my $in, "<", $input) or die "\tCannot read gene fasta file from $input: $!\n";
	open (my $out, ">>", "introntables") or die "\t Cannot write to $input.introntable: $!\n";
	my $fasta = new FAlite($in);
	while (my $entry = $fasta -> nextEntry) {
		my $header = $entry->def;
		my $seq    = $entry->seq;
		$total_gene++;
		
		# 2.a Filter by filter params
		if (defined($filter{'nuc'})) {
			my $result = 1;
			$result = filter_nuc($seq, $filter);
			print "\tGene $header filtered\n" if $result == 0;
			next if $result == 0;
		}
		if (defined($filter{'intron'})) {
			my ($id) = $header =~ />(.+)_strand_=/;
			print "\tGene $header filtered due to having intron\n" and next if has_intron($id) == 0;
			
		}
		if (defined($filter{'nointron'})) {
			my ($id) = $header =~ />(.+)_strand_=/;
			print "\tGene $header filtered due to having no intron\n" and next if has_intron($id) == 1;
		}
		
		# 2.b Count graph params
		$gene_count++;
		print "\t$gene_count Processing $header\n";
		my %final_count = %{graph_nuc($seq, $graph)};
		foreach my $param (keys %{$final_count{0}}) {
			foreach my $type (keys %{$final_count{0}{$param}}) {
				for (my $i = 0; $i < @{$final_count{0}{$param}{$type}}; $i++) {
					if (not $opt_c) {
						$gene{0}{$param}{$type}[$i] += $final_count{0}{$param}{$type}[$i] if (not $opt_c);
					}
					elsif ($opt_c) {
						$gene{0}{$param}{'combine'}[$i] += $final_count{0}{$param}{$type}[$i] if ($opt_c);
					}
				}
			}
		}
	}
	print "Processing final graph parameters...\n";
	my %kmer_map;
	my $highest_pos = 0;
	foreach my $param (keys %{$gene{0}}) {
		foreach my $type (keys %{$gene{0}{$param}}) {
			my @highest;

			## OPT K 
			if ($opt_k) { # Get the coordinate of highest(s) oe of each queried kmer
				# Sort by large -> small #
				#my @highest_temp = sort {$gene{0}{$param}{$type}[$b] <=> $gene{0}{$param}{$type}[$a]} @{$gene{0}{$param}{$type}};
				my @highest_temp = sort {$b <=> $a} @{$gene{0}{$param}{$type}} if not($opt_l);
				@highest_temp = sort {$a <=> $b} @{$gene{0}{$param}{$type}} if ($opt_l);

				# Divide each value by gene count;
				for (my $i = 0; $i < @highest_temp; $i++) {
					$highest_temp[$i] /= $gene_count;
				}

				# Get the highest score to array (or lowest score if $opt_l)
				push(@highest, $highest_temp[0]);
				print "HIGHEST = $highest_temp[0]\n" if not $opt_l;
				print "LOWEST = $highest_temp[0]\n" if $opt_l;
	

				# Also take value that are close (>90%) to highest score, but when it's not flat (mean is < 0.75 of highest temp)
				for (my $i = 1; $i < @highest_temp; $i++) {
					push(@highest, $highest_temp[$i]) if not grep(/^$highest_temp[$i]$/, @highest);# and $highest_temp[$i] > 0.99*$highest_temp[0] and not($opt_l);#mitochy::ave(@highest_temp) < 0.75*$highest_temp[0] and not($opt_l);
					push(@highest, $highest_temp[$i]) if not grep(/^$highest_temp[$i]$/, @highest);# and $highest_temp[$i] < 1.01*$highest_temp[0] and $opt_l;# and mitochy::ave(@highest_temp) < 1.5*$highest_temp[0];

				}

			}
			$highest_pos = @{$gene{0}{$param}{$type}};
			my $highest2 = -9999999 if not($opt_l);
			$highest2 = 9999999 if ($opt_l);

			# Score of (pc, oe, etc)
			for (my $i = 0; $i < @{$gene{0}{$param}{$type}}; $i++) {
				next if $type !~ /combine/ and $opt_c;
				$gene{0}{$param}{$type}[$i] /= $gene_count;
				my $totalscore = $gene{0}{$param}{$type}[$i];
				$highest2 = $totalscore if $totalscore > $highest2 and not($opt_l);
				$highest2 = $totalscore if $totalscore < $highest2 and ($opt_l);
				
				# If it's this location is one of the highest/lowest peak list, then put it in hash
				$kmer_map{0}{$param}{$type}[$i] = $totalscore if grep (/^$totalscore$/, @highest) and $opt_k;
			}		
		}
	}
	
	# DEBUG OPT_K #
	my %kmer_map_final;
	if ($opt_k) {
		foreach my $param (keys %{$kmer_map{0}}) {
			foreach my $type (keys %{$kmer_map{0}{$param}}) {
				for (my $i = 0; $i < $highest_pos; $i++) {
					foreach my $type2 (keys %{$kmer_map{0}{$param}}) {
						my $score = $kmer_map{0}{$param}{$type2}[$i];
						next if not defined($score);
						#print "$i $type2($score)\n";
						if (defined($kmer_map_final{0}{$param}{'optk'}[$i])) {
							$kmer_map_final{0}{$param}{'optk'}[$i] = $type2 if $kmer_map{0}{$param}{$type2}[$i] > $kmer_map{0}{$param}{$kmer_map_final{0}{$param}{'optk'}[$i]}[$i];
						}
						else {
							$kmer_map_final{0}{$param}{'optk'}[$i] = $type2;
						}
					}
				}
			last;
			}
		}
		%gene = %kmer_map_final;
	}
	
	print "Done!\n";

	return(0) if $total_gene == 0;
	return(0) if $gene_count == 0;
	return(\%gene, $gene_count, $total_gene);
}

sub filter_nuc {
	my ($seq, $filter) = @_;

	my %filter = %{$filter};
	if (defined($filter{'nuc'})) {
	my $check = 0;
	my $num_of_param = 0;
	foreach my $param (keys %{$filter{'nuc'}}) {
		foreach my $type (keys %{$filter{'nuc'}{$param}}) {
			$num_of_param++;
		}
	}
	foreach my $param (keys %{$filter{'nuc'}}) {
		foreach my $type (keys %{$filter{'nuc'}{$param}}) {
			die "FATAL ERROR AT COMBINE\n" if ($opt_c and $type !~ /combine/);
			my $val    = $filter{'nuc'}{$param}{$type}{'val'}   ; # 0.6 | 0.001
			my $window_size = $filter{'nuc'}{$param}{$type}{'window'}; # 200 (bp)
			die "\tUndefined filter window size\n" unless defined($window_size);
			if ($param !~ /^oe$/ and $param !~ /^pc$/ and $param !~ /^skew$/ and $param !~ /^dinuc$/) {
				$check++;
				next;
			}
			
			for (my $i = 1500; $i < 2500; $i++) {
				my $seq_part = substr($seq, $i, $window_size);
				my %count = %{count_nuc($type, $seq_part)};
				if ($param =~ /^oe$/i) {
					my (@denom) = split("", $type);
					my ($nom, $denom) = ($count{$type}, $count{$denom[0]});
					for (my $j = 1; $j < @denom; $j++) {
						$denom *= $count{$denom[$j]};
					}
					my $oe = $denom == 0 ? 0 : $nom *($window_size**(@denom-1)) / $denom;
					$check++ and last if $oe > $val;
				}
				elsif ($param =~ /^pc$/i) {
					$check++ and last if $count{$type}/$window_size > $val;	
				}
				
				elsif ($param =~ /^dinuc$/i) {
					die "\tDinucleotide count cannot be done for more/less than 2 nucleotides!\n" if length($type) != 2;
					my (@type) = split("", $type);
					$check++ and last if ($count{$type[0]}+$count{$type[1]})/$window_size > $val;
				}
				
				elsif ($param =~ /^skew$/i) {
					die "\tSkew cannot be done for more than 2 nucleotides!\n" if length($type) != 2;
					my @denom = split("", $type);
					die "\tComparing identical nucleotide ($denom[0] vs $denom[1]) for skew is pointless!\n" if $denom[0] =~ /$denom[1]/i;	
					my $skew = $count{$denom[0]}+$count{$denom[1]} == 0 ? 0 : ($count{$denom[0]}-$count{$denom[1]})/($count{$denom[0]}+$count{$denom[1]});
					$check++ and last if $skew > $val;
				}
			}
		}
		
		## if (defined($filter{'others'})) {...$check++ and last if...}
	
		$check == $num_of_param ? return(1) : return(0);
	}
}	

sub graph_nuc {
	my ($seq, $graph) = @_;
	my %graph = %{$graph};
	my %final_count;
	my ($window_size, $step_size);

	# Window_size, Step_size #
	$window_size = defined($graph{'window'}) ? $graph{'window'} : 200; #Default
	$step_size   = defined($graph{'step'})   ? $graph{'step'}   : 1  ; #Default

	if (defined($graph{'nuc'})) {
		foreach my $param (keys %{$graph{'nuc'}}) {
			foreach my $type (keys %{$graph{'nuc'}{$param}}) {
				next if ($param !~ /^oe$/ and $param !~ /^pc$/ and $param !~ /^skew$/ and $param !~ /^dinuc$/);
				my $count = -1;


				# FACTOR FOR KMER #
				my $factor = 0;
				$factor = 1; # Comment this to disable #
				my $count_kmer = 0;
				if ($factor == 1) {
					$count_kmer = count_markov_max($type, $seq);
					$MARKOV{$param}{$type} += $count_kmer/length($seq);
				
				}



				for (my $i = 0; $i < length($seq) - $window_size; $i += $step_size) {
					my $seq_part = substr($seq, $i, $window_size);
					$count++;
					my %count = %{count_nuc($type, $seq_part)};

					
					if ($param =~ /^oe$/i) {
						
						my (@denom) = split("", $type);
						
						my ($nom, $denom) = ($count{$type}, $count{$denom[0]});
						for (my $j = 1; $j < @denom; $j++) {
							$denom *= $count{$denom[$j]};
						}
						$final_count{0}{$param}{$type}[$count] = $denom == 0 ? 0 : $nom *($window_size**(@denom-1)) / $denom;
					}
					
					elsif ($param =~ /^pc$/i) {
						$final_count{0}{$param}{$type}[$count] = $count{$type}/$window_size;
					}
					
					elsif ($param =~ /^dinuc$/i) {
						die "Dinucleotide count cannot be done for more/less than 2 nucleotides!\n" if length($type) != 2;
						my (@type) = split("", $type);
						$final_count{0}{$param}{$type}[$count] = ($count{$type[0]}+$count{$type[1]})/$window_size;
					}
					
					elsif ($param =~ /^skew$/i) {
						die "Skew cannot be done for more/less than 2 nucleotides!\n" if length($type) != 2;
						my (@denom) = split("", $type);
						die "Comparing identical nucleotide ($denom[0] vs $denom[1]) for skew is pointless!\n" if $denom[0] =~ /$denom[1]/i;	
						$final_count{0}{$param}{$type}[$count] = $count{$denom[0]}+$count{$denom[1]} == 0 ? 0 : ($count{$denom[0]}-$count{$denom[1]})/($count{$denom[0]}+$count{$denom[1]});
						#my $equalizer = $count{$denom[0]} >= $count{$denom[1]} ? $count{$denom[0]}/$WINDOW_SIZE : $count{$denom[1]}/$WINDOW_SIZE;
						#$final_count{0}{$param}{$type}[$count] = $count{$denom[0]}+$count{$denom[1]} == 0 ? 0 : ($count{$denom[0]}-$count{$denom[1]})/($count{$denom[0]}+$count{$denom[1]}) * $equalizer;
					}
				}
			}
		}
		
		## if (defined($graph{'others'})) {..$final_count{$param}{$type}[$i] = ...}
			

	}
	return(\%final_count);	
}
sub count_nuc {
	my ($type, $seq) = @_; # type is nucleotide
	my %count;
	$type = uc($type);
	$seq = uc($seq);
	
	my @type_part = split("", $type);
	foreach my $type_part (@type_part) {
		# Count by Transliterate #
		$count{'A'} = $seq =~ tr/A/A/ if $type_part =~ /A/i;
		$count{'T'} = $seq =~ tr/T/T/ if $type_part =~ /T/i;
		$count{'G'} = $seq =~ tr/G/G/ if $type_part =~ /G/i;
		$count{'C'} = $seq =~ tr/C/C/ if $type_part =~ /C/i;	
	}
	if (length($type) > 1) {
		$count{$type} = 0;
		while ($seq =~ /$type/ig) {
			$count{$type}++;
		}
	}
	return(\%count);
} 	

sub count_markov_max {
	my ($type, $seq) = @_;
	return(1/16) unless length($type) > 2;
	die "Cannot count markov max model with k less than 3!\n" unless length($type) > 2;
	$type = uc($type);
	$seq = uc($seq);
	
	my ($t1) = $type =~ /^(\w+)\w$/;
	my ($t2) = $type =~ /^\w(\w+)$/;
	my ($st) = $type =~ /^\w(\w+)\w$/;
	my ($t1c, $t2c, $stc) = (0,0,0,0,0);
	while ($seq =~ /$t1/ig) {
		$t1c++;
	}
	while ($seq =~ /$t2/ig) {
		$t2c++;
	}
	while ($seq =~ /$st/ig) {
		$stc++;
	}
	$stc = 1 if $stc == 0;
	return($t1c*$t2c/$stc);

}

sub R_graph_single {
	my ($output, $gene, $gene_count, $total_gene, $linearray) = @_;
	my @line = @{$linearray};
	# Subroutine Global Variable #
	my ($PLOT_X1, $PLOT_X2, $PLOT_Y1, $PLOT_Y2) = (-2000, 2000, -5, 110); 	# Plot Width #
	my ($LINE_SEP, $TEXT_SEP, $TEXT_TEXT_SEP) = (500, 150, 200);
	my ($PAR_L, $PAR_R);
	my ($PAR_L_PLOT, $PAR_R_PLOT) = (-1,-1);
	my $Y_SCALE = 0.9*$PLOT_Y2;
	my $scaler;
	my $KMER_NUMBER = 0 if ($opt_k);
	my %R_par; # Main R scripts
	my $R_pdf; # PDF name
	my $scale = 0;
	my %gene = %{$gene};
	my %firstcolor;
	my ($min_val, $max_val, $step_val);
	my %values;

	for (my $i = 0; $i < $numberofinput; $i++) {
		print "Processing $i\n";
		($PAR_L, $PAR_R) = (-1,-1);
		my $color_count = -1;

		foreach my $param (keys %{$gene{$i}}) { #oe, pc, skew

			foreach my $type (sort keys %{$gene{$i}{$param}}) { #GC, CG, ATATAT
				if (not defined($scaler)) {
					$scaler = (2000-($WINDOW_SIZE/2))/$STEP_SIZE;
					$scale = 2000/$scaler;
					#print "with number of geneblabbla is $scaler * 2, scale is 2000 / $scaler = $scale (does x_axis = $scaler?)\n";
				}
			
				$color_count = -1 if $color_count > 9;
				# Plot plus or minus each PAR_L or PAR_R
				my $org = "";
				if ($type !~ /optm/ and not defined($opt_k)) {
					($org) = $type =~ /^\w+\.(\w+)$/ if ($opt_m);
					print "HERE\n" if ($opt_k);
					$PAR_L ++ if $param =~ /skew/;
					$PAR_R ++ if $param =~ /oe/ or $param =~ /pc/ or $param =~ /dinuc/;
					$PAR_L_PLOT ++ if $param =~ /skew/;
					$PAR_R_PLOT ++ if $param =~ /oe/ or $param =~ /pc/ or $param =~ /dinuc/;
				}

	
				# Color #
				$color_count++ if not ($opt_k);
				$color_count = 1 if ($opt_k);
				if ($type =~ /optm/) {
					my ($typeoptm) = $type =~ /^(\w+)\.optm$/i if $type =~ /optm/;
					$firstcolor{$param}{"$typeoptm.optm"} = $color_count unless defined($firstcolor{$param}{"$typeoptm.optm"});
					$color_count = $firstcolor{$param}{"$typeoptm.optm"} if $type =~ /optm/;
					#print "Type = $type\t Color count = $color_count\n" if $type =~ /optm/;
				}
				my @color = @COLOR;
				my $lwd = 4;
				if ($opt_m) {
					@color = $type =~ /optm/ ? @COLOR : @COLOR_LIGHT;
					$lwd = $type =~ /optm/ ? 4 : 1.5;
					
				}

				# Variable for data
				my $var = "num$i\.$param\.$type"; 
				$R_pdf .= "\.$var" if ($i != -1);
				# Dynamic Min Max Value
					##@{$gene{$i}{$param}{$type}} = sort {$gene{$i}{$param}{$type}[$a] <=> {$gene{$i}{$param}{$type}[$b]} @{$gene{$i}{$param}{$type}};
					##my ($min_val, $max_val) = $gene{$i}{$param}{$type}[0], $gene{$i}{$param}{$type}[@{$gene}{$param}{$type}}];
					##my $step_val = $max_val / 10;
				
				# Static Min Max Value
				($min_val, $max_val, $step_val) = (-0.2, 0.2, 0.02) if $param =~ /skew/;
				($min_val, $max_val, $step_val) = (-0.4, 0.4, 0.1) if $param =~ /skew/ and $opt_a =~ /plants/i;
				($min_val, $max_val, $step_val) = (-0.4, 0.4, 0.1) if $param =~ /skew/ and $opt_a =~ /fungi_Molds/i;
				
				$values{$param}{min} = $min_val;
				$values{$param}{max} = $max_val;
				$values{$param}{step} = $step_val;

				my ($nuc) = $type =~ /(\w+)\.optm/ if $type =~ /optm/;
				($nuc) = $type =~ /(\w+)\.\w+/;
				$nuc = $type if not defined($nuc);
				my $length_type = length($nuc);
				#$length_type = 2 if not defined($length_type); #fail safe
				#print "Type = $type\n";
				
				#print "TYPE = $type NUC = $nuc\n" if $type =~ /optm/;
				#print "TYPENON = $type\n" if $type !~ /optm/;
				if ($length_type == 2 or $type =~ /combine/) {
					if ($opt_m) {
						($min_val, $max_val, $step_val) = (-0.2, 1.4, 0.2) if $param =~ /oe/;
						($min_val, $max_val, $step_val) = (0.2, 0.8, 0.1) if $param =~ /dinuc/;
						($min_val, $max_val, $step_val) = (0, 4/(4**($length_type)),  4/(10*4**($length_type))) if $param =~ /pc/ and ($opt_m);
						#print "HERE, min max step = $min_val, $max_val, $step_val\n";
					}					
					elsif (not $opt_m) {
						($min_val, $max_val, $step_val) = (-0.2, 1.4, 0.3) if $param =~ /oe/;
						($min_val, $max_val, $step_val) = (0.2, 0.8, 0.1) if $param =~ /dinuc/;
						($min_val, $max_val, $step_val) = (0, 0.1, 0.01) if $param =~ /pc/;
					}
				}
				elsif ($length_type != 2 and $type !~ /combine/) {
					if ($opt_m) {
						($min_val, $max_val, $step_val) = (-0.2, 1.4, 0.2) if $param =~ /oe/i and ($opt_m);
						($min_val, $max_val, $step_val) = (0.2, 0.8, 0.1) if $param =~ /dinuc/i and ($opt_m);
						#($min_val, $max_val, $step_val) = (0, 4/(4**($length_type)), 4/(10*4**($length_type))) if $param =~ /pc/ and ($opt_m);
						($min_val, $max_val, $step_val) = (0, 0.5,0.05) if $param =~ /pc/i and ($opt_m);

					}
					else {
						($min_val, $max_val, $step_val) = (0, 5, 0.5) if $param =~ /oe/i and not ($opt_m);
						#($min_val, $max_val, $step_val) = (0, 0.02, 0.002) if $param =~ /pc/ and not defined($opt_c) and not ($opt_m);
						($min_val, $max_val, $step_val) = (0, 0.5, 0.05) if $param =~ /pc/i and not defined($opt_c) and not ($opt_m);
						($min_val, $max_val, $step_val)  = (0, 0.1, 0.01) if $param =~ /pc/i and defined($opt_c) and not ($opt_m);
					}
				}

				if ($param !~ /skew/) {
					$values{$param}{min} = $min_val;
					$values{$param}{max} = $max_val;
					$values{$param}{step} = $step_val;
				}
			
				if ($opt_k) { #$gene{$i}{$param}{$type}[$i] = AGAGAG;
			
 					# Print KMER at top of graph in alphabetical order.
					my $KMER_NUMBER = 0;		
					my @temp = @{$gene{$i}{$param}{$type}}; #(AGAGAG, AGAGCG, {undef};
					my @kmerlist = (0);
					
						## Get Kmer List
					for (my $j = 0; $j < @temp; $j++) {	
					
						if (not $opt_m) {
							next if not defined($temp[$j]);
							if (not grep (/^$temp[$j]$/, @kmerlist)) {
								push(@kmerlist, $temp[$j]);
								$KMER_NUMBER++;
							}
						}
						
						elsif ($opt_m) {
							my $kmer = $temp[$j]{'type'};
							next if not defined($kmer) or $kmer =~ /NA/ or $kmer =~ /score/ or $kmer =~ /type/;
							if (not grep (/^$kmer$/, @kmerlist)) {
								print "KMER =$kmer\n";
								push(@kmerlist, $kmer);
								$KMER_NUMBER++;
							}
						}
					}
					#@kmerlist = @printthis;
					my $x_axis_range = int(4000/$KMER_NUMBER);
					my $x_axis_start = -2000+($WINDOW_SIZE/2);
					for (my $j = 0; $j <= $KMER_NUMBER; $j++) {
						next if not defined($graph{'score'}{$kmerlist[$j]});
						$R_par{$var}{'ytext'}[$j] = "text($x_axis_start+$x_axis_range*($j-1), $PLOT_Y2-18, \"$kmerlist[$j]\",cex=0.3,col=\"$COLOR_OPTK[$j]\")\n";
						$R_par{$var}{'ytext'}[$j] .= "text($x_axis_start+$x_axis_range*($j-1), $PLOT_Y2-20, \"$graph{'score'}{$kmerlist[$j]}\",cex=0.3,col=\"$COLOR_OPTK[$j]\")\n";
					}	
					my $text_x_axis = int(2000*$STEP_SIZE/$scale);
					my @temp2;
					for (my $j = 0; $j < @temp; $j++) {
						my $x_axis = $j - $text_x_axis;
						
						
						my ($name, $score);
						
						if ($opt_m) {
							$name = defined($gene{$i}{$param}{$type}[$j]{'type'}) ? $gene{$i}{$param}{$type}[$j]{'type'} : "";
							$score = defined($gene{$i}{$param}{$type}[$j]{'score'}) ? $gene{$i}{$param}{$type}[$j]{'score'} : 0;
							#print "at $j: type = $name, score = $score\n";
						}
						else {
							$name = defined($gene{$i}{$param}{$type}[$j]) ? $gene{$i}{$param}{$type}[$j] : "";
							$score = defined($gene{$i}{$param}{$type}[$j]) ? 1 : 0;	
						}
						push(@temp2, $score);
						my $color_optk;						
						if (defined($gene{$i}{$param}{$type}[$j]{'type'}) or defined($gene{$i}{$param}{$type}[$j])) {
							next if $name =~ /^NA$/i or $name =~ /^$/;
							my $x_kmerpos = 0;
							for (my $k = 0; $k < @kmerlist; $k++) {	
								#print "kmerlist k = $kmerlist[$k]\tname = $name\n";
								$x_kmerpos = $x_axis_start+$x_axis_range*($k-1) if $kmerlist[$k] =~ /^$name$/;
								$color_optk = $COLOR_OPTK[$k] if $kmerlist[$k] =~ /^$name$/;
							}
							die "FATAL: KMERPOS not defined at $name\n" unless defined($x_kmerpos);
						
							$R_par{$var}{'xline'} .= "points($x_axis, 0,pch=\".\",col=\"$color_optk\")\n" if defined($temp[$j]);
							$R_par{$var}{'yline'} .= "lines(c($x_axis,$x_axis),c(0,$score/$numberofinput*0.5*$PLOT_Y2),lwd=0.5,col=\"red\")\n";
							$R_par{$var}{'yline'} .= "lines(c($x_axis,$x_axis),c($score/$numberofinput*0.5*$PLOT_Y2,0.5*$PLOT_Y2),lwd=0.5,col=\"$color_optk\")\n";
							$R_par{$var}{'yline'} .= "lines(c($x_axis,$x_kmerpos),c(0.5*$PLOT_Y2,$PLOT_Y2-21),lwd=0.5,col=\"$color_optk\")\n";
						}
					}
					($min_val, $max_val, $step_val) = (0,2,1);
					
					$R_par{$var}{'data'} = R_toolbox::newRArray(\@temp2, $var, "no_quote", 1) . "\n";
					$R_par{$var}{'data'}.= "$var <- ($var - $min_val) / ($max_val - $min_val) * $Y_SCALE";
				}

				#print "VAR = $var, param = $param, PAR = $PAR_L, min_val = $min_val, max_val = $max_val\n";
				die "died at $var\n" unless defined($step_val);
				if (not $opt_k) {
					$R_par{$var}{'ytext'}[0] = "";
					# Data
					$R_par{$var}{'data'} = R_toolbox::newRArray(\@{$gene{$i}{$param}{$type}}, $var, "no_quote", 1) . "\n" if $type =~ /optm/ or not $opt_m;
					$R_par{$var}{'data'} .= "$var <- ($var - $min_val) / ($max_val - $min_val) * $Y_SCALE" if $type =~ /optm/ or not $opt_m;
					
					# Data Line
					$R_par{$var}{'xline'} = "lines(x,$var,type=\"l\",col=$color[$color_count],lwd=$lwd)" if $type =~ /optm/ or not $opt_m;
					$R_par{$var}{'yline'} = "";
				
					if ($type !~ /optm/) {
						my $PLOT_X_MOD;
						$PLOT_X_MOD = $PLOT_X2+50+(($PAR_R)*$LINE_SEP) if $param =~ /oe/ or $param =~ /pc/ or $param =~ /dinuc/;
						$PLOT_X_MOD = $PLOT_X1-50-(($PAR_L)*$LINE_SEP) if $param =~ /skew/;
						
							# RIGHT Y axis line and text
						my ($type1) = $type =~ /(\w+)\.\w+/;
						$type1 = $type if not defined($type1);
						$R_par{$var}{'yline'} = "lines(c($PLOT_X_MOD,$PLOT_X_MOD),c(0,$Y_SCALE*1.05),lwd=2,col=$COLOR[$color_count])\n" if $param =~ /oe/ or $param =~ /pc/  or $param =~ /dinuc/;
						$R_par{$var}{'yline'}.= "text($PLOT_X_MOD+$TEXT_SEP+$TEXT_TEXT_SEP,($PLOT_Y2*0.45),\"$type1 $param\", srt=270, cex=0.8, col=$COLOR[$color_count])\n" if not defined($SCORE) and ($param =~ /oe/ or $param =~ /pc/ or $param =~ /dinuc/);
						$R_par{$var}{'yline'}.= "text($PLOT_X_MOD+$TEXT_SEP+$TEXT_TEXT_SEP,($PLOT_Y2*0.45),\"$type1 $param ($SCORE)\", srt=270, cex=0.8, col=$COLOR[$color_count])\n" if defined($SCORE) and $SCORE > 9999 and ($param =~ /oe/ or $param =~ /pc/ or $param =~ /dinuc/);
							# LEFT Y axis line and text
						$R_par{$var}{'yline'} = "lines(c($PLOT_X_MOD,$PLOT_X_MOD),c(0,$Y_SCALE*1.05),lwd=2,col=$COLOR[$color_count])\n" if $param =~ /skew/;
						$R_par{$var}{'yline'}.= "text($PLOT_X_MOD-$TEXT_SEP-$TEXT_TEXT_SEP,($PLOT_Y2*0.45),\"$type1 $param\", srt=90, cex=0.8, col=$COLOR[$color_count])\n" if $param =~ /skew/;			
						# Text (Each Par_R *)
						my $text_count = 0;
						my $range = $max_val - $min_val;
						for (my $j = $min_val; $j <= $max_val+0.000001; $j += $step_val) {
							my $nominator = $j - $min_val;
							
							# Correct Stupid Perl Bug #

							my $val = int($j*1000+0.00001)/1000 if $j >= 0 and abs($j) > 0.01;
							$val = int($j*1000-0.00001)/1000 if $j < 0 and abs($j) > 0.01;
			
							$val = int($j*10000+0.000001)/10000 if $j >= 0 and abs($j) < 0.01 and abs($j) >= 0.001;
							$val = int($j*10000-0.000001)/10000 if $j < 0  and abs($j) < 0.01 and abs($j) >= 0.001;
							$val = int($j*100000+0.0000001)/100000 if $j >= 0 and abs($j) < 0.001 and abs($j) >= 0.0001;
							$val = int($j*100000-0.0000001)/100000 if $j < 0  and abs($j) < 0.001 and abs($j) >= 0.0001;
							$val = int($j*1000000+0.00000001)/1000000 if $j >= 0 and abs($j) < 0.0001 and abs($j) >= 0.00001;
							$val = int($j*1000000-0.00000001)/1000000 if $j < 0  and abs($j) < 0.0001 and abs($j) >= 0.00001;
							$val = int($j*10000000+0.000000001)/10000000 if $j >= 0 and abs($j) < 0.00001 and abs($j) >= 0.000001;
							$val = int($j*10000000-0.000000001)/10000000 if $j < 0  and abs($j) < 0.00001 and abs($j) >= 0.000001;
							$val = int($j*100000000+0.0000000001)/100000000 if $j >= 0 and abs($j) < 0.000001 and abs($j) >= 0.0000001;
							$val = int($j*100000000-0.0000000001)/100000000 if $j < 0  and abs($j) < 0.000001 and abs($j) >= 0.0000001;
							$val = 0 if $j == 0;
							#print "$i -> $val\n";
							$text_count++;
							# OE or PC
							$R_par{$var}{'ytext'}[$text_count]  = "text($PLOT_X_MOD+$TEXT_SEP,$nominator/$range*$Y_SCALE,\"$val\",cex=0.6)\n" if $param =~ /oe/ or $param =~ /pc/ or $param =~ /dinuc/;
							$R_par{$var}{'ytext'}[$text_count] .= "lines(c($PLOT_X_MOD,$PLOT_X_MOD+25),c($nominator/$range*$Y_SCALE,$nominator/$range*$Y_SCALE),lwd=1)\n" if $param =~ /oe/ or $param =~ /pc/ or $param =~ /dinuc/;
							# Skew
							$R_par{$var}{'ytext'}[$text_count] = "text($PLOT_X_MOD-$TEXT_SEP,$nominator/$range*$Y_SCALE,\"$val\",cex=0.6)\n" if $param =~ /skew/;
							$R_par{$var}{'ytext'}[$text_count] .= "lines(c($PLOT_X_MOD,$PLOT_X_MOD-25),c($nominator/$range*$Y_SCALE,$nominator/$range*$Y_SCALE),lwd=1)\n" if $param =~ /skew/;
						}
					}
				}
			}
		}
	}
	print "PAR L = $PAR_L, PAR R = $PAR_R\n";
	print "Done processing each data\n";




	# X Axis Text #
	my $xaxis_text;
	for (my $i = -2000; $i <= 2000; $i+=500) {
		my $text_x_axis = int($i*$STEP_SIZE/$scale);
		$xaxis_text .= "lines(c($i,$i),c(0,-0.5),lwd=1)\ntext($i,-1.5,\"$text_x_axis\",cex=0.6)\n";
	}
	my $pdffile = "$output$command";
	my $orgi_pdffile = $pdffile;
	my ($pdffile1, $pdffile2) = $pdffile =~ /^(.{35,35}).*(.{35,35})$/i if length($pdffile) > 70;
	$pdffile = "$pdffile1$pdffile2" if length($pdffile) > 70;
	die "$orgi_pdffile\n" unless defined($pdffile);

	my $title = "text(0,110,\"Metaplot of $ORG ($gene_count of $total_gene genes) - created on $time\", cex = 0.9)\n";
	$title = "text(0,110,\"Metaplot of $opt_a - created on $time\", cex = 0.9)\n" if defined($opt_a);
	$title .= "text(0,105,\"$number_of_input organisms: $gene_count of average $total_gene genes\", cex=0.8)" if defined($opt_a);
	$title = "text(0,110,\"Peak Kmer position of family $opt_a ($number_of_input org: $gene_count of average $total_gene genes) - created on $time\", cex = 0.9)\n" if defined($opt_a) and ($opt_k);
	
	my $title_graphs = length($opt_g) > 15 ? substr($opt_g, 0, 15) : $opt_g;
	my $title_filter;
	$title_graphs =~ s/.add./ /ig;
	my $length_title_graphs = 10*(length($title_graphs) + 15);
	my $length_title_filter = 10*(length($title_filter) + 15) if ($opt_f);
	if (defined($opt_f)) {
		$title_filter =~ s/.add./ /ig;
		$title_filter = length($opt_f) > 15 ? substr($opt_f, 0, 15) : $opt_f;
	}

	#$title .= "text(-1500+$length_title_graphs,107,\"graphs_param = $title_graphs\",cex=0.5)\n" if ($opt_g);
	#$title .= "text(-1500+$length_title_filter,105,\"filter_param = $title_filter\",cex=0.5)\n" if ($opt_f);
	
	# Print Out #
	open (my $out, ">", "$pdffile.R") or die "Cannot write to $pdffile.R: $!\n";	
	print $out "

	par(oma=c(0,0,0,0),mar=c(0,0,0,0))
	pdf(\"$pdffile.pdf\")

	plot(NA,type=\"n\",xlim=c($PLOT_X1-50-($PAR_L+1)*$LINE_SEP,$PLOT_X2+50+($PAR_R+1)*$LINE_SEP),ylim=c($PLOT_Y1,$PLOT_Y2),xaxt=\"n\",yaxt=\"n\",bty=\"n\",xlab=NA,ylab=NA)

 	
	# BEGIN X AXIS DATA #
	x <- seq(from = -$scaler*$scale, to = ($scaler-1)*$scale, by = $scale)
	# END X AXIS DATA #
	";
	print "Printing out each data to R script\n";

	my %printed;
	foreach my $var (keys %R_par) {
		my ($params) = $var =~ /\w+\.(\w+)\.\w+/;
		next if ($var =~ /optm/);
		print $out "

		# BEGIN DATA
		
		# Y Axis Data #
		$R_par{$var}{'data'}
		$R_par{$var}{'xline'}
		# END DATA
		" if not $opt_m;

		print $out "
		#BEGIN Y LINE
		$R_par{$var}{'yline'}
		";

		if (not defined($printed{$params})) {
			print $out "
			# BEGIN Y TICK TEXT
			" if not $opt_m;

			for (my $i = 1; $i < @{$R_par{$var}{'ytext'}}; $i++) {
				my $texts = $R_par{$var}{'ytext'}[$i];
				my ($value) = $texts =~ /(\-{0,1}\d+\.*\d*)\",cex=/i;
				print $out "
				$texts
				" if $value >= 0 and $var =~ /\.oe/;
				print $out "
				$texts
				" if $var !~ /\.oe/;
			}
			print $out "
			# END Y TICK TEXT
			";
			$printed{$params} = 1;
		}
	}


	if ($opt_m) {
		my ($min_vals, $max_vals) = (0,0);
		for (my $j = 0; $j < @line; $j++) {
			foreach my $param (keys %{$line[$j]}) {
				$min_vals = $values{$param}{min};
				$max_vals = $values{$param}{max};
				$step_val = $values{$param}{step};
				my $color2 = $COLOR_LIGHT[1] if $param =~ /skew/i;
				$color2 = $COLOR_LIGHT[2] if $param =~ /dinuc/i;
				$color2 = $COLOR_LIGHT[0] if $param =~ /oe/i;
				$line[$j]{$param}{high} = $max_vals if $line[$j]{$param}{high} > $max_vals;
				$line[$j]{$param}{low} = $min_vals if $line[$j]{$param}{low} < $min_vals;
				print $out "
				# BEGIN DATALINE_$param
				lines(c(-$scaler \* $scale+$scale \* $j, -$scaler \* $scale+$scale \* $j), c(($line[$j]{$param}{high}-$min_vals)/($max_vals-$min_vals)*$Y_SCALE, ($line[$j]{$param}{low}-$min_vals)/($max_vals-$min_vals)*$Y_SCALE), col=$color2)
				# END_DATALINE_$param
				";
			}
		}
	}

	foreach my $var (keys %R_par) {
		my ($params) = $var =~ /\w+\.(\w+)\.\w+/;
		next if ($var !~ /optm/);
		print $out "
			
		# Y Axis Data #
		$R_par{$var}{'data'}
		$R_par{$var}{'xline'}
		";

		if (not defined($printed{$params})) {
			print $out "
			$R_par{$var}{'yline'}
			";
			for (my $i = 1; $i < @{$R_par{$var}{'ytext'}}; $i++) {
				print $out "
				# BEGIN Y TICK TEXT
				$R_par{$var}{'ytext'}[$i]
				# END Y TICK TEXT
				";
			}
			$printed{$params} = 1;
		}
	}


	print $out "
	# BEGIN TITLE 
	$title
	# END TITLE

	# BEGIN TSSLINE
	lines(c(0,0),c(0,100),lty=3,lwd=3)
	lines(c(0,600),c(100,100),lty=3,lwd=3)
	lines(c(600,800),c(101,100),lty=1,lwd=1)
	lines(c(600,800),c(99,100),lty=1,lwd=1)
	lines(c(600,600),c(99,101),lty=1,lwd=1)
	# END TSSLINE
	
	# BEGIN X AXIS LINE
	lines(c(min(x),max(x)),c(0,0),lwd=2.5)
	text(0,-5,\"Coordinates in relation to TSS \(bp\)\", cex=0.8)
	$xaxis_text	
	# END X AXIS LINE
	
	";

	foreach my $param (sort keys %MARKOV) {
		foreach my $type (sort keys %{$MARKOV{$param}}) {
			my $count = $MARKOV{$param}{$type};
			print $out "
			# BEGIN EXPECTED MARKOV
			\#$param\t$type\t$count
			# END EXPECTED MARKOV
			";
		}
	}
	print $out "
	# BEGIN DASHED LINES
	lines(c(-2050,2050),c(50,50),lty=2,lwd=1)
	# END DASHED LINES
	" if not($opt_k);
	
	print "Done!\n";
	close $out;
	return("$pdffile");
	}
}

sub R_graph_3D {
	my ($output, $gene, $gene_count, $total_gene) = @_;
	 

}
sub process_bsseq {
	my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
	my $bsseq = $cache -> get("bsseqdball");
	#if (not defined($bsseq)) {
	#	my $bsseq_cache = mitochy::process_bsseqdb();
	#	$cache -> set("bsseqdb", $bsseq_cache);
	#	$bsseq = $bsseq_cache;
	#}
	die "Undefined bsseqdball\n" unless defined($bsseq);
	my %bsseq = %{$bsseq};
}


sub has_intron {
	my ($id) = @_;
	$id = uc($id);
	my %exon = %{$exon_db};
	
        foreach my $tid (sort keys %{$exon{$id}{'tid'}}) {
	        my $chr = $exon{$id}{'chr'};
		my $start = $exon{$id}{'tid'}{$tid}[0]{'start'}; # 0 = exon 1 start
		my $end = $exon{$id}{'tid'}{$tid}[0]{'end'}; # 0 = exon 1 end
        	my $strand = $exon{$id}{'strand'};
                my $num_of_exon = @{$exon{$id}{'tid'}{$tid}};
          
		print "\t$id: NO INTRON at $tid\n" if $num_of_exon == 1; # No intron since only 1 exon
                print "\t$id: NO INTRON at $tid\n" if $end-$start > 2000; # Intron is located more than 2000 bp after TSS
                print "\t$id: HAVE INTRON at $tid\n" if $end-$start <= 2000; # Has intron since more than 1 exon and is located within 2000bp of TSS
		return(0) if ($end-$start) < 2000; # 0 has intron
        }
	return(1); # Has no intron
}

sub process_kmerfile {
	my ($input) = @ARGV;
	my %graph;
	open (my $in, "<", $input) or die "Cannot process $input: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		my ($kmer, $score) = split("\t", $line);
		$graph{'nuc'}{'pc'}{$kmer} = $score;
		$graph{'score'}{$kmer} = $score;
	}
	return(\%graph);
}
