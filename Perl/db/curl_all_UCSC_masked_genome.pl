#!/usr/bin/perl

use strict; use warnings;

my @org = qw(Ailuropoda_melanoleuca Anolis_carolinensis Anopheles_gambiae Apis_mellifera Aplysia_californica Bos_taurus Branchiostoma_floridae Caenorhabditis_brenneri Caenorhabditis_briggsae Caenorhabditis_elegans Caenorhabditis_japonica Caenorhabditis_remanei Callithrix_jacchus Canis_familiaris Cavia_porcellus Ciona_intestinalis Danio_rerio Drosophila_ananassae Drosophila_erecta Drosophila_grimshawi Drosophila_melanogaster Drosophila_mojavensis Drosophila_persimilis Drosophila_pseudoobscura Drosophila_sechellia Drosophila_simulans Drosophila_virilis Drosophila_yakuba Equus_caballus Felis_catus Fugu_rubripes Gallus_gallus Gorilla_gorilla_gorilla Heterocephalus_glaber Homo_sapiens Loxodonta_africana Macropus_eugenii Meleagris_gallopavo Monodelphis_domestica Mus_musculus Myotis_lucifugus Nomascus_leucogenys Ornithorhynchus_anatinus Oryctolagus_cuniculus Oryzias_latipes Ovis_aries Pan_troglodytes Petromyzon_marinus Pongo_abelii Pongo_pygmaeus_abelii Pristionchus_pacificus Rattus_norvegicus Rhesus_macaque SARS_coronavirus Saccharomyces_cerevisiae Strongylocentrotus_purpuratus Sus_scrofa Taeniopygia_guttata Takifugu_rubripes Tetraodon_nigroviridis Xenopus_tropicalis);

foreach my $org (@org) {
	my $curl = "curl ftp:\/\/hgdownload.cse.ucsc.edu\/goldenPath\/currentGenomes\/$org\/bigZips\/";
	print "downloading curl list from $curl…\n";
	my @list = `$curl`;
	print @list;
	my $correctlist;
	foreach my $list (@list) {
		$correctlist = $list if $list =~ /masked/i;
	}
	#print "correctlist = $correctlist\n";
	die "correctlist undefined\n" unless defined($correctlist);
	my ($filename) = $correctlist =~ m/^.+\d\d\d\d\ (.*masked.*)$/i;
	die "file name undefined from $correctlist\n" unless defined($filename);
	print "Does ./$org$filename exixts?\n";
	if (-e "./$org$filename") {
		print "skipped; $org$filename exists\n";
		next;
	}
	print "./$org$filename does not exists\n";
	my $newfilename = "curl ftp:\/\/hgdownload.cse.ucsc.edu\/goldenPath\/currentGenomes\/$org\/bigZips\/$filename > ./$org$filename";
	print "downloading $newfilename\n";
	system($newfilename) == 0 or print STDERR "Failed to download $org\n";
}

__END__

#ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ailuropoda_melanoleuca/bigZips/ailMel1.fa.masked.gz

my @org = qw(Ailuropoda_melanoleuca Anolis_carolinensis Anopheles_gambiae Apis_mellifera Aplysia_californica Bos_taurus Branchiostoma_floridae Caenorhabditis_brenneri Caenorhabditis_briggsae Caenorhabditis_elegans Caenorhabditis_japonica Caenorhabditis_remanei Callithrix_jacchus Canis_familiaris Cavia_porcellus Ciona_intestinalis Danio_rerio Drosophila_ananassae Drosophila_erecta Drosophila_grimshawi Drosophila_melanogaster Drosophila_mojavensis Drosophila_persimilis Drosophila_pseudoobscura Drosophila_sechellia Drosophila_simulans Drosophila_virilis Drosophila_yakuba Equus_caballus Felis_catus Fugu_rubripes Gallus_gallus Gorilla_gorilla_gorilla Heterocephalus_glaber Homo_sapiens Loxodonta_africana Macropus_eugenii Meleagris_gallopavo Monodelphis_domestica Mus_musculus Myotis_lucifugus Nomascus_leucogenys Ornithorhynchus_anatinus Oryctolagus_cuniculus Oryzias_latipes Ovis_aries Pan_troglodytes Petromyzon_marinus Pongo_abelii Pongo_pygmaeus_abelii Pristionchus_pacificus Rattus_norvegicus Rhesus_macaque SARS_coronavirus Saccharomyces_cerevisiae Strongylocentrotus_purpuratus Sus_scrofa Taeniopygia_guttata Takifugu_rubripes Tetraodon_nigroviridis Xenopus_tropicalis);

StellaHartonoMacBookPro:Allmasked stella$ ./tempdelete.pl 
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ailuropoda_melanoleuca/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1719    0     0   3844      0 --:--:-- --:--:-- --:--:--  4073
dr-xr-xr-x   2 ftp      ftp            24 Jun  7 13:30 .
dr-xr-xr-x  11 ftp      ftp            11 Jul 30  2010 ..
-r--r--r--   1 ftp      ftp          3959 Apr  1  2010 README.txt
-r--r--r--   1 ftp      ftp      604875083 Feb  3  2010 ailMel1.2bit
-r--r--r--   1 ftp      ftp       3755367 Apr  1  2010 ailMel1.agp.gz
-r--r--r--   1 ftp      ftp      747624943 Apr  1  2010 ailMel1.fa.gz
-r--r--r--   1 ftp      ftp      469801072 Apr  1  2010 ailMel1.fa.masked.gz
-r--r--r--   1 ftp      ftp      126463518 Apr  1  2010 ailMel1.fa.out.gz
-r--r--r--   1 ftp      ftp       4262004 Apr  1  2010 ailMel1.trf.bed.gz
-r--r--r--   1 ftp      ftp           415 Jun  5 11:53 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  5 11:53 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           510 May 20  2010 md5sum.txt
-r--r--r--   1 ftp      ftp         28630 Jun  5 11:35 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  5 11:35 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        708478 Apr  5  2010 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Apr  5  2010 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun  7 11:30 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 11:30 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun  7 11:31 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 11:31 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun  7 11:31 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 11:31 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2779611397 Jun  5 11:44 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  5 11:45 xenoMrna.fa.gz.md5
Does ./Ailuropoda_melanoleucaailMel1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ailuropoda_melanoleuca/bigZips/ailMel1.fa.masked.gz > ./Ailuropoda_melanoleucaailMel1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  448M  100  448M    0     0  2642k      0  0:02:53  0:02:53 --:--:-- 2918k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Anolis_carolinensis/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1574    0     0    887      0 --:--:--  0:00:01 --:--:--  1161
dr-xr-xr-x   2 ftp      ftp            22 Jun  5 13:41 .
dr-xr-xr-x  15 ftp      ftp            15 Nov  1  2011 ..
-r--r--r--   1 ftp      ftp          4408 Apr 15  2011 README.txt
-r--r--r--   1 ftp      ftp      515946569 Apr 13  2011 anoCar2.2bit
-r--r--r--   1 ftp      ftp       1052182 Apr 14  2011 anoCar2.agp.gz
-r--r--r--   1 ftp      ftp      570701481 Apr 14  2011 anoCar2.fa.gz
-r--r--r--   1 ftp      ftp      361729074 Apr 14  2011 anoCar2.fa.masked.gz
-r--r--r--   1 ftp      ftp      37365108 Apr 14  2011 anoCar2.fa.out.gz
-r--r--r--   1 ftp      ftp       5804830 Apr 14  2011 anoCar2.trf.bed.gz
-r--r--r--   1 ftp      ftp      42330609 Jun  5 12:30 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  5 12:30 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           304 Apr 14  2011 md5sum.txt
-r--r--r--   1 ftp      ftp         29506 Jun  5 12:13 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  5 12:13 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun  5 12:30 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  5 12:30 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun  5 12:30 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  5 12:30 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun  5 12:30 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  5 12:30 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2779608677 Jun  5 12:21 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  5 12:22 xenoMrna.fa.gz.md5
Does ./Anolis_carolinensisanoCar2.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Anolis_carolinensis/bigZips/anoCar2.fa.masked.gz > ./Anolis_carolinensisanoCar2.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  344M  100  344M    0     0  2784k      0  0:02:06  0:02:06 --:--:-- 3036k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Anopheles_gambiae/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1022    0     0   1734      0 --:--:-- --:--:-- --:--:--  1802
dr-xr-xr-x   2 ftp      ftp            15 Jun  5 13:43 .
dr-xr-xr-x   9 ftp      ftp            10 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          2296 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp        221865 Jun 17  2004 chromAgp.zip
-r--r--r--   1 ftp      ftp      84967880 Jun 17  2004 chromFa.zip
-r--r--r--   1 ftp      ftp      77235245 Jun 17  2004 chromFaMasked.zip
-r--r--r--   1 ftp      ftp       4070990 Jun 17  2004 chromOut.zip
-r--r--r--   1 ftp      ftp        631259 Jun 17  2004 chromTrf.zip
-r--r--r--   1 ftp      ftp      32082469 Jun  5 12:59 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  5 12:59 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           239 Jun 17  2004 md5sum.txt
-r--r--r--   1 ftp      ftp      16408023 Jun  5 12:36 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  5 12:36 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2763245678 Jun  5 12:45 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  5 12:46 xenoMrna.fa.gz.md5
Does ./Anopheles_gambiaechromFaMasked.zip exixts?
skipped; Anopheles_gambiaechromFaMasked.zip exists
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Apis_mellifera/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1022    0     0   2344      0 --:--:-- --:--:-- --:--:--  2498
dr-xr-xr-x   2 ftp      ftp            15 Jun  5 19:34 .
dr-xr-xr-x   6 ftp      ftp             7 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp        408915 Mar  1  2005 GroupAgp.zip
-r--r--r--   1 ftp      ftp      72792687 Feb 28  2005 GroupFa.zip
-r--r--r--   1 ftp      ftp      64987873 Feb 28  2005 GroupFaMasked.zip
-r--r--r--   1 ftp      ftp      10448086 Feb 28  2005 GroupOut.zip
-r--r--r--   1 ftp      ftp       1192175 Mar  1  2005 GroupTrf.zip
-r--r--r--   1 ftp      ftp          1719 Mar  1  2005 README.txt
-r--r--r--   1 ftp      ftp      13725776 Jun  5 14:33 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  5 14:33 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           192 Mar  1  2005 md5sum.txt
-r--r--r--   1 ftp      ftp      52925757 Jun  5 14:12 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  5 14:12 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2726724992 Jun  5 14:20 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  5 14:21 xenoMrna.fa.gz.md5
Does ./Apis_melliferaGroupFaMasked.zip exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Apis_mellifera/bigZips/GroupFaMasked.zip > ./Apis_melliferaGroupFaMasked.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 61.9M  100 61.9M    0     0  2413k      0  0:00:26  0:00:26 --:--:-- 2984k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Aplysia_californica/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1186    0     0   1213      0 --:--:-- --:--:-- --:--:--  1275
dr-xr-xr-x   2 ftp      ftp            17 Jun  5 19:38 .
dr-xr-xr-x   5 ftp      ftp             5 Oct 17  2011 ..
-r--r--r--   1 ftp      ftp          3785 Feb 22  2010 README.txt
-r--r--r--   1 ftp      ftp       1541608 May 28  2009 aplCal1.agp.gz
-r--r--r--   1 ftp      ftp      195130544 May 28  2009 aplCal1.fa.gz
-r--r--r--   1 ftp      ftp      181622660 May 28  2009 aplCal1.fa.masked.gz
-r--r--r--   1 ftp      ftp      16567671 May 28  2009 aplCal1.fa.out.gz
-r--r--r--   1 ftp      ftp       8523599 May 28  2009 aplCal1.trf.bed.gz
-r--r--r--   1 ftp      ftp      53239924 Jun  5 16:00 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  5 16:00 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           257 May 28  2009 md5sum.txt
-r--r--r--   1 ftp      ftp        317953 Jun  5 15:39 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  5 15:39 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jan 14  2010 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jan 14  2010 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2779321661 Jun  5 15:49 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  5 15:50 xenoMrna.fa.gz.md5
Does ./Aplysia_californicaaplCal1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Aplysia_californica/bigZips/aplCal1.fa.masked.gz > ./Aplysia_californicaaplCal1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  173M  100  173M    0     0  2714k      0  0:01:05  0:01:05 --:--:-- 3085k
100  173M  100  173M    0     0  2713k      0  0:01:05  0:01:05 --:--:-- 2713kdownloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Bos_taurus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1720    0     0   3757      0 --:--:-- --:--:-- --:--:--  4000
dr-xr-xr-x   2 ftp      ftp            24 Jun 10 01:30 .
dr-xr-xr-x  12 ftp      ftp            12 Nov  1  2011 ..
-r--r--r--   1 ftp      ftp          4152 Jun 14  2011 README.txt
-r--r--r--   1 ftp      ftp      700816540 May 10  2011 bosTau6.2bit
-r--r--r--   1 ftp      ftp       1928031 Jun 14  2011 bosTau6.agp.gz
-r--r--r--   1 ftp      ftp      867917146 Jun 14  2011 bosTau6.fa.gz
-r--r--r--   1 ftp      ftp      478197913 Jun 14  2011 bosTau6.fa.masked.gz
-r--r--r--   1 ftp      ftp      168507081 Jun 14  2011 bosTau6.fa.out.gz
-r--r--r--   1 ftp      ftp       2624815 Jun 14  2011 bosTau6.trf.bed.gz
-r--r--r--   1 ftp      ftp      322909898 Jun  5 19:03 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  5 19:04 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           463 Jun 14  2011 md5sum.txt
-r--r--r--   1 ftp      ftp      11181434 Jun  5 18:30 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  5 18:30 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      10872638 Jun  5 19:04 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  5 19:04 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       3613527 Jun  9 23:31 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 23:31 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       6929568 Jun  9 23:31 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 23:31 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      16795834 Jun  9 23:31 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 23:31 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2768467889 Jun  5 18:40 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  5 18:41 xenoMrna.fa.gz.md5
Does ./Bos_taurusbosTau6.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Bos_taurus/bigZips/bosTau6.fa.masked.gz > ./Bos_taurusbosTau6.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  456M  100  456M    0     0  2344k      0  0:03:19  0:03:19 --:--:-- 3027k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Branchiostoma_floridae/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1505    0     0   3934      0 --:--:-- --:--:-- --:--:--  4192
dr-xr-xr-x   2 ftp      ftp            21 Jun  6 01:36 .
dr-xr-xr-x  12 ftp      ftp            13 Feb 24  2011 ..
-r--r--r--   1 ftp      ftp          3763 Oct 16  2008 README.txt
-r--r--r--   1 ftp      ftp         72494 May  1  2008 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      277521099 May  1  2008 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      214229362 May  1  2008 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       1579953 May  1  2008 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      38939383 May 28  2008 chromWMSdust.bed.gz
-r--r--r--   1 ftp      ftp      66524290 Jun  6 00:36 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 00:36 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           259 Jun  2  2008 md5sum.txt
-r--r--r--   1 ftp      ftp        224021 Jun  5 23:18 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  5 23:18 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        147530 Jun  6 00:37 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 00:37 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp        288594 Jun  6 00:37 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 00:37 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp        707610 Jun  6 00:37 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 00:37 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2779412903 Jun  6 00:08 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 00:17 xenoMrna.fa.gz.md5
Does ./Branchiostoma_floridaechromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Branchiostoma_floridae/bigZips/chromFaMasked.tar.gz > ./Branchiostoma_floridaechromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  204M  100  204M    0     0  2487k      0  0:01:24  0:01:24 --:--:-- 1456k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_brenneri/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1041    0     0   2327      0 --:--:-- --:--:-- --:--:--  2466
dr-xr-xr-x   2 ftp      ftp            15 Jun  6 07:38 .
dr-xr-xr-x   7 ftp      ftp             8 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          3567 Jun 25  2008 README.txt
-r--r--r--   1 ftp      ftp        358874 May 13  2008 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      57848723 May 13  2008 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      44690852 May 13  2008 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp        219043 May 13  2008 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      12255697 May 13  2008 chromWMSdust.bed.gz
-r--r--r--   1 ftp      ftp       5942731 Jun  6 05:02 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 05:02 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           262 May 13  2008 md5sum.txt
-r--r--r--   1 ftp      ftp         42452 Jun  6 03:55 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 03:55 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2789810271 Jun  6 04:31 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 04:42 xenoMrna.fa.gz.md5
Does ./Caenorhabditis_brennerichromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_brenneri/bigZips/chromFaMasked.tar.gz > ./Caenorhabditis_brennerichromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 42.6M  100 42.6M    0     0  2068k      0  0:00:21  0:00:21 --:--:-- 2969k
100 42.6M  100 42.6M    0     0  2065k      0  0:00:21  0:00:21 --:--:-- 2065kdownloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_briggsae/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1107    0     0   2133      0 --:--:-- --:--:-- --:--:--  2335
dr-xr-xr-x   2 ftp      ftp            16 Jun  6 20:28 .
dr-xr-xr-x  11 ftp      ftp            12 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          3238 Jun 25  2008 README.txt
-r--r--r--   1 ftp      ftp         15584 Apr 13  2007 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      33893800 Apr 13  2007 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      27217418 Apr 13  2007 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       3570476 Apr 13  2007 chromOut.tar.gz
-r--r--r--   1 ftp      ftp        265666 Apr 13  2007 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp        278426 Jun  6 14:06 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 14:06 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           254 Jun  5  2007 md5sum.txt
-r--r--r--   1 ftp      ftp         59175 Jun  6 13:48 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 13:48 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp            31 Jul 16  2007 refMrna.fa.gz
-r--r--r--   1 ftp      ftp      2789801541 Jun  6 13:57 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 13:58 xenoMrna.fa.gz.md5
Does ./Caenorhabditis_briggsaechromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_briggsae/bigZips/chromFaMasked.tar.gz > ./Caenorhabditis_briggsaechromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 25.9M  100 25.9M    0     0  1888k      0  0:00:14  0:00:14 --:--:-- 2265k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_elegans/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1708    0     0   3313      0 --:--:-- --:--:-- --:--:--  3580
dr-xr-xr-x   2 ftp      ftp            24 Jun  6 22:09 .
dr-xr-xr-x  15 ftp      ftp            16 Feb 24  2011 ..
-r--r--r--   1 ftp      ftp          4549 Oct 16  2008 README.txt
-r--r--r--   1 ftp      ftp      25784539 May 30  2008 ce6.2bit
-r--r--r--   1 ftp      ftp         55698 Jun 20  2008 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      31813072 Jun 20  2008 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      27693468 Jun 20  2008 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       2771526 Jun 20  2008 chromOut.tar.gz
-r--r--r--   1 ftp      ftp        193957 Jun 20  2008 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      74214652 Jun  6 16:29 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 16:29 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           254 Oct 16  2008 md5sum.txt
-r--r--r--   1 ftp      ftp       1725831 Jun  6 16:04 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 16:04 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      12168226 Jun  6 16:29 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  6 16:29 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       2797161 Jun  6 16:29 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 16:29 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       5328066 Jun  6 16:29 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 16:29 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      12470708 Jun  6 16:29 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 16:29 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2788137566 Jun  6 16:14 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 16:16 xenoMrna.fa.gz.md5
Does ./Caenorhabditis_eleganschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_elegans/bigZips/chromFaMasked.tar.gz > ./Caenorhabditis_eleganschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 26.4M  100 26.4M    0     0  2436k      0  0:00:11  0:00:11 --:--:-- 1999k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_japonica/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1181    0     0   1937      0 --:--:-- --:--:-- --:--:--  2039
dr-xr-xr-x   2 ftp      ftp            17 Jun  6 07:32 .
dr-xr-xr-x   7 ftp      ftp             8 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          3661 Jun 25  2008 README.txt
-r--r--r--   1 ftp      ftp        922902 Jun 20  2008 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      44396330 Jun 20  2008 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      28225796 Jun 20  2008 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       1324462 Jun 20  2008 chromOut.tar.gz
-r--r--r--   1 ftp      ftp        284666 Jun 20  2008 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp       6337224 Jun  6 01:49 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 01:49 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           308 Jun 24  2008 md5sum.txt
-r--r--r--   1 ftp      ftp          5326 Jun  6 01:09 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 01:09 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun  6 01:49 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  6 01:49 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2779636048 Jun  6 01:30 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 01:35 xenoMrna.fa.gz.md5
Does ./Caenorhabditis_japonicachromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_japonica/bigZips/chromFaMasked.tar.gz > ./Caenorhabditis_japonicachromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 26.9M  100 26.9M    0     0  2663k      0  0:00:10  0:00:10 --:--:-- 2860k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_remanei/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1041    0     0    995      0 --:--:--  0:00:01 --:--:--  1028
dr-xr-xr-x   2 ftp      ftp            15 Jun  6 13:30 .
dr-xr-xr-x   7 ftp      ftp             8 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          3479 Jun 19  2008 README.txt
-r--r--r--   1 ftp      ftp        351711 May 23  2008 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      46396627 May 23  2008 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      35469234 May 23  2008 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp        186491 May 23  2008 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp       9816616 May 22  2008 chromWMSdust.bed.gz
-r--r--r--   1 ftp      ftp       5193978 Jun  6 07:33 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 07:33 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           258 Jun 16  2008 md5sum.txt
-r--r--r--   1 ftp      ftp         79608 Jun  6 06:22 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 06:22 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2789783761 Jun  6 06:43 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 06:46 xenoMrna.fa.gz.md5
Does ./Caenorhabditis_remaneichromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Caenorhabditis_remanei/bigZips/chromFaMasked.tar.gz > ./Caenorhabditis_remaneichromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 33.8M  100 33.8M    0     0  2375k      0  0:00:14  0:00:14 --:--:-- 2555k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Callithrix_jacchus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1726    0     0   3291      0 --:--:-- --:--:-- --:--:--  3438
dr-xr-xr-x   2 ftp      ftp            24 Jun  6 13:32 .
dr-xr-xr-x  16 ftp      ftp            18 Feb 24  2011 ..
-r--r--r--   1 ftp      ftp          4584 Jun 10  2009 README.txt
-r--r--r--   1 ftp      ftp       6408320 Jan 11  2008 calJac1.agp.gz
-r--r--r--   1 ftp      ftp      956337575 Jan 11  2008 calJac1.fa.gz
-r--r--r--   1 ftp      ftp      529133790 Jan 11  2008 calJac1.fa.masked.gz
-r--r--r--   1 ftp      ftp      165662223 Jan 11  2008 calJac1.fa.out.gz
-r--r--r--   1 ftp      ftp      560864515 Jun  8  2009 calJac1.quals.fa.gz
-r--r--r--   1 ftp      ftp       5918851 Jan 11  2008 calJac1.trf.bed.gz
-r--r--r--   1 ftp      ftp        641065 Jun  6 09:51 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 09:51 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           311 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp        272935 Jun  6 09:35 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 09:35 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp         55906 Jun  6 09:51 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  6 09:51 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      13802747 Jun  6 09:52 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 09:52 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp      26420955 Jun  6 09:52 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 09:52 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      70372826 Jun  6 09:53 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 09:53 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2789579780 Jun  6 09:43 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 09:43 xenoMrna.fa.gz.md5
Does ./Callithrix_jacchuscalJac1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Callithrix_jacchus/bigZips/calJac1.fa.masked.gz > ./Callithrix_jacchuscalJac1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  504M  100  504M    0     0  2667k      0  0:03:13  0:03:13 --:--:-- 2954k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Canis_familiaris/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1723    0     0   2433      0 --:--:-- --:--:-- --:--:--  2530
dr-xr-xr-x   2 ftp      ftp            24 Jun  7 13:30 .
dr-xr-xr-x  29 ftp      ftp            30 Nov  1  2011 ..
-r--r--r--   1 ftp      ftp          2511 Jun 10  2009 README.txt
-r--r--r--   1 ftp      ftp      145179683 Jun  9  2009 canFam2.quals.fa.gz
-r--r--r--   1 ftp      ftp        985160 Nov 21  2005 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      780291568 Dec  6  2005 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      484465642 Dec  6  2005 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      140024497 Nov 21  2005 chromOut.tar.gz
-r--r--r--   1 ftp      ftp       8564548 Dec  6  2005 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      76220013 Jun  6 11:51 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 11:51 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           308 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp       1046544 Jun  6 11:28 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 11:28 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        890290 Jun  6 11:52 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  6 11:52 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        480619 Jun  7 12:29 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 12:29 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp        919283 Jun  7 12:29 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 12:29 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp       2222813 Jun  7 12:29 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 12:29 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2788820680 Jun  6 11:37 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 11:38 xenoMrna.fa.gz.md5
Does ./Canis_familiarischromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Canis_familiaris/bigZips/chromFaMasked.tar.gz > ./Canis_familiarischromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  462M  100  462M    0     0  2692k      0  0:02:55  0:02:55 --:--:-- 3070k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Cavia_porcellus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1726    0     0   4130      0 --:--:-- --:--:-- --:--:--  4414
dr-xr-xr-x   2 ftp      ftp            24 Jun  6 13:43 .
dr-xr-xr-x  13 ftp      ftp            14 Apr 26  2010 ..
-r--r--r--   1 ftp      ftp          4254 Jun 10  2009 README.txt
-r--r--r--   1 ftp      ftp       1639703 Apr 23  2008 cavPor3.agp.gz
-r--r--r--   1 ftp      ftp      875388603 Apr 23  2008 cavPor3.fa.gz
-r--r--r--   1 ftp      ftp      637072549 Apr 23  2008 cavPor3.fa.masked.gz
-r--r--r--   1 ftp      ftp      121237900 Apr 23  2008 cavPor3.fa.out.gz
-r--r--r--   1 ftp      ftp      130859601 Jun  9  2009 cavPor3.quals.fa.gz
-r--r--r--   1 ftp      ftp       6745011 Apr 23  2008 cavPor3.trf.bed.gz
-r--r--r--   1 ftp      ftp       3958401 Jun  6 12:15 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 12:15 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           311 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp        334731 Jun  6 11:56 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 11:56 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        247816 Jun  6 12:16 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  6 12:16 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      10855282 Jun  6 12:17 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 12:17 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp      21208395 Jun  6 12:17 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 12:17 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      58668089 Jun  6 12:18 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  6 12:18 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2789523995 Jun  6 12:06 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 12:07 xenoMrna.fa.gz.md5
Does ./Cavia_porcelluscavPor3.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Cavia_porcellus/bigZips/cavPor3.fa.masked.gz > ./Cavia_porcelluscavPor3.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  607M  100  607M    0     0  2679k      0  0:03:52  0:03:52 --:--:-- 2974k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ciona_intestinalis/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1111    0     0   2151      0 --:--:-- --:--:-- --:--:--  2239
dr-xr-xr-x   2 ftp      ftp            16 Jun  6 22:54 .
dr-xr-xr-x   6 ftp      ftp             7 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          2245 Sep 17  2008 README.txt
-r--r--r--   1 ftp      ftp       5143784 Sep 17  2008 Scaffold.out.zip
-r--r--r--   1 ftp      ftp      46591603 Sep 17  2008 ScaffoldFa.zip
-r--r--r--   1 ftp      ftp      39307993 Sep 17  2008 ScaffoldFaMasked.zip
-r--r--r--   1 ftp      ftp       1274459 Sep 17  2008 ScaffoldTrf.zip
-r--r--r--   1 ftp      ftp      262019550 Jun  6 18:44 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  6 18:46 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           205 Sep 17  2008 md5sum.txt
-r--r--r--   1 ftp      ftp       4749505 Jun  6 17:39 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  6 17:39 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        690637 Jun  6 18:54 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  6 18:54 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2785112454 Jun  6 17:52 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  6 17:54 xenoMrna.fa.gz.md5
Does ./Ciona_intestinalisScaffoldFaMasked.zip exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ciona_intestinalis/bigZips/ScaffoldFaMasked.zip > ./Ciona_intestinalisScaffoldFaMasked.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 37.4M  100 37.4M    0     0  2709k      0  0:00:14  0:00:14 --:--:-- 2332k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Danio_rerio/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1720    0     0   3784      0 --:--:-- --:--:-- --:--:--  4000
dr-xr-xr-x   2 ftp      ftp            24 Jun  7 13:35 .
dr-xr-xr-x  21 ftp      ftp            21 May 11 22:32 ..
-r--r--r--   1 ftp      ftp          4384 Dec 14  2010 README.txt
-r--r--r--   1 ftp      ftp      372476150 Dec  9  2010 danRer7.2bit
-r--r--r--   1 ftp      ftp        874121 Dec 14  2010 danRer7.agp.gz
-r--r--r--   1 ftp      ftp      455753784 Dec 14  2010 danRer7.fa.gz
-r--r--r--   1 ftp      ftp      234966927 Dec 14  2010 danRer7.fa.masked.gz
-r--r--r--   1 ftp      ftp      115495797 Dec 14  2010 danRer7.fa.out.gz
-r--r--r--   1 ftp      ftp       9057240 Dec 14  2010 danRer7.trf.bed.gz
-r--r--r--   1 ftp      ftp      320214666 Jun  7 08:33 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  7 08:33 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           463 Dec 14  2010 md5sum.txt
-r--r--r--   1 ftp      ftp      17908020 Jun  7 07:25 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  7 07:25 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      10845345 Jun  7 08:35 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  7 08:35 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       5132730 Jun  7 08:35 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 08:35 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       9751563 Jun  7 08:36 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 08:36 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      23622925 Jun  7 08:36 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  7 08:36 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2835648875 Jun  7 07:45 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 07:49 xenoMrna.fa.gz.md5
Does ./Danio_reriodanRer7.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Danio_rerio/bigZips/danRer7.fa.masked.gz > ./Danio_reriodanRer7.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  224M  100  224M    0     0  2846k      0  0:01:20  0:01:20 --:--:-- 3007k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_ananassae/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   825    0     0   1368      0 --:--:-- --:--:-- --:--:--  1601
dr-xr-xr-x   2 ftp      ftp            12 Jun  7 19:59 .
dr-xr-xr-x   7 ftp      ftp             8 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          1519 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp           200 May 13  2010 md5sum.txt
-r--r--r--   1 ftp      ftp         29763 Jun  7 16:32 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  7 16:32 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      66317409 Aug  5  2005 scaffoldFa.gz
-r--r--r--   1 ftp      ftp      55105908 May 12  2010 scaffoldFaMasked.gz
-r--r--r--   1 ftp      ftp       5091553 Aug  5  2005 scaffoldOut.gz
-r--r--r--   1 ftp      ftp        482994 Aug  5  2005 scaffoldTrf.gz
-r--r--r--   1 ftp      ftp      2853509445 Jun  7 16:50 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 16:52 xenoMrna.fa.gz.md5
Does ./Drosophila_ananassaescaffoldFaMasked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_ananassae/bigZips/scaffoldFaMasked.gz > ./Drosophila_ananassaescaffoldFaMasked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 52.5M  100 52.5M    0     0  2545k      0  0:00:21  0:00:21 --:--:-- 3047k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_erecta/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   825    0     0    871      0 --:--:-- --:--:-- --:--:--   930
dr-xr-xr-x   2 ftp      ftp            12 Jun  7 20:06 .
dr-xr-xr-x   7 ftp      ftp             8 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          1673 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp           200 Aug  4  2005 md5sum.txt
-r--r--r--   1 ftp      ftp         31032 Jun  7 17:06 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  7 17:06 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      45245337 Aug  4  2005 scaffoldFa.gz
-r--r--r--   1 ftp      ftp      39534444 Aug  4  2005 scaffoldFaMasked.gz
-r--r--r--   1 ftp      ftp       2773687 Aug  4  2005 scaffoldOut.gz
-r--r--r--   1 ftp      ftp        501886 Aug  4  2005 scaffoldTrf.gz
-r--r--r--   1 ftp      ftp      2853506147 Jun  7 18:06 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 18:11 xenoMrna.fa.gz.md5
Does ./Drosophila_erectascaffoldFaMasked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_erecta/bigZips/scaffoldFaMasked.gz > ./Drosophila_erectascaffoldFaMasked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 37.7M  100 37.7M    0     0  2381k      0  0:00:16  0:00:16 --:--:-- 1841k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_grimshawi/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   687    0     0   1700      0 --:--:-- --:--:-- --:--:--  1924
dr-xr-xr-x   2 ftp      ftp            10 Jun  7 20:12 .
dr-xr-xr-x   6 ftp      ftp             7 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          1554 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp           200 Aug  5  2005 md5sum.txt
-r--r--r--   1 ftp      ftp      59237544 Aug  5  2005 scaffoldFa.gz
-r--r--r--   1 ftp      ftp             0 Aug  5  2005 scaffoldFaMasked.gz
-r--r--r--   1 ftp      ftp       6534057 Aug  5  2005 scaffoldOut.gz
-r--r--r--   1 ftp      ftp       1447510 Aug  5  2005 scaffoldTrf.gz
-r--r--r--   1 ftp      ftp      2853533943 Jun  7 18:30 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 18:33 xenoMrna.fa.gz.md5
Does ./Drosophila_grimshawiscaffoldFaMasked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_grimshawi/bigZips/scaffoldFaMasked.gz > ./Drosophila_grimshawiscaffoldFaMasked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_melanogaster/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1407    0     0   2573      0 --:--:-- --:--:-- --:--:--  2685
dr-xr-xr-x   2 ftp      ftp            20 Jun  7 19:37 .
dr-xr-xr-x  26 ftp      ftp            27 Feb 24  2011 ..
-r--r--r--   1 ftp      ftp          2929 Oct 27  2008 README.txt
-r--r--r--   1 ftp      ftp        778194 Jun 21  2007 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      51423560 Jun 21  2007 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      38232935 Jun 21  2007 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       4410146 Jun 21  2007 chromOut.tar.gz
-r--r--r--   1 ftp      ftp        422921 Jun 21  2007 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      113949243 Jun  7 14:29 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  7 14:29 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           413 Oct 21  2008 md5sum.txt
-r--r--r--   1 ftp      ftp      34760645 Jun  7 13:51 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  7 13:51 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      22416438 Jun  7 14:29 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  7 14:29 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       4443720 Oct 21  2008 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp       8318117 Oct 21  2008 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp      18974254 Oct 21  2008 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp      2818787474 Jun  7 14:04 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 14:07 xenoMrna.fa.gz.md5
Does ./Drosophila_melanogasterchromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_melanogaster/bigZips/chromFaMasked.tar.gz > ./Drosophila_melanogasterchromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 36.4M  100 36.4M    0     0  2933k      0  0:00:12  0:00:12 --:--:-- 3101k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_mojavensis/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   825    0     0   1929      0 --:--:-- --:--:-- --:--:--  2126
dr-xr-xr-x   2 ftp      ftp            12 Jun  8 01:36 .
dr-xr-xr-x   6 ftp      ftp             7 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          1680 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp           200 Aug  6  2005 md5sum.txt
-r--r--r--   1 ftp      ftp         22032 Jun  7 19:43 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  7 19:43 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      56918432 Aug  6  2005 scaffoldFa.gz
-r--r--r--   1 ftp      ftp      49279201 Aug  6  2005 scaffoldFaMasked.gz
-r--r--r--   1 ftp      ftp       8513446 Aug  6  2005 scaffoldOut.gz
-r--r--r--   1 ftp      ftp       1692472 Aug  6  2005 scaffoldTrf.gz
-r--r--r--   1 ftp      ftp      2853528824 Jun  7 19:57 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 20:01 xenoMrna.fa.gz.md5
Does ./Drosophila_mojavensisscaffoldFaMasked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_mojavensis/bigZips/scaffoldFaMasked.gz > ./Drosophila_mojavensisscaffoldFaMasked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 46.9M  100 46.9M    0     0  2573k      0  0:00:18  0:00:18 --:--:-- 3044k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_persimilis/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   687    0     0   1487      0 --:--:-- --:--:-- --:--:--  1713
dr-xr-xr-x   2 ftp      ftp            10 Jun  8 01:42 .
dr-xr-xr-x   7 ftp      ftp            14 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          1587 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp           200 Nov 24  2005 md5sum.txt
-r--r--r--   1 ftp      ftp      56312231 Nov 24  2005 scaffoldFa.gz
-r--r--r--   1 ftp      ftp      48284848 May 31  2006 scaffoldFaMasked.gz
-r--r--r--   1 ftp      ftp       4416328 Nov 24  2005 scaffoldOut.gz
-r--r--r--   1 ftp      ftp       1106032 Nov 24  2005 scaffoldTrf.gz
-r--r--r--   1 ftp      ftp      2853535943 Jun  7 20:15 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 20:18 xenoMrna.fa.gz.md5
Does ./Drosophila_persimilisscaffoldFaMasked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_persimilis/bigZips/scaffoldFaMasked.gz > ./Drosophila_persimilisscaffoldFaMasked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 46.0M  100 46.0M    0     0  2697k      0  0:00:17  0:00:17 --:--:-- 2887k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_pseudoobscura/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   953    0     0    740      0 --:--:--  0:00:01 --:--:--  1549
dr-xr-xr-x   2 ftp      ftp            14 Jun  7 19:48 .
dr-xr-xr-x   7 ftp      ftp             8 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          1927 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp      43189682 Nov 16  2004 chromFa.zip
-r--r--r--   1 ftp      ftp      40629127 Nov 16  2004 chromFaMasked.zip
-r--r--r--   1 ftp      ftp       2931498 Nov 16  2004 chromOut.zip
-r--r--r--   1 ftp      ftp        948564 Nov 16  2004 chromTrf.zip
-r--r--r--   1 ftp      ftp      13215070 Jun  7 15:49 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  7 15:49 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           192 Nov 16  2004 md5sum.txt
-r--r--r--   1 ftp      ftp         59452 Jun  7 15:18 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  7 15:18 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853490500 Jun  7 15:35 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 15:38 xenoMrna.fa.gz.md5
Does ./Drosophila_pseudoobscurachromFaMasked.zip exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_pseudoobscura/bigZips/chromFaMasked.zip > ./Drosophila_pseudoobscurachromFaMasked.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 38.7M  100 38.7M    0     0  2273k      0  0:00:17  0:00:17 --:--:-- 2991k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_sechellia/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   687    0     0   1333      0 --:--:-- --:--:-- --:--:--  1431
dr-xr-xr-x   2 ftp      ftp            10 Jun  8 01:48 .
dr-xr-xr-x   7 ftp      ftp             8 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          1586 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp           200 Nov 30  2005 md5sum.txt
-r--r--r--   1 ftp      ftp      49726960 Nov 30  2005 scaffoldFa.gz
-r--r--r--   1 ftp      ftp      39641643 Nov 30  2005 scaffoldFaMasked.gz
-r--r--r--   1 ftp      ftp       3748236 Nov 30  2005 scaffoldOut.gz
-r--r--r--   1 ftp      ftp        238382 Nov 30  2005 scaffoldTrf.gz
-r--r--r--   1 ftp      ftp      2853539395 Jun  7 20:31 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 20:33 xenoMrna.fa.gz.md5
Does ./Drosophila_sechelliascaffoldFaMasked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_sechellia/bigZips/scaffoldFaMasked.gz > ./Drosophila_sechelliascaffoldFaMasked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 37.8M  100 37.8M    0     0  2581k      0  0:00:14  0:00:14 --:--:-- 2990k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_simulans/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1037    0     0   1470      0 --:--:-- --:--:-- --:--:--  1552
  0     0    0  1037    0     0    670      0 --:--:--  0:00:01 --:--:--   670dr-xr-xr-x   2 ftp      ftp            15 Jun  8 01:53 .
dr-xr-xr-x   8 ftp      ftp             9 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          3187 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp        907624 Apr 13  2005 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      41082390 Apr 13  2005 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      36233575 Apr 13  2005 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       2444839 Apr 13  2005 chromOut.tar.gz
-r--r--r--   1 ftp      ftp        232276 Apr 13  2005 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      17813715 Jun  7 22:09 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  7 22:09 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           254 Apr 13  2005 md5sum.txt
-r--r--r--   1 ftp      ftp         58811 Jun  7 21:12 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  7 21:12 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853490554 Jun  7 21:28 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 21:33 xenoMrna.fa.gz.md5
Does ./Drosophila_simulanschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_simulans/bigZips/chromFaMasked.tar.gz > ./Drosophila_simulanschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 34.5M  100 34.5M    0     0  1996k      0  0:00:17  0:00:17 --:--:-- 2842k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_virilis/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1105    0     0   1399      0 --:--:-- --:--:-- --:--:--  1471
dr-xr-xr-x   2 ftp      ftp            16 Jun  8 02:06 .
dr-xr-xr-x   6 ftp      ftp             7 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          1941 Mar 18  2006 README.txt
-r--r--r--   1 ftp      ftp       6243836 Jun  7 23:32 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  7 23:32 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           200 Aug 12  2005 md5sum.txt
-r--r--r--   1 ftp      ftp         51466 Jun  7 22:51 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  7 22:51 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun  7 23:32 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  7 23:32 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      57404685 Aug 12  2005 scaffoldFa.gz
-r--r--r--   1 ftp      ftp      49017837 Aug 12  2005 scaffoldFaMasked.gz
-r--r--r--   1 ftp      ftp       6187119 Aug 12  2005 scaffoldOut.gz
-r--r--r--   1 ftp      ftp       1240817 Aug 12  2005 scaffoldTrf.gz
-r--r--r--   1 ftp      ftp      2853497022 Jun  7 23:15 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  7 23:20 xenoMrna.fa.gz.md5
Does ./Drosophila_virilisscaffoldFaMasked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_virilis/bigZips/scaffoldFaMasked.gz > ./Drosophila_virilisscaffoldFaMasked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 46.7M  100 46.7M    0     0  2487k      0  0:00:19  0:00:19 --:--:-- 2813k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_yakuba/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1037    0     0   2036      0 --:--:-- --:--:-- --:--:--  2206
dr-xr-xr-x   2 ftp      ftp            15 Jun  8 07:43 .
dr-xr-xr-x   8 ftp      ftp             9 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          2801 Nov 16  2005 README.txt
-r--r--r--   1 ftp      ftp        340825 Nov 16  2005 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      51779370 Nov 16  2005 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      43285556 Nov 16  2005 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       3881967 Nov 16  2005 chromOut.tar.gz
-r--r--r--   1 ftp      ftp        607094 Nov 16  2005 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp       1719194 Jun  8 01:47 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  8 01:47 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           254 Nov 16  2005 md5sum.txt
-r--r--r--   1 ftp      ftp        176198 Jun  8 00:57 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  8 00:57 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853360283 Jun  8 01:23 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  8 01:29 xenoMrna.fa.gz.md5
Does ./Drosophila_yakubachromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Drosophila_yakuba/bigZips/chromFaMasked.tar.gz > ./Drosophila_yakubachromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 41.2M  100 41.2M    0     0  2377k      0  0:00:17  0:00:17 --:--:-- 2714k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Equus_caballus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1722    0     0   3362      0 --:--:-- --:--:-- --:--:--  3602
dr-xr-xr-x   2 ftp      ftp            24 Jun  9 01:32 .
dr-xr-xr-x  14 ftp      ftp            14 Apr 29  2011 ..
-r--r--r--   1 ftp      ftp          4460 Jun 10  2009 README.txt
-r--r--r--   1 ftp      ftp       1482107 Sep  9  2008 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      805147430 Sep  9  2008 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      490536928 Sep  9  2008 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      118334693 Sep  9  2008 chromOut.tar.gz
-r--r--r--   1 ftp      ftp       1920691 Sep  9  2008 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      97438070 Jun  9  2009 equCab2.quals.fa.gz
-r--r--r--   1 ftp      ftp       7210472 Jun  8 20:45 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  8 20:45 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           467 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp        559109 Jun  8 18:22 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  8 18:22 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        499534 Jun  8 20:47 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  8 20:47 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        136978 Jun  8 20:48 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  8 20:48 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp        262955 Jun  8 20:48 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  8 20:48 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp        636608 Jun  8 20:48 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  8 20:48 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853144576 Jun  8 18:52 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  8 18:56 xenoMrna.fa.gz.md5
Does ./Equus_caballuschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Equus_caballus/bigZips/chromFaMasked.tar.gz > ./Equus_caballuschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  467M  100  467M    0     0  2681k      0  0:02:58  0:02:58 --:--:-- 3056k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Felis_catus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1719    0     0   3554      0 --:--:-- --:--:-- --:--:--  3769
dr-xr-xr-x   2 ftp      ftp            24 Jun 10 01:35 .
dr-xr-xr-x  13 ftp      ftp            13 Aug  5  2011 ..
-r--r--r--   1 ftp      ftp          4498 Aug  6  2010 README.txt
-r--r--r--   1 ftp      ftp        180907 Jun  9 05:29 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  9 05:29 est.fa.gz.md5
-r--r--r--   1 ftp      ftp      823922247 May 27  2010 felCat4.2bit
-r--r--r--   1 ftp      ftp      14575418 Jul  2  2010 felCat4.agp.gz
-r--r--r--   1 ftp      ftp      677015241 Jul  2  2010 felCat4.fa.gz
-r--r--r--   1 ftp      ftp      422007052 Jul  2  2010 felCat4.fa.masked.gz
-r--r--r--   1 ftp      ftp      126401738 Jul  2  2010 felCat4.fa.out.gz
-r--r--r--   1 ftp      ftp       8070740 Jul  2  2010 felCat4.trf.bed.gz
-r--r--r--   1 ftp      ftp           463 Jul  2  2010 md5sum.txt
-r--r--r--   1 ftp      ftp        933680 Jun  9 03:03 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  9 03:03 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        197006 Jun  9 05:31 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  9 05:31 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp         46304 Jun 10 00:21 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 00:21 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp         83853 Jun 10 00:21 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 00:21 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp        189410 Jun 10 00:21 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 00:21 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2852791992 Jun  9 03:57 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  9 04:16 xenoMrna.fa.gz.md5
Does ./Felis_catusfelCat4.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Felis_catus/bigZips/felCat4.fa.masked.gz > ./Felis_catusfelCat4.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  402M  100  402M    0     0  2631k      0  0:02:36  0:02:36 --:--:-- 1879k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Fugu_rubripes/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1580    0     0   4334      0 --:--:-- --:--:-- --:--:--  4674
dr-xr-xr-x   2 ftp      ftp            22 Jun  9 13:38 .
dr-xr-xr-x  19 ftp      ftp            20 Feb 24  2011 ..
-r--r--r--   1 ftp      ftp          2559 Mar 28  2007 README.txt
-r--r--r--   1 ftp      ftp        166181 Feb 14  2007 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      118172484 Feb 14  2007 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      99211879 Feb 14  2007 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       5766866 Mar 20  2007 chromOut.tar.gz
-r--r--r--   1 ftp      ftp       1594120 Feb 14  2007 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      11667835 Feb 14  2007 chromWMSdust.bed.tar.gz
-r--r--r--   1 ftp      ftp       4410257 Jun  9 12:04 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  9 12:04 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           406 Mar 20  2007 md5sum.txt
-r--r--r--   1 ftp      ftp        359080 Jun  9 09:27 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  9 09:27 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        114970 Jun  9 12:04 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 12:04 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp        218039 Jun  9 12:04 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 12:04 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp        516713 Jun  9 12:04 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 12:04 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853360042 Jun  9 10:08 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  9 10:13 xenoMrna.fa.gz.md5
Does ./Fugu_rubripeschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Fugu_rubripes/bigZips/chromFaMasked.tar.gz > ./Fugu_rubripeschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 94.6M  100 94.6M    0     0  2579k      0  0:00:37  0:00:37 --:--:-- 2926k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Gallus_gallus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1723    0     0   4249      0 --:--:-- --:--:-- --:--:--  4582
dr-xr-xr-x   2 ftp      ftp            24 Jun 10 01:40 .
dr-xr-xr-x  33 ftp      ftp            34 Nov  1  2011 ..
-r--r--r--   1 ftp      ftp          3704 Jun 10  2009 README.txt
-r--r--r--   1 ftp      ftp       2057989 Aug  4  2006 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      333568281 Aug  4  2006 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      296762486 Aug  4  2006 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      15630751 Aug  4  2006 chromOut.tar.gz
-r--r--r--   1 ftp      ftp       1370119 Aug  4  2006 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      149352583 Jun  9 20:25 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  9 20:25 est.fa.gz.md5
-r--r--r--   1 ftp      ftp      130659267 Jun  9  2009 galGal3.quals.fa.gz
-r--r--r--   1 ftp      ftp           308 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp      12596683 Jun  9 19:27 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  9 19:27 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       4445595 Jun  9 20:26 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  9 20:26 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       1172356 Jun  9 20:26 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 20:26 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       2280127 Jun  9 20:26 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 20:26 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp       5579347 Jun  9 20:26 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  9 20:26 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2841130056 Jun  9 19:43 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  9 19:45 xenoMrna.fa.gz.md5
Does ./Gallus_galluschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Gallus_gallus/bigZips/chromFaMasked.tar.gz > ./Gallus_galluschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  283M  100  283M    0     0  2798k      0  0:01:43  0:01:43 --:--:-- 3089k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Gorilla_gorilla_gorilla/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1439    0     0   2082      0 --:--:-- --:--:-- --:--:--  2157
dr-xr-xr-x   2 ftp      ftp            20 Jun 10 07:35 .
dr-xr-xr-x  19 ftp      ftp            19 May  2 19:24 ..
-r--r--r--   1 ftp      ftp          3718 Nov 14  2011 README.txt
-r--r--r--   1 ftp      ftp      794541353 Oct 14  2011 gorGor3.2bit
-r--r--r--   1 ftp      ftp        757230 Nov 14  2011 gorGor3.agp.gz
-r--r--r--   1 ftp      ftp      908896045 Nov 14  2011 gorGor3.fa.gz
-r--r--r--   1 ftp      ftp      490839303 Nov 14  2011 gorGor3.fa.masked.gz
-r--r--r--   1 ftp      ftp      165755661 Nov 14  2011 gorGor3.fa.out.gz
-r--r--r--   1 ftp      ftp       6270316 Nov 14  2011 gorGor3.trf.bed.gz
-r--r--r--   1 ftp      ftp           304 Nov 14  2011 md5sum.txt
-r--r--r--   1 ftp      ftp         89061 Jun 10 01:20 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun 10 01:20 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       3682385 Jun 10 01:35 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 01:35 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       6973753 Jun 10 01:36 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 01:36 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      16569230 Jun 10 01:36 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 01:36 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853659348 Jun 10 01:32 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun 10 01:34 xenoMrna.fa.gz.md5
Does ./Gorilla_gorilla_gorillagorGor3.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Gorilla_gorilla_gorilla/bigZips/gorGor3.fa.masked.gz > ./Gorilla_gorilla_gorillagorGor3.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  468M  100  468M    0     0  2714k      0  0:02:56  0:02:56 --:--:-- 2997k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Heterocephalus_glaber/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1113    0     0   1813      0 --:--:-- --:--:-- --:--:--  1899
dr-xr-xr-x   2 ftp      ftp            16 Jun 10 07:39 .
dr-xr-xr-x   6 ftp      ftp             6 May 15 17:35 ..
-r--r--r--   1 ftp      ftp          3512 Apr 18 20:20 README.txt
-r--r--r--   1 ftp      ftp            20 Jun 10 02:39 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun 10 02:39 est.fa.gz.md5
-r--r--r--   1 ftp      ftp      778548639 Dec  7  2011 hetGla1.2bit
-r--r--r--   1 ftp      ftp       6577551 Jan  4 22:06 hetGla1.agp.gz
-r--r--r--   1 ftp      ftp      818432175 Jan  4 22:19 hetGla1.fa.gz
-r--r--r--   1 ftp      ftp      591616055 Jan  4 22:29 hetGla1.fa.masked.gz
-r--r--r--   1 ftp      ftp      132489341 Jan  4 22:07 hetGla1.fa.out.gz
-r--r--r--   1 ftp      ftp       4458101 Jan  4 22:07 hetGla1.trf.bed.gz
-r--r--r--   1 ftp      ftp           304 Jan  4 22:29 md5sum.txt
-r--r--r--   1 ftp      ftp         24884 Jun 10 02:16 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun 10 02:16 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853690564 Jun 10 02:28 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun 10 02:30 xenoMrna.fa.gz.md5
Does ./Heterocephalus_glaberJan  4 22:29 hetGla1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Heterocephalus_glaber/bigZips/Jan  4 22:29 hetGla1.fa.masked.gz > ./Heterocephalus_glaberJan  4 22:29 hetGla1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (78) RETR response: 550

curl: (7) Failed to connect to 0.0.0.4: No route to host

curl: (7) Failed to connect to 0.0.0.22: No route to host

curl: (6) Could not resolve host: hetGla1.fa.masked.gz; nodename nor servname provided, or not known

curl: (7) Failed to connect to 0.0.0.4: No route to host

curl: (7) Failed to connect to 0.0.0.22: No route to host

curl: (6) Could not resolve host: hetGla1.fa.masked.gz; nodename nor servname provided, or not known
Failed to download Heterocephalus_glaber
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Homo_sapiens/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1716    0     0   3209      0 --:--:-- --:--:-- --:--:--  3351
dr-xr-xr-x   2 ftp      ftp            24 Jun 10 19:38 .
dr-xr-xr-x  79 ftp      ftp            79 May  2 19:36 ..
-r--r--r--   1 ftp      ftp          3873 Jul 29  2009 README.txt
-r--r--r--   1 ftp      ftp        550693 Mar 20  2009 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      948736151 Mar 20  2009 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      500370505 Mar 20  2009 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      170657732 Mar 20  2009 chromOut.tar.gz
-r--r--r--   1 ftp      ftp       7997971 Mar 20  2009 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      1612388476 Jun 10 15:48 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun 10 15:49 est.fa.gz.md5
-r--r--r--   1 ftp      ftp      816241703 Mar  8  2009 hg19.2bit
-r--r--r--   1 ftp      ftp           457 Jul 29  2009 md5sum.txt
-r--r--r--   1 ftp      ftp      174476169 Jun 10 15:08 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun 10 15:08 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      43606775 Jun 10 15:49 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun 10 15:49 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       7977144 Jun 10 15:51 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 15:51 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp      15019021 Jun 10 15:52 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 15:52 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      36834537 Jun 10 15:53 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 15:53 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2679259985 Jun 10 15:18 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun 10 15:20 xenoMrna.fa.gz.md5
Does ./Homo_sapienschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Homo_sapiens/bigZips/chromFaMasked.tar.gz > ./Homo_sapienschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  477M  100  477M    0     0  2758k      0  0:02:57  0:02:57 --:--:-- 3005k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Loxodonta_africana/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1584    0     0   3135      0 --:--:-- --:--:-- --:--:--  3807
dr-xr-xr-x   2 ftp      ftp            22 Jun 11 01:35 .
dr-xr-xr-x   8 ftp      ftp             8 Nov 19  2011 ..
-r--r--r--   1 ftp      ftp          3276 Mar 23  2010 README.txt
-r--r--r--   1 ftp      ftp      838656757 Jul 16  2009 loxAfr3.2bit
-r--r--r--   1 ftp      ftp       2577165 Jul 29  2009 loxAfr3.agp.gz
-r--r--r--   1 ftp      ftp      1037858330 Jul 29  2009 loxAfr3.fa.gz
-r--r--r--   1 ftp      ftp      571065734 Jul 29  2009 loxAfr3.fa.masked.gz
-r--r--r--   1 ftp      ftp      180874179 Jul 29  2009 loxAfr3.fa.out.gz
-r--r--r--   1 ftp      ftp       1972653 Jul 29  2009 loxAfr3.trf.bed.gz
-r--r--r--   1 ftp      ftp           304 Jul 29  2009 md5sum.txt
-r--r--r--   1 ftp      ftp          9185 Jun 10 19:36 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun 10 19:36 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun 10 19:48 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun 10 19:48 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun 10 19:48 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 19:48 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun 10 19:48 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 19:48 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp            20 Jun 10 19:48 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 19:48 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853711401 Jun 10 19:46 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun 10 19:48 xenoMrna.fa.gz.md5
Does ./Loxodonta_africanaloxAfr3.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Loxodonta_africana/bigZips/loxAfr3.fa.masked.gz > ./Loxodonta_africanaloxAfr3.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  544M  100  544M    0     0  2717k      0  0:03:25  0:03:25 --:--:-- 3023k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Macropus_eugenii/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1113    0     0   1838      0 --:--:-- --:--:-- --:--:--  2262
dr-xr-xr-x   2 ftp      ftp            16 Jun 11 01:40 .
dr-xr-xr-x   5 ftp      ftp             5 Jan 23 21:19 ..
-r--r--r--   1 ftp      ftp          3590 Dec 16 18:49 README.txt
-r--r--r--   1 ftp      ftp      79832139 Jun 10 20:14 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun 10 20:14 est.fa.gz.md5
-r--r--r--   1 ftp      ftp      825708781 Nov  7  2010 macEug2.2bit
-r--r--r--   1 ftp      ftp      28124089 Dec  8  2011 macEug2.agp.gz
-r--r--r--   1 ftp      ftp      864820996 Dec  8  2011 macEug2.fa.gz
-r--r--r--   1 ftp      ftp      485271095 Dec  8  2011 macEug2.fa.masked.gz
-r--r--r--   1 ftp      ftp      185593391 Dec  8  2011 macEug2.fa.out.gz
-r--r--r--   1 ftp      ftp       7929384 Dec  8  2011 macEug2.trf.bed.gz
-r--r--r--   1 ftp      ftp           304 Dec  8  2011 md5sum.txt
-r--r--r--   1 ftp      ftp         83605 Jun 10 19:53 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun 10 19:53 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853625113 Jun 10 20:04 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun 10 20:06 xenoMrna.fa.gz.md5
Does ./Macropus_eugeniimacEug2.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Macropus_eugenii/bigZips/macEug2.fa.masked.gz > ./Macropus_eugeniimacEug2.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  462M  100  462M    0     0  2694k      0  0:02:55  0:02:55 --:--:-- 2983k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Meleagris_gallopavo/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1574    0     0   3323      0 --:--:-- --:--:-- --:--:--  3482
dr-xr-xr-x   2 ftp      ftp            22 Jun 11 01:44 .
dr-xr-xr-x  14 ftp      ftp            14 Nov  1  2011 ..
-r--r--r--   1 ftp      ftp          3624 Dec 16 18:56 README.txt
-r--r--r--   1 ftp      ftp       4223619 Jun 10 20:39 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun 10 20:39 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           304 Mar  9  2011 md5sum.txt
-r--r--r--   1 ftp      ftp      269924661 Nov  5  2010 melGal1.2bit
-r--r--r--   1 ftp      ftp       4093406 Mar  9  2011 melGal1.agp.gz
-r--r--r--   1 ftp      ftp      303627933 Mar  9  2011 melGal1.fa.gz
-r--r--r--   1 ftp      ftp      279531134 Mar  9  2011 melGal1.fa.masked.gz
-r--r--r--   1 ftp      ftp      10959920 Mar  9  2011 melGal1.fa.out.gz
-r--r--r--   1 ftp      ftp       1085719 Mar  9  2011 melGal1.trf.bed.gz
-r--r--r--   1 ftp      ftp         95090 Jun 10 20:19 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun 10 20:19 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        654370 Jun 10 20:39 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 20:39 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       1241933 Jun 10 20:39 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 20:39 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp       2990313 Jun 10 20:39 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun 10 20:39 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2853623388 Jun 10 20:28 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun 10 20:30 xenoMrna.fa.gz.md5
Does ./Meleagris_gallopavomelGal1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Meleagris_gallopavo/bigZips/melGal1.fa.masked.gz > ./Meleagris_gallopavomelGal1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  266M  100  266M    0     0  2710k      0  0:01:40  0:01:40 --:--:-- 2850k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Monodelphis_domestica/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1800    0     0   3387      0 --:--:-- --:--:-- --:--:--  3543
dr-xr-xr-x   2 ftp      ftp            25 Jun  3 13:32 .
dr-xr-xr-x  32 ftp      ftp            32 Nov 19  2011 ..
-r--r--r--   1 ftp      ftp       2015384 Jun  8  2009 Monodelphis5.0.agp.gz
-r--r--r--   1 ftp      ftp          3603 Aug 26  2009 README.txt
-r--r--r--   1 ftp      ftp      1151919956 Nov  9  2010 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      552574139 Nov  9  2010 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      247333031 Jun  8  2009 chromOut.tar.gz
-r--r--r--   1 ftp      ftp      10530135 Jun  8  2009 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp         50772 Jun  3 11:55 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  3 11:55 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           361 Nov  9  2010 md5sum.txt
-r--r--r--   1 ftp      ftp      951088332 Dec  1  2008 monDom5.2bit
-r--r--r--   1 ftp      ftp      285378404 Jun  9  2009 monDom5.quals.fa.gz
-r--r--r--   1 ftp      ftp        196080 Jun  3 11:35 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  3 11:35 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        181389 Jun  3 11:56 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  3 11:56 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp         17977 Jun  3 11:56 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 11:56 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp         34368 Jun  3 11:56 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 11:56 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp         82399 Jun  3 11:56 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 11:56 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2779329077 Jun  3 11:44 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  3 11:46 xenoMrna.fa.gz.md5
Does ./Monodelphis_domesticachromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Monodelphis_domestica/bigZips/chromFaMasked.tar.gz > ./Monodelphis_domesticachromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  526M  100  526M    0     0  2481k      0  0:03:37  0:03:37 --:--:-- 2773k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Mus_musculus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1478    0     0   1702      0 --:--:-- --:--:-- --:--:--  1759
dr-xr-xr-x   2 ftp      ftp            21 Jun 11 01:51 .
dr-xr-xr-x  11 ftp      ftp            11 May 15 17:35 ..
-r--r--r--   1 ftp      ftp          4495 Feb  9 22:48 README.txt
-r--r--r--   1 ftp      ftp          9956 Feb  9 21:40 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      870152350 Feb  9 21:54 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      502286607 Feb  9 22:02 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      162656369 Feb  9 21:41 chromOut.tar.gz
-r--r--r--   1 ftp      ftp      19493743 Feb  9 22:02 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      822361542 Jun 10 21:19 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun 10 21:19 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           457 Feb  9 22:20 md5sum.txt
-r--r--r--   1 ftp      ftp      714784109 Feb  7 18:52 mm10.2bit
-r--r--r--   1 ftp      ftp      136270720 Jun 10 20:45 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun 10 20:45 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      30003822 Jun 10 21:20 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun 10 21:20 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       6948661 Feb  9 22:18 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp      13192406 Feb  9 22:19 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp      31615132 Feb  9 22:20 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp      2717457505 Jun 10 20:55 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun 10 20:56 xenoMrna.fa.gz.md5
Does ./Mus_musculusFeb  9 22:02 chromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Mus_musculus/bigZips/Feb  9 22:02 chromFaMasked.tar.gz > ./Mus_musculusFeb  9 22:02 chromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (78) RETR response: 550

curl: (7) Failed to connect to 0.0.0.9: No route to host

curl: (7) Failed to connect to 0.0.0.22: No route to host

curl: (6) Could not resolve host: chromFaMasked.tar.gz; nodename nor servname provided, or not known

curl: (7) Failed to connect to 0.0.0.9: No route to host

curl: (7) Failed to connect to 0.0.0.22: No route to host

curl: (6) Could not resolve host: chromFaMasked.tar.gz; nodename nor servname provided, or not known
Failed to download Mus_musculus
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Myotis_lucifugus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1439    0     0   3474      0 --:--:-- --:--:-- --:--:--  3643
dr-xr-xr-x   2 ftp      ftp            20 Jun  3 13:32 .
dr-xr-xr-x   5 ftp      ftp             5 Nov  1  2011 ..
-r--r--r--   1 ftp      ftp          3618 Jun 30  2011 README.txt
-r--r--r--   1 ftp      ftp           304 Jun 30  2011 md5sum.txt
-r--r--r--   1 ftp      ftp          9608 Jun  2 08:41 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 08:41 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      532144225 Nov  3  2010 myoLuc2.2bit
-r--r--r--   1 ftp      ftp       1748117 Jun 30  2011 myoLuc2.agp.gz
-r--r--r--   1 ftp      ftp      651038555 Jun 30  2011 myoLuc2.fa.gz
-r--r--r--   1 ftp      ftp      439819649 Jun 30  2011 myoLuc2.fa.masked.gz
-r--r--r--   1 ftp      ftp      103322682 Jun 30  2011 myoLuc2.fa.out.gz
-r--r--r--   1 ftp      ftp       5085075 Jun 30  2011 myoLuc2.trf.bed.gz
-r--r--r--   1 ftp      ftp        339255 Jun  3 11:56 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 11:56 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp        646801 Jun  3 11:57 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 11:57 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp       1554095 Jun  3 11:57 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 11:57 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2777460433 Jun  2 09:06 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 09:09 xenoMrna.fa.gz.md5
Does ./Myotis_lucifugusmyoLuc2.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Myotis_lucifugus/bigZips/myoLuc2.fa.masked.gz > ./Myotis_lucifugusmyoLuc2.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  419M  100  419M    0     0  2592k      0  0:02:45  0:02:45 --:--:-- 2805k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Nomascus_leucogenys/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   977    0     0   1963      0 --:--:-- --:--:-- --:--:--  2061
dr-xr-xr-x   2 ftp      ftp            14 Jun  2 13:35 .
dr-xr-xr-x   7 ftp      ftp             7 Nov 24  2011 ..
-r--r--r--   1 ftp      ftp          3470 Dec  2  2011 README.txt
-r--r--r--   1 ftp      ftp           304 Nov 21  2011 md5sum.txt
-r--r--r--   1 ftp      ftp         10130 Jun  2 09:21 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 09:21 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      766667785 Oct 31  2010 nomLeu1.2bit
-r--r--r--   1 ftp      ftp       4947558 Nov 21  2011 nomLeu1.agp.gz
-r--r--r--   1 ftp      ftp      896928701 Nov 21  2011 nomLeu1.fa.gz
-r--r--r--   1 ftp      ftp      475593735 Nov 21  2011 nomLeu1.fa.masked.gz
-r--r--r--   1 ftp      ftp      159439203 Nov 21  2011 nomLeu1.fa.out.gz
-r--r--r--   1 ftp      ftp       6808315 Nov 21  2011 nomLeu1.trf.bed.gz
-r--r--r--   1 ftp      ftp      2777456323 Jun  2 09:36 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 09:39 xenoMrna.fa.gz.md5
Does ./Nomascus_leucogenysnomLeu1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Nomascus_leucogenys/bigZips/nomLeu1.fa.masked.gz > ./Nomascus_leucogenysnomLeu1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  453M  100  453M    0     0  2631k      0  0:02:56  0:02:56 --:--:-- 2827k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ornithorhynchus_anatinus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1726    0     0   3641      0 --:--:-- --:--:-- --:--:--  3861
dr-xr-xr-x   2 ftp      ftp            24 Jun  3 13:35 .
dr-xr-xr-x  21 ftp      ftp            22 Nov  1  2011 ..
-r--r--r--   1 ftp      ftp          3074 Jun 10  2009 README.txt
-r--r--r--   1 ftp      ftp       1932916 Jun  3 12:22 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  3 12:22 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           311 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp         62997 Jun  3 12:03 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  3 12:03 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       8264814 Jul 24  2007 ornAna1.agp.gz
-r--r--r--   1 ftp      ftp      604971438 Jul 24  2007 ornAna1.fa.gz
-r--r--r--   1 ftp      ftp      344238093 Jul 24  2007 ornAna1.fa.masked.gz
-r--r--r--   1 ftp      ftp      154003072 Jul 24  2007 ornAna1.fa.out.gz
-r--r--r--   1 ftp      ftp      451172914 Jun  9  2009 ornAna1.quals.fa.gz
-r--r--r--   1 ftp      ftp       2491967 Jul 24  2007 ornAna1.trf.bed.gz
-r--r--r--   1 ftp      ftp        148368 Jun  3 12:22 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  3 12:22 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        291281 Jun  3 12:24 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 12:24 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp        530328 Jun  3 12:24 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 12:24 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp       1188720 Jun  3 12:25 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 12:25 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2779472163 Jun  3 12:12 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  3 12:13 xenoMrna.fa.gz.md5
Does ./Ornithorhynchus_anatinusornAna1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ornithorhynchus_anatinus/bigZips/ornAna1.fa.masked.gz > ./Ornithorhynchus_anatinusornAna1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  328M  100  328M    0     0  2491k      0  0:02:14  0:02:14 --:--:-- 2707k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Oryctolagus_cuniculus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1719    0     0   3739      0 --:--:-- --:--:-- --:--:--  3924
dr-xr-xr-x   2 ftp      ftp            24 Jun  3 13:37 .
dr-xr-xr-x   9 ftp      ftp             9 Apr  2  2010 ..
-r--r--r--   1 ftp      ftp          4909 Apr 22  2010 README.txt
-r--r--r--   1 ftp      ftp       7148677 Jun  3 12:54 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  3 12:54 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           510 May 20  2010 md5sum.txt
-r--r--r--   1 ftp      ftp       1100894 Jun  3 12:33 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  3 12:33 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      715493848 Aug 12  2009 oryCun2.2bit
-r--r--r--   1 ftp      ftp       2221567 Apr  2  2010 oryCun2.agp.gz
-r--r--r--   1 ftp      ftp      854412134 Apr  2  2010 oryCun2.fa.gz
-r--r--r--   1 ftp      ftp      505855869 Apr  2  2010 oryCun2.fa.masked.gz
-r--r--r--   1 ftp      ftp      146746054 Apr  2  2010 oryCun2.fa.out.gz
-r--r--r--   1 ftp      ftp       8948994 Apr  2  2010 oryCun2.trf.bed.gz
-r--r--r--   1 ftp      ftp        843739 Jun  3 12:55 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  3 12:55 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      11703859 Jun  3 12:56 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 12:56 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp      22764394 Jun  3 12:58 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 12:58 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      62572160 Jun  3 13:00 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  3 13:00 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2778419211 Jun  3 12:41 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  3 12:42 xenoMrna.fa.gz.md5
Does ./Oryctolagus_cuniculusoryCun2.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Oryctolagus_cuniculus/bigZips/oryCun2.fa.masked.gz > ./Oryctolagus_cuniculusoryCun2.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  482M  100  482M    0     0  2579k      0  0:03:11  0:03:11 --:--:-- 2910k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Oryzias_latipes/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1974    0     0   2141      0 --:--:-- --:--:-- --:--:--  2274
dr-xr-xr-x   2 ftp      ftp            27 Jun  2 13:41 .
dr-xr-xr-x  20 ftp      ftp            21 May 11 23:22 ..
-r--r--r--   1 ftp      ftp          5192 Jun 10  2009 README.txt
-r--r--r--   1 ftp      ftp       1449165 Sep  8  2008 ensGene.upstream1000.fa.gz
-r--r--r--   1 ftp      ftp       2729589 Sep  8  2008 ensGene.upstream2000.fa.gz
-r--r--r--   1 ftp      ftp       6360372 Sep  8  2008 ensGene.upstream5000.fa.gz
-r--r--r--   1 ftp      ftp      153294819 Jun  2 10:27 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 10:27 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           494 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp        582184 Jun  2 09:51 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 09:51 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       3313007 Sep  8  2008 oryLat2.agp.gz
-r--r--r--   1 ftp      ftp      240966871 Sep  8  2008 oryLat2.fa.gz
-r--r--r--   1 ftp      ftp      174427587 Sep  8  2008 oryLat2.fa.masked.gz
-r--r--r--   1 ftp      ftp       7039267 Sep  8  2008 oryLat2.fa.out.gz
-r--r--r--   1 ftp      ftp      67505148 Jun  9  2009 oryLat2.quals.fa.gz
-r--r--r--   1 ftp      ftp        918128 Sep  8  2008 oryLat2.trf.bed.gz
-r--r--r--   1 ftp      ftp        372224 Jun  2 10:28 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  2 10:28 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       1446427 Jun  2 10:37 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 10:37 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       2724054 Jun  2 10:37 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 10:37 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp       6346523 Jun  2 10:37 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 10:37 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2776883701 Jun  2 10:10 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 10:13 xenoMrna.fa.gz.md5
Does ./Oryzias_latipesoryLat2.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Oryzias_latipes/bigZips/oryLat2.fa.masked.gz > ./Oryzias_latipesoryLat2.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  166M  100  166M    0     0  2552k      0  0:01:06  0:01:06 --:--:-- 2911k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ovis_aries/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1718    0     0   2833      0 --:--:-- --:--:-- --:--:--  2962
dr-xr-xr-x   2 ftp      ftp            24 Jun  2 13:46 .
dr-xr-xr-x  10 ftp      ftp            10 Apr 16  2011 ..
-r--r--r--   1 ftp      ftp          3659 Feb  7  2011 README.txt
-r--r--r--   1 ftp      ftp      67693059 Jun  2 11:45 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 11:45 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           304 Apr  2 16:22 md5sum.txt
-r--r--r--   1 ftp      ftp        783107 Jun  2 11:07 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 11:07 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      752625739 Apr 15  2010 oviAri1.2bit
-r--r--r--   1 ftp      ftp      62521073 Feb  7  2011 oviAri1.agp.gz
-r--r--r--   1 ftp      ftp      446513138 Feb  7  2011 oviAri1.fa.gz
-r--r--r--   1 ftp      ftp      353758034 Feb  7  2011 oviAri1.fa.masked.gz
-r--r--r--   1 ftp      ftp      63509343 Feb  7  2011 oviAri1.fa.out.gz
-r--r--r--   1 ftp      ftp        512667 Feb  7  2011 oviAri1.trf.bed.gz
-r--r--r--   1 ftp      ftp        382502 Jun  2 11:46 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  2 11:46 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp         61643 Jun  2 11:47 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 11:47 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp        109717 Jun  2 11:47 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 11:47 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp        237442 Jun  2 11:47 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 11:47 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2776685173 Jun  2 11:19 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 11:23 xenoMrna.fa.gz.md5
Does ./Ovis_ariesoviAri1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Ovis_aries/bigZips/oviAri1.fa.masked.gz > ./Ovis_ariesoviAri1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  337M  100  337M    0     0  2641k      0  0:02:10  0:02:10 --:--:-- 2928k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Pan_troglodytes/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1867    0     0   3218      0 --:--:-- --:--:-- --:--:--  3376
dr-xr-xr-x   2 ftp      ftp            26 Jun  2 13:55 .
dr-xr-xr-x  21 ftp      ftp            23 Mar  1  2011 ..
-r--r--r--   1 ftp      ftp          4206 Apr  5  2011 README.txt
-r--r--r--   1 ftp      ftp       6631204 Apr  4  2006 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      950620265 Apr  4  2006 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      517607159 Apr  4  2006 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      163779918 Apr  4  2006 chromOut.tar.gz
-r--r--r--   1 ftp      ftp      436355512 Jul 17  2006 chromQuals.tar.gz
-r--r--r--   1 ftp      ftp       6935000 Apr  4  2006 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp       2820193 Jun  2 13:04 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 13:04 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           566 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp       1928998 Jun  2 12:38 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 12:38 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      872466380 Mar 24  2006 panTro2.2bit
-r--r--r--   1 ftp      ftp      75795794 Jun  8  2009 panTro2.quals.fa.gz
-r--r--r--   1 ftp      ftp        919039 Jun  2 13:04 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  2 13:04 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp        275921 Jun  2 13:04 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 13:04 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp        524863 Jun  2 13:04 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 13:04 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp       1259339 Jun  2 13:04 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 13:04 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2775581470 Jun  2 12:50 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 12:51 xenoMrna.fa.gz.md5
Does ./Pan_troglodyteschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Pan_troglodytes/bigZips/chromFaMasked.tar.gz > ./Pan_troglodyteschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  493M  100  493M    0     0  2426k      0  0:03:28  0:03:28 --:--:-- 2063k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Petromyzon_marinus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1725    0     0   3173      0 --:--:-- --:--:-- --:--:--  3317
dr-xr-xr-x   2 ftp      ftp            24 Jun  2 19:37 .
dr-xr-xr-x  13 ftp      ftp            14 Feb 24  2011 ..
-r--r--r--   1 ftp      ftp          3801 Jun 10  2009 README.txt
-r--r--r--   1 ftp      ftp      24110582 Jun  2 17:40 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 17:40 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           311 Jun 10  2009 md5sum.txt
-r--r--r--   1 ftp      ftp        262492 Jun  2 17:10 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 17:10 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       5978560 Apr 29  2008 petMar1.agp.gz
-r--r--r--   1 ftp      ftp      282795561 Apr 29  2008 petMar1.fa.gz
-r--r--r--   1 ftp      ftp      187728695 Apr 29  2008 petMar1.fa.masked.gz
-r--r--r--   1 ftp      ftp       8628148 Apr 29  2008 petMar1.fa.out.gz
-r--r--r--   1 ftp      ftp      348538793 Jun  9  2009 petMar1.quals.fa.gz
-r--r--r--   1 ftp      ftp       2101389 Apr 29  2008 petMar1.trf.bed.gz
-r--r--r--   1 ftp      ftp            20 Jun  2 17:40 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  2 17:40 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp         46310 Jun  2 17:41 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 17:41 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp         81409 Jun  2 17:41 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 17:41 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp        159389 Jun  2 17:42 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 17:42 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2777201445 Jun  2 17:28 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 17:29 xenoMrna.fa.gz.md5
Does ./Petromyzon_marinuspetMar1.fa.masked.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Petromyzon_marinus/bigZips/petMar1.fa.masked.gz > ./Petromyzon_marinuspetMar1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  179M  100  179M    0     0  1890k      0  0:01:36  0:01:36 --:--:-- 2290k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Pongo_abelii/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1730    0     0   3448      0 --:--:-- --:--:-- --:--:--  3619
dr-xr-xr-x   2 ftp      ftp            24 Jun  2 19:41 .
dr-xr-xr-x  22 ftp      ftp            23 May  2 19:48 ..
-r--r--r--   1 ftp      ftp          4453 Oct 16  2008 README.txt
-r--r--r--   1 ftp      ftp      10921097 Oct  2  2007 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      1006598447 Oct  2  2007 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      530476712 Oct  2  2007 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      181378897 Oct  2  2007 chromOut.tar.gz
-r--r--r--   1 ftp      ftp       7970851 Oct  2  2007 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp       9282476 Jun  2 18:15 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 18:15 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           314 Oct 14  2008 md5sum.txt
-r--r--r--   1 ftp      ftp       4768041 Jun  2 17:49 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 17:49 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      761436797 Oct 14  2008 ponAbe2.quality.fa.tar.gz
-r--r--r--   1 ftp      ftp       3451099 Jun  2 18:16 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  2 18:16 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      14958046 Jun  2 18:18 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 18:18 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp      28853931 Jun  2 18:20 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 18:20 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      77894441 Jun  2 18:23 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 18:23 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2772739534 Jun  2 18:01 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 18:05 xenoMrna.fa.gz.md5
Does ./Pongo_abeliichromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Pongo_abelii/bigZips/chromFaMasked.tar.gz > ./Pongo_abeliichromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  505M  100  505M    0     0  2603k      0  0:03:19  0:03:19 --:--:-- 2417k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Pongo_pygmaeus_abelii/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1730    0     0   2449      0 --:--:-- --:--:-- --:--:--  2559
dr-xr-xr-x   2 ftp      ftp            24 Jun  2 19:41 .
dr-xr-xr-x  22 ftp      ftp            23 May  2 19:48 ..
-r--r--r--   1 ftp      ftp          4453 Oct 16  2008 README.txt
-r--r--r--   1 ftp      ftp      10921097 Oct  2  2007 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      1006598447 Oct  2  2007 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      530476712 Oct  2  2007 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      181378897 Oct  2  2007 chromOut.tar.gz
-r--r--r--   1 ftp      ftp       7970851 Oct  2  2007 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp       9282476 Jun  2 18:15 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 18:15 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           314 Oct 14  2008 md5sum.txt
-r--r--r--   1 ftp      ftp       4768041 Jun  2 17:49 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 17:49 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      761436797 Oct 14  2008 ponAbe2.quality.fa.tar.gz
-r--r--r--   1 ftp      ftp       3451099 Jun  2 18:16 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  2 18:16 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      14958046 Jun  2 18:18 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 18:18 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp      28853931 Jun  2 18:20 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 18:20 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      77894441 Jun  2 18:23 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 18:23 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2772739534 Jun  2 18:01 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 18:05 xenoMrna.fa.gz.md5
Does ./Pongo_pygmaeus_abeliichromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Pongo_pygmaeus_abelii/bigZips/chromFaMasked.tar.gz > ./Pongo_pygmaeus_abeliichromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  505M  100  505M    0     0  2393k      0  0:03:36  0:03:36 --:--:-- 2725k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Pristionchus_pacificus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1037    0     0    915      0 --:--:--  0:00:01 --:--:--  1511
dr-xr-xr-x   2 ftp      ftp            15 Jun  3 01:31 .
dr-xr-xr-x  11 ftp      ftp            12 Nov  1  2008 ..
-r--r--r--   1 ftp      ftp          2968 Jun  6  2007 README.txt
-r--r--r--   1 ftp      ftp        533305 May  1  2007 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      46793770 May  1  2007 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      45853803 May  1  2007 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp       1169682 May  1  2007 chromOut.tar.gz
-r--r--r--   1 ftp      ftp        175342 May  1  2007 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp       6344897 Jun  2 20:02 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 20:02 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           254 May  1  2007 md5sum.txt
-r--r--r--   1 ftp      ftp         40796 Jun  2 19:21 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 19:21 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      2777427679 Jun  2 19:37 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 19:42 xenoMrna.fa.gz.md5
Does ./Pristionchus_pacificuschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Pristionchus_pacificus/bigZips/chromFaMasked.tar.gz > ./Pristionchus_pacificuschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 43.7M  100 43.7M    0     0  2601k      0  0:00:17  0:00:17 --:--:-- 2832k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Rattus_norvegicus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1786    0     0   4178      0 --:--:-- --:--:-- --:--:--  4626
dr-xr-xr-x   2 ftp      ftp            25 Jun  3 01:35 .
dr-xr-xr-x  32 ftp      ftp            33 Nov  1  2011 ..
-r--r--r--   1 ftp      ftp          4187 Jan  4  2010 README.txt
-r--r--r--   1 ftp      ftp       3791630 Jan 30  2006 chromAgp.tar.gz
-r--r--r--   1 ftp      ftp      846228788 Mar 17  2006 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      496050158 Mar 17  2006 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      143149396 Mar 17  2006 chromOut.tar.gz
-r--r--r--   1 ftp      ftp      15556949 Jan 30  2006 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      218463296 Jun  2 23:00 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 23:00 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           347 Jan  4  2010 md5sum.txt
-r--r--r--   1 ftp      ftp      25700201 Jun  2 22:24 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 22:25 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      13934892 Jun  2 23:01 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  2 23:01 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      744722583 Mar 17  2006 rn4.2bit
-r--r--r--   1 ftp      ftp      362806320 Jun  9  2009 rn4.quals.fa.gz
-r--r--r--   1 ftp      ftp       4234833 Jun  2 23:02 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 23:02 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       8076995 Jun  2 23:03 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 23:03 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp      19431545 Jun  2 23:03 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 23:03 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      2751793678 Jun  2 22:38 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 22:40 xenoMrna.fa.gz.md5
Does ./Rattus_norvegicuschromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Rattus_norvegicus/bigZips/chromFaMasked.tar.gz > ./Rattus_norvegicuschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  473M  100  473M    0     0  2289k      0  0:03:31  0:03:31 --:--:-- 2798k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Rhesus_macaque/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0  1978    0     0   4382      0 --:--:-- --:--:-- --:--:--  4654
dr-xr-xr-x   2 ftp      ftp            27 Jun  3 01:33 .
dr-xr-xr-x  18 ftp      ftp            19 Nov 24  2011 ..
-r--r--r--   1 ftp      ftp          3458 Oct 16  2008 README.txt
-r--r--r--   1 ftp      ftp      872483618 Jun 12  2006 chromFa.tar.gz
-r--r--r--   1 ftp      ftp      479072110 Jun 12  2006 chromFaMasked.tar.gz
-r--r--r--   1 ftp      ftp      150272972 Jun 12  2006 chromOut.tar.gz
-r--r--r--   1 ftp      ftp      14123717 Jun 12  2006 chromTrf.tar.gz
-r--r--r--   1 ftp      ftp      16131450 Jun  2 20:52 est.fa.gz
-r--r--r--   1 ftp      ftp            44 Jun  2 20:52 est.fa.gz.md5
-r--r--r--   1 ftp      ftp           799 Jun 14  2006 md5sum.txt
-r--r--r--   1 ftp      ftp      145200715 Jun  2 20:14 mrna.fa.gz
-r--r--r--   1 ftp      ftp            45 Jun  2 20:14 mrna.fa.gz.md5
-r--r--r--   1 ftp      ftp       4154784 Jun  2 20:53 refMrna.fa.gz
-r--r--r--   1 ftp      ftp            48 Jun  2 20:53 refMrna.fa.gz.md5
-r--r--r--   1 ftp      ftp      17734913 Feb  9  2006 rheMac2.agp.tar.gz
-r--r--r--   1 ftp      ftp      225838620 Mar  9  2006 rheMac2.qual.qv.gz
-r--r--r--   1 ftp      ftp       1621648 Jun  2 20:54 upstream1000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 20:54 upstream1000.fa.gz.md5
-r--r--r--   1 ftp      ftp       3081872 Jun  2 20:54 upstream2000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 20:54 upstream2000.fa.gz.md5
-r--r--r--   1 ftp      ftp       7353566 Jun  2 20:54 upstream5000.fa.gz
-r--r--r--   1 ftp      ftp            53 Jun  2 20:54 upstream5000.fa.gz.md5
-r--r--r--   1 ftp      ftp      869895664 Jan 27  2006 v1.edit3.noContam.ctg.fasta.gz
-r--r--r--   1 ftp      ftp      301323668 Jan 27  2006 v1.edit3.noContam.ctg.qv.gz
-r--r--r--   1 ftp      ftp      853268925 Jan 27  2006 v1_edit4.scf.fasta.gz
-r--r--r--   1 ftp      ftp      2632312278 Jun  2 20:29 xenoMrna.fa.gz
-r--r--r--   1 ftp      ftp            49 Jun  2 20:32 xenoMrna.fa.gz.md5
Does ./Rhesus_macaquechromFaMasked.tar.gz exixts?
downloading curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Rhesus_macaque/bigZips/chromFaMasked.tar.gz > ./Rhesus_macaquechromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  456M  100  456M    0     0  2656k      0  0:02:56  0:02:56 --:--:-- 2526k
downloading curl list from curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/SARS_coronavirus/bigZips/…
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0   470    0     0    192      0 --:--:--  0:00:02 --:--:--   585
dr-xr-xr-x   2 ftp      ftp             7 Nov 23  2004 .
dr-xr-xr-x   4 ftp      ftp             4 Jun  7  2004 ..
-r--r--r--   1 ftp      ftp          1317 Nov 20  2004 README.txt
-r--r--r--   1 ftp      ftp          9764 Oct  8  2004 SARS.fa.zip
-r--r--r--   1 ftp      ftp         66274 Jun  5  2003 otherSARS.fa.zip
-r--r--r--   1 ftp      ftp        163896 Jun  5  2003 viralProt.fa.zip
-r--r--r--   1 ftp      ftp      97176298 Jun  5  2003 viralany.fa.zip
correctlist undefined
StellaHartonoMacBookPro:Allmasked stella$ 

StellaHartonoMacBookPro:Allmasked stella$ curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Heterocephalus_glaber/bigZips/hetGla1.fa.masked.gz > /Users/stella/Desktop/Work/FredIan/Genomes/Allmasked/Heterocephalus_glaberhetGla1.fa.masked.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  564M  100  564M    0     0  2805k      0  0:03:25  0:03:25 --:--:-- 2844k
StellaHartonoMacBookPro:Allmasked stella$ curl ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Mus_musculus/bigZips/chromFaMasked.tar.gz > ./Mus_musculuschromFaMasked.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  479M  100  479M    0     0  2641k      0  0:03:05  0:03:05 --:--:-- 2447k
StellaHartonoMacBookPro:Allmasked stella$ 