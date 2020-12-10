## transform CNSpipeline bigwig to bed to get score of each loci

#!/usr/bin/env python
import pyBigWig
threshold = 0  # Change me
bw = pyBigWig.open("all-sing-score.bw")  # Change me
of = open("all-sing-score.bed", "w")  # Change me

for chrom, len in bw.chroms().items():
    intervals = bw.intervals(chrom)
    for interval in intervals:
        #if abs(interval[2]) > threshold:
            of.write("{}\t{}\t{}\t{}\n".format(chrom, interval[0], interval[1], interval[2]))
bw.close()
of.close()