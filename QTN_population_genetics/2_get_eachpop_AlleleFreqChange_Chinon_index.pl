open IN, $ARGV[0] or die "diff group allele count?";
open OUT, ">$ARGV[0].Hdiversity";
open OUT1, ">$ARGV[0].AlterAF";


while(<IN>){
  chomp;
  $lines++;
  @tmp = split/\t/;
  if($lines == 1){
    print OUT "$_\n";	
    print OUT1 "$_\n";	
  }else{
   # $H_values = '';
    for $i (0..$#tmp){
      print OUT "$tmp[$i]\t";
      print OUT1 "$tmp[$i]\t";
    }
    for $i (7..$#tmp){
      $count = $tmp[$i];
      $H_value = &cal_Shannon_index($count);
      $allele_freq = &alt_freq($count);
      print OUT "$H_value\t";
      print OUT1 "$allele_freq\t";
    }
    print OUT "\n";
    print OUT1 "\n";

  }
}


sub alt_freq {
  ($count_info) = @_;
   ($alt,$het,$ref) = split/\|/,$count_info;
   $NO_alt_alleles = 2*$alt + $het;
   $NO_ref_alleles = 2*$ref + $het;
   $all_NO_alleles = $NO_alt_alleles + $NO_ref_alleles;
   if($all_NO_alleles > 0){
     $alt_freq = sprintf("%.4f",$NO_alt_alleles/$all_NO_alleles);
   }else{
     $alt_freq = 'NA';
   }
}




sub cal_Shannon_index {
   ($count_info) = @_;
   ($alt,$het,$ref) = split/\|/,$count_info;
   $NO_alt_alleles = 2*$alt + $het;
   $NO_ref_alleles = 2*$ref + $het;
   if($NO_alt_alleles + $NO_ref_alleles == 0){
    $H_index = 'NA'; 	
   }else{
     $alt_pct = $NO_alt_alleles/($NO_alt_alleles + $NO_ref_alleles);
     $ref_pct = $NO_ref_alleles/($NO_alt_alleles + $NO_ref_alleles);
     if($alt_pct == 0){
       $H_index = -1 * ($ref_pct*log($ref_pct));
     }
     elsif($ref_pct == 0){
       $H_index = -1 * ($alt_pct*log($alt_pct));	
     }
     else{
       $H_index = -1 * ($alt_pct*log($alt_pct) + $ref_pct*log($ref_pct));  	
     }
     $H_index = sprintf("%.4f",$H_index);
   }
   return $H_index;
}