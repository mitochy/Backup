package R_biomart;

use strict; use warnings;

use mitochy; use FAlite;
use Cache::FileCache;

# Global_Variables
# Mart list, Organism list
sub Global_Var {
	my ($query) = @_;
	my @martlist = qw(ensembl metazoa fungi plants protists);

	my %org;
	@{$org{'all'}} = qw(aaegypti acarolinensis acephalotes aclavatus aflavus afumigatusa1163 afumigatus agambiae agossypii alaibachii alyrata amelanoleuca amellifera anidulans aniger aoryzae apisum aqueenslandica aterreus athaliana bdistachyon bfuckeliana bmori brapa btaurus cbrenneri cbriggsae celegans cfamiliaris choffmanni cintestinalis cjacchus cjaponica cmerolae cporcellus cquinquefasciatus creinhardtii cremanei csavignyi dananassae ddiscoideum derecta dgrimshawi dmelanogaster dmojavensis dnovemcinctus dordii dpersimilis dplexippus dpseudoobscura dpulex drerio dsechellia dsimulans dvirilis dwillistoni dyakuba ecaballus eeuropaeus ehistolytica etelfairi fcatus foxysporum gaculeatus ggallus ggorilla ggraminis gmax gmoniliformis gmorhua gzeae harabidopsidis hmelpomene hsapiens d iscapularis lafricana lchalumnae lmajor mdomestica meugenii mgallopavo mgraminicola mlucifugus mmulatta mmurinus mmusculus moryzae mpoae ncrassa nfischeri nhaematococca nleucogenys nvectensis oanatinus obrachyantha ocuniculus ogarnettii oglaberrima oindica olatipes oprinceps osativa pabelii pberghei pcapensis pchabaudi pfalciparum pgraminis phumanus pinfestans pknowlesi pmarinus pnodorum ppacificus ppatens pramorum psojae ptrichocarpa ptricornutum ptriticina ptroglodytes pultimum pvampyrus pvivax rnorvegicus saraneus sbicolor scerevisiae sharrisii sitalica slycopersicum smoellendorffii spombe spurpuratus ssclerotiorum sscrofa stridecemlineatus tadhaerens tbelangeri tbrucei tcastaneum tgondii tguttata tmelanosporum tnigroviridis tpseudonana trubripes tspiralis tsyrichta tthermophila ttruncatus umaydis vpacos vvinifera xtropicalis zmays);

	@{$org{'insects'}} = qw(aaegypti acephalotes agambiae amellifera apisum bmori cquinquefasciatus dananassae derecta dgrimshawi dmojavensis dpersimilis dplexippus dpseudoobscura dpulex dsechellia dsimulans dvirilis dwillistoni dyakuba hmelpomene iscapularis phumanus tcastaneum);
	
	@{$org{'plants'}} = qw(alyrata athaliana bdistachyon brapa cmerolae creinhardtii gmax obrachyantha oglaberrima oindica 
osativa ppatens ptricocarpa sbicolor sitalica slycopersicum smoellendorffii vvinifera zmays);

	@{$org{'worms'}} = qw(aqueenslandica cbrenneri cbriggsae cjaponica cremanei nvectensis ppacificus spurpuratus tadhaerens 
tspiralis);
	
	@{$org{'fungi'}} = qw(aclavatus aflavus afumigatusa1163 afumigatus agossypii anidulans aniger aoryzae aterreus bfuckeliana 
foxysporum ggraminis gmoniliformis gzeae mgraminicola moryzae mpoae ncrassa nfischeri nhaematococca pgraminis pnodorum ptriticina 
scerevisiae ssclerotiorum tmelanosporum umaydis);
	
	@{$org{'protists'}} = qw(alaibachii ddiscoideum ehistolytica harabidopsidis lmajor pberghei pchabaudi pfalciparum 
pinfestans pknowlesi pramorum psojae ptricornutum pultimum pvivax tbrucei tpseudonana tthermophila);

	@{$org{'tunicates'}} = qw(cintestinalis csavignyi);

	@{$org{'vertebrates'}} = qw(acarolinensis amelanoleuca btaurus cfamiliaris choffmanni cjacchus cporcellus dnovemcinctus 
dordii drerio ecaballus eeuropaeus etelfairi fcatus gaculeatus ggallus ggorilla gmorhua lafricana lchalumnae mdomestica meugenii 
mgallopavo mlucifugus mmulatta mmurinus mmusculus nleucogenys oanatinus ocuniculus ogarnettii olatipes oprinceps pabelii pcapensis 
pmarinus ptroglodytes pvampyrus rnorvegicus saraneus sharrisii sscrofa stridecemlineatus tbelangeri tguttata tnigroviridis 
trubripes tsyrichta ttruncatus vpacos xtropicalis);

	return(@martlist) if $query =~ /martlist/;
	return(%org) if $query =~ /orglist/;

}

sub cache {
	my $cache = new Cache::FileCache();
	$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
	my $exon_db = $cache -> get("exondb");
	if (not defined($exon_db)) {
		my $cmd = "R_biomart_getexon.pl";
		system($cmd);
	}
}


sub gethomolog {
	my ($org) = @_;

	my $R_dataset = getdataset($org);
	validate($R_dataset, "dataset");
	return ($R_dataset) if $R_dataset =~ /^ERROR/;
	
}	

# Return mart and ensembl_dataset of certain organism
sub process_ensembl_dataset {

        my ($mart) = @_;
	my @martlist = Global_Var("martlist");

        die "at R_biomart.pm process_ensembl_dataset\nusage: mart = ensembl, metazoa, fungi, plants, protists\nYour input: $mart\n" if not grep(/^$mart$/, @martlist);

        my @datasets;
        my $dataset = "/home/mitochi/Desktop/Work/ensembl/ensembl_datasets_$mart.dat";
        open (my $in, "<", $dataset) or die "Dataset process error: Cannot read from $dataset: $!\n";
        while (my $line = <$in>) {
                chomp($line);
                my @arr = split("\t", $line);
                push(@datasets, $arr[1]);

        }
        close $in;
        return(@datasets);
}
sub getdataset {

        my ($org) = @_;
        my ($ensembl_dataset, $mart);

        #dataset
        ($ensembl_dataset, $mart) = ("$org\_eg_gene", "fungi_mart_14") if grep(/$org/,process_ensembl_dataset("fungi"));
        ($ensembl_dataset, $mart) = ("$org\_eg_gene", "protists_mart_14") if grep(/$org/,process_ensembl_dataset("protists"));
        ($ensembl_dataset, $mart) = ("$org\_eg_gene", "metazoa_mart_14") if grep(/$org/,process_ensembl_dataset("metazoa"));
        ($ensembl_dataset, $mart) = ("$org\_eg_gene", "plants_mart_14") if grep(/$org/,process_ensembl_dataset("plants"));
        ($ensembl_dataset, $mart) = ("$org\_gene_ensembl", "ensembl") if grep(/$org/,process_ensembl_dataset("ensembl"));

        my $R_biomart = "
        $org.mart <- useMart(\"$mart\", dataset = \"$ensembl_dataset\")
        " if defined($mart);

	$R_biomart = "ERROR(0): R_biomart::R_biomart_getdataset error: Database not found for $org\n" if not defined($mart);
	$mart = 0 if not defined($mart);
	$ensembl_dataset = 0 if not defined($ensembl_dataset);

        return($R_biomart, $mart, $ensembl_dataset);
}


# Get Gene(s) flanking queried gene
# Return Gene ID, Chr name, Start pos, End pos, Strand at $org.table.geneflank.$flank.txt
sub getflankgenes {
        my ($org, $chr, $start, $end, $flank) = @_;
	
	#Get Dataset
	my ($dataset) = getdataset($org);
	validate($dataset, "dataset");
	return ($dataset) if $dataset =~ /^ERROR/;

        my $R_biomart = "
        $dataset
	$chr
        $start
        $end
        $org.geneflank <- getBM(mart=$org.mart, attributes = c(\"ensembl_gene_id\", \"chromosome_name\", \"start_position\", \"end_position\", \"strand\"), filters=c(\"chromosome_name\", \"start\", \"end\"), values = list($org.chr, $org.start, $org.end))
        write.table($org.geneflank, \"$org.table.geneflank.$flank.txt\")
        ";

        return($R_biomart);
}

# Get Exon
# Return Exon Start Coor, Exon End Coor, and Chr of Gene ID List
sub getexon {
	my ($org, $id) = @_;

	#Get Dataset
	my ($dataset, $mart, $mart2) = getdataset($org);
	validate($dataset, "dataset");
	return ($dataset) if $dataset =~ /^ERROR/;

	my $R_biomart = "
	$dataset
        $id
        $org.exontable <- getBM(mart = $org.mart, attributes = c(\"ensembl_gene_id\", \"ensembl_transcript_id\", \"exon_chrom_start\", \"exon_chrom_end\", \"strand\", \"chromosome_name\"), filters = \"ensembl_gene_id\", values = $org.id)
        write.table($org.exontable, \"/home/mitochi/Desktop/Work/newcegma/exon/$org.table.exon.txt\")
        ";

	return($R_biomart);
}



sub validate {
	my ($query, $type) = @_;

	#Dataset not defined
	if ($type =~ /dataset/ and $query =~ /^ERROR(0)/) {
		print "$query\n";
		return($query);
	}

}
1;
