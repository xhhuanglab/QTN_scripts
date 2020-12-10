#!/usr/bin/perl

################# RiceNavi-SampleSelect ###############################################################################
#  Usage: perl RiceNavi-SampleSelect.pl example_genotyping_matrix.geno DTH8_xa5.loci PrefixName > example_genotyping_matrix.indiv_info
# 
#  Inputs:
#  (1) BCnF1.geno: genotyping matrix of BCnF1. The format is as follows:
#      Indiv Sample1 Sample2  ..  SampleN
#  Chr1_win1   0        1     ..    1
#  Chr1_win2   1        0     ..    0
#  ..
#  Chr12_winN   0       1     ..    1
#  
#  (2) Selected_gene.loci: The locations (Rice MSUv7) of genes selected by Users.
#  The format is like:
#  LOC_Os08g07740	DTH8	chr8	4333717	4335434
#  LOC_Os05g01710	xa5	Chr5	437010	443270
#
#  Output: Summarized genotype characteristics for each individual. The individuals are ordered based on Heterozygosity Percentage.
#          including  (1) No. genes targeted by heterozygous regions
#                     (2) No. recombination breakpoints
#                     (3) No. heterozygous genomic blocks
#                     (4) Heterozygosity Percentage across the whole genome
#                     (5) Homozygous (Donor genotype) percentage across the whole genome
#                     (6) Size of the heterozygous regions covering the targeted genes
#                     (7) Whether all the selected genes are covered by heterozygous regions
#  Format example:
#  Indiv	Selected_genes	Breakpoint_Count	Het_regions_count	Heterozygosity_Percent	Homo_donor_Pct	DTH8(8|4.33)	xa5(5|0.44)	Y_or_N
#  BC1F1_133	1 | 2	11	11	0.336986	0.000000	(20.7)8_0|8_20.7	(0.0)|	N
#  BC1F1_96	1 | 2	10	10	0.337900	0.000000	(25.2)8_3|8_28.2	(0.0)|	N
#  BC1F1_1	1 | 2	18	14	0.341553	0.000000	(0.0)|	(6.0)5_0|5_6	N
#  BC1F1_17	2 | 2	11	10	0.346119	0.000000	(5.4)8_0|8_5.4	(1.5)5_0|5_1.5	Y  
#
####################################################################################################################

my ($geno,$genelist,$generation_prefix);
my (@candidates,@indivs,@two_dim_geno);

my (%gene2chrom,%gene2start,%gene2end,%gene2midpoint,%lineinfo,%chrom2posi,%chrom,%chrom2len);
my (%count_gene_targets,%num2tit,%indivgeno,%indiv2break,%all_chrom_geno);
my (%gene2leftline,%gene2rightline);
my (%gene2line);
my %line2posi;
my (%leftloci,%rightloci);
my %count_het_regions;

if(@ARGV < 3){
  die "Usage: perl $0 <Genotyping Matrix> <Genelist> <OutPrefix> > OutFile";	
}else{
  ($geno,$genelist,$generation_prefix) = @ARGV;	
}



open LIST, $genelist;
while(<LIST>){
  chomp;
  s/ //;
  next if /^\#/;
  my ($geneid,$genename,$chrom,$start,$end) = split/\t/;
  $chrom =~ s/chr0|chr//i;
  $start =~ s/\,//g; $end =~ s/\,//g;
  push @candidates,$genename;
  $gene2chrom{$genename} = $chrom;
  $gene2start{$genename} = $start;
  $gene2end{$genename} = $end;
  $gene2midpoint{$genename} = int(0.5*($start + $end));
}


my $No_selected_genes = scalar @candidates;



open GENO, $geno;
my ($countline);
while(<GENO>){
  chomp;
  $countline++;
  my @tmp = split/\t/;
  if($countline == 1){
    for my $i (1..$#tmp){
      $num2tit{$i} = $tmp[$i];	
      push @indivs,$tmp[$i];
    }	
  }else{
  	for my $i (1..$#tmp){
      push @{$indivgeno{$num2tit{$i}}},$tmp[$i];
    }
    my ($chrom,$posi) = ($1,$2) if $tmp[0] =~ /(.+?)_(.+)/;
    $chrom{$chrom} = 1;
    push @{$chrom2posi{$chrom}},$posi;
    $line2posi{$countline} = $chrom."_".$posi;
    my @geno = split/\t/,$2 if /(.+?)\t(.+)/;
    push @two_dim_geno, [@geno];   
  }
}



foreach (sort {$a<=>$b} keys%chrom){
  $chrom2len{$_} = ${$chrom2posi{$_}}[-1];	
}

for my $i (0..$#indivs){
  for my $j (0..$#two_dim_geno - 1){
  	my $pre_loci = $line2posi{$j + 2};   
    my $after_loci = $line2posi{$j + 3};

    my ($pre_chrom,$pre_base) = ($1,$2) if $pre_loci =~ /(.+?)_(.+)/;
    my ($after_chrom,$after_base) = ($1,$2) if $after_loci =~ /(.+?)_(.+)/;

    foreach my $genename (@candidates){
    	if($gene2chrom{$genename} eq $pre_chrom and 
    	$gene2midpoint{$genename} >= $pre_base * 1e6 and $gene2midpoint{$genename} < $after_base*1e6){
    	  $gene2line{$genename} = $j + 2;
    	  if($two_dim_geno[$j][$i] eq '1'){
    	    $count_gene_targets{$indivs[$i]}++;
    	  }	
    	}
    }
    
  	$all_chrom_geno{$indivs[$i]}{$pre_chrom} .= $two_dim_geno[$j][$i];
    if($two_dim_geno[$j][$i] ne $two_dim_geno[$j+1][$i]){  
    	if($pre_chrom eq $after_chrom){
       push @{$indiv2break{$indivs[$i]}},$j+2; 
    	}
    }
  }
  my $loci = $line2posi{$#two_dim_geno + 2};
  my $chrom = $1 if $loci =~ /(.+?)_/;
  $all_chrom_geno{$indivs[$i]}{$chrom} .= $two_dim_geno[$#two_dim_geno][$i];
  #print "$all_chrom_geno{$indivs[$i]}{$chrom}\n";
  next if not defined $indiv2break{$indivs[$i]};
  #print "$indivs[$i]\n";
  if(scalar @{$indiv2break{$indivs[$i]}} >= 2){ 
  	
    foreach my $gene (@candidates){
    	my $geneline = $gene2line{$gene};
    	my ($breakline1,$breakline2);
    	if($two_dim_geno[$geneline - 2][$i] eq '1'){
       for my $k (0..$#{$indiv2break{$indivs[$i]}}){
       	$breakline1 = ${$indiv2break{$indivs[$i]}}[$k];
       	$breakline2 = ${$indiv2break{$indivs[$i]}}[$k + 1]; 
         my $breakline1_chrom = $1 if $line2posi{$breakline1} =~ /(.+?)_(.+)/;
         my $breakline2_chrom = $1 if $line2posi{$breakline2} =~ /(.+?)_(.+)/;
         
         if($breakline1 < $geneline and $breakline2 >= $geneline){
    
         	  if($gene2chrom{$gene} eq $breakline1_chrom and $gene2chrom{$gene} eq $breakline2_chrom){  
               $leftloci{$indivs[$i]}{$gene} = $line2posi{${$indiv2break{$indivs[$i]}}[$k]+1};
               $rightloci{$indivs[$i]}{$gene} = $line2posi{${$indiv2break{$indivs[$i]}}[$k+1]+1};
         	  }
         	  elsif($gene2chrom{$gene} eq $breakline1_chrom and $gene2chrom{$gene} < $breakline2_chrom){ 
         	    $leftloci{$indivs[$i]}{$gene} = $line2posi{${$indiv2break{$indivs[$i]}}[$k]+1};
         	    $rightloci{$indivs[$i]}{$gene} = $gene2chrom{$gene}.'_'.$chrom2len{$gene2chrom{$gene}};
         	  }
         	  elsif($gene2chrom{$gene} > $breakline1_chrom and $gene2chrom{$gene} eq $breakline2_chrom){ 
         	    $leftloci{$indivs[$i]}{$gene} = $gene2chrom{$gene}.'_0';
         	    $rightloci{$indivs[$i]}{$gene} = $line2posi{${$indiv2break{$indivs[$i]}}[$k+1]+1};      	  	
         	  }
         	  elsif($gene2chrom{$gene} > $breakline1_chrom and $gene2chrom{$gene} < $breakline2_chrom){ 
         	    $leftloci{$indivs[$i]}{$gene} = $gene2chrom{$gene}.'_0';
         	    $rightloci{$indivs[$i]}{$gene} = $gene2chrom{$gene}.'_'.$chrom2len{$gene2chrom{$gene}};     	  	
         	  }
         }              
         elsif(${$indiv2break{$indivs[$i]}}[0] >= $geneline and $gene2chrom{$gene} eq $breakline1_chrom){
         	  $leftloci{$indivs[$i]}{$gene} = $gene2chrom{$gene}.'_0';
         	  $rightloci{$indivs[$i]}{$gene} = $line2posi{${$indiv2break{$indivs[$i]}}[0]+1}; 
         }
         elsif(${$indiv2break{$indivs[$i]}}[-1] < $geneline and $gene2chrom{$gene} eq $breakline2_chrom){ 
         	  $leftloci{$indivs[$i]}{$gene} = $line2posi{${$indiv2break{$indivs[$i]}}[-1]}; 
         	  $rightloci{$indivs[$i]}{$gene} = $gene2chrom{$gene}.'_'.$chrom2len{$gene2chrom{$gene}};	
         }
       }
      }
    }
  }
  elsif(scalar @{$indiv2break{$indivs[$i]}} == 1){  
    foreach my $gene (@candidates){
    	my $geneline = $gene2line{$gene};
    	if($two_dim_geno[$geneline - 2][$i] eq '1'){
    	  my $breakline = ${$indiv2break{$indivs[$i]}}[0];
    	  my $breakline_chrom = $1 if $line2posi{$breakline} =~ /(.+?)_(.+)/;
    	  if($breakline >= $geneline and $gene2chrom{$gene} eq $breakline_chrom){
         	  $leftloci{$indivs[$i]}{$gene} = $gene2chrom{$gene}.'_0';
         	  $rightloci{$indivs[$i]}{$gene} = $line2posi{$breakline + 1};     	    	
    	  }
    	  elsif($breakline < $geneline and $gene2chrom{$gene} eq $breakline_chrom){
         	  $leftloci{$indivs[$i]}{$gene} = $line2posi{$breakline + 1}; 
         	  $rightloci{$indivs[$i]}{$gene} = $gene2chrom{$gene}.'_'.$chrom2len{$gene2chrom{$gene}};	    	    	
    	  }
    	}
    }
  }
}


my %indiv_het_pct;
my %combined_info;


foreach my $indiv (@indivs){
	my %genocount;
	my $combined_posi = '';
	my $count_targets = $count_gene_targets{$indiv} || 0;
	my $pct_count_targets = $count_targets.' | '.$No_selected_genes;
	my @genos = @{$indivgeno{$indiv}};
	my $total_breaks = 0;
	if($indiv2break{$indiv}){$total_breaks = scalar @{$indiv2break{$indiv}};}
	#my $total_breaks = scalar @{$indiv2break{$indiv}};
	my $count = scalar @genos;
	foreach (@genos){$genocount{$_}++};
	
	my $het_pct = sprintf("%.6f",$genocount{'1'}/scalar @genos);
	my $homo_count = $genocount{'2'} || 0;
	my $inbreed_pct = sprintf("%.6f",$homo_count/scalar @genos);  
	$indiv_het_pct{$indiv} = $het_pct;
	my $selected_mark = ($count_targets == $No_selected_genes 
	and $inbreed_pct < 0.01)?'Y':'N';
  
  foreach my $chrom (sort {$a<=>$b} keys%chrom){
  	if($all_chrom_geno{$indiv}{$chrom} =~ /^1+$/){
  		$count_het_regions{$indiv}++;
  	}else{
  	  my @break_patterns = split/0+/, $all_chrom_geno{$indiv}{$chrom};
      foreach (@break_patterns){
        $count_het_regions{$indiv}++ if /1/; 
      }
  	}
  }
 
  
  my $count_het_regions = $count_het_regions{$indiv} || 0;
  foreach my $gene (@candidates){
    my $gene_left_break = $leftloci{$indiv}{$gene};
    my $left_posi = $1 if $gene_left_break =~ /_(.+)/;
    my $gene_right_break = $rightloci{$indiv}{$gene};
    my $right_posi = $1 if $gene_right_break =~ /_(.+)/;
    my $range_size = sprintf("%.1f",$right_posi - $left_posi);   
    $combined_posi .= "($range_size)$gene_left_break|$gene_right_break\t";
  }
  chop $combined_posi;
  my $combined_info = "$indiv\t$pct_count_targets\t$total_breaks\t$count_het_regions\t$het_pct\t$inbreed_pct\t$combined_posi\t$selected_mark";
  $combined_info{$indiv} = $combined_info;
}


print  "Indiv\tSelected_genes\tBreakpoint_Count\tHet_regions_count\tHeterozygosity_Percent\tHomo_donor_Pct\t";
my $genetits = '';
foreach my $gene (@candidates){
	my $start = sprintf("%.2f",$gene2start{$gene}/1000000);
  $genetits .= $gene.'('.$gene2chrom{$gene}.'|'.$start.')'."\t";
}
chop $genetits;
print  "$genetits\tY_or_N\n";

foreach my $indiv (sort {$indiv_het_pct{$a}<=>$indiv_het_pct{$b}} keys%indiv_het_pct){
    print  "$combined_info{$indiv}\n";	
}
