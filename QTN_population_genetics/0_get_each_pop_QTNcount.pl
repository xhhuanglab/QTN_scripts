opendir DIR, './';
open IN, 'wild_landrace_variety_QTNinfo.matrix';
open OUT, ">wild_landrace_variety.genomatrix.count";

foreach (readdir DIR){
  if(/(.+)\.names$/){
  	$region = $1;
  	push @regions,$region;
    open IN1, $_ or die;
    while(<IN1>){
      chomp;
      push @{$region},$_;
    }	
  }	
}


print OUT "Chr\tbase\tMethod\tRef\tAlt\tEffect\tGeneName\t";
foreach $region (@regions){
  print OUT "$region\t";	
}
print OUT "\n";



while(<IN>){
  chomp;
  $lines++;
  @tmp = split/\t/;
  if($lines == 1){
    for $i (7..$#tmp){
  	  $tit2col{$tmp[$i]} = $i;
  	}
  }else{
  	$info = '';
    for $i (0..6){
      $info .= "$tmp[$i]\t";	
    }
    chop $info;
    print OUT "$info\t";
      foreach $region (@regions){
        $alt = 0; $het = 0; $ref = 0;
          if($tmp[3] eq 'Manta'){
            foreach $line (@{$region}){
              if($tmp[$tit2col{$line}] eq '|'){
                $ref++;	
              }else{
                $alt++;	
              }	
            }
          }
          else{
            foreach $line (@{$region}){
              if($tmp[$tit2col{$line}] eq '1|1'){
                $alt++;	
              }
              elsif($tmp[$tit2col{$line}] eq '0|1'){
                $het++;	
              }
              elsif($tmp[$tit2col{$line}] eq '0|0'){
                $ref++;	
              }
            }
          }
        print OUT "$alt\|$het\|$ref\t";	
      }
    print OUT "\n";
  }	
}