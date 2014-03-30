package mitochy;

use strict; use warnings;

use FAlite;
#use BioMart::Initializer;
#use BioMart::Query;
#use BioMart::QueryRunner;
use Cache::FileCache;

sub test {
	print "Test: Hello World\n";
}

sub return_org {
	my @org = qw(aaegypti acarolinensis acephalotes aclavatus aflavus afumigatus afumigatusa1163 agambiae agossypii alaibachii alyrata amelanoleuca amellifera anidulans aniger aoryzae apisum aqueenslandica aterreus athaliana bdistachyon bmori brapa btaurus cbrenneri cbriggsae celegans cfamiliaris choffmanni cintestinalis cjacchus cjaponica cmerolae cporcellus cquinquefasciatus creinhardtii cremanei csavignyi dananassae ddiscoideum derecta dgrimshawi dmelanogaster dmojavensis dnovemcinctus dordii dpersimilis dplexippus dpseudoobscura dpulex drerio dsechellia dsimulans dvirilis dwillistoni dyakuba ecaballus eeuropaeus ehistolytica etelfairi fcatus foxysporum gaculeatus ggallus ggorilla ggraminis gmax gmoniliformis gmorhua gzeae harabidopsidis hmelpomene hsapiens iscapularis itridecemlineatus lafricana lchalumnae lmajor mdomestica meugenii mgallopavo mgraminicola mlucifugus mmulatta mmurinus mmusculus moryzae mpoae ncrassa nfischeri nhaematococca nleucogenys nvectensis oanatinus obrachyantha ocuniculus ogarnettii oglaberrima oindica olatipes oprinceps osativa pabelii pberghei pcapensis pchabaudi pfalciparum phumanus pinfestans pknowlesi pmarinus pnodorum ppacificus ppatens pramorum psojae ptrichocarpa ptricornutum ptriticina ptroglodytes pultimum pvampyrus pvivax rnorvegicus saraneus sbicolor scerevisiae sharrisii sitalica slycopersicum smoellendorffii spombe spurpuratus sscrofa tadhaerens tbelangeri tbrucei tcastaneum tgondii tguttata tmelanosporum tnigroviridis tpseudonana trubripes tspiralis tsyrichta tthermophila ttruncatus umaydis vpacos vvinifera xtropicalis zmays);
	return(@org);
}

# Global_Variables
# Mart list, Organism list
sub Global_Var {
        my ($query) = @_;
        my @martlist = qw(ensembl metazoa fungi plants protists);

	my %name;
        my %org;
	my %orig_org;
	my %orgfullname;
       # @{$org{'all'}} = qw(aaegypti acarolinensis acephalotes aclavatus aflavus afumigatusa1163 afumigatus agambiae agossypii alaibachii alyrata ame
	#@{$orig_org{'protists'}} = qw(alaibachii creinhardtii ddiscoideum ehistolytica harabidopsidis lmajor pberghei pchabaudi pfalciparum pinfestans pknowlesi pramorum psojae ptricornutum pultimum pvivax tbrucei tgondii tpseudonana tthermophila);
	@{$orig_org{'protists'}} = qw(alaibachii ddiscoideum ehistolytica harabidopsidis lmajor pberghei pchabaudi pfalciparum pinfestans pknowlesi pramorum psojae ptricornutum pultimum pvivax tbrucei tgondii tpseudonana);
        @{$orig_org{'plants'}} = qw(alyrata athaliana bdistachyon brapa gmax obrachyantha oglaberrima oindica osativa ppatens ptrichocarpa sbicolor sitalica slycopersicum vvinifera zmays);
        #@{$orig_org{'plants'}} = qw(alyrata athaliana bdistachyon brapa gmax obrachyantha oglaberrima oindica osativa ppatens ptrichocarpa sbicolor sitalica smoellendorffii slycopersicum vvinifera zmays);
        @{$orig_org{'fungi'}} = qw(aclavatus aflavus afumigatusa1163 afumigatus agossypii anidulans aniger aoryzae aterreus bfuckeliana foxysporum ggraminis gmoniliformis gzeae mgraminicola moryzae mpoae ncrassa nfischeri nhaematococca pgraminis pnodorum ptriticina scerevisiae ssclerotiorum spombe tmelanosporum umaydis);
        @{$orig_org{'tunicates'}} = qw(cintestinalis csavignyi);
	@{$orig_org{'porifera'}} = qw(tadhaerens aqueenslandica);
	@{$orig_org{'cnidarians'}} = qw(nvectensis);
	@{$orig_org{'echinodermata'}} = qw(spurpuratus);
        @{$orig_org{'insects'}} = qw(aaegypti acephalotes agambiae amellifera apisum bmori cquinquefasciatus dananassae derecta dgrimshawi dmelanogaster dmojavensis dpersimilis dplexippus dpseudoobscura dpulex dsechellia dsimulans dvirilis dwillistoni dyakuba hmelpomene iscapularis phumanus tcastaneum);
	@{$orig_org{'fishes'}} = qw(drerio olatipes gaculeatus trubripes tnigroviridis pmarinus lchalumnae);
	@{$orig_org{'amphibians'}} = qw( xtropicalis);
	@{$orig_org{'reptiles'}} = qw(acarolinensis);
	@{$orig_org{'birds'}} = qw(mgallopavo tguttata ggallus);
	@{$orig_org{'mammals'}} = qw(amelanoleuca btaurus cfamiliaris choffmanni cjacchus cporcellus dnovemcinctus dordii ecaballus eeuropaeus etelfairi fcatus ggorilla gmorhua hsapiens itridecemlineatus lafricana mdomestica meugenii mlucifugus mmulatta mmurinus mmusculus nleucogenys oanatinus ocuniculus ogarnettii oprinceps pabelii pcapensis ptroglodytes pvampyrus rnorvegicus saraneus sharrisii sscrofa tbelangeri tsyrichta ttruncatus vpacos);


	my @class = qw(
	Protists_Fornicata Protists_Cryptophyta Plants_Rhodophyta Protists_Amoebozoa 
	Protists_Kinetoplastida Protists_Stramenopiles Protists_Alveolata 
	Plants_Chlorophyta Plants_Bryophyta Plants_Lycopodiophyta Plants_Eudicotyledons Plants_Liliopsida 
	Fungi_Tremellales Fungi_Ustilaginales Fungi_Eukaryota Fungi_Pucciniales Fungi_Schizosaccharomycetales Fungi_Saccharomycetales 
	Fungi_Pezizales Fungi_Capnodiales Fungi_Pleosporales Fungi_Eurotiales Fungi_Erysiphales Fungi_Sclerotiniaceae Fungi_Sordiales
	Fungi_Magnaporthales Fungi_Glomerellales Fungi_Hypocreales
	Metazoa_Porifera Metazoa_Placozoa Metazoa_Cnidaria Metazoa_Platyhelminthes Metazoa_Mollusca Metazoa_Annelida
	Metazoa_Nematoda Metazoa_Chelicerata Metazoa_Myriapoda Metazoa_Crustacea Metazoa_Phthiraptera Metazoa_Hemiptera 
	Metazoa_Coleoptera Metazoa_Hymenoptera Metazoa_Lepidoptera Metazoa_Diptera Metazoa_Echinodermata 
	Chordate_Tunicates Chordate_Agnatha Chordate_Osteichthyes Chordate_Amphibia Chordate_Reptilia Chordate_Aves 
	Chordate_Prototheria Chordate_Marsupialia Chordate_Xenartha 
	Chordate_Afrotheria Chordate_Laurasiatheria Chordate_Rodents Chordate_Primates
	);

	@{$org{Protists_Fornicata}} = qw(glamblia);
	@{$org{Protists_Cryptophyta}} = qw(gtheta);
	@{$org{Plants_Rhodophyta}} = qw(cmerolae);

	@{$org{Protists_Amoebozoa}} = qw(ddiscoideum ehistolytica);
	@{$org{Protists_Kinetoplastida}} = qw(tbrucei lmajor);
	@{$org{Protists_Stramenopiles}} = qw(tpseudonana ptricornutum alaibachii pultimum harabidopsidis pramorum psojae pinfestans);
	@{$org{Protists_Alveolata}} = qw(tthermophila ptetraurelia tgondii pfalciparum pvivax pknowlesi pchabaudi pberghei);

	@{$org{Plants_Chlorophyta}} = qw(creinhardtii);
	@{$org{Plants_Bryophyta}} = qw(ppatens);
	@{$org{Plants_Lycopodiophyta}} = qw(smoellendorffii);
	@{$org{Plants_Eudicotyledons}} = qw(stuberosum slycopersicum vvinifera brapa alyrata athaliana ptrichocarpa mtruncatula gmax);
	@{$org{Plants_Liliopsida}} = qw(macuminata sitalica zmays sbicolor oglaberrima obrachyantha osativa oindica bdistachyon atauschii turartu hvulgare);

	@{$org{Fungi_Tremellales}} = qw(cneoformans);
	@{$org{Fungi_Ustilaginales}} = qw(sreilianum umaydis);
	@{$org{Fungi_Eukaryota}} = qw(mviolaceum);
	@{$org{Fungi_Pucciniales}} = qw(mlaricipopulina ptriticina pgraminis);
	@{$org{Fungi_Schizosaccharomycetales}} = qw(spombe);
	@{$org{Fungi_Saccharomycetales}} = qw(ylipolytica agossypii scerevisiae kpastoris);
	@{$org{Fungi_Pezizales}} = qw(tmelanosporum);
	@{$org{Fungi_Capnodiales}} = qw(ztritici);
	@{$org{Fungi_Pleosporales}} = qw(pnodorum lmaculans pteres ptriticirepentis);
	@{$org{Fungi_Eurotiales}} = qw(nfischeri afumigatus afumigatusa1163 anidulans aterreus aoryzae aniger aflavus aclavatus);
	@{$org{Fungi_Erysiphales}} = qw(bgraminis);
	@{$org{Fungi_Sclerotiniaceae}} = qw(bfuckeliana ssclerotiorum);
	@{$org{Fungi_Sordiales}} = qw(ncrassa);
	@{$org{Fungi_Magnaporthales}} = qw(ggraminis moryzae mpoae);
	@{$org{Fungi_Glomerellales}} = qw(ggraminicola);
	@{$org{Fungi_Hypocreales}} = qw(treesei tvirens gmonilliformis gzeae nhaematococca foxysporum gmoniliformis);


	@{$org{Metazoa_Porifera}} = qw(aqueenslandica);
	@{$org{Metazoa_Placozoa}} = qw(tadhaerens);
	@{$org{Metazoa_Cnidaria}} = qw(nvectensis);
	@{$org{Metazoa_Platyhelminthes}} = qw(smansoni);
	@{$org{Metazoa_Mollusca}} = qw(lgigantea cgigas);
	@{$org{Metazoa_Annelida}} = qw(cteleta hrobusta);
	@{$org{Metazoa_Nematoda}} = qw(tspiralis ppacificus lloa bmalayi cjaponica cbrenneri cremanei celegans cbriggsae);
	@{$org{Metazoa_Chelicerata}} = qw(turticae iscapularis);
	@{$org{Metazoa_Myriapoda}} = qw(smaritima);
	@{$org{Metazoa_Crustacea}} = qw(dpulex);
	@{$org{Metazoa_Phthiraptera}} = qw(phumanus);
	@{$org{Metazoa_Hemiptera}} = qw(rprolixus apisum);
	@{$org{Metazoa_Coleoptera}} = qw(tcastaneum);
	@{$org{Metazoa_Hymenoptera}} = qw(nvitripennis acephalotes amellifera);
	@{$org{Metazoa_Lepidoptera}} = qw(bmori hmelpomene dplexippus);
	@{$org{Metazoa_Diptera}} = qw(adarlingi agambiae cquinquefasciatus aaegypti mscalaris dgrimshawi dvirilis dmojavensis dwillistoni dpseudoobscura dpersimilis dananassae dyakuba dsimulans dsechellia dmelanogaster derecta);
	@{$org{Metazoa_Echinodermata}} = qw(spurpuratus);

# delete: Plasmodium Vinckeia smansoni	
# missing: xtropicalis
	@{$org{Chordate_Tunicates}} = qw(csavignyi cintestinalis);
	@{$org{Chordate_Agnatha}} = qw(pmarinus);
	@{$org{Chordate_Osteichthyes}} = qw(drerio gmorhua oniloticus tnigroviridis trubripes gaculeatus olatipes xmaculatus lchalumnae);
	@{$org{Chordate_Amphibia}} = qw(xtropicalis);
	@{$org{Chordate_Reptilia}} = qw(acarolinensis psinensis);
	@{$org{Chordate_Aves}} = qw(aplatyrhynchos falbicollis tguttata mgallopavo ggallus);
	@{$org{Chordate_Prototheria}} = qw(oanatinus);
	@{$org{Chordate_Marsupialia}} = qw(mdomestica meugenii sharrisii);
	@{$org{Chordate_Xenartha}} = qw(dnovemcinctus choffmanni);
	@{$org{Chordate_Afrotheria}} = qw(pcapensis lafricana etelfairi);
	@{$org{Chordate_Laurasiatheria}} = qw(ecaballus pvampyrus mlucifugus saraneus eeuropaeus vpacos btaurus sscrofa ttruncatus fcatus mfuro amelanoleuca cfamiliaris);
	@{$org{Chordate_Rodents}} = qw(tbelangeri ocuniculus oprinceps cporcellus itridecemlineatus dordii rnorvegicus mmusculus);
	@{$org{Chordate_Primates}} = qw(ogarnettii mmurinus tsyrichta cjacchus mmulatta nleucogenys pabelii hsapiens ptroglodytes ggorilla);

	@{$orgfullname{Protists_Cryptophyta}} = qw(Guillardia_theta);
	@{$orgfullname{Protists_Fornicata}} = qw(Giardia_lamblia);
	@{$orgfullname{Protists_Alveolata}} = qw(Paramecium_tetraurelia plasmodium_berghei plasmodium_chabaudi plasmodium_falciparum plasmodium_knowlesi plasmodium_vivax tetrahymena_thermophila toxoplasma_gondii);
	@{$orgfullname{Protists_Amoebozoa}} = qw(dictyostelium_discoideum entamoeba_histolytica);
	@{$orgfullname{Protists_Stramenopiles}} = qw(albugo_laibachii hyaloperonospora_arabidopsidis phaeodactylum_tricornutum phytophthora_infestans phytophthora_ramorum phytophthora_sojae pythium_ultimum thalassiosira_pseudonana);
	@{$orgfullname{Protists_Kinetoplastida}} = qw(leishmania_major trypanosoma_brucei);

	@{$orgfullname{Fungi_Tremellales}} = qw(Cryptococcus_neoformans);
	@{$orgfullname{Fungi_Eukaryota}} = qw(Microbotryum_violaceum);
	@{$orgfullname{Fungi_Erysiphales}} = qw(Blumeria_graminis);
	@{$orgfullname{Fungi_Capnodiales}} = qw(Zymoseptoria_tritici);
	@{$orgfullname{Fungi_Eurotiales}} = qw(aspergillus_clavatus aspergillus_flavus aspergillus_fumigatus aspergillus_fumigatusa1163 aspergillus_nidulans aspergillus_niger aspergillus_oryzae aspergillus_terreus neosartorya_fischeri);
	@{$orgfullname{Fungi_Glomerellales}} = qw(Glomerella_graminicola);
	@{$orgfullname{Fungi_Hypocreales}} = qw(Gibberella_moniliformis Fusarium_oxysporum Gibberella_zeae Nectria_haematococca Trichoderma_virens Trichoderma_reesei);
	@{$orgfullname{Fungi_Pezizales}} = qw(Tuber_melanosporum);
	@{$orgfullname{Fungi_Pleosporales}} = qw(Phaeosphaeria_nodorum Leptosphaeria_maculans Pyrenophora_teres Pyrenophora_triticirepentis);
	@{$orgfullname{Fungi_Pucciniales}} = qw(Melampsora_laricipopulina Puccinia_graminis Puccinia_triticina);
	@{$orgfullname{Fungi_Sordiales}} = qw(Neurospora_crassa);
	@{$orgfullname{Fungi_Magnaporthales}} = qw(Gaeumannomyces_graminis Magnaporthe_oryzae Magnaporthe_poae);
	@{$orgfullname{Fungi_Saccharomycetales}} = qw(Ashbya_gossypii Komagataella_pastoris Saccharomyces_cerevisiae Yarrowia_lipolytica);
	@{$orgfullname{Fungi_Schizosaccharomycetales}} = qw(Schizosaccharomyces_pombe);
	@{$orgfullname{Fungi_Ustilaginales}} = qw(Sporisorium_reilianum Ustilago_maydis);
	@{$orgfullname{Fungi_Sclerotiniaceae}} = qw(Botryotinia_fuckeliana Sclerotinia_sclerotiorum);

	@{$orgfullname{Plants_Liliopsida}} = qw(Aegilops_tauschii Triticum_urartu Brachypodium_distachyon Hordeum_vulgare Musa_acuminata Oryza_brachyantha Oryza_glaberrima Oryza_sativa Oryza_indica Setaria_italica Sorghum_bicolor Zea_mays);
	@{$orgfullname{Plants_Eudicotyledons}} = qw(Medicago_truncatula Arabidopsis_lyrata Arabidopsis_thaliana Brassica_rapa Glycine_max Populus_trichocarpa Solanum_lycopersicum Solanum_tuberosum Vitis_vinifera);
	@{$orgfullname{Plants_Lycopodiophyta}} = qw(Selaginella_moellendorffii);
	@{$orgfullname{Plants_Bryophyta}} = qw(Physcomitrella_patens);
	@{$orgfullname{Plants_Chlorophyta}} = qw(Chlamydomonas_reinhardtii);
	@{$orgfullname{Plants_Rhodophyta}} = qw(Cyanidioschyzon_merolae);
	
	@{$orgfullname{Metazoa_Myriapoda}} = qw(Strigamia_maritima);
	@{$orgfullname{Metazoa_Annelida}} = qw(Capitella_teleta Helobdella_robusta);
	@{$orgfullname{Metazoa_Mollusca}} = qw(Crassostrea_gigas Lottia_gigantea);
	@{$orgfullname{Metazoa_Diptera}} = qw(Aedes_aegypti Anopheles_darlingi Anopheles_gambiae Culex_quinquefasciatus Drosophila_ananassae Drosophila_erecta Drosophila_grimshawi Drosophila_melanogaster Drosophila_mojavensis Drosophila_persimilis Drosophila_pseudoobscura Drosophila_sechellia Drosophila_simulans Drosophila_virilis Drosophila_willistoni Drosophila_yakuba Megaselia_scalaris);
	@{$orgfullname{Metazoa_Nematoda}} = qw(Brugia_malayi Caenorhabditis_brenneri Caenorhabditis_briggsae Caenorhabditis_elegans Caenorhabditis_japonica Caenorhabditis_remanei Pristionchus_pacificus Trichinella_spiralis Loa_loa);
	@{$orgfullname{Metazoa_Chelicerata}} = qw(Ixodes_scapularis Tetranychus_urticae);
	@{$orgfullname{Metazoa_Hymenoptera}} = qw(Atta_cephalotes Apis_mellifera Nasonia_vitripennis);
	@{$orgfullname{Metazoa_Coleoptera}} = qw(Tribolium_castaneum);
	@{$orgfullname{Metazoa_Lepidoptera}} = qw(Bombyx_mori Danaus_plexippus Heliconius_melpomene);
	@{$orgfullname{Metazoa_Hemiptera}} = qw(Acyrthosiphon_pisum Rhodnius_prolixus);
	@{$orgfullname{Metazoa_Phthiraptera}} = qw(Pediculus_humanus);
	@{$orgfullname{Metazoa_Platyhelminthes}} = qw(Schistosoma_mansoni);
	@{$orgfullname{Metazoa_Placozoa}} = qw(Trichoplax_adhaerens);
	@{$orgfullname{Metazoa_Echinodermata}} = qw(Strongylocentrotus_purpuratus);
	@{$orgfullname{Metazoa_Cnidaria}} = qw(Nematostella_vectensis);
	@{$orgfullname{Metazoa_Porifera}} = qw(Amphimedon_queenslandica);
	@{$orgfullname{Metazoa_Crustacea}} = qw(Daphnia_pulex);

	@{$orgfullname{Chordate_Tunicates}} = qw(Ciona_intestinalis Ciona_savignyi);	
	@{$orgfullname{Chordate_Agnatha}} = qw(Petromyzon_marinus);
	@{$orgfullname{Chordate_Osteichthyes}} = qw(Gadus_morhua Latimeria_chalumnae Takifugu_rubripes Oryzias_latipes Xiphophorus_maculatus Gasterosteus_aculeatus Tetraodon_nigroviridis Oreochromis_niloticus Danio_rerio);
	@{$orgfullname{Chordate_Amphibia}} = qw(Xenopus_tropicalis);
	@{$orgfullname{Chordate_Reptilia}} = qw(Anolis_carolinensis Pelodiscus_sinensis);
	@{$orgfullname{Chordate_Aves}} = qw(Gallus_gallus Ficedula_albicollis Anas_platyrhynchos Meleagris_gallopavo Taeniopygia_guttata);
	@{$orgfullname{Chordate_Prototheria}} = qw(Ornithorhynchus_anatinus);
	@{$orgfullname{Chordate_Marsupialia}} = qw(Monodelphis_domestica Sarcophilus_harrisii Macropus_eugenii);
	@{$orgfullname{Chordate_Xenartha}} = qw(Dasypus_novemcinctus Choloepus_hoffmanni);
	@{$orgfullname{Chordate_Afrotheria}} = qw(Loxodonta_africana Procavia_capensis Echinops_telfairi);
	@{$orgfullname{Chordate_Laurasiatheria}} = qw(Vicugna_pacos Felis_catus Bos_taurus Canis_familiaris Tursiops_truncatus Mustela_furo Erinaceus_europaeus Equus_caballus Pteropus_vampyrus Myotis_lucifugus Ailuropoda_melanoleuca Sus_scrofa Sorex_araneus);
	@{$orgfullname{Chordate_Rodents}} = qw(Cavia_porcellus Dipodomys_ordii Mus_musculus Ochotona_princeps Oryctolagus_cuniculus Rattus_norvegicus Ictidomys_tridecemlineatus Tupaia_belangeri);
	@{$orgfullname{Chordate_Primates}} = qw(Otolemur_garnettii Pan_troglodytes Nomascus_leucogenys Gorilla_gorilla Homo_sapiens Macaca_mulatta Callithrix_jacchus Microcebus_murinus Pongo_abelii Tarsius_syrichta);


	my @family = qw(protists_Oomycete protists_Protozoa algae fungi_Yeast fungi_Mold plants_Monocot plants_Eudicot insectsA insectsB insectsC worms tunicates porifera cnidarians echinodermata fishes_Jawed fishes_Jawless reptiles amphibians birds mammals_Nonprimates mammals_Primates);
	my %orgtofam;
	foreach my $family (sort keys %org) {
		for (my $i = 0; $i < @{$org{$family}}; $i++) {
			my $orgs = $org{$family}[$i];
			$orgtofam{$orgs} = $family;
		}
	}
	return(\@class)		if $query =~ /^class$/;
        return(@martlist) 	if $query =~ /martlist/;
        return(\%org) 		if $query =~ /^orglist$/;
        return(\%orgfullname) 	if $query =~ /^orgfullname$/;
        return(\%orig_org) 	if $query =~ /orig_orglist/;
	return(\@family) 	if $query =~ /family/;
	return(\%orgtofam) 	if $query =~ /orgtofam/;

}

sub org_name {
	my %name;
	

}

sub process_biomart_fasta {
	my ($input) = @_;

	my %fasta;
	open (my $in, "<", $input) or die "Cannot read from $input: $!\n";
	my ($org, $type) = $input =~ /(\w+).table.(\w+)./i;
	($org, $type) = $input =~ /\w+\.\w+\.id\.(\w+).ID\.(\w+)./i if not defined($org);

	die "process_biomart_fasta: organism undefined (make sure name is org.table.<query>...)\n" unless defined($org) and defined($type);
	while (my $line = <$in>) {
		chomp($line);
		$line =~ s/"//ig;
	
		next if $line !~ /^\d+/;
	
		my ($num, $fasta, $id, $strand) = split(" ", $line);
		$id = uc($id);
		next if $line =~ /Sequence/i;
		print "fasta not defined at $line\n" unless defined($fasta);
		print "ERROR at $line\n" if $strand !~ /^1$/ and $strand !~/^-1$/; 
		die "$line\n" unless defined($strand);

		if ($type =~ /peptide/i) {
			push(@{$fasta{$id}{'seq'}},$fasta);
		}

		elsif ($type !~ /peptide/i) {
			
#			$fasta{$id}{'seq'} = revcomp($fasta) if $strand =~ /^-1$/;
			$fasta{$id}{'seq'} = $fasta;# if $strand =~ /^1$/;
	
		}
		$fasta{$id}{'org'} = $org;
		$fasta{$id}{'strand'} = $strand if $strand =~ /^1$/ or $strand =~ /^-1$/i;

	}
	close $in;

	return(%fasta);
}

sub biomart_kogid_array {
	my $orgcache = new Cache::FileCache();
	$orgcache -> set_cache_root("/home/mitochi/Desktop/Cache");
	my $org_cache = $orgcache -> get("orgdb");
	my %org = %{$org_cache};
	my @kog;
	foreach my $kog (sort keys %org) {
		my $count = 0;
		foreach my $org (sort keys %{$org{$kog}}) {
			$count++;
		}
	push(@kog, [$count, $kog]);
	}
	@kog = sort {$b -> [0] <=> $a -> [0]} @kog;
	return(@kog);

}
sub process_biomart_flank {
	my ($flanks) = @_;
	my %id = mitochy::process_kogIDdb();
	
	my $orgcache = new Cache::FileCache();
	$orgcache -> set_cache_root("/home/mitochi/Desktop/Cache");
	my $org_cache = $orgcache -> get("orgdb");
	print "Checking Org Database...(orgdb)\n";
	if (not defined($org_cache)) {
	        print "NOT DEFINED ORGDB\n";
	        my %orgs = mitochy::process_orgID();
	        my $orgscalar = \%orgs;
	        $orgcache -> set ("orgdb", $orgscalar);
		$org_cache = $orgscalar;
	}
	my %org = %{$org_cache};
	print "Done\n";

	print "Checking Flank Database...(orgdbflank_$flanks\_raw)\n";
	my $flankdb = $orgcache -> get ("orgdbflank_$flanks\_raw");
	if (not defined ($flankdb)) {
		print "NOT DEFINED FLANKDB\n";
		my $flankfolder = "/home/mitochi/Desktop/Work/newcegma/flankgene";
		my @flankfile = <$flankfolder\/$flanks\/*.table.geneflank.*.txt>;
		my %flank;
		my $flank;
		foreach my $flankfile (@flankfile) {
			print "\tprocessing $flankfile\...\n";
			my ($org, $flanks) = $flankfile =~ /(\w+).table.geneflank.(\d+).txt$/i;
			$flank = $flanks;
			die "ORG not defined at $flankfile\n" unless defined($org);
			open (my $in, "<", $flankfile) or die "Cannot read from $flankfile: $!\n";
		
			while (my $line = <$in>) {
				chomp($line);
				#$line = uc($line);
				$line =~ s/\"//ig;
	
				next if $line =~ /ensembl_gene_id/i;
				my ($num, $id, $chr, $start, $end, $strand) = split(" ", $line);
				#print "$start\t$id\t$chr\n";
				$flank{$org}{$chr}{'start'}{$start}{'id'} = $id;
				$flank{$org}{$chr}{'start'}{$start}{'strand'} = $strand;
				$flank{$org}{$chr}{'end'}{$end}{'id'} = $id;
				$flank{$org}{$chr}{'end'}{$end}{'strand'} = $strand;
	
			}
		}
		$orgcache -> set ("orgdbflank_$flanks\_raw", \%flank);
	}
	$flankdb = $orgcache -> get ("orgdbflank_$flanks\_raw");
	my %flank = %{$flankdb};
	print "Done\n";
	
	my $count_no_flank = 0;	
	my $count_kogid = 0;
	print "Linking Genes with Flanks...\n";
	my $count_gene = 0;
	my $count_flank = 0;
	foreach my $kogid (sort keys %org) {
		$count_kogid++;
		print "$count_kogid\tKOGID: $kogid\n";
		foreach my $org (sort keys %{$org{$kogid}}) {
                	my $chr = $org{$kogid}{$org}{'chr'};
                	my $start = $org{$kogid}{$org}{'start'};
                	my $end = $org{$kogid}{$org}{'end'};
                	my $strand = $org{$kogid}{$org}{'strand'};
			my $id2 = $id{$kogid}{$org};
			if (not defined($flank{$org}{$chr})) {
				$count_gene++;
				$count_no_flank++;
				$org{$kogid}{$org}{'no_flank'} = $id2; 
				#print "$count_kogid\tOrg:$org at Chr:$chr doesn't have any flank\n";
				next;
			}
			else {
				foreach my $flankstart (sort keys %{$flank{$org}{$chr}{'start'}}) {
					$count_gene++;
					my $flankid = $flank{$org}{$chr}{'start'}{$flankstart}{'id'};
					my $flankstrand = $flank{$org}{$chr}{'start'}{$flankstart}{'strand'};
					my @arr = ([$flankid, $flankstrand]);
					$count_gene-- and next if not defined($flankid);
					$count_gene-- and next if $flankid =~ /^$id2$/i;
					if ($flankstart > $end and $flankstart < $end+$flanks) {
						$count_flank++;
						push(@{$org{$kogid}{$org}{'flank_end'}}, $arr[0]) if $strand == 1;
						push(@{$org{$kogid}{$org}{'flank_start'}}, $arr[0]) if $strand == -1;
					}
					else {
						$count_no_flank++;
					}
				}
				foreach my $flankend (sort keys %{$flank{$org}{$chr}{'end'}}) {
					$count_gene++;
					my $flankid = $flank{$org}{$chr}{'end'}{$flankend}{'id'};
					my $flankstrand = $flank{$org}{$chr}{'end'}{$flankend}{'strand'};
					my @arr = ([$flankid, $flankstrand]);
					$count_gene-- and next if not defined($flankid);
					$count_gene-- and next if $flankid =~ /^$id2$/i;
					if ($flankend < $start and $flankend > $start-$flanks) {
						$count_flank++;
						push(@{$org{$kogid}{$org}{'flank_start'}}, $arr[0]) if $strand == 1;
						push(@{$org{$kogid}{$org}{'flank_end'}}, $arr[0]) if $strand == -1;
					}
					else {
						$count_no_flank++;
					}
				}
			}

		}
	}
	print "Done\n";
	print "Not having flank: $count_no_flank/$count_gene\nHaving flank: $count_flank/$count_gene\n";
	$orgcache -> set ("orgdbflank_$flanks", \%org);
}

sub process_orgID {
	my %kogid = mitochy::process_kogIDdb();
	my %org;
	my $folder = "/home/mitochi/Desktop/Work/newcegma/ID";
	my @files = <$folder/*.new.ID>;
	
	foreach my $file (@files) {
	
		my ($org) = $file =~ /org.(\w+).ID.new.ID$/i;
		die "process_orgID: ORG not defined (should be in org.ORG.ID.new.ID format)\n" unless defined($org);

		open (my $in, "<", $file) or die "Cannot read from $file: $!\n";
		while (my $line = <$in>) {
			chomp($line);
			next if $line =~ /^"V1"/i;

			$line = uc($line);
			$line =~ s/\"//ig;

			my ($num, $coreid, $id, $chr, $start, $end, $strand) = split(" ", $line);
			die "Format error on ID file at org = $org, file = $file\n" unless defined($strand) and defined($num);
			my $kog;
			foreach my $kogid (sort keys %kogid) {
				$kog = $kogid if $kogid{$kogid}{$org} =~ /^$id$/i;				
			}
			print "WARNING: KOG not found for org $org and ID $id\n" unless defined($kog);
			next unless defined($kog);
			$kog = "NA" if not defined($kog);
			$org{$kog}{$org}{'id'} = $id;
			#print "$kog\t$org\t$org{$kog}{$org}{'id'}\n";

			$org{$kog}{$org}{'chr'} = $chr;
			$org{$kog}{$org}{'start'} = $start;
			$org{$kog}{$org}{'end'} = $end;
			$org{$kog}{$org}{'strand'} = $strand;
		}

		close $in;
	}
	return(%org);
}

sub process_hgskewIDdb {
	my $cache = new Cache::FileCache();
	$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
	

	my $id_folder = "/home/mitochi/Desktop/Work/humanskewgenes/database";
	my @ID_files = <$id_folder/*.ID>;
	my %hggene;
	
	foreach my $ID_file (@ID_files) {
	        my ($org) = $ID_file =~ /hgensembllist.id.(\w+).ID/;
	        print "Fatal: at file $ID_file undefined organism: Invalid file name\n" unless defined($org);
	        open (my $in, "<", $ID_file) or die "Cannot read from file $ID_file\n";
	        while (my $line = <$in>) {
	                chomp($line);
	                next if $line =~ /^\"V1/;
	                $line =~ s/"//ig;
	                my ($num, $hgid, $orgid) = split(" ", $line);
	                $hggene{$hgid}{$org}{'id'} = $orgid;
	        }
	} 
	$cache -> set("hgiddb", \%hggene);
}

sub process_kogIDdb {
	open (my $in, "<", "/home/mitochi/Desktop/Work/newcegma/ID/all.id") or die "process_kogIDdb failed: Cannot read from /home/mitochi/Desktop/Work/newcegma/ID/all.id: $!\n";
	my %id;
	my @org;
	while (my $line = <$in>) {
		chomp($line);

		#header
		next if $line =~ /\#/i;
		my @arr = split("\t", $line);

		#organisms		
		@org = @arr if defined($arr[0]) and $arr[0] =~ />/;
		next if defined($arr[0]) and $arr[0] =~ />/;
		
		#actual genes
		next if $line !~ /KOG/i;
		my $kogid = $arr[0];
		for (my $i = 1; $i < @arr; $i++) {
			die "died at i = $i $line\n" if not defined($org[$i]);
			$id{$kogid}{$org[$i]} = $arr[$i];
		}
	}
	close $in;
	
	return(%id);
}


#Process Perl API for Biomart

sub biomart {
	my ($registryfile, $dataset, $filter, $attribute) = @_;
	#die "usage: $0 <registryname> <dataset> <filter> <attribute>
	#\t- <registryname (metazoa, ensembl)>
	#\t- <dataset (dmojavensis_eg_gene)>
	#\t- <filter (array of ['ensembl_gene_id', ['id1', 'id2'], 'upstream_flank'['1000']])> 
	#\t- <array of attribute [ensembl_gene_id, gene_exon_intron]>\n" 
	#unless @ARGV == 4;	

	$registryfile = "apiMetazoaRegistry.xml" if $registryfile =~ /metazoa/i;
	
	my $confFile = (grep { m/biomart-perl\/lib+$/ } @INC)[0]."/../conf/$registryfile";
	die ("Cant find configuration file $confFile\n") unless (-f $confFile);
	
	#
	# NB: change action to 'cached' if you want 
	# to skip the configuraiton step on subsequent runs
	# from the same registry
	#
	print "action\n";
	my $action='cached';
	my $initializer = BioMart::Initializer->new('registryFile'=>$confFile, 'action'=>$action);
	my $registry = $initializer->getRegistry;
	
	
	
	# you can check for the available filters and attributes here
	# you need to uncomment a print statement in the sub
	&check_available_datasets_filters_attributes($registry);
	
	# or just run your favourite query
	&setup_and_run_query($registry, $dataset, $filter, $attribute);
}
	
sub setup_and_run_query {

    my ($registry, $dataset, $filter, $attribute) = @_;
    my @filter = @{$filter};
    my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');
print "query\n";
print "dataset: $dataset\nattribute: $attribute\n";
$query->setDataset("$dataset");
 
# $query->setDataset("$dataset");
    for (my $i = 0; $i < @filter-1; $i+=2) {
	print "$query->addFilter('$filter[$i]', $filter[$i+1])\n";
        $query->addFilter($filter[$i], $filter[$i+1]);
    }
	$query->addAttribute("$attribute");
    	$query->formatter("FASTA");

    # $query->formatter('HTML'); leave this blank for tab delimited

    my $query_runner = BioMart::QueryRunner->new();
         # to obtain unique rows only
         # $query_runner->uniqueRowsOnly(1);
my $results;
    $query_runner->execute($query);
    #$query_runner->printHeader();
    $results = $query_runner->_getResultTable();
$query_runner->printResults();
    #$query_runner->printFooter();
print "printed: $results\n";
return($results);
}

sub check_available_datasets_filters_attributes {	
    my ($registry) = @_;

    foreach my $schema (@{$registry->getAllVirtualSchemas()}){
        foreach my $mart (@{$schema->getAllMarts()}){
            foreach my $dataset (@{$mart->getAllDatasets()}){
                foreach my $configurationTree (@{$dataset->getAllConfigurationTrees()}){                
                    foreach my $attributeTree (@{$configurationTree->getAllAttributeTrees()}){
                        foreach my $group(@{$attributeTree->getAllAttributeGroups()}){
                            foreach my $collection (@{$group->getAllCollections()}){
                                foreach my $attribute (@{$collection->getAllAttributes()}){
#                                   print "mart: ",$mart->name, 
#                                   "\tdataset: ",$dataset->name,
#                                   "\tattribute: ",$attribute->name,"\n";
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
		
#Process Fasta file into hash
sub process_fasta {
	my ($fh, $mode) = @_;
	open (my $in, "<", $fh) or die "mitochy.pm: cannot read from $fh: $!\n";
	my $fasta = new FAlite($in);
	my %fasta;
	while (my $entry = $fasta -> nextEntry) {
		my $head = uc($entry -> def) if defined($mode);
		$head = $entry -> def if not defined($mode);
		#print "$head\n";
		$fasta{$head}{'seq'} = uc($entry -> seq);
	}
	close $in;
	return(\%fasta);
}

sub process_rmes_table {
	my ($fh) = @_;
	open (my $in, "<", $fh) or die "mitochy.pm: cannot read from $fh: $!\n";
	my %kmer;
	while (my $line = <$in>) {
		chomp($line);
		if ($line =~ /^Results from algorithm/) {
			for (my $i = 0; $i < 8; $i++) {
				$line = <$in>;
			}
			while (1==1) {
				chomp($line);
				my @arr = split(" ",$line);
				my ($word, $count, $expect, $sigma, $score, $rank) = ($arr[0], $arr[2], $arr[4], $arr[6], $arr[8], $arr[10]);		
				my $kmer = length($word);		
				if ($line !~ m/\.\.\.\.\.\./i) {
					die "$line\n$word\n" if not defined ($rank);
					$kmer{$kmer}{$word}{'count'} = $count;
					$kmer{$kmer}{$word}{'expect'} = $expect;
					$kmer{$kmer}{$word}{'sigma'} = $sigma;
					$kmer{$kmer}{$word}{'score'} = $score;
					$kmer{$kmer}{$word}{'rank'} = $rank;
				}

				$line = <$in>;
				next if $line =~ /\.\.\.\.\.\./i;
				
				last if $line =~ /^-----/i;
			}
		}
	}
	return(%kmer);	
}

sub rmes_compare {
	#usage: $0 <rmes_table1.fa> <rmes_table2.fa> <min_kmer [0]> <max_kmer [7]>\n"
	
	my ($fh1, $fh2, $kmer_min, $kmer_max) = @_;
	$kmer_min = 0 if not defined($kmer_min);
	$kmer_max = 7 if not defined($kmer_max);
	
	my %kmer1;
	my %kmer2;
	
	%kmer2 = process_rmes_table($fh2);
	%kmer1 = process_rmes_table($fh1);
	
	print "\#Depleted = RMES table 1 is depleted while RMES table 2 is enriched in this word\n";
	print "\#RMES table 1 = $fh1\n\#RMES table 2= $fh2\n\n";
	print "word\trank1\tscore1\trank2\tscore2\n";
	
	foreach my $kmer (sort {$a <=> $b} keys %kmer1) {
		next unless ($kmer <= $kmer_max and $kmer > $kmer_min);
		foreach my $word (sort {$kmer1{$kmer}{$a}{'rank'} <=> $kmer1{$kmer}{$b}{'rank'}} keys %{$kmer1{$kmer}}) {
			if ($kmer1{$kmer}{$word}{'score'} < -1) {
				#print "$word\t$kmer1{$kmer}{$word}{'rank'}\t$kmer1{$kmer}{$word}{'score'}\t";
				
				if (not exists($kmer2{$kmer}{$word})) {
					print "DEPLETED_NEW1\t$word\t$kmer1{$kmer}{$word}{'rank'}\t$kmer1{$kmer}{$word}{'score'}\n";
				}
				if (exists ($kmer2{$kmer}{$word}) and $kmer2{$kmer}{$word}{'score'} > 0) {
					print "DEPLETED\t$word\t$kmer1{$kmer}{$word}{'rank'}\t$kmer1{$kmer}{$word}{'score'}\t$kmer2{$kmer}{$word}{'rank'}\t$kmer2{$kmer}{$word}{'score'}\n";
				}
			}
			if ($kmer1{$kmer}{$word}{'score'} > 1) {
				if (exists ($kmer2{$kmer}{$word}) and $kmer2{$kmer}{$word}{'score'} < 0) {
					print "ENRICHED\t$word\t$kmer1{$kmer}{$word}{'rank'}\t$kmer1{$kmer}{$word}{'score'}\t$kmer2{$kmer}{$word}{'rank'}\t$kmer2{$kmer}{$word}{'score'}\n";
				}
				if (not exists($kmer2{$kmer}{$word})) {
					print "ENRICHED_NEW1\t$word\t$kmer1{$kmer}{$word}{'rank'}\t$kmer1{$kmer}{$word}{'score'}\n";
				}
			}
		}
	}
	
	foreach my $kmer (sort {$a <=> $b} keys %kmer2) {
		next unless ($kmer <= $kmer_max and $kmer > $kmer_min);
		foreach my $word2 (sort {$kmer2{$kmer}{$a}{'rank'} <=> $kmer2{$kmer}{$b}{'rank'}} keys %{$kmer2{$kmer}}) {
			if (not exists($kmer1{$kmer}{$word2})) {
					print "DEPLETED_NEW2\t$word2\t$kmer2{$kmer}{$word2}{'rank'}\t$kmer2{$kmer}{$word2}{'score'}\n" if $kmer2{$kmer}{$word2}{'score'} < -1;
					print "ENRICHED_NEW2\t$word2\t$kmer2{$kmer}{$word2}{'rank'}\t$kmer2{$kmer}{$word2}{'score'}\n" if $kmer2{$kmer}{$word2}{'score'} > 1;
			}
		}
	}
}

sub split_big_multifasta_genome {
	my ($fh) = @_;
	open (my $in, "<", $fh) or die "mitochy.pm: cannot read from $fh: $!\n";
	my $name;
	my $switch = 0;
	while (my $line = <$in>) {
		chomp($line);
		if ($switch == 1 and defined($name)) {
			open (my $out, ">>", "$fh.$name") or die "Cannot write to $fh.$name: $!\n";
			while ($line !~ m/>/) {
				chomp($line);
				print $out "$line\n";
				$line = <$in>;
				last if not defined($line);
			}
			close $out;
		}
		last if not defined($line);
		if ($line =~ m/>/) {
			($name) = $line =~ />(\w+)/i;
			open (my $out, ">", "$fh.$name") or die "Cannot write to $fh.$name: $!\n";
			chomp($line);
			print $out "$line\n";
			close $out;
			$switch = 1;
		}
	}
}
	
	
sub process_file {
	my ($fh, $sep) = @_;
	die "usage: mitochy.pm::process_file(\$fh, \$sep)\n" unless defined($fh) and defined($sep);
	my %tsv;
	open (my $in, "<", $fh) or die "mitochy.pm: Cannot read from $fh: $!\n";
	my $linecount = 0;
	while (my $line =  <$in>) {
		chomp($line);
		next if $line =~ /\#/;
		@{$tsv{$linecount}} = split("$sep", $line);
	}
	close $in;
	return(\%tsv);
}	
	
sub process_bed {
	my ($fh, $num) = @_;
	#num is how many column to be taken
	
	$num = 3 if not defined($num);
	
	open (my $in, "<", $fh) or die "mitochy.pm: Cannot read from $fh: $!\n";
	my %bed;
	my $linecount;
	my $genecount;
	my $curr_chr = "INIT";
	while (my $line = <$in>) {
		$linecount++;
		chomp($line);
		next if $linecount == 1;
		my @arr = split("\t", $line);
		my ($chr, $start, $end, $name, $value, $strand) = @arr;
		my $locstart = int($start / 100000);
		die "Error: bed 6 format but line is\n$line\n" if $num == 6 and not defined($value) and not defined($strand);
		$genecount++;
		$bed{$chr}{$locstart}{$genecount}{'start'} = $start;
		$bed{$chr}{$locstart}{$genecount}{'end'} = $end;
		if ($num > 3) {
			$bed{$chr}{$locstart}{$genecount}{'name'} = $name;
		}
		if ($num > 4) {
			$bed{$chr}{$locstart}{$genecount}{'value'} = $value;
		}
		if ($num > 5) {
			$bed{$chr}{$locstart}{$genecount}{'strand'} = $strand;
		}
		if ($num > 6) {
			$bed{$chr}{$locstart}{$genecount}{'7'} = $arr[7];
		}
		if ($num > 7) {
			$bed{$chr}{$locstart}{$genecount}{'8'} = $arr[8];
		}
		if ($num > 8) {
			$bed{$chr}{$locstart}{$genecount}{'9'} = $arr[9];
		}
		if ($num > 9) {
			$bed{$chr}{$locstart}{$genecount}{'10'} = $arr[10];
		}
		if ($num > 10) {
			$bed{$chr}{$locstart}{$genecount}{'11'} = $arr[11];
		}
		if ($num > 11) {
			$bed{$chr}{$locstart}{$genecount}{'12'} = $arr[12];
		}
		if ($num > 12) {
			$bed{$chr}{$locstart}{$genecount}{'13'} = $arr[13];
		}
		if ($num > 13) {
			$bed{$chr}{$locstart}{$genecount}{'14'} = $arr[14];
		}
		if ($num > 14) {
			$bed{$chr}{$locstart}{$genecount}{'15'} = $arr[15];
		}
	}
	return(\%bed);
}

#
sub count_nuc {
	my ($seq, $nuc) = @_;
	
	die "usage: count_nuc(seq, nuc)\n" unless defined($nuc);
	my $count_nuc = 0;
	
	my $nuc_window = length($nuc);
	
	while ($seq =~ /$nuc/ig) {
		 $count_nuc++;
	}
	
	return($count_nuc);
}

sub dinuc_window_count {
	my ($sequence, $nuc1, $nuc2, $window_size, $step_size) = @_;
	$window_size = 100 if not defined($window_size);
	$step_size = 1 if not defined($step_size);
	my (@cpg_oe, @skew, @gc);
	my $count = -1;
	for (my $i = 0; $i < length($sequence)-$window_size; $i += $step_size) { # change i to 1 for 1 bp window step
		$count++;

		my $seq_part = substr($sequence, $i, $window_size);
		my ($cpg_count, $nuc1_count, $nuc2_count) = (0, 0, 0);
		
		# Count by Transliterate #
		$nuc1_count = $seq_part =~ tr/A/A/ if $nuc1 =~ /A/;
		$nuc1_count = $seq_part =~ tr/T/T/ if $nuc1 =~ /T/;
		$nuc1_count = $seq_part =~ tr/G/G/ if $nuc1 =~ /G/;
		$nuc1_count = $seq_part =~ tr/C/C/ if $nuc1 =~ /C/;
								
		$nuc2_count = $seq_part =~ tr/A/A/ if $nuc2 =~ /A/;
		$nuc2_count = $seq_part =~ tr/T/T/ if $nuc2 =~ /T/;
		$nuc2_count = $seq_part =~ tr/G/G/ if $nuc2 =~ /G/;
		$nuc2_count = $seq_part =~ tr/C/C/ if $nuc2 =~ /C/;
		
		while ($seq_part =~ /$nuc1$nuc2/g) {
			$cpg_count++;
		}
		#print "$seq_part\n";		
		my $cpg_oe = $nuc1_count*$nuc2_count == 0 ? 0 : $cpg_count/($nuc1_count*$nuc2_count)*$window_size;
		my $equalizer = $nuc2_count > $nuc1_count ? $nuc2_count : $nuc1_count;
		#my $skew = $nuc2_count+$nuc1_count == 0 ? 0 : (($nuc2_count-$nuc1_count)*($equalizer/$window_size))/($nuc2_count+$nuc1_count);
		my $skew = $nuc2_count+$nuc1_count == 0 ? 0 : ($nuc2_count-$nuc1_count)/($nuc2_count+$nuc1_count);
		my $gc = ($nuc2_count+$nuc1_count)/$window_size;
		$cpg_oe[$count] = $cpg_oe;
		$skew[$count] = $skew;
		$gc[$count] = $gc;
		die "fatal at dinuc_window_count mitochy.pm: cpg_oe not defined\n" if not defined($cpg_oe);
		die "fatal at dinuc_window_count mitochy.pm: skew not defined\n" if not defined($skew);
		die "fatal at dinuc_window_count mitochy.pm: gc content not defined\n" if not defined($gc);
		
	}
	return(\@cpg_oe, \@gc, \@skew);
}
sub dinuc_window_count_NA {
	my ($sequence, $nuc1, $nuc2, $window_size, $step_size) = @_;
	$window_size = 100 if not defined($window_size);
	$step_size = 1 if not defined($step_size);
	my (@cpg_oe, @skew, @gc);
	my $count = -1;
	for (my $i = 0; $i < length($sequence)-$window_size; $i += $step_size) { # change i to 1 for 1 bp window step
		$count++;

		my $seq_part = substr($sequence, $i, $window_size);
		my ($cpg_count, $nuc1_count, $nuc2_count) = (0, 0, 0);
		
		# Count by Transliterate #
		$nuc1_count = $seq_part =~ tr/A/A/ if $nuc1 =~ /A/;
		$nuc1_count = $seq_part =~ tr/T/T/ if $nuc1 =~ /T/;
		$nuc1_count = $seq_part =~ tr/G/G/ if $nuc1 =~ /G/;
		$nuc1_count = $seq_part =~ tr/C/C/ if $nuc1 =~ /C/;
								
		$nuc2_count = $seq_part =~ tr/A/A/ if $nuc2 =~ /A/;
		$nuc2_count = $seq_part =~ tr/T/T/ if $nuc2 =~ /T/;
		$nuc2_count = $seq_part =~ tr/G/G/ if $nuc2 =~ /G/;
		$nuc2_count = $seq_part =~ tr/C/C/ if $nuc2 =~ /C/;
		
		while ($seq_part =~ /$nuc1$nuc2/g) {
			$cpg_count++;
		}
		#print "$seq_part\n";		
		my $cpg_oe = $nuc1_count*$nuc2_count == 0 ? 0 : $cpg_count/($nuc1_count*$nuc2_count)*$window_size;
		my $equalizer = $nuc2_count > $nuc1_count ? $nuc2_count : $nuc1_count;
		#my $skew = $nuc2_count+$nuc1_count == 0 ? 0 : (($nuc2_count-$nuc1_count)*($equalizer/$window_size))/($nuc2_count+$nuc1_count);
		my $skew = $nuc2_count+$nuc1_count == 0 ? 0 : ($nuc2_count-$nuc1_count)/($nuc2_count+$nuc1_count);
		my $gc = ($nuc2_count+$nuc1_count)/$window_size;
		$cpg_oe[$count] = $seq_part =~ /^[Nn]+$/ ? "NA" : $cpg_oe;
		$skew[$count] = $seq_part =~ /^[Nn]+$/ ? "NA" : $skew;
		$gc[$count] = $seq_part =~ /^[Nn]+$/ ? "NA" : $gc;
		die "fatal at dinuc_window_count mitochy.pm: cpg_oe not defined\n" if not defined($cpg_oe);
		die "fatal at dinuc_window_count mitochy.pm: skew not defined\n" if not defined($skew);
		die "fatal at dinuc_window_count mitochy.pm: gc content not defined\n" if not defined($gc);
		
	}
	return(\@cpg_oe, \@gc, \@skew);
}
sub trinuc_chh_count {
	my ($sequence, $window_size, $step_size, @nuc) = @_;
	$window_size = 100 if not defined($window_size);
	$step_size = 1 if not defined($step_size);
	my $count = -1;
	my %count;
	for (my $i = 0; $i < length($sequence)-$window_size; $i += $step_size) { # change i to 1 for 1 bp window step
		$count++;

		my $seq_part = substr($sequence, $i, $window_size);
		my $cpg_count = 0;
		
		# Count by Transliterate #
		my ($An, $Tn, $Gn, $Cn) = (0,0,0,0);
		$An = $seq_part =~ tr/A/A/;
		$Tn = $seq_part =~ tr/T/T/;
		$Gn = $seq_part =~ tr/G/G/;
		$Cn = $seq_part =~ tr/C/C/;		
		foreach my $nuc (@nuc) {
			my @denom = split("", $nuc);
			my $denomT = 1;
			foreach my $denom (@denom) {
				my $denomcount = 0;
				$denomcount = $An if $denom eq "A";
				$denomcount = $Tn if $denom eq "T";
				$denomcount = $Gn if $denom eq "G";
				$denomcount = $Cn if $denom eq "C";
				$denomT *= $denomcount;
			}
			$count{$nuc}{dens}[$count] = 0 if $denomT == 0;
			next if $denomT == 0;
			
			while ($seq_part =~ /$nuc/g){
				$count{$nuc}{curr}++;
			}
			$count{$nuc}{curr} = 0 if not defined($count{$nuc}{curr});
			$count{$nuc}{dens}[$count] = ($count{$nuc}{curr} * $window_size**2) / $denomT;
			$count{$nuc}{curr} = 0;
		}
	}
	return(\%count);
}

sub getFilename {
        my ($fh, $type) = @_;
        my (@splitname) = split("\/", $fh);
        my $name = $splitname[@splitname-1];
	my @tempfolder = pop(@splitname);
        my $folder = join("\/", @tempfolder);
        @splitname = split(/\./, $name);
        $name = $splitname[0];
        return($name) if not defined($type);
        return($folder, $name) if defined($type);
}

sub smithwater {
	my ($seq_ref, $seq_que) = @_;
	die "smithwater: seq_ref not defined!\n" if not defined($seq_ref);
	die "smithwater: seq_que not defined!\n" if not defined($seq_que);
	
	# Check if sequence has ANY similarity at all or not #
	my ($A1, $A2, $T1, $T2, $G1, $G2, $C1, $C2) = (0,0,0,0,0,0,0,0);
	$A1 = $seq_ref =~ tr/A/A/; $A2 = $seq_que =~ tr/A/A/;
	$T1 = $seq_ref =~ tr/T/T/; $T2 = $seq_que =~ tr/T/T/;
	$G1 = $seq_ref =~ tr/G/G/; $G2 = $seq_que =~ tr/G/G/;
	$C1 = $seq_ref =~ tr/C/C/; $C2 = $seq_que =~ tr/C/C/;
	
	
	if ($A1 == 0 or $A2 == 0) {
		if ($T1 == 0 or $T2 == 0) {
			if ($G1 == 0 or $G2 == 0) {
				if ($C1 == 0 or $C2 == 0) {
					die "Sequence has 0 similarity\n\ntotal score = 0\nnormalized score = 0\n";
				}
			}
		}
	}
	
	my %seq_ref = array2hash(split("",$seq_ref));
	my %seq_que = array2hash(split("",$seq_que));
	
	my %matchtable;
	for (my $i = 0; $i < (keys %seq_ref)+1; $i++) {
		for (my $j = 0; $j < (keys %seq_que)+1; $j++) {
			$matchtable{$i}{$j} = 0 if ($i == 0 or $j == 0);
		}
	}
	
	#fill table
	my @biggest_score = (0,0,0);
	for (my $i = 0; $i < (keys %seq_ref)+1; $i++) {
		for (my $j = 0; $j < (keys %seq_que)+1; $j++) {			

			if ($i != 0 and $j != 0) {
				my $match_dia;
				if ($seq_ref{$i} =~ /^$seq_que{$j}$/i) {$match_dia = $matchtable{$i-1}{$j-1} + 1}
				else {
					if ($seq_ref{$i} =~ /[ag]/i and $seq_que{$j} =~ /r/i) {$match_dia = $matchtable{$i-1}{$j-1}-0.5}
					elsif ($seq_ref{$i} =~ /[ct]/i and $seq_que{$j} =~ /y/i) {$match_dia = $matchtable{$i-1}{$j-1}-0.5}
					else {$match_dia = $matchtable{$i-1}{$j-1} - 1}
				}

				my $indel_hor = $matchtable{$i-1}{$j} - 2 < 0 ? 0 : $matchtable{$i-1}{$j} - 2;
				my $indel_ver = $matchtable{$i}{$j-1} - 2 < 0 ? 0 : $matchtable{$i}{$j-1} - 2;
				my @biggest = sort {$b <=> $a} ($match_dia, $indel_hor, $indel_ver);
				$matchtable{$i}{$j} = $biggest[0];
				@biggest_score = ($i, $j, $biggest[0]) if $biggest_score[2] < $biggest[0];
			}
			#print "$matchtable{$i}{$j}\t";
		}
		#print "\n";
	}
	
	#traceback
	my $totalscore = 0;
	#my $hor = keys(%seq_que);
	#my $ver;
	
	#foreach my $ver_tmp (sort {$b <=> $a} keys %matchtable) {
	#	print "$matchtable{$ver_tmp}{$hor}\n";
	#}
	
	#die;
	
	my ($ver, $hor) = @biggest_score;
	#print "\#$ver\t$hor\t$biggest_score[2]\n";
	my $seq_ref_out = $seq_ref{$ver};
	my $seq_que_out = $seq_que{$hor};
	my $seq_match;
	if ($seq_ref_out =~ m/$seq_que_out/i) {$seq_match = "*"}
	elsif ($seq_ref_out =~ /[ag]/i and $seq_que_out =~ /r/i) {$seq_match = "."}
	elsif ($seq_ref_out =~ /[tc]/i and $seq_que_out =~ /y/i) {$seq_match = "."}
	else {$seq_match = " "}

	while ($ver != 1 and $hor != 1) {
		my $d_score = $matchtable{$ver-1}{$hor-1};
		my $h_score = $matchtable{$ver}{$hor-1};
		my $v_score = $matchtable{$ver-1}{$hor};
		if ($d_score >= $h_score and $d_score >= $v_score) {
			$ver-- and $hor--;
			$seq_ref_out .= $seq_ref{$ver};
			$seq_que_out .= $seq_que{$hor};
			if ($seq_ref{$ver} =~ m/$seq_que{$hor}/i) {$seq_match .= "*"}
			elsif ($seq_ref{$ver} =~ /[ag]/i and $seq_que{$hor} =~ /r/i) {$seq_match .= "."}
			elsif ($seq_ref{$ver} =~ /[tc]/i and $seq_que{$hor} =~ /y/i) {$seq_match .= "."}
			else {$seq_match .= " "}
			#print "$seq_ref{$ver} = $seq_que{$hor}\n" if $seq_ref{$ver} =~ m/$seq_que{$hor}/i;
			$totalscore += $d_score;
		
		}
		elsif ($h_score > $d_score and $h_score >= $v_score) {
			$hor--;
			$seq_que_out .= "-";
			$seq_ref_out .= $seq_ref{$ver};
			$seq_match .= " ";
			$totalscore += $h_score;
		}
		elsif ($v_score > $d_score and $v_score > $h_score) {
			$ver--;
			$seq_que_out .= $seq_que{$hor};
			$seq_ref_out .= "-";
			$seq_match .= " ";			
			$totalscore += $v_score;
		}
		else {print "WARNING: SOMETHING WRONG AT THIS SEQ!\n";}
	}
	$seq_ref_out = reverse($seq_ref_out);
	$seq_que_out = reverse($seq_que_out);
	$seq_match = reverse($seq_match);
	my $normalized_score = $totalscore/length($seq_que);
	my $lengthref = length($seq_ref);
	my $lengthque = length($seq_que);
	#print "$seq_ref_out ($lengthref)\n$seq_que_out ($lengthque)\n$seq_match\ntotal score = $totalscore\nnormalized score = $normalized_score\n";
	my %res;
	$res{score} = $totalscore;
	$res{nscore} = $normalized_score;
	$res{ref} = $ver;
	$res{motif} = $hor;
	my $ref_out = $seq_ref_out;
	$ref_out  =~ s/\-//ig;
	$res{refout} = $ref_out;
	die if not defined($res{refout});
	return(\%res);
}

sub define_alu {
	my $alu = "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACGAGGTCAGGAGATCGAGACCATCCCGGCTAAAACGGTGAAACCCCGTCTCTACTAAAAATACAAAAAATTAGCCGGGCGTAGTGGCGGGCGCCTGTAGTCCCAGCTACTTGGGAGGCTGAGGCAGGAGAATGGCGTGAACCCGGGAGGCGGAGCTTGCAGTGAGCCGAGATCCCGCCACTGCACTCCAGCCTGGGCGACAGAGCGAGACTCCGTCTC";
	return($alu);
}

sub count_alu {
	my ($seq) = @_;
	return(count_nuc($seq, define_alu()));
}

sub array2hash {
	my @array = @_;
	my %hash;
	for (my $i = 0; $i < @array; $i++) {
		$hash{$i+1} = $array[$i];
	}
	return(%hash);
}

sub arrayseq {
	my ($start, $end, $step_size) = @_;
	my @array;
	for (my $i = 0; $i < $end-$start; $i+=$step_size) {
		$array[$i] = $start+$i;
	}
	return(@array);
}

sub twodec {
	my ($number0) = @_;
	my ($number) = $number0 == 0 ? 0 : $number0 =~ m/^(-*\d+.\d\d)/i;
	die "number = $number0\n" if not defined($number);
	return($number);
}

sub revcomp {
	my ($sequence) = @_;
	$sequence = uc($sequence);
	$sequence =~ tr/[ATGC]/[TACG]/;
	$sequence = reverse($sequence);
	return ($sequence);
}


sub within {
	my ($coor1, $coor2, $coorq) = @_;
	return(1) if ($coor1 <= $coorq and $coor2 > $coorq); # in between coor2 and 1
	return(1) if ($coor1 >= $coorq and $coor2 < $coorq); # in between coor1 and coor2
	
	return(0);
}	

sub between {
        my ($start1, $end1, $start2, $end2) = @_;
        return 1 if $start1 >= $start2 and $start1 <= $end2;
        return 1 if $start2 >= $start1 and $start2 <= $end1;
        return 0;
}

sub swap {
	my ($small, $big) = @_;
	return($small, $big) if $small <= $big;
	return($big, $small) if $small > $big;
}	
sub R_array {
	my ($array, $var, $mode, $step_size) = @_;
	
	$step_size = 1 if not defined($step_size);
	my @array = @{$array};
	my $Rscript;
	
	$Rscript .= "$var <- c(";
	
	if (defined($mode) and $mode =~ /with_quote/i) {
		for (my $i = 0; $i < @array; $i+=$step_size) {
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
1;

sub markov {
	my ($seq, $test_seq, $markov) = @_;
	die "usage: markov(seq, test_seq, markov_num)\n" if (not defined($test_seq) or not defined($markov));
	my $length = length($test_seq);
	die "markov number ($markov) must be smaller than test sequence ($length)\n" if $markov >= length($test_seq); 

	print "using default markov = 0\n" if not defined($markov);
	$markov = 0 if not defined($markov);
	my @test_seq = split("", $test_seq);
	
	my ($top, $bot) = (1,1);
	
	for (my $i = 0; $i < @test_seq-$markov; $i++) {
		my ($topseq, $botseq);
		for (my $j = $i; $j <= $i+$markov; $j++) {
			$topseq .= $test_seq[$j];
			$botseq .= $test_seq[$j] unless $j == $i;
		}
		$top *= mitochy::count_nuc($seq, $topseq);
		$bot *= mitochy::count_nuc($seq, $botseq) if $i > 0 and $markov > 0;
		$bot *= length($seq) if $i > 0 and $markov == 0;
	}
	#$bot == 0 ? printf "Markov $markov exp for $test_seq: 0.00\n" : printf "Markov $markov exp for $test_seq: %.2f\n", $top/$bot;
	$bot == 0 ? return(0) : return($top/$bot);
}

sub permutation_nuc {
	my ($kmer, $nc) = @_;
	die "usage: permutation_nuc(kmer, nuc)\n" unless defined($kmer);
	print "using default nuc: ATGC\n" unless defined($nc);
	$nc = "ATGC" unless defined($nc);
	my @nuc = split("", $nc);
	
	#initialize position array
	my @pos;
	for (my $i = 0; $i < $kmer; $i++) {
		$pos[$i] = 0;
	}
	
	my @final;
	#There will be @nuc**$kmer possible combination
	for (my $i = 0; $i < @nuc**$kmer; $i++) {
		my $nuc;
		
		#For each my nucleotide in the kmer
		for (my $j = 0; $j < $kmer; $j++) {
			if ($j == 0) {
				$nuc = $nuc[$pos[0]];
				$pos[0]++;
			}
			if ($j > 0) {
				#if current pos is @nuc, then reset to 0
				$pos[$j] = 0 if $pos[$j] == @nuc;
				
				$nuc .= $nuc[$pos[$j]];
				
				#if last position is @nuc, then pos ++ and reset last position to 0
				($pos[$j]++ and $pos[$j-1] = 0) if $pos[$j-1] == @nuc;
				
				#reset first position to 0 whenever it's @nuc
				$pos[0] = 0 if $pos[0] == @nuc;
			}
		}
		push(@final, $nuc);
	}
	return(@final);
}

sub scramble {
	my ($seq) = @_;
	my @seq = split("",$seq);
	for (my $i = 0; $i < 5000; $i++) {
		my ($rand1, $rand2) = (int(rand()*length($seq)), int(rand()*length($seq)));
		my $one = $seq[$rand1];
		my $two = $seq[$rand2];
		$seq[$rand1] = $two;
		$seq[$rand2] = $one;
	}
	#print "prev seq = $seq\n";
	#my $newseq = join("",@seq);
	#print "new seq = $newseq\n";
	return(join("",@seq));
}

sub rmes_concatenante {
	my ($fh) = @_;
	die "usage: (input.fa)\n" unless defined($fh);
	
	open (my $in, "<", $fh) or die "Cannot open $fh: $!\n";
	open (my $out, ">", "$fh.out.fa") or die "Cannot write into $fh.out.fa: $!\n";
	
	my $fasta_file = new FAlite($in); 
	print $out ">$fh\n";
	while (my $entry = $fasta_file -> nextEntry) {
	my $hd = $entry -> def;
	my $sq = $entry -> seq;
	if ($hd =~ /strand=-/) {
		$sq = mitochy::revcomp($sq);
	}
	print $out "$sq";
	print $out "Z";
}
close $in;
}

sub R_biomart_getexon {
	my ($org, $id) = @_;
	my @id = @{$id};
	foreach my $id (@id) {
		$id = "\"$id\"" if $id !~ /"/i;
	}
	my ($ensembl_dataset, $mart);
	my $R_id = mitochy::R_array(\@id, "$org.id");

	#dataset
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "fungi_mart_17") if grep(/$org/, get_biomart_dataset("fungi"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "protists_mart_17") if grep(/$org/, get_biomart_dataset("protists"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "metazoa_mart_17") if grep(/$org/, get_biomart_dataset("metazoa"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "plants_mart_17") if grep(/$org/, get_biomart_dataset("plants"));
	($ensembl_dataset, $mart) = ("$org\_gene_ensembl", "ensembl") if grep(/$org/, get_biomart_dataset("main"));
	
	my $R_biomart = "
	library(biomaRt)
	$org.mart <- useMart(\"$mart\", dataset = \"$ensembl_dataset\")
	$R_id
	$org.exontable <- getBM(mart = $org.mart, attributes = c(\"ensembl_gene_id\", \"ensembl_transcript_id\", \"exon_chrom_start\", \"exon_chrom_end\", \"strand\", \"chromosome_name\"), filters = \"ensembl_gene_id\", values = $org.id)
	write.table($org.exontable, \".\/$org.table.txt\")
	";

	open (my $out, ">", ".\/$org.table.R") or die "Cannot write to output: $!\n";
	print $out "$R_biomart";
	close $out;

	my $Rthis = "R --vanilla --no-save < .\/$org.table.R";
	print "$Rthis\n";
	system($Rthis) == 0 or print "Failed to run $org.table.R\n";
}

sub R_biomart_getdataset {
	my ($org) = @_;
	my ($ensembl_dataset, $mart);

	#dataset
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "fungi_mart_17") if grep(/$org/, get_biomart_dataset("fungi"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "protists_mart_17") if grep(/$org/, get_biomart_dataset("protists"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "metazoa_mart_17") if grep(/$org/, get_biomart_dataset("metazoa"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "plants_mart_17") if grep(/$org/, get_biomart_dataset("plants"));
	($ensembl_dataset, $mart) = ("$org\_gene_ensembl", "ensembl") if grep(/$org/, get_biomart_dataset("ensembl"));
	my $R_biomart = "
	$org.mart <- useMart(\"$mart\", dataset = \"$ensembl_dataset\")
	";
	return($R_biomart);
}
sub R_biomart_getflankgenes {
	my ($org, $chr, $start, $end, $flank) = @_;

	my $R_biomart = "
	$chr
	$start
	$end
	$org.geneflank <- getBM(mart=$org.mart, attributes = c(\"ensembl_gene_id\", \"chromosome_name\", \"start_position\", \"end_position\", \"strand\"), filters=c(\"chromosome_name\", \"start\", \"end\"), values = list($org.chr, $org.start, $org.end))
	write.table($org.geneflank, \"$org.table.geneflank.$flank.txt\")
	";

	return($R_biomart);
}

sub R_biomart_get {
	my ($org, $id, $query, $tablename, $flank) = @_;
	# query are: gene_flank, gene_exon_intron, etc
	my @id = @{$id};
	foreach my $id (@id) {
		$id = "\"$id\"" if $id !~ /"/i;
	}
	my ($ensembl_dataset, $mart);
	my $R_id = mitochy::R_array(\@id, "$org.id");
	#dataset
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "fungi_mart_14") if grep(/$org/, get_biomart_dataset("fungi"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "protists_mart_14") if grep(/$org/, get_biomart_dataset("protists"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "metazoa_mart_14") if grep(/$org/, get_biomart_dataset("metazoa"));
	($ensembl_dataset, $mart) = ("$org\_eg_gene", "plants_mart_14") if grep(/$org/, get_biomart_dataset("plants"));
	($ensembl_dataset, $mart) = ("$org\_gene_ensembl", "ensembl") if grep(/$org/, get_biomart_dataset("ensembl"));
	my $mart_type = $mart =~ /ensembl/ ? "gene_ensembl" : "eg_gene";
	my $R_biomart;
	$R_biomart .= "
	library(biomaRt)
	$R_id
	$org.mart <- useMart(\"$mart\", dataset = \"$ensembl_dataset\")
	$org.gettable <- getBM(mart = $org.mart, attributes = c(\"ensembl_transcript_id\", \"$query\", \"strand\"), filters = \"ensembl_transcript_id\", values = $org.id)
	" if not defined($flank);
	
	if (defined($flank)) {
		$R_biomart .= "

		library(biomaRt)
		$R_id
		$org.mart <- useMart(\"$mart\", dataset = \"$org\_gene_ensembl\")

		$org.getflank <- getBM(mart = $org.mart, attributes = c(\"ensembl_transcript_id\", \"gene_flank\", \"strand\"), checkFilters=FALSE, filters = c(\"ensembl_transcript_id\", \"upstream_flank\") , values = list($org.id, $flank))
		" if $flank >= 0;

		my $newflank = 0 - $flank if $flank < 0;
		$R_biomart .= "
		library(biomaRt)
		$R_id
		$org.mart <- useMart(\"$mart\", dataset = \"$org\_gene_ensembl\")

		$org.getflank <- getBM(mart = $org.mart, attributes = c(\"ensembl_transcript_id\", \"gene_flank\", \"strand\"), checkFilters=FALSE, filters = c(\"ensembl_transcript_id\", \"downstream_flank\") , values = list($org.id, $newflank))
		" if $flank < 0;

	}


	$R_biomart .= "
	write.table($org.gettable, \"$tablename.$query.0_flanktxt\")
	" if not defined($flank);

	$R_biomart .= "
	write.table($org.getflank, \"$tablename.$query.$flank\_flank.txt\")
	" if defined($flank);

	#$flank = 0 if not defined($flank);
	return($R_biomart);
	#open (my $out, ">", ".\/$org.table.$query.$flank\_flank.R") or die "Cannot write to output: $!\n";
	#print $out "$R_biomart";
	#close $out;

	#my $Rthis = "R --vanilla --no-save < .\/$org.table.$query.$flank\_flank.R";
	#print "$Rthis\n";
	#return($Rthis);
}


#Processing Dataset
sub get_biomart_dataset {
	my @martlist = qw(ensembl metazoa fungi plants protists);
	my ($mart) = @_;
	die "usage: mart = ensembl, metazoa, fungi, plants, protists\n" if not grep(/^$mart$/, @martlist); 
	
	my @datasets;
	my $dataset = "/home/mitochi/Desktop/Work/Codes/dataset/ensembl_datasets_$mart.dat";
	open (my $in, "<", $dataset) or die "Dataset process error: Cannot read from $dataset: $!\n";
	while (my $line = <$in>) {
		chomp($line);
		my @arr = split("\t", $line);
		push(@datasets, $arr[1]);
	
	}
	close $in;
	return(@datasets);
}

sub max_pars {
	my ($seq1, $seq2) = @_;
	my @seq1 = split("", $seq1);
	my @seq2 = split("", $seq2);
	
	my $count;
	for (my $i = 0; $i < @seq1; $i++) {
		$count++ if $seq1[$i] !~ /$seq2[$i]/i;
	}
	return($count);
}

#sub is_curve {



#}
sub is_linear {
	my @numbers = @_;
	my ($sum_x, $sum_y, $sum_xy, $sum_x2, $sum_y2) = (0,0,0,0,0);
	for (my $i = 0; $i < @numbers; $i++) {
		$sum_x += $i;
		$sum_y += $numbers[$i];
		$sum_xy += ($i*$numbers[$i]);
		$sum_x2 += $i**2;
		$sum_y2 += $numbers[$i]**2;
	}
	my $a_val = (($sum_y*$sum_x2)-($sum_x*$sum_xy))/(@numbers*($sum_x2)-($sum_x)**2);
	
	my $b_val = ((@numbers*$sum_xy)-($sum_x*$sum_y))/((@numbers*$sum_x2)-($sum_x)**2);
	
	#equation:
	#y = $a_val + $b_val *x;
	my $mean = ($sum_y/@numbers);
	my ($SStot, $SSerr) = (0,0);
	for (my $i = 0; $i < @numbers; $i++) {
		$SStot += ($numbers[$i] - $mean)**2;
		$SSerr += ($numbers[$i] - ($a_val + $b_val*$i))**2;
	}
	
	my $R2 = 1 - ($SSerr/$SStot);
	#print "R2\n";
	return($R2, $a_val, $b_val);
}


sub expval {
	my @num = @_;
	my $exp;
	for (my $i = 0; $i < @num; $i++) {
		$exp += $num[$i] * (1/@num);
	}
	
	return($exp);
}
	
sub square {
	my @num = @_;
	for (my $i = 0; $i < @num; $i++) {
		$num[$i] = $num[$i]**2;
	}
	return(@num);
}

sub var {
	my @num = @_;
	my @num2 = square(@num);	
	my $expval = expval(@num);
	my $expval2 = expval(@num2);
	return($expval2 - ($expval)**2);

}
sub var_sample {
	my @num = @_;
	my $n = @num;
	my $mean = expval(@num);
	my $sum = 0;
	for (my $i = 0; $i < @num; $i++) {
		$sum += ($num[$i]-$mean)**2;
	}
	return($sum/($n-1));
}

sub translate {
        my ($seq, $start) = @_;
 
	my %Translation = (
        'AAA' => 'K', 'AAC' => 'N', 'AAG' => 'K', 'AAT' => 'N',
        'ACA' => 'T', 'ACC' => 'T', 'ACG' => 'T', 'ACT' => 'T',
        'AGA' => 'R', 'AGC' => 'S', 'AGG' => 'R', 'AGT' => 'S',
        'ATA' => 'I', 'ATC' => 'I', 'ATG' => 'M', 'ATT' => 'I',
        'CAA' => 'Q', 'CAC' => 'H', 'CAG' => 'Q', 'CAT' => 'H',
        'CCA' => 'P', 'CCC' => 'P', 'CCG' => 'P', 'CCT' => 'P',
        'CGA' => 'R', 'CGC' => 'R', 'CGG' => 'R', 'CGT' => 'R',
        'CTA' => 'L', 'CTC' => 'L', 'CTG' => 'L', 'CTT' => 'L',
        'GAA' => 'E', 'GAC' => 'D', 'GAG' => 'E', 'GAT' => 'D',
        'GCA' => 'A', 'GCC' => 'A', 'GCG' => 'A', 'GCT' => 'A',
        'GGA' => 'G', 'GGC' => 'G', 'GGG' => 'G', 'GGT' => 'G',
        'GTA' => 'V', 'GTC' => 'V', 'GTG' => 'V', 'GTT' => 'V',
        'TAA' => '*', 'TAC' => 'Y', 'TAG' => '*', 'TAT' => 'Y',
        'TCA' => 'S', 'TCC' => 'S', 'TCG' => 'S', 'TCT' => 'S',
        'TGA' => '*', 'TGC' => 'C', 'TGG' => 'W', 'TGT' => 'C',
        'TTA' => 'L', 'TTC' => 'F', 'TTG' => 'L', 'TTT' => 'F'
	);       
        my $trans = "";
        for (my $i = $start; $i < length($seq); $i+=3) {
                my $codon = substr($seq, $i, 3);
                last if length($codon) < 3;
                if (not exists $Translation{$codon}) {$trans .= '0'}
                else                                 {$trans .= $Translation{$codon}}
        }
        return $trans;
}
sub ave {
	my @num = @_;
	my $ave = 0;
	foreach my $num (@num) {
		$ave += $num;
	}
	return($ave/@num);
}

sub process_bsseqdb {
	my $folder = "/home/mitochi/Desktop/Work/newcegma/bsseq";
	my @files = <$folder/*.bsseq>;
	my %bsq;

	foreach my $file (@files) {
		my ($org, $chr) = $file =~ /gene_(\w+)_(.+).bsseq/i;
		print "Org $org or Chr $chr not defined\n" unless defined($org) and defined($chr);
		open (my $in, "<", $file) or die "Cannot read from $file: $!\n";
		while (my $line = <$in>) {
			chomp($line);
			next if $line =~ /^KOGID/;
			my ($kogid, $org, $id, $start, $current, $end, $chr, $gene_strand, $type, $strand, $score) = split("\t", $line);
			#print "KOGID $kogid ORG $org START $start CURR $current END $end CHR $chr GENE_STRAND $gene_strand TYPE $type STRAND $strand SCORE $score\n";
			
			$bsq{$kogid}{$org}{'bsseq'}{$current-$start}{'score'} = $score;
			$bsq{$kogid}{$org}{'bsseq'}{$current-$start}{'strand'} = $strand;
			$bsq{$kogid}{$org}{'bsseq'}{$current-$start}{'type'} = $type;
		}
		close $in;
		
	}

	return(\%bsq);
}

sub process_exondb {
	my $folder = "/home/mitochi/Desktop/Work/newcegma/exon";
	my %exon;
	my @files = <$folder/*.txt>;

	foreach my $file (@files) {
		my ($org) = $file =~ /\/(\w+)\.table\.exon\.txt$/i;
		print "Processing org $org at $file\n";
		open (my $in, "<", $file) or die "Cannot read from file $file: $!\n";
		my $i = 0;
		my $current = 0;
		while (my $line = <$in>) {
			chomp($line);
			next if $line =~ /ensembl_gene_id/;
			$line =~ s/"//ig;
			$line = uc($line);
			my ($num, $id, $tid, $start, $end, $strand, $chr) = split(" ", $line);
			#print "NUM $num ID $id TID $id START $start END $end STRAND $strand CHR $chr\n";
			$i = 0 if $current !~ /$tid/i;
			$i++ if defined($exon{$id}{'tid'}{$tid});
			#print "I $i START $start END $end\n";
			$exon{$id}{'tid'}{$tid}[$i]{'start'} = $start;
			$exon{$id}{'tid'}{$tid}[$i]{'end'} = $end;
			$exon{$id}{'chr'} = $chr;
			$exon{$id}{'strand'} = $strand;
			die "at $org start undefined\n" if not defined($start) or not defined($end);
			$current = $tid;
		}
		close $in;
		print "Done\n";
		
	}
	
	my $cache = new Cache::FileCache();
	$cache -> set_cache_root("/home/mitochi/Desktop/Cache");
	$cache -> set("exondb", \%exon);
	
	foreach my $id (sort keys %exon) {
		foreach my $tid (sort keys %{$exon{$id}{'tid'}}) {
			my $chr = $exon{$id}{'chr'};
			my $strand = $exon{$id}{'strand'};
			my $num_of_exon = @{$exon{$id}{'tid'}{$tid}};
			next if $num_of_exon > 1;
			for (my $i = 0; $i < @{$exon{$id}{'tid'}{$tid}}; $i++) {
				my $start = $exon{$id}{'tid'}{$tid}[$i]{'start'};
				my $end = $exon{$id}{'tid'}{$tid}[$i]{'end'};
				print "at ID $id CHR $chr STRAND $strand exon number $i, start = $start end = $end\n";
			}
		}
	}



}

sub process_humanskewgenesdb {
	my $file = "/home/mitochi/Desktop/Work/humanskewgenes/humanskewgenes.id";
	open (my $in, "<", $file) or die "Cannot read from $file: $!\n";
	my %gene;
	while (my $line = <$in>) {
		chomp($line);
		next if $line =~ /^\#/;
		$line = uc($line);
		my ($strong, $weak, $no, $reverse) = split("\t", $line);
		push(@{$gene{'strong'}}, $strong) if $strong =~ /.{2,9999}/;
		push(@{$gene{'reverse'}}, $reverse) if $reverse =~ /.{2,9999}/;
		push(@{$gene{'no'}}, $no) if $no =~ /.{2,9999}/;
		push(@{$gene{'weak'}}, $weak) if $weak =~ /.{2,9999}/;
	}
	my $cache = new Cache::FileCache();
	$cache -> set("humanskewgenesdb", \%gene);
	close $in;
}

sub position_weight_entropy {
	my @seq = @_;
	my @pwe;
	for (my $i = 0; $i < @seq; $i++) {
		for (my $j = 0; $j < length($seq[$i]); $j++) {
			my $nuc = substr($seq[$i], $j, 1);
			$pwe[$i]{nuc}{$nuc}++;
			$pwe[$i]{tot}++;
		}
	}

	for (my $i = 0; $i < @pwe; $i++) {
		foreach my $nuc (sort {$pwe[$i]{nuc}{$b} <=> $pwe[$i]{nuc}{$a}} keys %{$pwe[$i]}) {
			$pwe[$i]{nuc}{$nuc} /= $pwe[$i]{tot};
			$pwe[$i]{ent}{$nuc} = -1 * $pwe[$i]{nuc}{$nuc} * (log($pwe[$i]{nuc}{$nuc}) / log(2));
		}
	}
	return(\@pwe);
}

sub process_tsv {
	# takes a tsv file, that takes an input file
	# skip certain syntax that are not needed
	# has option to take out certain column
	# return a hash of tsv file

	my ($input) 	= @_;
	my %parameters 	= %{$input};
	my @skip 	= @{$parameters{skip}};
	my @input 	= @{$parameters{input}};
	my @col 	= @{$parameters{col}};

	my %output;

	# Process each input
	for (my $i = 0; $i < @input; $i++) {
		open (my $in, "<", $input[$i]) or die "Cannot read from $input[$i]: $!\n";
		my $line_number = 0;
		while (my $line = <$in>) {
			chomp($line);
			my $check = 0;
			foreach my $skip (@skip) {
				$check = 1 if $line =~ /$skip/i;
			}
			next if $check == 1;

			my @array = split("\t", $line);
			for (my $j = 0; $j < @array; $j++) {
				if (not grep(/^all$/i, @col)) {next if grep(/^$j$/i, @col);}
				$output{$i}{$line_number}{$j} = $array[$j];
			}
			$line_number++;
		}
	}
	return(\%output)
}


__END__
sub intersect_name {
	my ($input1, $input2) = @_;

	open (my $in1, "<", $input1) or die "Cannot read from $input1: $!\n";
	open (my $in2, "<", $input1) or die "Cannot read from $input2: $!\n";

	my @input1 = chomp(<$in1>);
	my @input2 = chomp(<$in2>);
	foreach my $inp1 (@input1) {
		print "$inp1\n";die;
		print "$inp1 not in input 2\n" if not grep(/^$inp1$/i, @input2);
	}

}

Phylogenetic Independent Contrast (PIC) analysis
O-U model
Bicawnian Motion model
Phylgenetic Comparison Method
Define states (can be continuous or discreete)
Then check which one fit best, with or without selection

sub prob {
	my ($init_prob, $win_max, $win_min, $exp_pvalue) = @_;	
	my $prob = 1-(1-(0.25**$init_prob))**($win_max - $win_min);
	$init_prob = $prob/$exp_pvalue < 2 ? 2 : $prob/$exp_pvalue;
	return($init_prob);
}
V
V

	@{$org{'Chromalveolate_Oomycete'}} = qw(alaibachii pultimum pinfestans psojae harabidopsidis pramorum);
	@{$org{'Chromalveolate_Apicomplexa'}} = qw(pvivax tgondii pfalciparum pberghei pchabaudi pknowlesi);
	@{$org{'Chromalveolate_Heterokontophyta'}} = qw(ptricornutum tpseudonana);
	@{$org{'Chromalveolate_Ciliophora'}} = qw(tthermophila);
	@{$org{'Excavate'}} = qw(lmajor tbrucei glamblia);
	@{$org{'Amoebozoa'}} = qw(ddiscoideum ehistolytica);
	#@{$org{'protistsC'}} = qw(tthermophila); #Tetrahymena/prrotozoa
	#@{$org{'protistsD'}} = qw(creinhardtii);
	@{$org{'Rhodophyta'}} = qw(cmerolae creinhardtii);
	@{$org{'Chlorophyta'}} = qw(creinhardtii);
        @{$org{'fungi_Mold'}} = qw(ptriticina aclavatus tmelanosporum umaydis aniger gzeae aoryzae aterreus afumigatus afumigatusa1163 agossypiitmelanosporum ggraminis mgraminicola mpoae pnodorum aflavus anidulans foxysporum moryzae ncrassa nhaematococca pgraminis);
	#aclavatus afumigatusa1163 afumigatus agossypii aniger oryzae aterreus bfuckeliana gmoniliformis gzeae nfischeri pgraminis ptriticina ssclerotiorum umaydis;
        @{$org{'fungi_Yeast'}} = qw(scerevisiae spombe agossypii);
        #@{$org{'plantsA'}} = qw(bdistachyon brapa oglaberrima oindica obrachyantha osativa sbicolor sitalica zmays);
        #@{$org{'plantsB'}} = qw(alyrata athaliana gmax ppatens ptrichocarpa slycopersicum vvinifera);
        @{$org{'plants_Monocot'}} = qw(bdistachyon oglaberrima oindica obrachyantha osativa sbicolor sitalica zmays);
        @{$org{'plants_Eudicot'}} = qw(alyrata athaliana brapa gmax ptrichocarpa slycopersicum vvinifera);
	@{$org{'plants_Moss'}} = qw(smoellendorffii ppatens);
	@{$org{'insects_Arthropoda'}} = qw(iscapularis); 
	@{$org{'insects_Crustacea'}} = qw(dpulex); 
	@{$org{'insects_Paraneoptera'}} = qw(apisum phumanus); 
	@{$org{'insects_Holometabola'}} = qw(tcastaneum dsechellia dsimulans dvirilis dananassae dwillistoni dyakuba dpersimilis dplexippus dpseudoobscura acephalotes amellifera bmori dmelanogaster dnanassae derecta dgrimshawi dmojavensis dnovemcinctus hmelpomene agambiae aaegypti cquinquefasciatus);
        @{$org{'worms'}} = qw(gmoniliformis cbrenneri cbriggsae celegans creinhardtiii cjaponica cremanei ppacificus tspiralis);
        @{$org{'tunicates'}} = qw(cintestinalis csavignyi);
	@{$org{'porifera'}} = qw(tadhaerens aqueenslandica);
	@{$org{'cnidarians'}} = qw(nvectensis);
	@{$org{'mollusca'}} = qw(nfischeri);
	@{$org{'echinodermata'}} = qw(spurpuratus);
        #@{$org{'vertebrates'}} = qw(acarolinensis amelanoleuca btaurus cfamiliaris choffmanni cjacchus cporcellus dnovemcinctus dordii drerio ecaballus eeuropaeus etelfairi fcatus gaculeatus ggallus ggorilla gmorhua lafricana lchalumnae mdomestica meugenii mgallopavo mlucifugus mmulatta mmurinus mmusculus nleucogenys oanatinus ocuniculus ogarnettii olatipes oprinceps pabelii pcapensis pmarinus ptroglodytes pvampyrus rnorvegicus saraneus sharrisii sscrofa stridecemlineatus tbelangeri tguttata tnigroviridis trubripes tsyrichta ttruncatus vpacos xtropicalis);
	@{$org{'fishes_Jawed'}} = qw(drerio gmorhua olatipes lchalumnae gaculeatus trubripes tnigroviridis);
	@{$org{'fishes_Jawless'}} = qw(pmarinus);
	@{$org{'reptiles'}} = qw(acarolinensis);
	@{$org{'amphibians'}} = qw(xtropicalis);
	@{$org{'birds'}} = qw(mgallopavo tguttata ggallus);
	@{$org{'mammals_Monotremes'}} = qw(oanatinus);
	@{$org{'mammals_Marsupials'}} = qw(mdomestica sharrisii meugenii);
	@{$org{'mammals_Nonprimates'}} = qw(pvampyrus saraneus tbelangeri vpacos ttruncatus amelanoleuca choffmanni cporcellus pcapensis dordii eeuropaeus etelfairi fcatus lafricana itridecemlineatus cjacchus mmusculus rnorvegicus btaurus cfamiliaris ecaballus mlucifugus ocuniculus oprinceps sscrofa);
	@{$org{'mammals_Primates'}} = qw(ogarnettii ggorilla hsapiens tsyrichta mmulatta mmurinus nleucogenys pabelii ptroglodytes);
