#$/usr/bin/perl -w
############################
#  Make sure you have the listed files available.
# (1) PedigreeSim.jar; 
# (2) *.chrom
# (3) *.map 
#############################

use strict;

my $map_file = 'RiceGeneticMap.Nip-9311.map'; 
my $chrom_file = 'RiceGeneticMap.Nip-9311.chrom';
my $Pedigree_soft = 'PedigreeSim.jar';


my ($BC1F1_count,$selected_gene_list,$data_output_dir);


if(@ARGV < 3){
  die "Usage: perl $0 <BC1F1_number_count> <selected_gene_list (e.g. BADH2.loci)> <output_dir (sim1)>\n";	
}else{
  ($BC1F1_count,$selected_gene_list,$data_output_dir) = @ARGV;
}

die "*.map file not in the current directory\n" unless (-f $map_file);
die "*.chrom file not in the current directory\n" unless (-f $chrom_file);
die "PedigreeSim.jar not in the current directory\n" unless (-f $Pedigree_soft);
die "Selected_Gene_List not in the current directory\n" unless (-f $selected_gene_list);


mkdir $data_output_dir;


my $pop_generation_prefix = 'BC1F1';


### Generate 1st *.ped file ###

open PED, '>'."$data_output_dir/BC1F1.ped";
my $head = "Name	Parent1	Parent2";

print PED "$head\n";
print PED "P1	NA	NA\nP2	NA	NA\n";
print PED "F1	P1	P2\n";


for my $i (1..$BC1F1_count){
   my $BC1F1 = "BC1F1".'_'.$i."\tP1\tF1";
	 print PED "$BC1F1\n";
}

### Generate 1st *.gen file ###

open GEN, ">$data_output_dir/BC1F1.gen";
print GEN "marker	P1_1	P1_2	P2_1	P2_2\n";

open MAP, $map_file;
while(<MAP>){
  chomp;
  next if /marker	chromosome	position/;
  my $marker = $1 if /(.+?)\t/;
  print GEN "$marker\t0\t0\t2\t2\n";	
}
close MAP;

### Generate 1st *.par ###
open PAR, ">$data_output_dir/BC1F1.par";
my $par_info = "
PLOIDY = 2
MAPFUNCTION = HALDANE 
MISSING = NA
CHROMFILE = $chrom_file 
PEDFILE = $data_output_dir/BC1F1.ped 
MAPFILE = $map_file
FOUNDERFILE = $data_output_dir/BC1F1.gen 
OUTPUT = $data_output_dir/BC1F1
ALLOWNOCHIASMATA = 1
NATURALPAIRING = 1 
PARALLELQUADRIVALENTS = 0.0
PAIREDCENTROMERES = 0.0
";
print PAR "$par_info\n";

### Run PedigreeSim.par ###
`java -jar PedigreeSim.jar ./$data_output_dir/BC1F1.par`;

my $BC1F1_geno_out = 'BC1F1_genotypes.dat';

### Run genotype format transforming ###
#`perl 02_trans_similated_data_format.pl $data_output_dir/$BC1F1_geno_out`;

my $pre_geno_file = "$data_output_dir/$BC1F1_geno_out";
&trans_geno_format($pre_geno_file);


### Run Individual selection ###
my $BC1F1_geno_out_trans = $BC1F1_geno_out.'.transform';
my $indiv_info = $pop_generation_prefix.'.indiv_info';

system(qq(perl RiceNavi-SampleSelect.pl $data_output_dir/$BC1F1_geno_out_trans $selected_gene_list $pop_generation_prefix > ./$data_output_dir/$indiv_info));

#### Remove useless files  ####
system(qq(rm -f $data_output_dir/*.dat));
system(qq(rm -f $data_output_dir/*.hsa));
system(qq(rm -f $data_output_dir/*.hsb));
system(qq(rm -f $data_output_dir/*.ped));
#system(qq(rm -f $data_output_dir/*.gen));
system(qq(rm -f $data_output_dir/*.par));

##############
##############
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