open IN, "$ARGV[0]" or die "Table?";
open OUT, ">$ARGV[0].fa";
open OUT1, ">$ARGV[0].len";

while(<IN>){
  chomp;
  $line++;
  @tmp = split/\t/;
  if($line == 1){
    for $i (11..$#tmp){
      $tit{$i} = $tmp[$i];
    }
  }else{
    for $i (11..$#tmp){
    	if(length $tmp[$i] ne 2){
    	  print "$tit{$i}\t$line\n";	
    	}
      $seq{$tit{$i}} .= $tmp[$i];
    }
  }
}

foreach $tit (sort keys%seq){
	$len = length $seq{$tit};
	print OUT1 "$tit\t$len\n";
   print OUT ">$tit\n$seq{$tit}\n";
}