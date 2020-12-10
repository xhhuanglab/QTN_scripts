opendir DIR, './';

foreach (readdir DIR){
  if(/^(.+)\.bim$/){
  	print "$1\n";
  	$tmp_file = "tmp.$_";
  	system(qq(mv $_ $tmp_file));
    open IN, $tmp_file or die;
    open OUT, ">$_";
    while(<IN>){
      chomp;
      @tmp = split/\t/;
      $snpid = $tmp[0].'_'.$tmp[3];
      s/\./$snpid/;
      print OUT "$_\n";	
    }
  }
}

system(qq(rm -f tmp.*));
