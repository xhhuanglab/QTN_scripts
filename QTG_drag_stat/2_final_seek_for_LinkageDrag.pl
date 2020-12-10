## Get effects of paired QTGs within 2Mb physical distance

open IN, $ARGV[0] or die "Bad or Good Genotype";
open OUT, ">$ARGV[0].linkageDrag.2Mb";

while(<IN>){
  chomp;
  @tmp = split/\t/;
  ($chrom,$posi,$genename,$method) = @tmp[0,1,3,4];
  $loci2gene{$chrom."\t".$posi} = $genename;
  push @{$chrom},$posi;
  $line++;
  if($line == 1){
  	#print "$_\n";
    for $i (5..$#tmp){
      $num2id{$i} = $tmp[$i];
      push @samples,$tmp[$i];
    }	
  }else{
    for $i (5..$#tmp){
      $geno{$chrom."\t".$posi}{$num2id{$i}} = $tmp[$i];
    }	
  }	
}

for $chrid (1..12){
  $chrom = "Chr$chrid";
  @eachchr_posi = sort {$a<=>$b} @{$chrom};
  print scalar @eachchr_posi."\n";
  for $j (0..$#eachchr_posi - 1){
    for $k ($j+1..$#eachchr_posi){
    	 $loci1 = $eachchr_posi[$j];
    	 $loci2 = $eachchr_posi[$k];
    	 if(abs($loci2 - $loci1) <= 2e6){
    	    $chrom_loci1 = "$chrom\t$loci1";
    	    $chrom_loci2 = "$chrom\t$loci2";
    	    $combined_loci = $chrom_loci1."\t".$chrom_loci2;
    	    print "$combined_loci\n";
    	    push @loci,$combined_loci;
    	    $gene1 = $loci2gene{$chrom_loci1};
    	    $gene2 = $loci2gene{$chrom_loci2};
    	    $combined_genes{$combined_loci} = "$gene1\t$gene2";
    	    foreach $sample (@samples){
    	      $sp_gene1_geno = $geno{$chrom_loci1}{$sample};	
    	      $sp_gene2_geno = $geno{$chrom_loci2}{$sample};
    	      $combined_geno{$combined_loci}{$sample} = "$sp_gene1_geno\|$sp_gene2_geno";
    	     # print OUT "$combined\t";
    	    }
    	 }
    }	
  }	
}

print OUT "Gene1_Chrom\tGene1_MidPoint\tGene2_Chrom\tGene2_MidPoint\tGene1\tGene2\t";
$sampleslist = join ("\t",@samples);
print OUT "$sampleslist\n";
foreach $two_loci (@loci){
   print OUT "$two_loci\t$combined_genes{$two_loci}\t";
   foreach $sample (@samples){
     $com_geno = $combined_geno{$two_loci}{$sample};
     print OUT "$com_geno\t";	
   }
   print OUT "\n";
}

