if(@ARGV < 3){
  die "Usage: perl $0 <Bam> <genome_size> <outdir>";	
}else{
  ($bamfile,$genome_size,$outdir) = @ARGV;	
}

system(qq(macs2 callpeak -f BED -t $bamfile -n $bamfile -g $genome_size --outdir $outdir --nomodel --extsize 147 --bdg -q 0.05));