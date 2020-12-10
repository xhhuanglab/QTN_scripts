#!/usr/bin/perl

my $map_file = 'RiceGeneticMap.Nip-9311.map'; 
my $chrom_file = 'RiceGeneticMap.Nip-9311.chrom';
my $Pedigree_soft = 'PedigreeSim.jar';

my ($sample_het,$pre_generation_geno,$selected_gene_list,$prefix,$all_indiv_num,$data_output_dir);
my (%count_samples);


if(@ARGV < 5){
  die "Usage: perl $0 <Previous_Generation_Geno> <Sample_het_info> <selected_gene_list> <Prefix> <all_indiv_num> <outdir>";	
}else{	
  ($pre_generation_geno,$sample_het,$selected_gene_list,$prefix,$all_indiv_num,$data_output_dir) = @ARGV;
}
my ($each_indiv_children, $each_generation_indivs);
($each_indiv_children,$each_generation_indivs) = &determine_offspring_num($all_indiv_num); 


############
open INFO, $sample_het;

my @gene_hit_samples;
my %indiv2regionsize;
my %indiv2breakpoint;
my %indiv2hetregions;
my %indiv2hetpct;

while(<INFO>){
  chomp;
  my @tmp = split/\t/;
  if($tmp[1] =~ /(.+?) \| (.+)/){
    my ($num_target,$num_bg) = ($1,$2);
    my ($sampleid,$breakpoint,$het_count,$het_pct,$donor_homo) = @tmp[0,2,3,4,5];
    
    if($num_target == $num_bg and $donor_homo < 0.01  and $breakpoint >= 1 
    ){
    	push @gene_hit_samples,$sampleid;
    	$indiv2breakpoint{$sampleid} = $breakpoint;
    	$indiv2hetregions{$sampleid} = $het_count;
    	$indiv2hetpct{$sampleid} = $het_pct;
      for my $i (6..$#tmp - 1){
    	 next if $tmp[$i] =~ /\(0\)\|/;
       if($tmp[$i] =~ /\((.+?)\)/){     
        $indiv2regionsize{$sampleid} += $1;   
       }	
      }
    }
  }
}
close INFO;

my %indiv2hetpct_rank = &get_rank(%indiv2hetpct);

my $count_indivs;
open TEST, ">>$data_output_dir/Indiv.hetpct.regionsize.stat";
foreach (sort {$indiv2hetpct_rank{$a}<=>$indiv2hetpct_rank{$b}} keys %indiv2hetpct_rank){
	print TEST "$data_output_dir\t$_\t$indiv2hetregions{$_}\t$indiv2hetpct{$_}\t$indiv2regionsize{$_}\t$indiv2hetpct_rank{$_}\n";
  $count_indivs++;
  if($count_indivs <= $each_generation_indivs){
  	print TEST "$_\n";
    $count_samples{$_}++;
  }	
}
close TEST;

my $No_selected_lines = scalar keys%count_samples;


############################
##### Generate .ped file####
open PED, ">$data_output_dir/$prefix.ped";

print PED "Name	Parent1	Parent2\n";
print PED "P1	NA	NA\n";
foreach (sort keys%count_samples){
  print PED "$_\tNA\tNA\n";	
}
my $new_generation_num;
my $simu_pop_num = $each_indiv_children; 
foreach my $sampleid (sort keys%count_samples){
  for my $i (1..$simu_pop_num){  
    $new_generation_num++;
    my $samplename = $prefix.'_'.$new_generation_num;
    my $pedinfo = "$samplename\tP1\t$sampleid";
    print PED "$pedinfo\n";
  }
}
close PED;

############################
#### Generate .geno file####
open GEN, $pre_generation_geno or die;
open OUT, ">$data_output_dir/$prefix.gen";

my $sample_head = <GEN>; chomp $sample_head;
my @samples = split/\t/,$sample_head;
my @sample_colnums;
for my $i (1..$#samples){
  if(defined $count_samples{$samples[$i]}){
    push @sample_colnums,$i;	
  }	
}


print OUT "marker\t";
print OUT "P1_1\tP1_2\t";
foreach my $i (@sample_colnums){
  my $sample_1 = $samples[$i].'_1';
  my $sample_2 = $samples[$i].'_2';
  print OUT "$sample_1\t$sample_2\t";	
}
print OUT "\n";

while(<GEN>){
  chomp;
  my @tmp = split/\t/;
  print OUT "$tmp[0]\t";
  my $double_geno;
  foreach my $num (@sample_colnums){
    my $geno = $tmp[$num];
    
    if($geno eq '0'){
      $double_geno .= "0\t0\t";	
    }
    elsif($geno eq '1'){
      $double_geno .= "0\t2\t";	
    }
    elsif($geno eq '2'){
      $double_geno .= "2\t2\t";		
    }
  }
  my $add_P1_geno = "0\t0\t$double_geno";
  print OUT "$add_P1_geno\n";
}
close GEN;
close OUT;

############################
#### Generate .par file#####
open PAR, ">$data_output_dir/$prefix.par";

my $par_info = "
PLOIDY = 2
MAPFUNCTION = HALDANE 
MISSING = NA
CHROMFILE = $chrom_file 
PEDFILE = $data_output_dir/$prefix.ped
MAPFILE = $map_file 
FOUNDERFILE = $data_output_dir/$prefix.gen
OUTPUT = $data_output_dir/$prefix
ALLOWNOCHIASMATA = 1
NATURALPAIRING = 1 
PARALLELQUADRIVALENTS = 0.0
PAIREDCENTROMERES = 0.0
";

print PAR "$par_info";
close PAR;

### Run PedigreeSim.par ###
`java -jar PedigreeSim.jar $data_output_dir/$prefix.par`;

my $BCnF1_geno_out = $prefix.'_genotypes.dat';

#### Run genotype format transforming ###
my $pre_geno_file = "$data_output_dir/$BCnF1_geno_out";
&trans_geno_format($pre_geno_file);

#### Run Individual selection ###
my $BCnF1_geno_out_trans = $prefix.'_genotypes.dat.transform';
my $indiv_info = $prefix.'.indiv_info';

`perl RiceNavi-SampleSelect.pl $data_output_dir/$BCnF1_geno_out_trans $selected_gene_list $prefix > ./$data_output_dir/$indiv_info`;


#### Remove useless files  ####
system(qq(rm -f $data_output_dir/*.dat));
system(qq(rm -f $data_output_dir/*.hsa));
system(qq(rm -f $data_output_dir/*.hsb));
system(qq(rm -f $data_output_dir/*.ped));
#system(qq(rm -f $data_output_dir/*.gen));
system(qq(rm -f $data_output_dir/*.par));

##############
##############

sub get_rank {
  my (%origin_hash) = @_;
  my $rank_num;
  my %rank_hash;
  foreach (sort {$origin_hash{$a} <=> $origin_hash{$b}} keys%origin_hash){
  	$rank_num++;
    $rank_hash{$_} = $rank_num;	
  }
  return %rank_hash;	
}

sub trans_geno_format {
  my ($genofile) = @_;
  open IN, $genofile;
  open OUT, ">$genofile.transform";
  my $line;
  my $sample_count;
  while(<IN>){
    chomp;
    $line++;
    my @tmp = split/\t/;
    if($line == 1){
     	print OUT "marker\t";
      $sample_count = (scalar @tmp - 1)/2;
      for my $i (1..$sample_count){
        my $sampleid = $1 if $tmp[2*$i - 1] =~ /(.+)\_/;
        print OUT "$sampleid\t";
      }
      print OUT "\n";
    }else{
    	print OUT "$tmp[0]\t";
      for my $i (1..$sample_count){
        my $allele1 = $tmp[2*$i - 1];
        my $allele2 = $tmp[2*$i];
        my $allele = '-';
        if($allele1 == 0 and $allele2 == 0){
          $allele = 0
        }elsif(($allele1 == 0 and $allele2 == 2) or ($allele1 == 2 and $allele2 == 0)){	
          $allele = 1;
        }elsif($allele1 == 2 and $allele2 == 2){
          $allele = 2;	
        }
        print OUT "$allele\t";
      }
      print OUT "\n";	
    }
  }  	
}


sub determine_offspring_num{
   my ($total_num) = @_;
   my ($each_indiv_children,$each_generation_indivs);
   if($total_num <= 500){
     $each_indiv_children = $total_num;
     $each_generation_indivs = "1";
   }
   elsif($total_num > 500 and $total_num <= 5000){
   	 $each_generation_indivs = 5;
     $each_indiv_children = $total_num/$each_generation_indivs;
   }
   elsif($total_num > 5000){
     $each_indiv_children = 1000;
     $each_generation_indivs = $total_num/$each_indiv_children;
   }
   return($each_indiv_children,$each_generation_indivs);
}