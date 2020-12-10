#!/usr/bin/perl

##################################################################################################
# Get the likelihood after simulations
# Usage: perl Stat_Sim_likelihood.pl <Target_size> <backcrossing_times>
# The <Target_size> is the size (Mb) of genomic region that covers the selected gene
#
# Output file: stat_simulation.2M & stat_simulation.2M.Likelihood
##################################################################################################
my $size_num;
my $back_times;

if(@ARGV < 2){
  die "Usage: perl $0 <Target_size> <backcrossing_times>";	
}else{
  ($size_num,$back_times) = @ARGV;
}

open OUT, ">stat_simulation.".$size_num."M";
open OUT1, ">stat_simulation.".$size_num."M.Likelihood";


my $pop_head;
for my $i (1..$back_times){
  $pop_head .= "BC$i"."F1\t";	
}
print OUT "SimulationID\t$pop_head\n";


opendir DIR, './';
my $total_sim;
my @sim_count;
foreach (readdir DIR){
  if(/^sim_group/){
  	my $dir = $_;
  	my $sim_match_count = '';
  	print OUT "$_\t";
    for my $i (1..$back_times){
      my $BCnF1 = "./$dir/BC".$i."F1.indiv_info";
      my $matched_BCnF1 = &count_match_samples($BCnF1);
      $sim_match_count .= "$matched_BCnF1\t";
    }
    chop $sim_match_count;
    print OUT "$sim_match_count\n";
    push @sim_count,$sim_match_count;
  }
}
print OUT "\n\n";


my $valid_sims;
my %count;
my $total_sim = scalar @sim_count;
foreach (@sim_count){
  my @tmp = split/\t/;
 # if($tmp[-1] > 0 and $tmp[0] == 0){
  #	$valid_sims++;
    for my $i (0..$back_times - 1){
      if($tmp[$i] >= 1){  ### 
        $count{'BC'.($i+1).'F1'}++;	
      }	
    }
 # }
}

print OUT1 "Group\tNum\tTotalSim\tLikelihood\n";
for my $i (1..$back_times){
  my $groupid = 'BC'.$i.'F1';
  my $count_sim = $count{$groupid} || 0;
  my $percent = sprintf("%.3f",$count{$groupid}/$total_sim);
  print OUT1 "$groupid\t$count_sim\t$total_sim\t$percent\n";	
}


sub count_match_samples {
  my ($file) = @_;
  my %count_match_size;
  open IN, $file or die;
  my $head = <IN>; chomp $head;
  my $count_matched_samples = 0;
  while(<IN>){
    chomp;
    my @tmp = split/\t/;

    my ($sampleid,$match_info,$het_regions) = @tmp[0,1,3];
    my ($num1,$num2);
    if($match_info =~ /(\d+) \| (\d+)/){
      ($num1,$num2) = ($1,$2);
    }
    my $num_genes = $num2;
    for my $j (6..$#tmp - 1){
      my $hit_size = $1 if $tmp[$j] =~ /\((.+?)\)/;
      $count_match_size{$sampleid}++ if ($hit_size <= $size_num and $hit_size > 0);
    }

    if($num1 == $num2 
    and $count_match_size{$sampleid} == $num_genes
    and $het_regions == $num_genes)
    {
      $count_matched_samples++;
    }	
  }
  close IN;
  return $count_matched_samples;	
}