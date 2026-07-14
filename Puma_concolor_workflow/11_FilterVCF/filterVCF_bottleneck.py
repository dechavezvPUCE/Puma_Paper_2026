'''
Input = raw VCF
Output = filtered VCF prints to screen
- Filtered sites are marked as FAIL_? in the 7th column
- Sites that pass go on to genotype filtering
- Filtered out genotypes are changed to './.', all others reported

Possible usage:

SCRIPT=filterVCF_MW.py 
python ${SCRIPT} myfile.vcf.gz | bgzip > myfile_filtered.vcf.gz
tabix -p vcf myfile_filtered.vcf.gz

'''

import sys
import gzip
import re
import scipy.stats as ss


vcf_file = sys.argv[1]
VCF = gzip.open(vcf_file, 'r')


# Min depth (1/3x mean) and max depth (2x mean)
#minD={'LS02':6,'LS03':6,'LS05':6,'LS06':6,'LS08':6,'LS09':6,'LS10':6,'LS12':6,'LS13':6,'LS14':6,'LS15':6,'LS21':6,'LS22':6,'LS25':6,'LS26':6,'LS27':6,'LS28':6,'LS29':6,'LS31':6,'LS32':6,'LS33':6,'LS34':6,'LS35':6,'LS36':6,'LS37':6,'LS38':6,'LS39':6,'LS40':6,'LS43':6,'LS44':6,'LS49':6,'LS50':6,'LS51':6,'LS52':6,'LS55':6,'LS56':6,'LS57':6,'LS58':6,'LS60':6}
#maxD={'LS02':193.72,'LS03':180,'LS05':58.76,'LS06':165.22,'LS08':157.5,'LS09':55.64,'LS10':160,'LS12':183.9,'LS13':161.6,'LS14':163.58,'LS15':185.44,'LS21':43.68,'LS22':191.22,'LS25':169.76,'LS26':163.12,'LS27':171.26,'LS28':169.68,'LS29':36.3,'LS31':148.62,'LS32':168.52,'LS33':190,'LS34':56.76,'LS35':44.02,'LS36':176.62,'LS37':168.84,'LS38':165.86,'LS39':176.7,'LS40':186.32,'LS43':166.2,'LS44':164.9,'LS49':36.86,'LS50':144.9,'LS51':149,'LS52':127.06,'LS55':129.94,'LS56':132.76,'LS57':46.82,'LS58':136.92,'LS60':123.48}
minD={'bebe':4, 'BR338':4,'Verus':4,'Spumi':4,'Mila':4,'Ili.Puma':4,'Mao':4,'Capal.Puma':4,'Capu.Puma':4,'Nacho':4,'Julio':4,'julio':4,'nacho':4}
maxD={'bebe':84, 'BR338':80,'Verus':80,'Spumi':50,'Mila':70,'Ili.Puma':84,'Mao':84,'Capal.Puma':84,'Capu.Puma':84,'Nacho':84,'Julio':84,'julio':84,'nacho':84}
# Get list of samples in VCF file
samples=[]
for line in VCF:
    if line.startswith('##'):
        pass
    else:
        for i in line.split()[9:]: samples.append(i)
        break


# Go back to beginning of file
VCF.seek(0)

# Filter to be applied to individual genotypes
### sample is the sample name
### GT_entry is the entire genotype entry for that individual
### ADpos is the position of the AD in FORMAT (typically GT:AD:DP:GQ)
### DPpos is the position of the DP in FORMAT
### GQpos is the position of the GQ in FORMAT
def GTfilter(sample, GT_entry, ADpos, DPpos, GQpos):
    if GT_entry[:1]=='.' : return GT_entry
    else:
        gt=GT_entry.split(':')
        if gt[0] in ('0/0','0/1','1/1') and gt[GQpos]!='.' and gt[DPpos]!='.':
            DP=int(gt[DPpos])
            GQ=float(gt[GQpos])
            if GQ>=0.0 and minD[sample]<=DP<=maxD[sample]:
                REF=float(gt[ADpos].split(',')[0])
                AB=float(REF/DP)
                if gt[0]=='0/0':
                    if AB>=0.9: return GT_entry
                    else: return './.:' + ':'.join(gt[1:])
                elif gt[0]=='0/1':
                    if 0.2<=AB<=0.8: return GT_entry
                    else: return './.:' + ':'.join(gt[1:])
                elif gt[0]=='1/1':
                    if AB<=0.1: return GT_entry
                    else: return './.:' + ':'.join(gt[1:])
                else: './.:' + ':'.join(gt[1:])
            else: return './.:' + ':'.join(gt[1:])
        else: return './.:' + ':'.join(gt[1:])


# Write header lines
### Add new header lines for filters being added - for GATK compatibility
for line0 in VCF:
    if line0.startswith('#'):
        if line0.startswith('##FORMAT'):
            sys.stdout.write('##FILTER=<ID=FAIL_refN,Description="Low quality">\n')
            sys.stdout.write('##FILTER=<ID=FAIL_multiAlt,Description="Low quality">\n')
            sys.stdout.write('##FILTER=<ID=FAIL_badAlt,Description="Low quality">\n')
            sys.stdout.write('##FILTER=<ID=FAIL_noQUAL,Description="Low quality">\n')
            sys.stdout.write('##FILTER=<ID=FAIL_noINFO,Description="Low quality">\n')
            sys.stdout.write('##FILTER=<ID=FAIL_mutType,Description="Low quality">\n')
            sys.stdout.write('##FILTER=<ID=FAIL_noGQi,Description="Low quality">\n')
            sys.stdout.write('##FILTER=<ID=FAIL_noDPi,Description="Low quality">\n')
            sys.stdout.write('##FILTER=<ID=FAIL_noADi,Description="Low quality">\n')
            sys.stdout.write(line0)
            break
        else: sys.stdout.write(line0)


# Go through VCF file line by line to apply filters
for line0 in VCF:
    if line0.startswith('#'):
        sys.stdout.write(line0); continue

### For all other lines:
    line=line0.strip().split('\t')

### Site filtering:
### Keep any filters that have already been applied
    filter=[]
    if line[6] not in ('.', 'PASS'):
        filter.append(line[6])

### Reference must not be N
    if line[3]=='N':
        filter.append('FAIL_refN')
        sys.stdout.write('%s\t%s\t%s\n' % ('\t'.join(line[0:6]), ';'.join(filter), '\t'.join(line[7:])) ) ; continue

### Alternate but not QUAL and INFO
    if line[3]!='N' and line[5]=='.' and line[7]=='.':
        filter.append('FAIL_noQUALnoINFO')
        sys.stdout.write('%s\t%s\t%s\n' % ('\t'.join(line[0:6]), ';'.join(filter), '\t'.join(line[7:])) ) ; continue

### Alternate allele must not be multiallelic or <NON_REF>
    if ',' in line[4]:
        filter.append('FAIL_multiAlt')

    if '<NON_REF>' in line[4]:
        filter.append('FAIL_badAlt')

### Must have a valid QUAL
    if line[5]=='.':
        filter.append('FAIL_noQUAL')

### Access INFO field annotations
    if ';' in line[7]:
        INFO=line[7].split(';')
        d=dict(x.split('=') for x in INFO)
    else:
        INFO=line[7]
        if '=' in INFO:
            d={INFO.split('=')[0]:INFO.split('=')[1]}
        else: filter.append('FAIL_noINFO')

### Only accept sites that are monomorphic or simple SNPs
    if 'VariantType' not in d or d['VariantType'] not in ('NO_VARIATION', 'SNP'):
        filter.append('FAIL_mutType')

### Get the position of AD, DP, GQ value in genotype fields
    if 'AD' in line[8]:
        ADpos=line[8].split(':').index('AD')
    else: filter.append('FAIL_noADi')

    if 'DP' in line[8]:
        DPpos=line[8].split(':').index('DP')
    else: filter.append('FAIL_noDPi')

    if 'GQ' in line[8]:
        ff=line[8].split(':')
        GQpos=[ff.index(x) for x in ff if 'GQ' in x][0]
    else: filter.append('FAIL_noGQi')

### If any filters failed, write out line and continue
    if filter!=[]:
        sys.stdout.write('%s\t%s\t%s\n' % ('\t'.join(line[0:6]), ';'.join(filter), '\t'.join(line[7:])) ) ; continue

### Genotype filtering:
    GT_list=[]
    for i in range(0,len(samples)):
        GT=GTfilter(samples[i],line[i+9],ADpos,DPpos,GQpos)
        GT_list.append(GT)
    if filter==[]:
        filter.append('PASS')

### Write out new line
    sys.stdout.write('%s\t%s\t%s\t%s\t%s\n' % ('\t'.join(line[0:6]), ';'.join(filter), ';'.join('{0}={1}'.format(key, val) for key, val in sorted(d.items())), line[8], '\t'.join(GT_list)) )


# Close files and exit
VCF.close()
exit()
