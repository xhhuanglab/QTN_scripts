open IN, 'rho_osaj_position';

while(<IN>){
  chomp;
  @tmp = split/\t/;
  ($chrom,$start,$end,$score) = @tmp[0,1,2,3];
  for	$i ($start..$end){
    $loci2score{$chrom."\t".$i} = $score;	
  }
}

open IN1, '268_QTN_sites';
#open IN1, 'test.sites';

while(<IN1>){
  chomp;
  @tmp = split/\t/;
  $geneid = "$tmp[0]\_$tmp[1]\_$tmp[5]";
  open $geneid, ">$geneid.UD2k.basescore";
  $causal_score = $loci2score{$tmp[2]."\t".$tmp[5]};
  print $geneid "$_\t$causal_score\n";
  for $j (($tmp[3] - 2000 - 1) .. ($tmp[3]-1)){
    $loci = $tmp[2]."\t".$j;
    $score = $loci2score{$loci} || 'NA';
    print $geneid "$loci\tUD2k\t$score\n";
  }
  for $j ($tmp[3]..$tmp[4]){
    $loci = $tmp[2]."\t".$j;
    $score = $loci2score{$loci} || 'NA';
    print $geneid "$loci\tGeneBody\t$score\n";	
  }
  for $j (($tmp[4] + 1) .. ($tmp[4]+2000)){
    $loci = $tmp[2]."\t".$j;
    $score = $loci2score{$loci} || 'NA';
    print $geneid "$loci\tUD2k\t$score\n";
  }
}