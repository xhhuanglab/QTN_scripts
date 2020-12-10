open IN, "$ARGV[0]" or die "Input Genotype data\n";
open SAM, ">sampleid";
open SNP, '>snpid';
open SNP_POS, '>snp_pos';
open SNP_CHRO, '>snp_chromosome';
open SNP_ALLE, '>snp_alleles';
open GENO, '>genotypes';

print SNP "snps\n";
print SNP_POS "positions\n";
print SNP_CHRO "chromosomes\n";
print SNP_ALLE "alleles\n";

while(<IN>){
  chomp;
  @tmp = split/\t/;
  $lines++;
  next if /\,/;
  if(/(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+)/){
    ($snpmakers,$alleles,$snp_chr,$snp_pos,$genos) = ($1,$2,$3,$4,$12);
    if($lines == 1){
      my @samples = split/\t/,$genos;
      print SAM "samples\n";   ###print samples
      foreach (@samples){
        print SAM "$_\n";
      }	
    }else{
      print SNP "$snpmakers\n";  ###print snpsids
      print SNP_POS "$snp_pos\n";
      print SNP_CHRO "$snp_chr\n";
      print SNP_ALLE "$alleles\n";
      $geno1 = substr($alleles,0,1);
      $geno2 = substr($alleles,2,1); 
      
      $genos =~ s/$geno1$geno1/0/g;
      $genos =~ s/$geno1$geno2/1/g;
      $genos =~ s/$geno2$geno1/1/g;
      $genos =~ s/$geno2$geno2/2/g;
      $genos =~ s/--/3/g;
      print GENO "$genos\n";
    }	
  }
}