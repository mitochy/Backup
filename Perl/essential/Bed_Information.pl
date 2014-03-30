#!/usr/bin/perl

use strict; use warnings; use mitochy; use Cache::FileCache;

my ($folder) = @ARGV;
if (not defined($folder)) {
	print "\nData structure:\n";
	print "data{\$orgname}{name}{\$gene_name}{chr/type/start/end/strand}\n";
	print "data{\$orgname}{type}{\$gene_type}{mean/q1/q2/q3/min/max}\n";
	die "\nusage: $0 <folder containing bed file of organisms>\n" unless defined($folder) and -d $folder;
}

die "\nusage: $0 <folder containing bed file of organisms>\n" unless defined($folder) and -d $folder;


my @bedFile = </data/genome/bed/*.bed>;
my @gtfFile = </data/genome/gtf/*.gtf>;

my $cache = new Cache::FileCache;
$cache->set_cache_root("/data/mitochi/Work/Cache/");

my %data;
my $bed_count = 0;
my $bed_count_total = @bedFile;
my @head = qw(count mean q1 q2 q3 min max);
my @type;
foreach my $bedFile (@bedFile) {
	print "Processed $bed_count out of $bed_count_total\n" if $bed_count % 20 == 0;
	$bed_count ++;

	my ($name) = mitochy::getFilename($bedFile);
	my ($shortname, $name2) = $name =~ /^(\w)\w+\_(\w+)$/;
	$shortname = lc("$shortname$name2");

	my @gene_length;
	open (my $in, "<", $bedFile) or die "Cannot open my $bedFile: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		my ($chr, $start, $end, $gene, $type, $strand) = split("\t", $line);
		push(@type, $type) if not grep(/^$type$/,@type);

		$data{$shortname}{name}{$gene}{chr}    = $chr;
		$data{$shortname}{name}{$gene}{type}   = $type;
		$data{$shortname}{name}{$gene}{start}  = $start;
		$data{$shortname}{name}{$gene}{end}    = $end;
		$data{$shortname}{name}{$gene}{strand} = $strand;

		push(@{$data{$shortname}{type}{$type}{length}}, abs($end - $start));
		$data{$shortname}{type}{$type}{count} ++;
	}
	close $in;

	foreach my $type (keys %{$data{$shortname}{type}}) {
		my @length = @{$data{$shortname}{type}{$type}{length}};
		my $count  = $data{$shortname}{type}{$type}{count};
		my ($mean, $Q1, $Q2, $Q3, $min, $max) = summary(@length);
		$data{$shortname}{type}{$type}{mean}    = $mean;
		$data{$shortname}{type}{$type}{q1}      = $Q1;
		$data{$shortname}{type}{$type}{q2}      = $Q2;
		$data{$shortname}{type}{$type}{q3}      = $Q3;
		$data{$shortname}{type}{$type}{min}     = $min;
		$data{$shortname}{type}{$type}{max}     = $max;
	}
}

open (my $out, ">", "geneinfo.txt") or die;
my @class = @{mitochy::Global_Var("class")};
my %orglist = %{mitochy::Global_Var("orglist")};

#HEADER
for (my $i = 0; $i < @class; $i++) {
	my $class = $class[$i];
	for (my $j = 0; $j < @{$orglist{$class}}; $j++) {
		my $org = $orglist{$class}[$j];
		print $out "\#ORG";
		for (my $h = 0; $h < @type; $h++) {
			my $type = $type[$h];
			for (my $k = 0; $k < @head; $k++) {
				my $value = $data{$org}{type}{$type}{$head[$k]};
				$value = "NA" if not defined($value);
				print $out "\t$type\_$head[$k]";
			}
		}
		print $out "\n";		
		last;
	}
	last;
}

for (my $i = 0; $i < @class; $i++) {
	my $class = $class[$i];
	for (my $j = 0; $j < @{$orglist{$class}}; $j++) {
		my $org = $orglist{$class}[$j];
		print $out "$class\_$org";
		for (my $h = 0; $h < @type; $h++) {
			my $type = $type[$h];
			for (my $k = 0; $k < @head; $k++) {
				my $value = $data{$org}{type}{$type}{$head[$k]};
				$value = "NA" if not defined($value);
				print $out "\t$value";
			}
		}
		print $out "\n";		
	}
}
close $out;
$cache->set("geneinfo",\%data);

sub summary {
	my @num = @_;

	@num = sort {$a <=> $b} (@num);

	# Mean
	my $mean = 0;
	foreach my $num (@num) {
		$mean += $num / @num;
	}
	
	# Q1, Q2, Q3
	my $Q1 = $num[int(0.25*(@num))];
	my $Q2 = $num[int(0.5*(@num))];
	my $Q3 = $num[int(0.75*(@num))];
	
	# Min, Max
	my $min = $num[0];
	my $max = $num[@num-1];
	return($mean, $Q1, $Q2, $Q3, $min, $max);
}
