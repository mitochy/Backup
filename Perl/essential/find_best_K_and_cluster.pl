#!/usr/bin/perl -w

#use lib '../blib/lib', '../blib/arch';

use strict; use warnings;
use Algorithm::KMeans;

my ($datafile, $mask, $desired_K) = @ARGV;
die "usage: $0 <datafile> <MASK> <desired K>\n" unless @ARGV >= 1;

$datafile =~ s/\s*$//;
$datafile =~ s/\n*$//;
#check line of datafile
my $linenum = `wc -l $datafile`;
($linenum) = $linenum =~ /^(\d+)/;
my $K = $linenum < 8 ? 2 : 0;
$K = defined($desired_K) ? $desired_K : $K;
#my $datafile = "mydatafile2.dat";

# Mask:

# The mask tells the module which columns of the data file
# are are to be used for clustering, which columns are to be
# ignored and which column contains the symbolic ID tag for
# a data point.  If the ID is in column 1 and you are
# clustering 3D data, the mast would be "N111".  Note the
# first character in the mask in this case is `N' for
# "Name".  If, on the other hand, you wanted to ignore the
# first data coordinate for clustering, the mask would be
# "N011".  The symbolic ID can be in any column --- you just
# have to place the character `N' at the right place:


my $clusterer = Algorithm::KMeans->new( datafile => $datafile,
                                        mask     => $mask,
                                        K        => $K,
                                        terminal_output => 1,
                                        cluster_seeding => 'random', 
#                                       do_variance_normalization => 1,
#                                       write_clusters_to_files => 1,
                                        debug => 0,
);

$clusterer->read_data_from_file();

# If you want to access the clusters in your own script:
my ($clusters, $cluster_centers) = $clusterer->kmeans();
foreach my $cluster (@$clusters) {
    print "Cluster:   @$cluster\n\n"
}

# The following call also prints out the best value for K:
if ($K == 0) {
	my $K_best = $clusterer->get_K_best();
	$clusterer->show_QoC_values();
}


# VISUALIZATION:

# Visualization mask:

# In most cases, you would not change the value of the mask
# between clustering and visualization.  But, if you are
# clustering multi-dimensional data and you wish to
# visualize the projection of of the data on each plane
# separately, you can do so by changing the value of the
# visualization mask.  The number of on bits in the
# visualization must not exceed the number of on bits in the
# original data mask.

#print "mask = $mask\n";
#$clusterer->visualize_clusters($mask);

#my ($family) = $datafile =~ /(\w+).cpgheavy/;
#print "\nfind_best_K_and_cluster.pl $datafile N1 2 | grep \"Cluster:\" | perl -pi -e 's/Cluster:\s{1,20}/ /ig' | perl -pi -e 's/ /,3.add.pc,/ig' | perl -pi -e 's/^,3.add./cpgheavy.pl -g /ig' |  perl -pi -e 's/$/ -m -a $family/'";
