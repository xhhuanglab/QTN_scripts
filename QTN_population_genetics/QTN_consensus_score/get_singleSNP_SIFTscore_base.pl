open IN, 'Final.RiceMSUv7.all_12chrs.siftscore';

while(<IN>){
  chomp;
  @tmp = split/\t/;
  $sift_score{$tmp[0]."\t".$tmp[1]."\t".$tmp[2]."\t".$tmp[3]} = $tmp[-1];
}


open IN1, '181QTG_sites.SNPeff';
open OUT, ">181QTG_sites.SIFTscore";


while(<IN1>){
  chomp;
  @tmp = split/\t/;
  $loci = "$tmp[0]\t$tmp[1]\t$tmp[2]\t$tmp[3]";
  $score = $sift_score{$loci} || 'NA';
  print OUT "$_\t$score\n";	
}