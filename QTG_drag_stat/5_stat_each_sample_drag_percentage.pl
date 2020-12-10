## Stat number of different types of QTG effect for each sample

open IN, $ARGV[0] or die "2M.info";
open OUT, ">$ARGV[0].samplepercent";
while(<IN>){
  chomp;
  $count++;
  @tmp = split/\t/;
  if($count == 1){
    for $i (6..$#tmp){
      $num2tit{$i} = $tmp[$i];
      push @samples,$tmp[$i];
    }	
  }else{
    for $i (6..$#tmp){
      push @{$num2tit{$i}},$tmp[$i];	
    }	
  }	
}

print OUT "Sample\t";
foreach $type (sort keys%types){
  print OUT "$type\t";	
}
print OUT "\n";

foreach $sample (@samples){
	%types = ();
  $total_pairs = scalar @{$sample};
  $count = 0;
  foreach (@{$sample}){
  	$types{$_}++;
  }
  
  print OUT "$sample\t";
  foreach $type (sort keys%types){
    print OUT "$types{$type}\t";	
  }
  print OUT "\n";

}