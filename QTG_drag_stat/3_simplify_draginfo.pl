## Simplify paired effect (Good|Bad Bad|Good) --> Bad|Good

open IN, $ARGV[0] or die ".2M";
open OUT, ">$ARGV[0].info";

$head = <IN>; chomp $head;
print OUT "$head\n";

while(<IN>){
 	chomp;
  @tmp = split/\t/;
  print OUT "$tmp[0]\t$tmp[1]\t$tmp[2]\t$tmp[3]\t$tmp[4]\t$tmp[5]\t";
  for $i (6..$#tmp){
    $info = $tmp[$i];
    $final_info = &sort_info($info) if length $info > 0;
    print OUT "$final_info\t";
  }
  print OUT "$final_info\n";
}

sub sort_info {
  my ($info) = @_;
  my @info = split/\|/,$info;
  my @sorted_info = sort @info;
  my $join_info = join("\|",@sorted_info);	
  return $join_info;
}