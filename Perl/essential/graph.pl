#!/usr/bin/perl

use strict; use warnings; use R_toolbox; use Getopt::Std; use mitochy;
use vars qw($opt_x $opt_y $opt_o $opt_z $opt_w $opt_s $opt_t $opt_l $opt_m $opt_c $opt_X);
getopts("x:y:o:z:w:s:t:l:m:c:X:");

my (@input) = @ARGV;
die "
usage: $0 [options] <multiple tsv two column: pos [tab] value>

options:

-x: offset of x (default:0)
-X: step offset of x (default:1)
-y: start position of y (default: 0)
-z: end position of y (default: 100)
-w: window_size (default: 100)
-s: step_size (default: 1)
-o: output pdf
-t: title
-l: x axis label (default: \"position from TSS (bp)\")
-m: y axis label (default: yaxis)
-c: File containing name and color information (name [tab] R_color_code) 
    Default: /data/mitochi/Work/Codes/dataset/color.tsv

" unless @ARGV;

my ($xstart, $xend, $xcheck, $Rdata, $Rlines) = (0, 0, 0);

my $opt_X   = defined($opt_X) ? $opt_X : 1;
my $xlab    = defined($opt_l) ? $opt_l : "position from TSS (bp)";
my $ylab    = defined($opt_m) ? $opt_m : "yaxis";
my $ystart  = defined($opt_y) ? $opt_y : 0;
my $yend    = defined($opt_z) ? $opt_z : 100;
my $window  = defined($opt_w) ? $opt_w : 100;
my $step    = defined($opt_s) ? $opt_s : 1;
my $output  = defined($opt_o) ? $opt_o : "Rplots.pdf";
my $title   = defined($opt_t) ? $opt_t : $output;
my $colfile = defined($opt_c) ? $opt_c : "/data/mitochi/Work/Codes/dataset/color.tsv";

foreach my $input (@input) {
	die "Cannot read from $input!\n" unless -e $input;
}

foreach my $input (@input) {
	my ($name) = mitochy::getFilename($input);
	open (my $in, "<", $input) or die "Cannot read from $input: $!\n";

	my $color = getColor($name, $colfile);
	my @pos;
	my @val;
	while (my $line = <$in>) {
		chomp($line);
		next if $line !~ /^\-?\d+/;
		my ($pos, $val) = split("\t", $line);
		$val = 0 if $val eq "NA";
		#$pos = defined($opt_X) ? $pos * $opt_X : $pos;
		$pos = defined($opt_x) ? $pos + $opt_x : $pos;
		push(@pos, $pos);
		push(@val, $val);
	}
	close $in;

	my @newval;
	my @newpos;
	my $total_data_point = @val;
	die "Error: Total data point ($total_data_point) is less than window size ($window)\n" if $total_data_point < $window;
	for (my $i = 0; $i < @val-$window; $i+= $step) {
		my $val = 0;
		for (my $j = $i; $j < $i+$window; $j++) {
			$val += $val[$j];
		}
		$val /= $window;
		push(@newval, $val);
		push(@newpos, $pos[$i]);# + int($window/2));
	}

	$xstart = $newpos[0];
	$xend   = $newpos[@newpos-1];
	@val    = @newval;
	@pos    = @newpos;
	my $valcount = @val;
	print "Total Y values = $valcount, Xstart = $xstart, Xend = $xend\n";
	my $Rpos = R_toolbox::newRArray(\@pos, "$name.pos");
	my $Rval = R_toolbox::newRArray(\@val, "$name.val");
	$Rdata .= "
$Rpos
$Rval
length1 = length($name.pos)
length2 = length($name.val)
print(length1)
print(length2)
	";
	$Rlines .= "
#smoothingSpline = smooth.spline($name.pos, $name.val, spar=0.5)
#lines(smoothingSpline,col=$color,type=\"l\")
lines($name.pos, $name.val,type=\"l\",col=$color)


lines(c($xend*0.8,$xend*0.85),c($yend*(0.95 - 0.05*$xcheck),$yend*(0.95 - 0.05*$xcheck)),col=$color,type=\"l\")
text($xend*0.85,$yend*(0.95-0.05*$xcheck),\"$name\",cex=0.5,pos=4)
	";
	@pos = ();
	@val = ();
	$xcheck ++;
}
my $Rscript = "
$Rdata
pdf(\"$output\")
plot(NA,xlim=c($xstart,$xend),ylim=c($ystart,$yend),xlab=\"$xlab\",ylab=\"$ylab\")
title(\"$title\")
$Rlines
lines(c(($xstart+$xend)*0.5,($xstart+$xend)*0.5),c($ystart,0.9*$yend),lty=2,type=\"l\")
lines(c(($xstart+$xend)*0.5,($xstart+$xend)*0.5+0.2*$xend),c(0.9*$yend,0.9*$yend),lty=2,type=\"l\")
lines(c(($xstart+$xend)*0.5+0.2*$xend,($xstart+$xend)*0.5+0.2*$xend),c(0.88*$yend,0.92*$yend),type=\"l\")
lines(c(($xstart+$xend)*0.5+0.2*$xend,($xstart+$xend)*0.5+0.25*$xend),c(0.92*$yend,0.9*$yend),type=\"l\")
lines(c(($xstart+$xend)*0.5+0.2*$xend,($xstart+$xend)*0.5+0.25*$xend),c(0.88*$yend,0.9*$yend),type=\"l\")
";



R_toolbox::execute_Rscript($Rscript);
print "Output: $output\n";

sub getColor {
	my ($name, $colfile) = @_;

	my %color;
	open (my $in, "<", $colfile) or die "Cannot read from color file $colfile: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		my ($name, $color) = split("\t", $line);
		die "Color: Died at $line\n" if not defined($name);
		$color{$name} = $color;
	}


	my $color = defined($color{$name}) ? $color{$name} : "rgb(0,0,0,maxColorValue=255)";
	return($color);
}
__END__
	while (my $line = <$in>) {
		chomp($line);
		my ($name, @value) = split("\t", $line);
		for (my $i = 0; $i < @value; $i++) {
			@pos[$i] = $i;
		}
		@val = @value;
	}

