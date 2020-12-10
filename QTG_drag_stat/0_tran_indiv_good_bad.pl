## Transform genotype (0/0 or 1/1) matrix to Good or Bad Matrix

open IN, 'final_sorted_322sites.geno';
open OUT, ">FMT.final_sorted_322sites.geno";



$head = <IN>; chomp $head;
@head = split/\t/,$head;
for $i (17..$#head){
  $samples .= $head[$i]."\t";	
}

print OUT "GeneID\tGeneName\tChrom\tStart\tEnd\tMidpoint\tCausalSite\tMethod\t$samples\n";

while(<IN>){
  chomp;
  @tmp = split/\t/;
  ($geneid,$genename,$chrom,$start,$end,$causal_site,$method,$eff) = @tmp[0,3,5,6,7,13,14,4];
  $midpoint = int(0.5*($start + $end));
  $combined_info = "$geneid\t$genename\t$chrom\t$start\t$end\t$midpoint\t$causal_site\t$method";
  $genos = '';
  if($method ne "Manta"){
    if($eff eq 't'){
    	print OUT "$combined_info\t";
      for $i (17..$#tmp){
        $geno = $tmp[$i];
        if($geno eq '1|1'){
          print OUT "Good\t"	
        }
        elsif($geno eq '0|0'){
          print OUT "Bad\t";	
        }
        else{
          print OUT "NA\t";	
        }
      }
      print OUT "\n";   	
    }
    elsif($eff eq 'f'){
      print OUT "$combined_info\t";
      for $i (17..$#tmp){
        $geno = $tmp[$i];
        if($geno eq '1|1'){
          print OUT "Bad\t"	
        }
        elsif($geno eq '0|0'){
          print OUT "Good\t";	
        }
        else{
          print OUT "NA\t";	
        }
      }
      print OUT "\n";    
    }
  }
  elsif($method eq 'Manta'){
    if($eff eq 't'){
    	print OUT "$combined_info\t";
      for $i (17..$#tmp){
        $geno = $tmp[$i];
        if($geno eq '|'){
          print OUT "Bad\t";	
        }
        else{
          print OUT "Good\t";	
        }
      }
      print OUT "\n";   	
    }
    elsif($eff eq 'f'){
      print OUT "$combined_info\t";
      for $i (17..$#tmp){
        $geno = $tmp[$i];
        if($geno eq '|'){
          print OUT "Good\t";
        }
        else{
          print OUT "Bad\t";	
        }
      }
      print OUT "\n";    
    }    	
  } 
}