## Simplify effect of QTG with multiple QTNs

open IN, 'FMT.final_sorted_322sites.geno';
open OUT, ">condensed.FMT.final_sorted_322sites.geno";

while(<IN>){
  chomp;
  @tmp = split/\t/;
  ($locid,$genename,$chrom,$midpoint,$method) = @tmp[0,1,2,5,7];
  $loci = $chrom."\t".$midpoint;
  $all_geneloci{$loci}++;
  $loci2info{$loci} = "$locid\t$genename\t$method";
  $count++;
  if($count == 1){
    for $i (8..$#tmp){
      $num2id{$i} = $tmp[$i];
      push @samples,$tmp[$i];
    }	
  }else{
    for $i (8..$#tmp){
      $geno{$loci}{$num2id{$i}} .= "$tmp[$i]\|";	
    }
  }
}

foreach $loci (sort keys%all_geneloci){
	print OUT "$loci\t$loci2info{$loci}\t";
	foreach $sample (@samples){
	  $geno = $geno{$loci}{$sample};
	  $condensed_geno = &condense_geno($geno);
	  print OUT "$condensed_geno\t";	
	}
	print OUT "\n";
}


sub condense_geno {
  my ($geno) = @_;
  %hash = ();
  @genos = split/\|/,$geno;
  for my $j (0..$#genos){
    $hash{$genos[$j]}++;	
  }
  my $count = scalar keys%hash;
  my @condensed_geno = sort keys%hash;
  #print "$count\t";
  if($count == 1){
    $final_geno = $condensed_geno[0];	
  }else{
    $final_geno = 'NA';	
  }
  return $final_geno;
}