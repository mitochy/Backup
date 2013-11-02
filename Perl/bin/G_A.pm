use strict;
use warnings;

my $orders = 4; # actually 3rd order, but the script use [actual order]+1
package Distribution;

sub new{
	my $class = shift;
	my $self = bless {}, $class;
	my $filename;
	if (scalar @_ == 1){
		$filename=shift;
		$self->import($filename);
	}
	return $self;
}

#Return a string of Counts table
#Parameter: wordsize = order of distribution + 1
sub get_counts{
	my ($self,$wordsize)=@_;
	my $string=array2string($self->{COUNTS}->{$wordsize});
	return $string;
}

##Convert the Array of Arrays to String
sub array2string{
	my $array=shift;
	my $string="";

	for(my $i=0;$i<scalar @{$array};$i++){
		for (my $j=0;$j<scalar @{$array->[$i]};$j++){
			$string.= int($array->[$i]->[$j]);
			$string.="\t";
		}
		$string.="\n";
	}
	return $string;
}

# Read HMM model so the counts can be used in distribution
sub read_hmm_model {
	my $hmm = $main::HMM_MODEL;

	open (my $in, "<", $hmm) or die "Cannot read from $hmm: $!\n";
	my $emm;
	my ($name);
	my ($row, $col) = (0,0);
	my $check = 0;
	my $total = 0;
	while (my $line = <$in>) {
		chomp($line);
		($name) = $line =~ /NAME: (\w+)/ if $line =~ /NAME/;
		$row = 0 if $line =~ /ORDER/;
		if ($line =~ /^\d+/) {
				$check = 1;
				my (@arr) = split("\t", $line);
				$total += $arr[0] + $arr[1] + $arr[2] + $arr[3]; $total = 1 if $total == 0;
				for (my $i = 0; $i < @arr; $i++) {
					$emm->{$name}->{COUNTS}->{$orders}->[$row]->[$i] = $arr[$i];
				}
				$row++;
 		}
		if ($check == 1 and $line =~ /\#\#\#\#\#/) {
			for (my $i = 0; $i < 4**($orders-1); $i++) {
				for (my $j = 0; $j < 4; $j++) {
					$emm->{$name}->{PERCENT}->{$orders}->[$i]->[$j] = $emm->{$name}->{COUNTS}->{$orders}->[$i]->[$j] / $total;
				}
			}
			$check = 0;
		}


	}
	close $in;
	return($emm);
}

#Import count table (not used)
sub import{
	my ($self, $file) = @_;
	open (my $in, "<", $file) or die "Couldn't open file $file: $!\n";

	my $name;
	
	while (my $line = <$in>){
		chomp ($line);
		if ($line =~ /^>(\d)/){
			$name=$1;
		}
		else{
			my @line = split ("\t", $line);
			
			for(my $i = 0; $i < @line; $i++) {
				$line[$i]++;
			}
			
			push (@{$self->{COUNTS}->{$name}}, \@line);
		}
	}
	$self->convert_to_percentages();
	return $self;
}

#Create percentage table using counts table (not used)
sub convert_to_percentages{
	my $self=shift;
	if (exists $self->{PERCENT}){
		return $self;
	}
	else{
		foreach my $dist (sort keys %{$self->{COUNTS}}){
			my $sum=0;
			my $rows=scalar @{$self->{COUNTS}->{$dist}};
			for(my $i=0;$i<$rows;$i++){
				for(my $j=0;$j<4;$j++){
					$sum+=$self->{COUNTS}->{$dist}->[$i]->[$j];
				}
			}
			
			for(my $i=0;$i<$rows;$i++){
				my @row=(0,0,0,0);
				push @{$self->{PERCENT}->{$dist}}, \@row;
			}
			
			for(my $i=0;$i<4**($orders-3);$i++){
				for(my $j=0;$j<4;$j++){
					die "$i\n" unless defined($self->{COUNTS}->{$dist}->[$i]->[$j]);
					my $percent=($self->{COUNTS}->{$dist}->[$i]->[$j])/$sum;
					$self->{PERCENT}->{$dist}->[$i]->[$j]=$percent;
				}
			}
		}
	}
	return $self;
}

package Population;
require Cwd;
require threads;
require Thread::Queue;
require Storable;


##Create a population ~10% from given counts and 90% random
##See generate() function
sub new{
	my ($class,$skew_file) = @_;
	
	my $self = bless {}, $class;
	my $skew=Distribution->new($skew_file);
	
	$self->generate($skew);

	return $self;
}


##Create a population base upon completely random distributions
sub new_random{
	my ($class)=shift;
	my $self=bless{}, $class;
	$self->generate_random();
}


## Generate a random distribution based on hmm model file
sub generate_random{
	my ($self)=@_;
	
	for(my $i=0;$i<$main::POPULATION_SIZE;$i++){

		my $individual = Individual->new();
		my $emm = Distribution::read_hmm_model();
		$individual->{DIST} = $emm;
		$individual->mutate();
		push @{$self->{INDIVIDUALS}}, $individual;
	}
	return $self;
}

## Save the Population to a file

sub store{
        my ($self,$file)=@_;
        Storable::store($self,$file);
}

#Purge 80% of population
sub purge{
	
	my $parent_size;
	#if (not defined($main::KILLED_POP) or $main::KILLED_POP == 0) {
		$parent_size = 1- $main::PARENT_SIZE;
	#}
	#else {
	#	$parent_size = $main::KILLED_POP/$main::POPULATION_SIZE > 1 - $main::PARENT_SIZE ? $main::KILLED_POP/$main::POPULATION_SIZE : 1 - $main::PARENT_SIZE;
	#}
	

	#Each Row

	my $self=shift;
	my $size=(int($main::POPULATION_SIZE * $parent_size))-1;
	
	my $end=(scalar @{$self->{INDIVIDUALS}}) -1;
	
	#Sorts the individual by score in ascending order
	$self->sort_scores();
	
	#Delete the first N of the population according to parent size
	delete @{$self->{INDIVIDUALS}}[0..$size];

	#Shift individuals to top of list
	my @array=@{$self->{INDIVIDUALS}};
	@array=@array[($size+1)..$end];
	$self->{INDIVIDUALS}=\@array;
}


# Sort fitness scores
sub sort_scores{
	my $self=shift;
	my @array=sort {$a->{SCORE} <=> $b->{SCORE}} @{$self->{INDIVIDUALS}};
	$self->{INDIVIDUALS}=\@array;
	return $self;
}


#Mate indivduals to generate new offspring
#Probability of mating is based on the fitness score.   Higher fitness have
#higher chance of mating
sub mate{
	my $self=shift;
	
	my $fitness_sum=0;
	my @scores;
	
	#Compute the sum of fitness scores
	foreach my $individual (@{$self->{INDIVIDUALS}}){
		push @scores,$individual->{SCORE};
		$fitness_sum+=$individual->{SCORE};
	}
	
	while(scalar @{$self->{INDIVIDUALS}}<$main::POPULATION_SIZE){
		#Select mate pairs
		my $father=int(rand($fitness_sum));
		my $mother=int(rand($fitness_sum));
		my $father_iter=-1;
		my $mother_iter=-1;
		
		my $running_sum=0;
		for(my $i=0;$i<scalar @scores;$i++){
			$running_sum+=$scores[$i];
			if ($father<$running_sum){
				$father_iter=$i;
			}
			
			if ($mother<$running_sum){
				$mother_iter=$i;
			}
			
			if ($mother_iter!=-1 && $father_iter!=-1){
				last;
			}
		}
		
		#Crossover
		if (rand(1)<$main::CROSSOVER_RATE){
			my $ind= Individual->new();
			$ind->crossover($self->{INDIVIDUALS}->[$father_iter], $self->{INDIVIDUALS}->[$mother_iter]);

			$ind->mutate();
			push @{$self->{INDIVIDUALS}},$ind;
		}
		else{
			my $ind= Individual->new();
			$ind->mate($self->{INDIVIDUALS}->[$father_iter], $self->{INDIVIDUALS}->[$mother_iter]);
			$ind->mutate();
			push @{$self->{INDIVIDUALS}},$ind;
		}
	}
	return $self;
}

#Evalute the new individuals in the population
#Outputs models for each individual
#Runs StochHMM
#Evaluates the Predictions
sub evaluate{
	my ($self)=@_;
	my $file_name=0;
	my @files;
	my $start_dir=Cwd::getcwd();

	
	unless (-d $main::OUTPUT_DIR){
		mkdir $main::OUTPUT_DIR or die;
	}
	
	chdir $main::OUTPUT_DIR or die "Couldn't change to working directory $main::OUTPUT_DIR\n";

	
	foreach my $indi (sort {$b->{SCORE} <=> $a->{SCORE}} @{$self->{INDIVIDUALS}}){
		# Not yet scored		
		if ($indi->{SCORE}==-1){
			my $file=$file_name;
			push @files,[$file,$indi];
			$indi->output_model($file_name);
			$file_name++;
		}
		else {
			my $file=$file_name;
			push @files,[$file,$indi];
			$indi->output_model($file_name);
			$file_name++;
		}

	}
	run_stochHMM(SEQ=>$main::SEQFILE,
			MODELS=>\@files,
			POSTERIOR => 1,
			 );
	evaluate_models(\@files);
	chdir $start_dir or die "Failed to change directory\n";
}

# Evaluate each model
# Report file is in .report
# Utilize evaluate_report.pl in OUTPUT_FOLDER file
sub evaluate_models{
	my ($hmm, $start_add, $end_add)=@_;
	my $eval = $main::EVALFILE;
	my $threshold = $main::THRESHOLD;
	my @totalQ;
	for (my $i = 0; $i < @{$hmm}; $i++) {
		my $model = $hmm->[$i]->[0] . ".hmm";
		my $res = $hmm->[$i]->[0]. ".report";
		my $comm = "evaluate_report.pl $res $threshold";
		push(@totalQ, $comm);
	}

	# Evaluate each report file using Thread Queue
	print "\tEvaluating models\n";
	my %result;
	for (my $i = 0; $i < int(@totalQ / $main::THREAD_NUM)+1;  $i++) {
		my $Q = new Thread::Queue;
		my $remaining = $i * $main::THREAD_NUM + $main::THREAD_NUM >= @totalQ ? @totalQ : $i * $main::THREAD_NUM + $main::THREAD_NUM;
		my $totalQ = @totalQ;
		for (my $j = $i*$main::THREAD_NUM; $j < $remaining; $j++) {
			$Q->enqueue($totalQ[$j]);
		}
		$Q->end();
		my $lastj = 0;
		my @threads;
	        for (my $j=0;$j<$main::THREAD_NUM;$j++){
	                $threads[$j] = threads->create(\&worker, $j, $Q);
			$lastj = $j+1;
			my $remainingQ = $Q->pending();
			last if not defined($remainingQ) or $remainingQ == 0;
			printf STDERR "\t%.2f %% Complete\r", 100 * (@totalQ - $remainingQ) / @totalQ;
	        }
	        for (my $j=0;$j<$lastj;$j++){
			#print "$j\n";
	                my @results = @{$threads[$j]->join()};
			foreach my $result (@results) {
				#print "$result\n";
				my ($hmm_number,$tp, $tn, $fp, $fn) = split(",", $result);
				die "died at $result\n" if not defined($tp);
				$result{$hmm_number}{tp} = $tp;
				$result{$hmm_number}{fp} = $fp;
				$result{$hmm_number}{tn} = $tn;
				$result{$hmm_number}{fn} = $fn;
			}
	        }
	}
	print "Done\n";
	my $check = 0 if not defined($main::LOWEST_FP);
	$check = 1 if defined($main::LOWEST_FP);
	printf "CURRENT HIGHEST FP = %d\n", $main::LOWEST_FP if defined($main::LOWEST_FP);
	for (my $i = 0; $i < @{$hmm}; $i++) {
		my $rpt = $hmm->[$i];
		my $hmm_number = $rpt->[0];
		my $tp = $result{$hmm_number}{tp};
		my $fp = $result{$hmm_number}{fp};
		my $tn = $result{$hmm_number}{tn};
		my $fn = $result{$hmm_number}{fn};
		my $sen = ($tp + $fn) == 0 ? 0 : $tp / ($tp + $fn);
		my $spe = ($tn + $fp) == 0 ? 0 : $tn / ($tn + $fp);
		my $pre = ($tp + $fp) == 0 ? 0 : $tp / ($tp + $fp);
		my $rec = ($tp + $fn) == 0 ? 0 : $tp / ($tp + $fn);
		#my $f = $pre;#($tp / ($tp + $fp)) * (0-$fn);#($tp + $fp + $fn + $tn);
		my $f = ($pre + $rec) == 0 ? 0 : (2 * $pre * $rec) / ($rec + $pre);
		#my $acc = ($tp + $fn + $tn + $fn) == 0 ? 0 : ($tp + $tn) / ($tp + $fp + $tn + $fn);
		#my $f = $acc;
		#if ($check == 0) {
		#	$main::LOWEST_FP = $fp if not defined($main::LOWEST_FP);
		#	$main::LOWEST_FP = $fp if $fp < $main::LOWEST_FP;
		#}
		#else {
		#	$main::LOWEST_FP = $fp if ($i == 0);
		#	$f = $f**2 if $main::LOWEST_FP < $fp and $i != 0;
		#	#$main::KILLED_POP ++ if $main::LOWEST_FP > $tp and $i != 0;
		#}
		$rpt->[1]->{SCORE} = $f;
		printf STDERR "\thmmfile $hmm_number\.hmm:\tf: %.4f\ttp $tp\ttn $tn\tfp $fp\tfn $fn\n", $f;
	}
	return;

}

#Run stochHMM on $main::THREAD_NUM threads
sub run_stochHMM{
	my %default=(MODELS=>[],
			 SEQ=>"",
			 REPORT=>0,
			 THRESHOLD=>0,
			 REP=>10,
			 RPT=>0,
			 PATH=>0,
			 LABEL=>0,
			 POSTERIOR=>0,
			 GFF=>0,
			 VITERBI=>0,
			 NBEST=>0,
			 THREADS=>$main::THREAD_NUM);

	my %arg=(%default,@_);
	my $seq = $main::SEQFILE;
	my @totalQ;
	my $command="StochHMM -model MODEL -seq \"$seq\" ";

	if (exists $arg{STOCH}){
		$command .= "-stochastic $arg{STOCH} -repetitions $arg{REP} ";
	}
	
	if (scalar @{$arg{MODELS}}<8){
		$arg{THREADS}=scalar @{$arg{MODELS}};
	}
	
	if ($arg{VITERBI}==1){
		$command.="-viterbi ";
	}
	if ($arg{POSTERIOR}==1){
		$command.="-posterior ";
	}	
	
	if ($arg{NBEST}>0){
		$command.="-nbest $arg{NBEST} ";
	}
	
	if ($arg{PATH}==1){
		$command.="-path ";
	}
	if ($arg{LABEL}==1){
		$command.="-label ";
	}
	if ($arg{GFF}==1){
		$command.="-gff ";
	}
	
	if ($arg{REPORT}>0){
		#$command.="-report OUTFILE ";
	}
			
	if ($arg{THRESHOLD}>0){
		$command.="-threshold " . $arg{THRESHOLD} . " ";
	}
	foreach my $mod (@{$arg{MODELS}}){
		my $comm = $command;
		my $hmm_file=$mod->[0];
		my $out_file= $mod->[0];
		$out_file.= ".report";
		$hmm_file.= ".hmm";
		$comm=~s/OUTFILE/$out_file/;
		$comm=~s/MODEL/$hmm_file/;
		$comm .= "> $out_file" if $arg{GFF} == 0;
		push(@totalQ, $comm);
	}
	

	print "\tRunning StochHMM\n";
	my $count = 0;
	for (my $i = 0; $i < int(@totalQ / $main::THREAD_NUM)+1;  $i++) {
		my $Q = new Thread::Queue;
		my $remaining = $i * $main::THREAD_NUM + $main::THREAD_NUM >= @totalQ ? @totalQ : $i * $main::THREAD_NUM + $main::THREAD_NUM;
		my $totalQ = @totalQ;
		for (my $j = $i*$main::THREAD_NUM; $j < $remaining; $j++) {
			$Q->enqueue($totalQ[$j]);
		}
		$Q->end();
	        my @threads;
	
		my $lastj = 0;
	        for (my $j=0;$j<$main::THREAD_NUM;$j++){
	                $threads[$j] = threads->create(\&worker, $j, $Q);
			$lastj = $j+1;
			my $remainingQ = $Q->pending();
			last if not defined($remainingQ) or $remainingQ == 0;
			printf STDERR "\t%.2f %% Complete\r", 100 * (@totalQ - $remainingQ) / @totalQ;
	        }
	        for (my $j=0;$j<$lastj;$j++){
	                $threads[$j]->join();
	        }
	}
	print "\nDone\n";
	return;
}

#worker subroutine for run_stochhmm
sub worker {
	my ($thread, $queue) = @_;
	my $tid = threads->tid;
	my @results;
	while ($queue->pending) {
		my $command = $queue->dequeue;
		next if not defined($command);
		my $results = `./$command`;

		push(@results, $results);
	}
	return(\@results);
}

#Gets the maximum score from the population
sub max{
	my $self=shift;
	my $max=0;
	my $count = 0;
	my $max_indiv = 0;
	my $maxcount = int(@{$self->{INDIVIDUALS}} * 0.2) == 0 ? 1 : int(@{$self->{INDIVIDUALS}} * 0.2);

	foreach my $indiv (sort {$b->{SCORE} <=> $a->{SCORE}} @{$self->{INDIVIDUALS}}){
		$count++;
		$max_indiv = $indiv->{SCORE} if $max_indiv < $indiv->{SCORE};
		$max += $indiv->{SCORE} / $maxcount if $count <= $maxcount
	}
	return ($max, $max_indiv);
}


package Individual;
use vars qw($MUTATION_RATE $MAX_MUTATION_CHANGE $CROSSOVER_RATE $POPULATION_SIZE);
my $Genomic;

#Individual is composed of a single 3rd order distibution and a fitness score.
#If unevaluated the fitness score = -1
sub new{
	my ($class,$dist) = @_;
	
	my $self = bless {"DIST"=>$dist,"SCORE"=>-1}, $class;
	return $self;
}


#Mutate an individuals distribution
sub mutate{
	my $self = shift;
	
	#Each Row
	my $distribution = $self->{DIST};

	foreach my $types (keys %{$distribution}) {
		for(my $i=0;$i< 4**($orders-1) ;$i++){
			#Each entry in row
			for(my $j=0;$j<4;$j++){
				if (rand(1)<$main::MUTATION_RATE){
					my $difference = rand($main::MAX_MUTATION_CHANGE);
					my $value = $self->{DIST}->{$types}->{COUNTS}->{$orders}->[$i]->[$j];
					die "died at $orders $i $j\n" if not defined($value);

					#determine whether to add or delete value
					if (rand(1)<0.5){
						$value+=$difference*$value;
					}
					else{
						$value-=$difference*$value;
					}
					
					#assign mutated new value
					$self->{DIST}->{$types}->{COUNTS}->{$orders}->[$i]->[$j]=$value;
				}
			}
		}
	}
	return $self;
}


#Mate two individuals
#Simple mating entails adding the two values together.
#Note:  Changed to average of two individuals instead of adding together 
sub mate{
	my ($self,$ind1,$ind2)=@_;

	#Each Row
	my %dis1 = %{$ind1->{DIST}};
	my %dis2 = %{$ind2->{DIST}};

	foreach my $dis (keys %dis1) {
		my $val1 = $dis1{$dis};
		my $val2 = $dis2{$dis};

		for(my $i=0;$i<4**($orders-1);$i++){
			for(my $j=0;$j<4;$j++){
				$self->{DIST}->{$dis}->{COUNTS}->{$orders}->[$i]->[$j]=($val1->{COUNTS}->{$orders}->[$i]->[$j]+$val2->{COUNTS}->{$orders}->[$i]->[$j])/2;
			}
		}
	}
	return $self;
}


##Crossover
## At crossover point the rows and values of two tables are swapped
sub crossover{
	my ($self,$ind1,$ind2)=@_;
	
	#Determine row of crossover
	my $crossover_point=int(rand(64))-1;
	
	#Determine column of crossover
	my $point=int(rand(4))-1;

	#Each Row
	my %dis1 = %{$ind1->{DIST}};
	my %dis2 = %{$ind2->{DIST}};

	foreach my $dis (keys %dis1) {
		my $val1 = $dis1{$dis};
		my $val2 = $dis2{$dis};
	

		for(my $i=0; $i<4**($orders-1); $i++) {

			if ($crossover_point<$i){
				my @line1=@{$val1->{COUNTS}->{$orders}->[$i]};
				push @{$self->{DIST}->{$dis}->{COUNTS}->{$orders}->[$i]}, @line1;
			}
			elsif ($crossover_point==$i){
				my @line1=@{$val1->{COUNTS}->{$orders}->[$i]};
				my @line2=@{$val2->{COUNTS}->{$orders}->[$i]};
	
				for(my $j=0;$j<4;$j++){
					if ($i<$point){
						$self->{DIST}->{$dis}->{COUNTS}->{$orders}->[$i]->[$j]=$line1[$j];
					}
					else{
						$self->{DIST}->{$dis}->{COUNTS}->{$orders}->[$i]->[$j]=$line2[$j];
					}
				}
			}
			else{
				my @line2=@{$val2->{COUNTS}->{$orders}->[$i]};
				push @{$self->{DIST}->{$dis}->{COUNTS}->{$orders}->[$i]}, @line2;
			}
		}
	}
	return $self;
}


#Print the model the the file
sub output_model{
	my ($self,$file)=@_;
	$file.=".hmm";
	
	#Transition probabilities are coded here
	#EMISSION=>ORDER of distribution to use
	my %GC_mod=(	OUTPUT_FILE=>$file,
                        G_ORDER => 3,
                        C_ORDER => 3,
                        G2G => (1-2/25000),
                        G2C => 1/25000,
                        G2N => 1/25000,
                        C2G => 1/880,
                        C2C => 1-(1/880),
                        N2G => 1/880,
                        N2N => 1-(1/880),
			G_EMM => 0,
                        C_EMM => 0,
                        N_EMM => 0
			);

	$GC_mod{G_EMM}=array2string($self->{DIST}->{G}->{COUNTS}->{$orders});
	$GC_mod{C_EMM}=array2string($self->{DIST}->{C}->{COUNTS}->{$orders});
	$GC_mod{N_EMM}=array2string($self->{DIST}->{N}->{COUNTS}->{$orders});
	_output_model(%GC_mod);
}


#Takes values created by output_model and prints the file
sub _output_model{
	my %default=(	OUTPUT_FILE=>"GC_SKEW.hmm",
			G_ORDER => 3,
			C_ORDER => 3,
			N_ORDER => 3,
			G2G => 0,
			G2C => 0,
			G2N => 0,
			C2G => 0,
			C2C => 0,
			N2G => 0,
			N2N => 0,
			G_EMM => 0,
			C_EMM => 0,
			N_EMM => 0,
			 );
	my %arg=(%default,@_);

	my $file=$arg{OUTPUT_FILE};
	open OUT, "> $file" or die "Can't open file for writing";

	my ($sec, $min, $hour, $day, $month, $yr19) = localtime(time);
	my $date = ($month+1) . "\/$day\/" . ($yr19+1900);
	
	print OUT "\#STOCHHMM MODEL FILE
MODEL INFORMATION
======================================================
MODEL_NAME:     CGI PROMOTER WITH SKEW CLASSES MODEL
MODEL_DESCRIPTION:      To find Promoter CpG Islands, which have 3 different Skew Class
MODEL_CREATION_DATE:    $date

TRACK SYMBOL DEFINITIONS
======================================================
SEQ:    A,C,G,T

AMBIGUOUS SYMBOL DEFINITIONS
======================================================
SEQ: N[A,C,G,T], R[A,G],Y[C,T],S[G,C],W[A,T],K[G,T],M[A,C],B[C,G,T]\n\n";

my %state;
$state{INIT} = "STATE DEFINITIONS
\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#
STATE:
        NAME: INIT
TRANSITION: STANDARD:   P(X)
        G: 0.5
        C: 0.5
        N: 0.5
\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#";


# TODO: Need to create loop so it automatically create each state instead of defining one by one
$state{G} = "STATE:
        NAME: G
        GFF_DESC: G
        PATH_LABEL: G
TRANSITION: STANDARD: P(X)
        G: $arg{G2G}
        C: $arg{G2C}
        N: $arg{G2N}
        END: 1
EMISSION:	SEQ: COUNTS
        ORDER: $arg{G_ORDER}	AMBIGUOUS: 	AVG
$arg{G_EMM}\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#";

$state{C} = "STATE:
        NAME: C
        GFF_DESC: C
        PATH_LABEL: C
TRANSITION: STANDARD: P(X)
        G: $arg{C2G}
        C: $arg{C2C}
        END: 1
EMISSION:	SEQ: COUNTS
        ORDER: $arg{C_ORDER}	AMBIGUOUS: 	AVG
$arg{C_EMM}\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#";

$state{N} = "STATE:
        NAME: N
        GFF_DESC: N
        PATH_LABEL: N
TRANSITION: STANDARD: P(X)
        G: $arg{N2G}
        N: $arg{N2N}
        END: 1
EMISSION:	SEQ: COUNTS
        ORDER: $arg{N_ORDER}	AMBIGUOUS: 	AVG
$arg{N_EMM}\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#";

	print OUT "$state{INIT}\n";
	print OUT "$state{G}\n";
	print OUT "$state{C}\n";
	print OUT "$state{N}\n";
	print OUT "//END\n";
	close OUT;
}

##Convert array to string
sub array2string{
	my ($array,$value)=@_;
	
	if (!defined $value){
		$value=1;
	}
	my $string="";

	for(my $i=0;$i<4**($orders-1);$i++){
		for (my $j=0;$j<scalar @{$array->[$i]};$j++){
			$string.= int($array->[$i]->[$j] * $value);
			$string.="\t";
		}
		$string.="\n";
	}
	return $string;
}

1;
__END__
