open IN, $ARGV[0] or die;
open OUT, ">$ARGV[0].freq";

while(<IN>){
  chomp;
  @tmp = split/\t/;
  $freqs = '';
  $lines++;
#  print OUT "$_\n" if $lines == 1;
  next if $lines == 1;
  for $i (7..$#tmp){
    $geno = $tmp[$i];
    print "$geno\n";
    ($alt,$het,$ref) = split/\|/,$geno;
    if($geno eq '0|0|0'){
      $freq = 'N.A.';
    }else{
      $freq = (2*$alt+$het)/(2*($alt+$het+$ref));	
    }
    $freqs .= sprintf("%.4f",$freq)."\t";	
  }
  print OUT "$_\t$freqs\n";
}