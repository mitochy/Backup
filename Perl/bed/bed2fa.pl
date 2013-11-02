#!/usr/bin/perl
#Take bed file coordinates (chrname\tstartcoor\tendcoor) and get sequence in multifasta.

use strict; use warnings;

BEGIN {
	my $lib = "$ENV{'HOME'}\/Desktop\/Work\/Codes\/Perl\/lib";
	push (@INC, $lib);
}

use mitochy;


my ($bedinput, $genome) = @ARGV;
die "usage: script.pl <bed> <genome.fa> <split>\n
Add \"split\" at the end if you want to split the genome\n" unless @ARGV >=2;
print "processing bed...";
my %bed = mitochy::process_bed($bedinput, 4);
print "done\n";

mitochy::split_big_multifasta_genome($genome) if defined($ARGV[2]) and $ARGV[2] =~ /split/i;

if (defined($ARGV[2]) and $ARGV[2] =~ /out/) {
	open (my $out, ">", "$bedinput.fa") or die "Cannot write to $bedinput.fa: $!\n";
	close $out;
}

if (not defined($ARGV[2]) or (defined($ARGV[2]) and $ARGV[2] !~ /split/)) {
	foreach my $chr (sort keys %bed) {
		open (my $in, "<", "$genome.$chr") or print "Cannot open from $genome.$chr or $genome.$chr not exists: $!\n";
		my ($head, $seq);
		while (my $line = <$in>) {
			chomp($line);
			$head = $line if $line =~ m/>/i;
			$seq .= $line if $line !~ m/>/i;
		}
		$head =~ s/>//i;
		
		foreach my $genecount (sort {$a <=> $b} keys %{$bed{$chr}}) {
			
			
			my $start = $bed{$chr}{$genecount}{'start'};
			my $end = $bed{$chr}{$genecount}{'end'};
			$bed{$chr}{$genecount}{'seq'} = uc(substr($seq, $start, $end-$start));
			
			
			if (defined($ARGV[2]) and $ARGV[2] =~ /out/) {
				my $numberofgenecount = (keys %{$bed{$chr}});
				open (my $out, ">>", "$bedinput.fa") or die "Cannot write to $bedinput.fa: $!\n";
				print "printing $genecount to $bedinput.fa\n";
				print $out ">$chr\_$genecount\_$start\_$end\_$bed{$chr}{$genecount}{1}\n$bed{$chr}{$genecount}{'seq'}\n";

				close $out;
			}
			
			else {
				print ">$chr\_$genecount\_$start\_$end\_$bed{$chr}{$genecount}{1}\n$bed{$chr}{$genecount}{'seq'}\n";
			}
		}
	}
}
		
__END__
foreach my $chr (sort keys %bed) {
	foreach my $genecount (sort {$a <=> $b} keys %{$bed{$chr}}) {
		print "$chr\t$genecount\t$bed{$chr}{$genecount}{'start'}\t$bed{$chr}{$genecount}{'end'}\t$bed{$chr}{$genecount}{1}\n";
	}
}

print "processing genome…";
open (my $in, "<", $genome) or die "Cannot read from $genome: $!\n";
while (my $line = <$in>) {
	chomp($line);
	
	if ($line =~ m/>/i) {
		foreach my $chr (sort keys %bed) {
			if ($line =~ m/>$chr/i) {
				my $coor = 0;
				$line = <$in>;
				my $current_line = 0;
				while ($line !~ m/>i) {
					my $length_per_row = length($line);
					foreach my $genecount (sort {$a <=> $b} keys %{$bed{$chr}}) {
						my $start = $bed{$chr}{$genecount}{'start'};
						my $end = $bed{$chr}{$genecount}{'end'};
						my $row_to_skip = int($coor/$length_per_row);
						my $substr = $start - ($row_to_skip * $length_per_row);
						
						$current_line += $row_to_skip;
						for (my $i = 0; $i < $row_to_skip; $i++) {
							$line = <$in>;
						}
						my $seq = 
				

				
				
				
				
				
				
				
				
				
				print "$line\n";
			}
		}
	}
}



print "dones\n";
