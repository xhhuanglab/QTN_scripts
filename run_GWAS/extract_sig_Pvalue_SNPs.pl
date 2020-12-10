opendir DIR, './';
$exp_id = shift or die "Apop_GWAS?";
$pvalue = shift or die "Pvalue?";

open OUT, ">$exp_id.Combined_Sig_SNPinfo.$pvalue.sig";
foreach (readdir DIR){
	if(/(.+)\.fastGWA/){
	  $prefix = $1;
	  print "$prefix\n";
	  print OUT "$prefix SigSNP summary (Pvalue: $pvalue)\n";
	  $count = 0;
	  open IN, $_ or die;
	  while(<IN>){
	    chomp;
	    @tmp = split/\t/;
      if($tmp[-1] < $pvalue and $tmp[6] >= 0.05){
      	$count++;
        print OUT "$prefix\t$_\n";	
      }    	
	  }
	  close IN;
	  $count_sigSNPs = $count;
	  print OUT "$prefix SigSNP: $count_sigSNPs\n\n";	
	}
}
