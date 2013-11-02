#!/usr/bin/perl

use strict; use warnings; use mitochy;
use Cache::FileCache;

my $cache = new Cache::FileCache();
$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
my ($folder) = @ARGV;
die "usage: rmes_compare.pl <folder of tables>\n" unless @ARGV;
my @input = <$folder/*.table>;

my %motif;
my %word;
my @org;
my $total = @input;
my $count = 0;
foreach my $input (@input) {
	$count++;
	my ($organism) = $input =~ m/^.+\/(.+).rmesinput.rmes.gauss.table/i;
	die "name of organism not defined at $input\n" if not defined($organism);
	push(@org, $organism) if not grep(/^$organism$/, @org);
	print "Proceegins $organism ($count / $total)\n";
	my %kmer = mitochy::process_rmes_table($input);
	foreach my $kmer (keys %kmer) {
		foreach my $word (keys %{$kmer{$kmer}}) {
			$word{$word} = 1;
			$motif{$word}{$organism} = $kmer{$kmer}{$word}{'score'};
		}
	}
}
open (my $out, ">", "$input[0].logodd.txt") or die "Cannot write to output: $!\n"; 
@org = sort @org; 
printf $out "%d\t", @org * (keys %word);
for (my $i = 0; $i < @org; $i++) {
	print $out "$org[$i]\t" if $i != @org-1;
	print $out "$org[$i]\n" if $i == @org-1;
}

foreach my $kmer (sort keys %word) {
	print $out "$kmer\t";
	for (my $i = 0; $i < @org; $i++) {
		if (defined($motif{$kmer}{$org[$i]})) {
			print $out "$motif{$kmer}{$org[$i]}\t" if $i != @org-1;
			print $out "$motif{$kmer}{$org[$i]}\n" if $i == @org-1;
		}
		else {
			print $out "0\t" if $i != @org-1;
			print $out "0\n" if $i == @org-1;
		}
	}
}
	
__END__
for (my $k = 0; $k < 10; $k++) {
	my @input;
	for (my $l = 0; $l < @animal; $l++) {
		my $input = "/Users/stella/Desktop/Work/FredIan/CEGMAfinal/biglist_promoter/test/biglist_seq.tsv.$animal[$l].rmesinput.$k.rmesinput.rmes.gauss.table";
		push(@input, $input);
	}
	
	my %motif;
	foreach my $input (@input) {
		my ($organism) = $input =~ m/^.+\/biglist_seq.tsv.(\w+).rmesinput.\d.rmesinput.rmes.gauss.table$/i;
		die "$input\n" if not defined($organism);
		print ">$k $organism\n";
		my %kmer = mitochy::process_rmes_table($input);
		foreach my $kmer (keys %kmer) {
			foreach my $word (keys %{$kmer{$kmer}}) {
				$motif{$word}{$organism} = $kmer{$kmer}{$word}{'score'};
			}
		}
	}
	
	open (my $out, ">", "/Users/stella/Desktop/Work/FredIan/CEGMAfinal/biglist_promoter/test/logoddtable$k.txt") or die "Cannot write to output: $!\n";
	
	foreach my $word (sort keys %motif) {
		my $key = (keys %motif);
		print $out "$key\t";
		foreach my $organism (sort keys %{$motif{$word}}) {
			print $out "$organism\t";
		}
		last;
	}
	print $out "\n";
	foreach my $word (sort keys %motif) {
		print $out "$word\t";
		foreach my $organism (sort keys %{$motif{$word}}) {
			print $out "$motif{$word}{$organism}\t";
		}
		print $out "\n";
	}
}
			
__END__	
	if ($mode != 0 and $mode != 1 and $mode > 0) {
		my %motif;
		foreach my $input (@input) {
			my ($organism) = $input =~ m/^.+\/biglist_seq.tsv.(\w+).rmesinput.rmes.gauss.table$/i;
			#print ">$organism\n";
			my %kmer = mitochy::process_rmes_table($input);
			foreach my $kmer (keys %kmer) {
				next if $kmer < $mode;
				next if $kmer > $mode;
				foreach my $word (sort {$kmer{$kmer}{$a}{'rank'} <=> $kmer{$kmer}{$b}{'rank'}} keys %{$kmer{$kmer}}) {
					if ($score_type =~ /normal/i) {
						if ($score_morethan !~ /N/) {
							$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} > $score_morethan;
							push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} > $score_morethan;
						}
						if ($score_lessthan !~ /N/) {
							$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} < $score_lessthan;
							push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} <$score_lessthan;
						}
					}
					elsif ($score_type =~ /between/i) {
						$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} > $score_morethan and $kmer{$kmer}{$word}{'score'} > $score_lessthan;
						push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} > $score_morethan and $kmer{$kmer}{$word}{'score'} > $score_lessthan;
					}
				}
			}
		}
		
		foreach my $word (sort {$motif{$a}{'count'} <=> $motif{$b}{'count'}} keys %motif) {
			print "$word\t$motif{$word}{'count'}\t";
			for (my $i = 0; $i < @{$motif{$word}{'org'}}; $i++) {
				my $organism = $motif{$word}{'org'}[$i];
				print "$organism\t";
			}
			print "\n";
		}
	}	
	
	elsif ($mode == 1) {
		for (my $i = 4; $i < 11; $i++) {
			my %motif;
			foreach my $input (@input) {
				my ($organism) = $input =~ m/^.+\/biglist_seq.tsv.(\w+).rmesinput.rmes.gauss.table$/i;
				#print ">$organism\n";
				my %kmer = mitochy::process_rmes_table($input);
				foreach my $kmer (keys %kmer) {
					next if $kmer < $i;
					next if $kmer > $i;
					foreach my $word (sort {$kmer{$kmer}{$a}{'rank'} <=> $kmer{$kmer}{$b}{'rank'}} keys %{$kmer{$kmer}}) {
						if ($score_type =~ /normal/i) {
							if ($score_morethan !~ /N/) {
								$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} > $score_morethan;
								push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} > $score_morethan;
							}
							if ($score_lessthan !~ /N/) {
								$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} < $score_lessthan;
								push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} <$score_lessthan;
							}
						}
						elsif ($score_type =~ /between/i) {
							$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} > $score_morethan and $kmer{$kmer}{$word}{'score'} > $score_lessthan;
							push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} > $score_morethan and $kmer{$kmer}{$word}{'score'} > $score_lessthan;
						}
					}
				}
			}
			
			foreach my $word (sort {$motif{$a}{'count'} <=> $motif{$b}{'count'}} keys %motif) {
				print "$word\t$motif{$word}{'count'}\t";
				for (my $i = 0; $i < @{$motif{$word}{'org'}}; $i++) {
					my $organism = $motif{$word}{'org'}[$i];
					print "$organism\t";
				}
				print "\n";
			}
		}
	}
	
	elsif ($mode == 0) {
		my %motif;
		foreach my $input (@input) {
			my ($organism) = $input =~ m/^.+\/biglist_seq.tsv.(\w+).rmesinput.rmes.gauss.table$/i;
			#print ">$organism\n";
			my %kmer = mitochy::process_rmes_table($input);
			foreach my $kmer (keys %kmer) {
				foreach my $word (sort {$kmer{$kmer}{$a}{'rank'} <=> $kmer{$kmer}{$b}{'rank'}} keys %{$kmer{$kmer}}) {
					if ($score_type =~ /normal/i) {
						if ($score_morethan !~ /N/) {
							$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} > $score_morethan;
							push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} > $score_morethan;
						}
						if ($score_lessthan !~ /N/) {
							$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} < $score_lessthan;
							push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} <$score_lessthan;
						}
					}
					elsif ($score_type =~ /between/i) {
						$motif{$word}{'count'}++ if $kmer{$kmer}{$word}{'score'} > $score_morethan and $kmer{$kmer}{$word}{'score'} > $score_lessthan;
						push(@{$motif{$word}{'org'}}, $organism) if $kmer{$kmer}{$word}{'score'} > $score_morethan and $kmer{$kmer}{$word}{'score'} > $score_lessthan;
					}
				}
			}
		}
		
		foreach my $word (sort {$motif{$a}{'count'} <=> $motif{$b}{'count'}} keys %motif) {
			print "$word\t$motif{$word}{'count'}\t";
			for (my $i = 0; $i < @{$motif{$word}{'org'}}; $i++) {
				my $organism = $motif{$word}{'org'}[$i];
				print "$organism\t";
			}
			print "\n";
		}
	}
	
}
	#$kmer{$kmer}{$word}{'rank'} = $rank;
	
	
	__END__
	#RMES
	if ($switch == 0) {
		die "usage: $0 <rmes_table1.fa> <rmes_table2.fa> <min_kmer [0]> <max_kmer [7]>\n" unless @ARGV;
		mitochy::rmes_compare(@ARGV);
	}
	
	__END__
	
	#R GRAPH
	if ($switch == 1) {
		my %kmer;
		open (my $in, "<", "$ARGV[0]") or die "Cannot read from $ARGV[0]: $!\n";
		while (my $line = <$in>) {
			chomp($line);
			next if $line =~ /^\#/;
			next if $line =~ /^word/;
			next unless $line =~ /^\w/;
		
			my ($status, $word) = split("\t", $line);
			my $length = length($word);
			$kmer{$length}{$status}{$word}++;
		}
				
		my %word;
		
		foreach my $length (sort {$a <=> $b} keys %kmer) {
			foreach my $status (sort keys %{$kmer{$length}}) {
				foreach my $word (sort keys %{$kmer{$length}{$status}}) {
					if ($status !~ /ENRICHED_/) {
							if ($status =~ /ENRICHED/) {
							my @words = split("",$word);
							for (my $i = 0; $i < @words; $i++) {
								$word{$length}{$i}{$words[$i]}++;
							}
						}
					}
				}
			}
		}
		
		foreach my $length (sort {$a <=> $b} keys %word) {
			print "KMER = $length\nPOS\tA\tT\tG\tC\n";
			for (my $i = 0; $i < $length; $i++) {
				my $pos = $i+1;
				my $a_num = defined($word{$length}{$i}{'a'}) ? $word{$length}{$i}{'a'} : 0;
				my $t_num = defined($word{$length}{$i}{'t'}) ? $word{$length}{$i}{'t'} : 0;
				my $g_num = defined($word{$length}{$i}{'g'}) ? $word{$length}{$i}{'g'} : 0;
				my $c_num = defined($word{$length}{$i}{'c'}) ? $word{$length}{$i}{'c'} : 0;
		
				print "$pos\t$a_num\t$t_num\t$g_num\t$c_num\n"; 
			}
			print "\n\n";
		}
		close $in;
	}
	__END__
