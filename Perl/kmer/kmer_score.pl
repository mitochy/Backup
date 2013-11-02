#!/usr/bin/perl

use strict; use warnings; 
use mitochy; use Statistics::LineFit;
use Algorithm::CurveFit;
use Math::Symbolic;
my ($input, $MIN_RSQ, $criteria) = @ARGV;
#types
#
#Type = 1	Linear		y = a + b*x
#Type = 2	Exponential	y = a*e^(b*x)   nb a > 0
#Type = 3	Logarithmic	y = a + b*ln(x)
#Type = 4	Power		y = a*x^b	nb a > 0
#
my @types = qw(linear exp log power);
my ($worked, $totalall) = (0,0);
$MIN_RSQ = 0.5 if not defined($MIN_RSQ);

die "usage: kmer_score.pl <get_kmer sort result> <min R squared> <top_10 or bot_10 or less_3 or more_3>\n" unless @ARGV ==3;
print "CRITERIA = $criteria\n";
my ($pos, $num) = $criteria =~ /^(\w+)_(-{0,1}\w+)$/i;
die "undefined pos and number\n" unless defined($pos) and defined($num);
die "pos must be either top or bot\n" unless $pos =~ /top/i or $pos =~ /bot/i or $pos =~ /more/i or $pos =~ /less/i;

#Get number of line in data file
my $cmd = "wc -l $input";
my ($linenum) = `$cmd` =~ /^(\d+)/i;
die "line number not defined\n" if not defined($linenum);


#print "next if rank > $linenum * 0.1\n";
print "Processuing data file...";
open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
my %org;
my $rank = -1;
while (my $line = <$in>) {
	chomp($line);
	$rank++;
	$line =~ s/.seq.fa//ig;
	$line =~ s/human\.id//ig;
	my @arr = split("\t", $line);
	foreach my $arr(@arr) {
		$arr =~ s/_\-*inf$/_0/ig;
		my ($org,$kmer, $score) = $arr =~ /^(\w+)\.*.*_(\w+)_(-{0,1}\d+\.{0,1}\d*)$/i;
		die "died at $arr\n" unless defined($org) and defined($kmer) and defined($score);
		#print "rank = $rank\n";
		if ($org =~ /hsapiens/i or $org =~ /zmays/ or $org =~ /spombe/) {
			$org{$org}{$kmer}{'rank'} = $rank;
			$org{$org}{$kmer}{'score'} = $score;
			next if $pos =~ /top/i and $rank > $linenum*$num/100;
			next if $pos =~ /bot/i and $rank < $linenum*(100-$num)/100;
			next if $pos =~ /more/i and $score < $num;
			next if $pos =~ /less/i and $score > $num;
			$org{$org . "2"}{$kmer}{'rank'} = $rank;
			$org{$org . "2"}{$kmer}{'score'} = $score;
		}
		else {
			$org{$org}{$kmer}{'rank'} = $rank;
			$org{$org}{$kmer}{'score'} = $score;
		}
	}
}
close $in;
print "Done!\n";
#my @organisms = qw(scerevisiae cintestinalis dmelanogaster lchalumnae xtropicalis acarolinensis mgallopavo meugenii eeuropaeus saraneus rnorvegicus tbelangeri etelfairi stridecemlineatus mmurinus tsyrichta cjacchus mmulatta hsapiens);
my %core;
my $core;

print "Processing Core Files...";
open (my $in5, "<", "/home/mitochi/Desktop/Work/newcegma/cpglite/temp3") or die "Cannot read from input: $!\n";
while (my $line = <$in5>) {
	chomp($line);
	($core) = $line =~ />(\w+)/i if $line =~ />/;
	next if $line =~ />/;
	print "CORE = $core\n";
	die if not defined($core);
	push(@{$core{$core}}, $line);
}
close $in5;
print "Done!\n";

print "Processing each core...\n";
foreach my $core1 (sort keys %core) {
	my $count = 0;
	my $Rscript = "
	library(ggplot2)
	library(meta)
	";

	next if $core1 =~ /all/;
	my ($core) = $core1 =~ /^(\w+)2$/i if $core1 !~ /^all$/;
	$core = 'hsapiens' if $core1 =~ /^all$/;
	print "\tCore = $core, using top organism $core1\n";
foreach my $kmer (sort keys %{$org{$core}}) {
	my @kmer;
	my @x_axis;
	
	#Xdata
	print "\t$core $kmer Xaxis data\n";
	for (my $i = 1; $i < @{$core{$core1}}+1; $i++) {
		push(@x_axis, $i);
	}

	#Ydata
	print "\t$core $kmer Yaxis data\n";
	for (my $i = 0; $i < @{$core{$core1}}; $i++) {
		my $score = $org{$core{$core1}[$i]}{$kmer}{'score'};
		$score = 0  unless defined($score);
		$score = 0 if $score =~ /inf/i;
		$score = 0 if $score =~ /nan/i;
		push(@kmer, $score);
	}
	
	#make Ydata non negative
	my @kmercheck = sort {$a <=> $b} @kmer;
	my $smallest = $kmercheck[0] * 1.1;
	if ($smallest < 0) {
		for (my $i = 0; $i < @kmer; $i++) {
			$kmer[$i] -= $smallest;
		}
	}
	elsif ($smallest == 0) {
		for (my $i = 0; $i < @kmer; $i++) {
			$kmer[$i] += 0.1;
		}
	}
	

	print "\t$core $kmer Curve Fitting\n";
	
	#print "linear\n";
	my ($resSS_linear, $par_linear) 	 = curvefit('linear', 'x', \@x_axis, \@kmer, 100);
	
	#print "power\n";
	my ($resSS_power, $par_power) 	 = curvefit('power', 'x', \@x_axis, \@kmer, 100);
	
	#print "exponential\n";
	my ($resSS_exp, $par_exp)		 = curvefit('exp', 'x', \@x_axis, \@kmer, 100);
	
	#print "log\n";
	my ($resSS_log, $par_log)		 = curvefit('log', 'x', \@x_axis, \@kmer, 100);
	
	my $totalSS = (@kmer-1) * mitochy::var_sample(@kmer);

	my $R2_linear = $resSS_linear =~ /NA/ ? 0 : 1-($resSS_linear/$totalSS);
        my $R2_power  = $resSS_power =~ /NA/ ? 0 : 1-($resSS_power/$totalSS);
        my $R2_exp    = $resSS_exp =~ /NA/ ? 0 : 1-($resSS_exp/$totalSS);
        my $R2_log    = $resSS_log =~ /NA/ ? 0 : 1-($resSS_log/$totalSS);
	
	my %R2 = (
	"linear",$R2_linear,
	"power",$R2_power,
	"exp",$R2_exp,
	"log",$R2_log,
	);
	my $biggest_R2 = 0;
	foreach my $R2 (sort {$R2{$b} <=> $R2{$a}} keys %R2) {
		$biggest_R2 = $R2;
		#print "R2 = $R2\n";
		last;
	}
	$totalall++;
	next if $R2{$biggest_R2} < $MIN_RSQ;

	#print "
	#totalSS = $totalSS
      	#R2 linear = $R2_linear, residual SS linear = $resSS_linear
        #R2 power  = $R2_power, residual SS power  = $resSS_power
        #R2 exp    = $R2_exp, residual SS exp    = $resSS_exp
        #R2_log    = $R2_log, residual SS log    = $resSS_log\n";
	
	my $name;
	$name = $kmer . "_" . "$R2{$biggest_R2}\_linear" if $biggest_R2 =~ /linear/;
	$name = $kmer . "_" . "$R2{$biggest_R2}\_power" if $biggest_R2 =~ /power/;
	$name = $kmer . "_" . "$R2{$biggest_R2}\_exp" if $biggest_R2 =~ /exp/;
	$name = $kmer . "_" . "$R2{$biggest_R2}\_log" if $biggest_R2 =~ /log/;
	$count++;

	print "\t$core $kmer Making R Script\n";

	$Rscript .= make_Rscript(\@x_axis, \@kmer, $name, \@{$core{$core1}}, $count, $core1);

}

	print "\t$core Running R Script\n";

open (my $out, ">", "$input.$pos.$core.R") or die "Cannot write to $input.$pos.$core.R: $!\n";

print $out "$Rscript\n";
close $out;

print "HERE\n";
my $Rthis = "R --vanilla --no-save < $input.$pos.$core.R";
print "$Rscript\n";
system($Rthis) == 0 or die "Failed to run R: $!\n";
$worked++;
}

open (my $out99, ">", "$input.$pos.certification") or die "Cannot write to $input.$pos.certiication: $!\n";
print $out99 "Done: $worked/$totalall identified\n";
close $out99;

sub make_Rscript {
	my ($xaxis, $yaxis, $name, $label, $count, $core1) = @_;
	my @xaxis = @{$xaxis};
	my @label = @{$label};
	foreach my $label (@label) {
		$label =~ s/^/"/ig;
		$label =~ s/$/"/ig;
	}
	my @yaxis = @{$yaxis};
	my $R_x = mitochy::R_array(\@xaxis, 'x');
	my $R_y = mitochy::R_array(\@yaxis, 'y');
	my $R_label = mitochy::R_array(\@label, 'lab');
	my $Rscript = "
	$R_x
	$R_y
	$R_label
	 
	Dataset <- data.frame(organism=x, score=y)

	p.$count <- ggplot(data = Dataset, aes(x = organism, y = score)) + geom_point(data=Dataset, aes(x=organism, y=score,colour=\"red\")) + geom_text(data=Dataset, aes(label=lab), size=3, hjust=0.5, vjust=1) + geom_smooth(method=\"lm\") + opts(title=\"$name\",legend.position=\"none\")
	ggsave(p.$count, filename=\"$input.$name.$pos.$core1.pdf\")
	";
	return($Rscript);
}
	
sub curvefit {
	my ($formula, $variable, $xdata, $ydata, $max_iter) = @_;
	
	my @parameters;
	if ($formula =~ /linear/i) {
		$formula = 'a + b*x';
		my ($a_val, $b_val) = is_linear($xdata, $ydata);
		#print "a = $a_val, b = $b_val\n";
	        @parameters = (['a', $a_val, 0.0001],['b', $b_val, 0.0005],);
	}

	elsif ($formula =~ /power/i) {
		$formula = 'a * x^b';
		my ($a_val, $b_val) = is_power($xdata, $ydata);
                #print "a = $a_val, b = $b_val\n";
	        @parameters = (['a', $a_val, 0.0001],['b', $b_val, 0.0005],);
	}

	elsif ($formula =~ /log/i) {
		$formula = 'a + b * (log(2.718281828,x))';
		my ($a_val, $b_val) = is_log($xdata, $ydata);
                #print "a = $a_val, b = $b_val\n";
	        @parameters = (['a', $a_val, 0.00001],['b', $b_val, 0.00005],);
	}

	elsif ($formula =~ /exp/i) {
		$formula = 'a * 2.718281828^(b * x)';
		my ($a_val, $b_val) = is_exp($xdata, $ydata);
                #print "a = $a_val, b = $b_val\n";
		@parameters = (['a', $a_val, 0.00001],['b', $b_val, 0.00005],);
	}

	my $square_residual = Algorithm::CurveFit -> curve_fit(
		formula 	=> $formula,
		params 		=> \@parameters,
		variable 	=> $variable,
		xdata 		=> $xdata, 
		ydata 		=> $ydata,
		maximum_iterations => $max_iter,
	);
		
	return($square_residual, \@parameters);
}

sub is_linear {
        my ($xdata, $ydata) = @_;
        my @numbers = @{$ydata};
        my @axis = @{$xdata};

        my $lineFit = Statistics::LineFit->new();
        $lineFit->setData(\@axis, \@numbers) or die "Invalid Data\n";
        my ($intercept, $slope) = $lineFit->coefficients();
        defined $intercept or die "Can't fit line if x values are all equal";
        my $rSquared = $lineFit->rSquared();
        return($intercept, $slope);
}
        
sub is_power {
        my ($xdata, $ydata) = @_;
        my @numbers = @{$ydata};
        my @axis = @{$xdata};

        my ($lnxlny, $lnx, $lny, $lnx2, $sum_y, $sum_x, $n) = (0,0,0,0,0, 0, @numbers);
        
        for (my $i = 0; $i < @numbers; $i++) {
                next if not defined($numbers[$i]);
                my $x = $axis[$i];
                my $y = $numbers[$i];
                $sum_x += $axis[$i];
                $sum_y += $numbers[$i];
                $lnxlny += ln($x) * ln($y);
                $lnx += ln($x);
                $lny += ln($y);
                $lnx2 += (ln($x))**2;
        }

        my $bval = ($n * $lnxlny - $lnx * $lny) / ($n * $lnx2 - $lnx**2);
        #print "bval = my $bval = ($n * $lnxlny - $lnx * $lny) / ($n * $lnx2 - $lnx**2)\n";

        my $aval = exp(($lny - $bval * $lnx)/$n);
        #print "aval = exp(($lny - $bval * $lnx)/$n)\n";

        return($aval, $bval);
}
        
sub is_exp {
        my ($xdata, $ydata) = @_;
	my @numbers = @{$ydata};
	my @axis = @{$xdata};

        my ($sum_lny, $sum_y, $sum_x2, $sum_x, $sum_xlny) = (0,0,0,0,0);
        
        for (my $i = 0; $i < @numbers; $i++) {
                my $x = $axis[$i];
                my $y = $numbers[$i];
                $sum_y += $y;
                $sum_x += $x;
                $sum_x2 += $x**2;
                $sum_lny += ln($y);
                $sum_xlny += $x*ln($y);
        }
                
        my $a_val = exp(($sum_lny * $sum_x2 - $sum_x * $sum_xlny)/(@numbers * $sum_x2 - ($sum_x)**2));
        my $b_val = (@numbers * $sum_xlny - $sum_x*$sum_lny)/(@numbers * $sum_x2 - ($sum_x)**2);
	return($a_val, $b_val);
}


sub is_log {
        my ($xdata, $ydata) = @_;
        my @numbers = @{$ydata};
        my @axis = @{$xdata};

	my ($sum_ylnx, $sum_y, $sum_lnx, $sum_lnx2) = (0,0,0,0);

	for (my $i = 0; $i < @numbers; $i++) {
		my $x = $axis[$i];
		my $y = $numbers[$i];
		$sum_ylnx += $y * ln($x);
		$sum_y += $y;
		$sum_lnx += ln($x);
		$sum_lnx2 += ln($x**2);
	}
	
	my $b_val = (@numbers * $sum_ylnx - $sum_y * $sum_lnx) / (@numbers * $sum_lnx2 - ($sum_lnx)**2);
	my $a_val = ($sum_y - $b_val * $sum_lnx) / @numbers;
	return($a_val, $b_val);

}

sub ln {
	my ($number) = @_;
	return(log($number)/log(exp(1)));
}

__END__

