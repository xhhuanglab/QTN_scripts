open IN, $ARGV[0] or die "vcf?";


if($ARGV[0] =~ /(.+)\/(.+?)\./){
  $prefix = $2;
}
elsif($ARGV[0] =~ /(.+?)\./){
 	$prefix = $1;
}
open OUT, ">$prefix.count";

opendir DIR, './';
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

print OUT "Chr\tbase\tRef\tAlt\t";
foreach $region (@regions){
  print OUT "$region\t";	
}
print OUT "\n";

while(<IN>){
  chomp;
  @tmp = split/\t/;
  if(/^#CHROM/){
  	for $i (9..$#tmp){
 # 	  $col2tit{$i} = $tmp[$i];
  	  $tit2col{$tmp[$i]} = $i;
  	}
  }
  elsif(/^chr/i){
  	$loci = $tmp[0]."\t".$tmp[1];
    $refbase = $tmp[3];
    $alterbase = $tmp[4];	
    print OUT "$loci\t$refbase\t$alterbase\t";
    foreach $region (@regions){
    	$region_alter = 0;
    	$region_heter = 0;
    	$region_ref = 0;
      foreach $line (@{$region}){
        if($tmp[$tit2col{$line}] =~ /1\/1/){
          $region_alter++;	
        }
        elsif($tmp[$tit2col{$line}] =~ /0\/1/){
          $region_heter++;	
        }
        elsif($tmp[$tit2col{$line}] =~ /0\/0/){
          $region_ref++;	
        }	
      }
     print OUT "$region_alter\|$region_heter\|$region_ref\t";
    }
    print OUT "\n";
  }
}
