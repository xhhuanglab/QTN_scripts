#!/usr/bin/perl -w
use FindBin;

###############################
#  Before running the script, edit the parameters in the config file (RiceNavi-Sim) based on needs.
#  Usage: perl RiceNavi-Sim_run_scripts.pl <RiceNavi-Sim.cfg> <Selected_Genes.loci> 
#  
#  The simulation outputs will be in 'simulation_dir'
#  After simulation process is finished, cd to 'simulation_dir', and run script stat_likelihood.pl
#
#
my $sim_cfg;
my $BC1F1_sim_num;
my $BC2F1_sim_num;
my $BC3F1_sim_num;
my $BCnF1_sim_num;

my $simulation_times;
my $BC_times;
my $selected_genelist;
my $outprefix;

if(@ARGV < 3){
  die "Usage: perl RiceNavi-Sim_run_scripts.pl <RiceNavi-Sim.cfg> <SelectedGene.loci> <outprefix>";	
}else{
  ($sim_cfg, $selected_genelist,$outprefix) = @ARGV;	
}

my $script_dir = $FindBin::Bin;

open SIM, $sim_cfg;
while(<SIM>){
  chomp;
  s/\s+//g;
  $BC1F1_sim_num = $1 if /BC1F1=(\d+)/;
  $BC2F1_sim_num = $1 if /BC2F1=(\d+)/;	
  $BC3F1_sim_num = $1 if /BC3F1=(\d+)/;
  $BCnF1_sim_num = $1 if /BCnF1=(\d+)/;
  $BC_times = $1 if /BC_times=(\d+)/;
  $simulation_times = $1 if /Sim_times=(\d+)/;
}

my $user_param = "
  Simulation Parameters Set by User:
  No. BC1F1 individuals: $BC1F1_sim_num
  No. BC2F1 individuals: $BC2F1_sim_num
  No. BC3F1 individuals: $BC3F1_sim_num
  No. individuals for other generations: $BCnF1_sim_num
  Backcrossing times: $BC_times
  Simulation times: $simulation_times
";
print "$user_param\n";

mkdir "$outprefix.parallel_cmd_dir";
mkdir "$outprefix.simulation_dir";

`cp $script_dir/$selected_genelist ./$outprefix.parallel_cmd_dir`;
`cp $script_dir/SimUtils/* ./$outprefix.parallel_cmd_dir`;
`cp $script_dir/scripts/* ./$outprefix.parallel_cmd_dir`;
`cp $script_dir/scripts/stat_likelihood.pl ./$outprefix.simulation_dir`;

my $cut_num = 5;  ##
my $break_simulation = $simulation_times/$cut_num; 

my $count;
for my $sim_num (1..$simulation_times){
	   
   if($sim_num % $break_simulation == 1){
     $count++;
     
     open BASH, ">$outprefix.parallel_cmd_dir/simulation_group.$count.sh";     	
   }
     my $sim_group_sub = $sim_num % ($simulation_times/$cut_num);
     my $sim_outdir = "../$outprefix.simulation_dir/sim_group".$count.'.'.$sim_group_sub;
     my $cmd = "perl 01_stepwise_generate_ped_forPedigreeSim.pl $BC1F1_sim_num $selected_genelist $sim_outdir\n";
     for my $i (1..($BC_times - 1)){  ## Generate BC1F1..BCnF1 genotypes;  
       my $BCn_1F1_geno = "BC".$i."F1_genotypes.dat.transform";
       my $BCn_1F1_indiv_info = "BC".$i."F1.indiv_info";
       my $BCn_generation = "BC".($i+1)."F1";
       my $indiv_num;
       if($i == 1){    ## BC2F1
         $indiv_num = $BC2F1_sim_num;
       }elsif($i == 2){ ## BC3F1
         $indiv_num = $BC3F1_sim_num;	
       }else{
         $indiv_num = $BCnF1_sim_num;
       }
       $cmd .= "perl 02_simulate_BC_newpop.pl $sim_outdir/$BCn_1F1_geno $sim_outdir/$BCn_1F1_indiv_info $selected_genelist $BCn_generation $indiv_num $sim_outdir\n";
     }
     print BASH $cmd;
}

### Run simulations in batch ###
chdir "$outprefix.parallel_cmd_dir";
print localtime() ." Start Simulating...\n";

if($simulation_times % $cut_num != 0){
  for my $i (1..$cut_num){
    system(qq(bash simulation_group.$i.sh &));
  }
  my $last_bash_num = $cut_num + 1;
  system(qq(bash simulation_group.$last_bash_num.sh));
}else{
  for my $i (1..$cut_num - 1){
    system(qq(bash simulation_group.$i.sh &));
  }
  system(qq(bash simulation_group.$cut_num.sh));  	
}


print localtime() ." Simulation finished!\n";