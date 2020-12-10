$faststructure = '/data/home/qiujie/biosoftwares/fastStructure/rajanil-fastStructure-e47212f/structure.py';

if(@ARGV < 2){
  die "Usage: perl $0 <Kvalue> <input(XX.str)>";	
}else{
  ($Kvalue,$input) = @ARGV;	
}

$prefix = $1 if $input =~ /(.+)\.str/;
	
system(qq(python $faststructure -K $Kvalue --input=$prefix --output=$prefix.out --format=str));