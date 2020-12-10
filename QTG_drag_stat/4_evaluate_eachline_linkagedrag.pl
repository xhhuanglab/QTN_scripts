## Stat different effect types of paired QTGs across 404 samples

open IN, $ARGV[0] or die "filtered_ordered_Good_Bad_genes.geno.linkageDrag";
open OUT, ">$ARGV[0].sample_good_badinfo";

$header = <IN>; chomp $header;
while(<IN>){
	chomp;
	@tmp = split/\t/;
	$info = "$tmp[0]\t$tmp[1]\t$tmp[2]\t$tmp[3]\t$tmp[4]\t$tmp[5]";
	for $i (6..$#tmp){
	#	print "$tmp[$i]\t";
	  $types{$tmp[$i]}++;
	  $count{$info}{$tmp[$i]}++;
	}
	push @infos,$info;
}

print OUT "Gene1_Chrom	Gene1_MidPoint	Gene2_Chrom	Gene2_MidPoint	Gene1	Gene2\t";
foreach $type (sort keys%types){
  print OUT "$type\t";	
}
print OUT "\n";

foreach $info (@infos){
	 print OUT "$info\t";
   foreach $type (sort keys%types){
     	$count = $count{$info}{$type} || 0;
     	print OUT "$count\t";
   }
   print OUT "\n";
}