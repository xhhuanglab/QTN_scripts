mkdir Chr1.gatk_tmp
java -Djava.io.tmpdir=./Chr1.gatk_tmp/ -Xmx500g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr1.MSUv7_404lines_SNP.vcf -nct 6 -nt 6 -stand_call_conf 30 -L Chr1 -glm SNP &
mkdir Chr2.gatk_tmp
java -Djava.io.tmpdir=./Chr2.gatk_tmp/ -Xmx500g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr2.MSUv7_404lines_SNP.vcf -nct 6 -nt 6 -stand_call_conf 30 -L Chr2 -glm SNP
mkdir Chr3.gatk_tmp
java -Djava.io.tmpdir=./Chr3.gatk_tmp/ -Xmx500g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr3.MSUv7_404lines_SNP.vcf -nct 6 -nt 6 -stand_call_conf 30 -L Chr3 -glm SNP &
mkdir Chr4.gatk_tmp
java -Djava.io.tmpdir=./Chr4.gatk_tmp/ -Xmx500g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr4.MSUv7_404lines_SNP.vcf -nct 6 -nt 6 -stand_call_conf 30 -L Chr4 -glm SNP
mkdir Chr5.gatk_tmp
java -Djava.io.tmpdir=./Chr5.gatk_tmp/ -Xmx500g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr5.MSUv7_404lines_SNP.vcf -nct 6 -nt 6 -stand_call_conf 30 -L Chr5 -glm SNP &
mkdir Chr6.gatk_tmp
java -Djava.io.tmpdir=./Chr6.gatk_tmp/ -Xmx400g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr6.MSUv7_404lines_SNP.vcf -nct 8 -nt 8 -stand_call_conf 30 -L Chr6 -glm SNP
mkdir Chr7.gatk_tmp
java -Djava.io.tmpdir=./Chr7.gatk_tmp/ -Xmx400g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr7.MSUv7_404lines_SNP.vcf -nct 8 -nt 8 -stand_call_conf 30 -L Chr7 -glm SNP &
mkdir Chr8.gatk_tmp
java -Djava.io.tmpdir=./Chr8.gatk_tmp/ -Xmx400g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr8.MSUv7_404lines_SNP.vcf -nct 8 -nt 8 -stand_call_conf 30 -L Chr8 -glm SNP
mkdir Chr9.gatk_tmp
java -Djava.io.tmpdir=./Chr9.gatk_tmp/ -Xmx400g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr9.MSUv7_404lines_SNP.vcf -nct 8 -nt 8 -stand_call_conf 30 -L Chr9 -glm SNP &
mkdir Chr10.gatk_tmp
java -Djava.io.tmpdir=./Chr10.gatk_tmp/ -Xmx400g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr10.MSUv7_404lines_SNP.vcf -nct 8 -nt 8 -stand_call_conf 30 -L Chr10 -glm SNP
mkdir Chr11.gatk_tmp
java -Djava.io.tmpdir=./Chr11.gatk_tmp/ -Xmx400g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr11.MSUv7_404lines_SNP.vcf -nct 8 -nt 8 -stand_call_conf 30 -L Chr11 -glm SNP &
mkdir Chr12.gatk_tmp
java -Djava.io.tmpdir=./Chr12.gatk_tmp/ -Xmx400g -jar /data/tool/GATKv3.7/GenomeAnalysisTK.jar -R /data/home/qiujie/Rice_Navigation_project/Rice_Ref_genomes/MSUv7/Rice_MSUv7.fa -T UnifiedGenotyper -I all_404_samples.list -o Chr12.MSUv7_404lines_SNP.vcf -nct 8 -nt 8 -stand_call_conf 30 -L Chr12 -glm SNP
