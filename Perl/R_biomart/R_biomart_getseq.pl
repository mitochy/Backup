#!/usr/bin/perl

use strict; use warnings;
use mitochy;

my ($input, $flankstart) = @ARGV;
die "usage: $0 <inputs from R_biomart_getID.pl> <flank_start>\n" unless @ARGV;
die "Please define numeric flankstart\n" if $flankstart !~ /\d+/;
print "flankstart = $flankstart\n";
my $folder;
my @failures;
my %org = %{mitochy::Global_Var('orglist')};
	my ($first, $org) = $input =~ /\w+\.id\.(\w)(\w+)\.ID\.new\.ID$/i;
	($first, $org) = $input =~ /\w+\.id\.(\w)(\w+)\.ID$/i if not defined($org);
	if (not defined($org)) {
		foreach my $families (keys %org) {
			foreach my $organism (@{$org{$families}}) {
				print "$organism\n";
				if ($input =~ /$organism/i) {
					($first, $org) = $organism =~ /^(\w)(\w+)$/;
					last;
				}
			}
			last if defined($org);
		}
	}
	die "organism undefined\n" unless defined($org);
	push (@failures, $input) unless defined($org);
	#next unless defined($org);
	
	my %query;
	open (my $in, "<", $input) or die;

	while (my $line = <$in>) {
		chomp($line);
		next if $line =~ /^"V1"/i;
		$line =~ s/"//ig;
		my ($num, $leader, $id, $chr, $start, $end, $strand) = split(" ", $line);
		
		#die "$line\n" if not defined($num) or not defined($strand);
		#print "$num\n$leader\n$id\n$chr\n$start\n$end\n$strand\n\n";
		$query{$chr}{$id}{'start'} = $start;
		$query{$chr}{$id}{'end'} = $end;
		$query{$chr}{$id}{'strand'} = $strand;
		$query{$chr}{$id}{'leader'} = $leader;
		#print "$id\n" if $strand == -1;
		#die if $strand == -1;
	}
	close $in;

	my $database = "/home/mitochi/Desktop/Work/newcegma/database/";
	my @folders = <$database\/*>;
	$database = "";
	foreach my $folders (@folders) {
		#print "folder = $folders\n";
		if ($folders =~ /\/$first\w+_$org/i) {
			#print "folder = $folders\n";
			my @file = <$folders/*.fa>;
			$database = $file[0];
			#print "database = $database\n";
			last;
		}
	}
	
	print "database undefined\n" unless $database =~ /\w+/i;
	push (@failures, $input) unless $database =~ /\w+/i;
	#next unless $database =~ /\w+/i;

	print "input = $input\norganism = $org\ndatabase = $database\n";

	my %fasta = mitochy::process_fasta($database);
	open (my $out, ">", "$input.$org.fa") or die "Cannot write to $input.$org.fa: $!\n";
	foreach my $chr (sort keys %query) {
		foreach my $id (sort keys %{$query{$chr}}) {
			
			my ($start, $end, $strand, $leader) = ($query{$chr}{$id}{'start'}, $query{$chr}{$id}{'end'}, $query{$chr}{$id}{'strand'}, $query{$chr}{$id}{'leader'});
			my $origstart = $start;
			my $origend = $end;

			$start -= $flankstart if defined($flankstart) and $strand == 1;
			$end += $flankstart if defined($flankstart) and $strand == -1;
			
			my $head;
			foreach my $header (sort keys %fasta) {
				#print "$header\n";
				$head = $header if $header =~ />$chr /i;
				#p falciparum only
				$head = $header if ($first =~ /p/i and $org =~ /falciparum/i and $header =~ />0\d /i);
				#print "header = $header\n"
			}
			
			print "chr = $chr failed due to undefined head!\n" if not defined($head);
			push(@failures, $input) if not defined($head);				
			next if not defined($head);

			my $lengthseq = length($fasta{$head}{'seq'});

			my $check = check_substr($start, $end, $lengthseq);

			#next if $check == 1;

			my $seq = substr($fasta{$head}{'seq'}, $start-1, $end-$start+1);
			$seq = "" if not defined($seq);
			if ($check == 1) {
				my $Ns;
				if ($strand == -1) {
					#print "my seq = substr(, $start-1, $end-$start+1)\n";
					#print "seq before: $seq\n";
					for (my $i = 0; $i < $end-$lengthseq; $i++) {
						$seq .= "N";
					}
  					#print "seq after: $seq\n";die;
				}
				if ($strand == 1) {
					$seq = substr($fasta{$head}{'seq'}, 1, $end-0+1);
					print "for my i = 0, i < 0- $start + 2, i++\n";
					for (my $i = 0; $i < 0-$start+2; $i++) {
						$seq = "N" . $seq;
					}
				}
			}
#			print "$seq\n" if ($check == 1 and $strand == 1);

			print "$chr $id\n$origstart to  $start\n$origend to $end\n $lengthseq substr out of str, excluded\n" if $check == 1 and $strand == 1 and length($seq) < $flankstart;
			push (@failures, "$input.$org.fa.$chr.$id.failed.due.to.substr") if $check == 1 and $strand == 1 and length($seq) < $flankstart;

			$seq = mitochy::revcomp($seq) if $strand == -1;
			#$query{$chr}{$id}{'seq'} = $seq;
			print $out ">$id\_$origstart\_to_$origend\_strand=$strand\_$start\_to_$end\_flank=$flankstart\_lengthseq=$lengthseq\n$seq\n";
		}
	}
	close $out;

foreach my $fail (@failures) {
	print "Failed to run: $fail\n";
}

sub check_substr {
	my ($start, $end, $lengthseq) = @_;
	return(1) if ($start > $lengthseq);
	return(1) if ($end > $lengthseq);
	return(1) if ($start < 0);
	return(0);
}
