package R_toolbox;

use strict; use warnings;
use mitochy; use FAlite;
use Cache::FileCache;

sub newRArray {
        my ($array, $var, $mode, $step_size) = @_;

        $step_size = 1 if not defined($step_size);
        my @array = @{$array};
        my $Rscript;

        $Rscript .= "$var <- c(";

        if (defined($mode) and $mode =~ /with_quote/i) {
                for (my $i = 0; $i < @array; $i+=$step_size) {
			next if ($array[$i] =~ /^\".+\"$/);
                        $Rscript .= "\"$array[$i]\", " if $i < @array-1;
                        $Rscript .= "\"$array[$i]\")" if $i == @array-1;
                }
        }

        else {
                for (my $i = 0; $i < @array; $i+=$step_size) {
                        $Rscript .= "$array[$i], " if $i < @array-1;
                        $Rscript .= "$array[$i])" if $i == @array-1;
                }
        }

        return ($Rscript);
}
sub newRMatrix {
        my ($array, $var, $mode, $step_size) = @_;

        $step_size = 1 if not defined($step_size);
        my @array = @{$array};
        my $Rscript;

        $Rscript .= "$var <- matrix(";

        if (defined($mode) and $mode =~ /with_quote/i) {
                for (my $i = 0; $i < @array; $i+=$step_size) {
			next if ($array[$i] =~ /^\".+\"$/);
                        $Rscript .= "\"$array[$i]\", " if $i < @array-1;
                        $Rscript .= "\"$array[$i]\")" if $i == @array-1;
                }
        }

        else {
                for (my $i = 0; $i < @array; $i+=$step_size) {
                        $Rscript .= "$array[$i], " if $i < @array-1;
                        $Rscript .= "$array[$i])" if $i == @array-1;
                }
        }

        return ($Rscript);
}
sub newRDF {
        my ($array, $var, $mode, $step_size) = @_;

        $step_size = 1 if not defined($step_size);
        my @array = @{$array};
        my $Rscript;

        $Rscript .= "$var <- data.frame(";

        if (defined($mode) and $mode =~ /with_quote/i) {
                for (my $i = 0; $i < @array; $i+=$step_size) {
			next if ($array[$i] =~ /^\".+\"$/);
                        $Rscript .= "\"$array[$i]\", " if $i < @array-1;
                        $Rscript .= "\"$array[$i]\")" if $i == @array-1;
                }
        }

        else {
                for (my $i = 0; $i < @array; $i+=$step_size) {
                        $Rscript .= "$array[$i], " if $i < @array-1;
                        $Rscript .= "$array[$i])" if $i == @array-1;
                }
        }

        return ($Rscript);
}

sub execute_Rscript {
	my ($Rfile, $mode) = @_;
	my $RCMD;
	# timestamp
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

	if (defined($mode) and $mode eq "file") {
		if (defined($mode) and $mode = "multi") {
			my @Rfile = @{$Rfile};
			my $number = @Rfile;
	
				print "number of files exceed 300! This will slow down computer. Are you sure you want to continue? (Ctrl C to cancel)\n" if ($number >= 500);
	
			foreach my $fh (@Rfile) {
				$RCMD .= "R --no-save < $fh > dump & ";
			}
		}
	
		else {
			$RCMD = "R --no-save < $Rfile > dump";
	
		}
		print "$RCMD\n";
		system($RCMD) == 0 or return(0);
	}
	else {
		my $rand = rand(100);
		open (my $out, ">", "temp.$rand$sec$min$hour$mday.R") or die "Cannot write to temp.$rand$sec$min$hour$mday.R: $!\n";
		print $out $Rfile;
		close $out;
		$RCMD = "R --no-save < temp.$rand$sec$min$hour$mday.R > dump";
		system($RCMD) == 0 or die "Failed to execute R script\n$Rfile\n";
		#$RCMD = "rm temp.$sec$min$hour$mday.R";
		#system($RCMD);
	}

}

sub combine_plots {
	my ($org, $Rfiles) = @_;
	my @Rfiles = @{$Rfiles};
	my $num_of_Rfiles = @Rfiles;
	my $squared = sqrt($num_of_Rfiles);
	my ($xsq, $ysq) = (int($squared), int($squared)+1);
	while ($xsq*$ysq < $num_of_Rfiles) {
		$ysq++;
	}

	my $combined_Rfile = "
	pdf(\"\.\/\/$org.combined.pdf\")
	par(mfrow=c($xsq,$ysq), oma=c(0,0,0,0), mar=c(0,0,0,0))
	";
	foreach my $Rfile (@Rfiles) {
		open (my $in, "<", $Rfile) or die "Cannot read from $Rfile: $!\n";
		while (my $line = <$in>) {
			#chomp($line);
			next if $line =~ /pdf/i;
			next if $line =~ /dev.off/i;
			next if $line =~ /par\(/;
			if ($line =~ /cex=\d+\.*\d*/i) {
				my ($textsize) = $line =~ /cex=(\d+\.*\d*)/i;
				die "$line\n" if ($line =~ /cex=\d+\.*\d*/i and not defined($textsize));
				my $newtextsize = $ysq == 1 ? $textsize : $textsize/($ysq**0.7);
				$line =~ s/cex=$textsize/cex=$newtextsize/ig if $line =~ /cex=\d+/i;
			}
			if ($line =~ /lwd=\d+\.*\d*/i) {
				my ($linesize) = $line =~ /lwd=(\d+\.*\d*)/i;
				die "$line\n" if ($line =~ /lwd=\d+\.*\d*/i and not defined($linesize));
				my $newlinesize = $ysq == 1 ? $linesize : $linesize/$ysq;
				$line =~ s/lwd=$linesize/lwd=$newlinesize/ig if $line =~ /lwd=\d+/i;
			}
			$combined_Rfile .= $line;
		}
		close $in;
	}
	return($combined_Rfile);
}

1;
