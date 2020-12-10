open CNS, 'all-sing-score.bed';
#open IN, 'QTN_base.rho_score';
open IN, 'Intergenic_UD2k.sites';
open OUT, '>Intergenic_UD2k.cnspipeline_value';


while(<CNS>){
  chomp;
  @tmp = split/\t/;
  $chromid = $1 if $tmp[0] =~ /Osativa\.(.+)/;
  $cns_score{$chromid."\t".$tmp[1]} = $tmp[3];	
}

while(<IN>){
  chomp;
  @tmp = split/\t/;
  $site = $tmp[0]."\t".$tmp[1];
  $score = $cns_score{$site} || 'NA';
  print OUT "$_\t$score\n";
}
