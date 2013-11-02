package seq_calculator;

use strict; use warnings;
use FAlite;
use Cache::FileCache;

# Calculate nucleotide either single or more than 1
sub count_nuc {
        my ($type, $seq) = @_; # type is nucleotide, seq is the sequence

	my $count;
	# Make it case insensitive
        $type = uc($type);
        $seq = uc($seq);

	# If length of type is 1 (mononucleotide) we just count it using transliterate
	if (length($type) == 1) {
	        # Count by Transliterate #
                $count = $seq =~ tr/A/A/ if $type eq "A";
                $count = $seq =~ tr/T/T/ if $type eq "T";
                $count = $seq =~ tr/G/G/ if $type eq "G";
                $count = $seq =~ tr/C/C/ if $type eq "C";
	}

	# Else, we count the k-mer using global match
        else {
                $count = 0;
                while ($seq =~ /$type/g) {
                        $count++;
                }
        }

        return($count);
}

1;

__END__
	        my @type_part = split("", $type);
	        foreach my $type_part (@type_part) {
	                # Count by Transliterate #
	                $count{'A'} = $seq =~ tr/A/A/ if $type_part =~ /A/i;
	                $count{'T'} = $seq =~ tr/T/T/ if $type_part =~ /T/i;
	                $count{'G'} = $seq =~ tr/G/G/ if $type_part =~ /G/i;
	                $count{'C'} = $seq =~ tr/C/C/ if $type_part =~ /C/i;
	        }
