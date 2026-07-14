# Puma concolor whole-genome workflow

Reproducible processing and population-genomic analysis workflow used for the study:

> **First genomic evidence of inbreeding in South American pumas and the role of Andean climate history in shaping genetic diversity**

This repository contains SLURM submission scripts, Bash wrappers, Python utilities, and R scripts used to process paired-end Illumina reads, call and filter variants, and perform downstream analyses of population structure, relatedness, heterozygosity, runs of homozygosity, deleterious variation, and demographic history in *Puma concolor*.

---

## Workflow overview

```text
Paired-end FASTQ
      │
      ▼
01. FASTQ quality control
      │
      ▼
02. FASTQ → unmapped BAM + read-group metadata
      │
      ▼
03. Mark Illumina adapters
      │
      ▼
04. Alignment to the reference genome + BAM cleanup
      │
      ▼
05. Mark PCR/optical duplicates
      │
      ▼
06. Remove low-quality, duplicate, secondary, and improperly paired reads
      │
      ▼
08. Per-sample GATK HaplotypeCaller in GVCF mode
      │
      ▼
09. Joint genotyping and variant annotation
      │
      ▼
11. Variant masking and hard filtering
      │
      ├── PCA and clustering
      ├── fastSTRUCTURE
      ├── relatedness
      ├── heterozygosity
      ├── runs of homozygosity
      ├── deleterious-variant genotype counts
      └── MSMC demographic reconstruction
```

The numbering follows the original analysis directory structure. Some intermediate or exploratory steps are not represented as separate folders.

---

## Repository structure

```text
Puma_concolor_workflow/
├── 02_FastqToSam/
│   ├── run_FastqToSam.sh
│   └── submit_run_FastqToSam.sh
├── 03_MarkIlluminaAdapters/
│   ├── run_MarkIlluminaAdapters.sh
│   └── submit_run_MarkIlluminaAdapters.sh
├── 04_AlignCleanBam/
│   ├── run_AlignCleanBam.sh
│   └── submit_run_AlignCleanBam.sh
├── 05_MarkDuplicates/
│   ├── run_MarkDuplicates.sh
│   └── submit_run_MarkDuplicates.sh
├── 06_RemoveBadReads/
│   ├── run_RemoveBadReads.sh
│   └── submit_run_RemoveBadReads.sh
├── 08_HaplotypeCaller/
│   ├── run_GATK_HC_bottleneck_Pumas.sh
│   └── submit_run_GATK_HC_Pumas.sh
├── 09_Genotype_gVCFs/
│   ├── submit_9a_JOINT_run_GATK_GenoGVCFs_PumasUCSC.sh
│   └── submit_9b_JOINT_GATK_TrimAlt_AddAnnot_Pumas.sh
├── 11_FilterVCF/
│   ├── Mask_Filter_bottleneck.Pumas.sh
│   ├── filterVCF_bottleneck.py
│   └── submit_MaskVCFtrimAnot.pumas.sh
└── 12_Demography/
    ├── DeltVariation/
    ├── FastStructure/
    ├── Heterozygosity/
    ├── PCA/
    ├── RELATEDNESS/
    ├── ROH/
    └── msmc/
```

---

## Important reproducibility note

The scripts were originally written for a specific HPC environment and contain absolute paths such as:

```text
/data/CEM/bottleneck/dechave4/...
```

Before running the workflow, replace all hard-coded paths with paths valid on your system. At minimum, update:

- project directory
- raw FASTQ directory
- BAM/GVCF/VCF output directories
- reference genome path
- temporary directory
- log directory
- Picard/GATK/BWA/SAMtools/PLINK/MSMC paths
- SLURM partition, quality-of-service, memory, runtime, and email settings

For portability, consider moving these values into a shared configuration file, for example:

```bash
PROJECT_DIR=/path/to/Puma_Paper_2026
REF=/path/to/Puma_concolor.reference.fa
RAW_DIR=${PROJECT_DIR}/data/raw_fastq
BAM_DIR=${PROJECT_DIR}/results/bam
GVCF_DIR=${PROJECT_DIR}/results/gvcf
VCF_DIR=${PROJECT_DIR}/results/vcf
TMP_DIR=${PROJECT_DIR}/tmp
LOG_DIR=${PROJECT_DIR}/logs
```

---

## Software requirements

The workflow uses the following software families:

- **Java**
- **Picard**
- **BWA-MEM**
- **SAMtools**
- **GATK**
- **BCFtools/VCFtools**
- **PLINK**
- **fastSTRUCTURE**
- **SNPRelate**
- **R**
- **Python**
- **MSMC/MSMC-tools**
- a SLURM-compatible HPC scheduler

Versions reported in the manuscript or scripts include:

- FastQC v0.12.1
- Picard v3.1.1
- BWA-MEM v0.7.17
- SAMtools
- GATK following Best Practices

For a fully reproducible release, record the exact versions used for every downstream package, including PLINK, fastSTRUCTURE, SNPRelate, R, Python, and MSMC.

---

## Input data

### Required per sample

- paired-end Illumina reads:
  - `SAMPLE_R1.fastq.gz`
  - `SAMPLE_R2.fastq.gz`
- sample metadata:
  - sample ID
  - read-group ID
  - library ID
  - platform unit/flow cell
  - sequencing center

### Reference files

Prepare the reference genome before alignment and variant calling:

```bash
bwa index Puma_concolor.reference.fa
samtools faidx Puma_concolor.reference.fa
gatk CreateSequenceDictionary \
  -R Puma_concolor.reference.fa \
  -O Puma_concolor.reference.dict
```

The chromosome names and ordering must remain consistent across the FASTA, BAM, VCF, BED/mask files, and downstream analyses.

---

# Pipeline steps

## 02 — FASTQ to unmapped BAM

Scripts:

```text
02_FastqToSam/run_FastqToSam.sh
02_FastqToSam/submit_run_FastqToSam.sh
```

This step converts paired-end FASTQ files into an unmapped BAM while embedding read-group metadata with Picard `FastqToSam`.

Expected arguments:

```text
directory
read_1
read_2
output_bam
read_group
sample_name
library_name
platform_unit
sequencing_center
```

Example:

```bash
sbatch run_FastqToSam.sh \
  /path/to/raw_fastq \
  SAMPLE_R1.fastq.gz \
  SAMPLE_R2.fastq.gz \
  SAMPLE_FastqToSam.bam \
  RG1 \
  SAMPLE \
  LIB1 \
  FLOWCELL1 \
  SEQUENCING_CENTER
```

Output:

```text
SAMPLE_FastqToSam.bam
```

---

## 03 — Mark Illumina adapters

Scripts:

```text
03_MarkIlluminaAdapters/run_MarkIlluminaAdapters.sh
03_MarkIlluminaAdapters/submit_run_MarkIlluminaAdapters.sh
```

Picard `MarkIlluminaAdapters` identifies adapter sequence in the unmapped BAM and creates an adapter-tagged BAM plus a metrics file.

Outputs:

```text
SAMPLE_MarkIlluminaAdapters.bam
SAMPLE_MarkIlluminaAdapters.bam_metrics.txt
```

---

## 04 — Align and clean BAM

Scripts:

```text
04_AlignCleanBam/run_AlignCleanBam.sh
04_AlignCleanBam/submit_run_AlignCleanBam.sh
```

This stage aligns reads to the *Puma concolor* reference genome with BWA-MEM and merges alignment information with the metadata-rich unmapped BAM. Depending on the exact script configuration, Picard utilities are used to produce a coordinate-sorted, cleaned BAM suitable for duplicate marking.

Expected output:

```text
SAMPLE_AlignCleanBam.bam
```

Verify each BAM:

```bash
samtools quickcheck -v SAMPLE_AlignCleanBam.bam
samtools flagstat SAMPLE_AlignCleanBam.bam
samtools stats SAMPLE_AlignCleanBam.bam > SAMPLE.stats.txt
```

---

## 05 — Mark duplicates

Scripts:

```text
05_MarkDuplicates/run_MarkDuplicates.sh
05_MarkDuplicates/submit_run_MarkDuplicates.sh
```

Picard `MarkDuplicates` identifies PCR and optical duplicates and generates duplication metrics.

Expected outputs:

```text
SAMPLE_marked_duplicates.bam
SAMPLE_marked_duplicates.metrics.txt
```

Duplicate reads are subsequently excluded from the analysis.

---

## 06 — Remove low-quality and unwanted reads

Scripts:

```text
06_RemoveBadReads/run_RemoveBadReads.sh
06_RemoveBadReads/submit_run_RemoveBadReads.sh
```

The workflow uses SAMtools filtering equivalent to:

```bash
samtools view -hb -f 2 -F 256 -q 30 input.bam \
  | samtools view -hb -F 1024 \
  > SAMPLE.filtered.bam
```

Flag interpretation:

- `-h`: retain the SAM/BAM header
- `-b`: output BAM
- `-f 2`: retain properly paired reads
- `-F 256`: remove secondary alignments
- `-q 30`: retain reads with mapping quality ≥30
- `-F 1024`: remove reads marked as PCR/optical duplicates

After filtering:

```bash
samtools sort -o SAMPLE.filtered.sorted.bam SAMPLE.filtered.bam
samtools index SAMPLE.filtered.sorted.bam
samtools flagstat SAMPLE.filtered.sorted.bam
```

This filtered BAM is the principal input for per-sample variant calling and individual-level genomic analyses.

---

## 08 — GATK HaplotypeCaller

Scripts:

```text
08_HaplotypeCaller/run_GATK_HC_bottleneck_Pumas.sh
08_HaplotypeCaller/submit_run_GATK_HC_Pumas.sh
```

GATK `HaplotypeCaller` is run independently for each individual in GVCF mode.

Conceptual command:

```bash
gatk HaplotypeCaller \
  -R Puma_concolor.reference.fa \
  -I SAMPLE.filtered.sorted.bam \
  -O SAMPLE.g.vcf.gz \
  -ERC GVCF
```

Outputs:

```text
SAMPLE.g.vcf.gz
SAMPLE.g.vcf.gz.tbi
```

---

## 09 — Joint genotyping

Scripts:

```text
09_Genotype_gVCFs/submit_9a_JOINT_run_GATK_GenoGVCFs_PumasUCSC.sh
09_Genotype_gVCFs/submit_9b_JOINT_GATK_TrimAlt_AddAnnot_Pumas.sh
```

This stage combines per-sample GVCFs and performs joint genotyping across all puma genomes. A second script trims unused alternate alleles and adds or retains annotations required for downstream filtering.

Expected outputs:

```text
Pumas.joint.raw.vcf.gz
Pumas.joint.annotated.vcf.gz
```

The jointly genotyped VCF should contain all individuals used in population-level analyses.

---

## 11 — Variant filtering and masking

Scripts:

```text
11_FilterVCF/Mask_Filter_bottleneck.Pumas.sh
11_FilterVCF/filterVCF_bottleneck.py
11_FilterVCF/submit_MaskVCFtrimAnot.pumas.sh
```

This stage applies hard filters and genomic masks to retain high-confidence variants. The exact thresholds are encoded in the scripts and should be reported explicitly in the manuscript and this README.

Recommended checks after filtering:

```bash
bcftools stats Pumas.filtered.vcf.gz > Pumas.filtered.stats.txt
bcftools view -H -v snps Pumas.filtered.vcf.gz | wc -l
bcftools query -l Pumas.filtered.vcf.gz
```

The final analysis VCF should contain high-quality, biallelic SNPs with consistent chromosome names and genotype annotations.

---

# Downstream analyses

## A. PCA and clustering

Directory:

```text
12_Demography/PCA/
```

Scripts:

```text
run_get_polymorphic_Pumas.sh
submit_run_get_polymorphic_Pumas.sh
run_snprelate_PCA_cluster_Pumas.sh
snprelate_PCA_cluster_Pumas.R
```

Purpose:

1. select polymorphic SNPs
2. convert/filter data for SNPRelate
3. perform LD pruning
4. calculate principal components
5. visualize geographic/population clustering

The manuscript reports a PCA based on 18,319 LD-pruned SNPs.

Recommended outputs:

```text
Pumas.PCA.eigenvalues.tsv
Pumas.PCA.scores.tsv
Pumas.PCA.pdf
```

---

## B. fastSTRUCTURE

Directory:

```text
12_Demography/FastStructure/
```

Scripts:

```text
fastStructure_Step_1_Pumas.sh
fastStructure_Step_2_runFASTSTRUCTURE.Pumas.sh
```

Purpose:

1. convert the filtered VCF to PLINK input
2. apply SNP and LD filters
3. run fastSTRUCTURE across a range of K values

The analysis should record:

- the input SNP count
- LD-pruning parameters
- K range
- random seed
- prior type
- marginal likelihood or model-choice output

---

## C. Relatedness

Directory:

```text
12_Demography/RELATEDNESS/
```

Script:

```text
ComparingRelatedness.relatedness.plinkMoM.Pumas.Ecuador.R
```

Purpose:

- compare pairwise relatedness estimates
- inspect kinship coefficients
- identify close relatives before population-structure analyses

Close relatives should be documented and, where appropriate, one member of a closely related pair should be excluded from analyses sensitive to family structure.

---

## D. Genome-wide heterozygosity

Directory:

```text
12_Demography/Heterozygosity/
```

Scripts:

```text
1a-run_HetPerInd.sh
HetPerInd.py
1b-SlidingWindowHet_Puma.sh
SlidingWindowHet.Puma.py
```

Purpose:

- calculate mean heterozygosity per individual
- summarize heterozygous sites across genomic windows
- identify large chromosome-scale regions depleted of heterozygosity

Report clearly:

- window size
- step size
- callable-site mask
- whether heterozygosity is expressed per site or per kilobase
- chromosome exclusions
- minimum depth and genotype-quality thresholds

---

## E. Runs of homozygosity

Directory:

```text
12_Demography/ROH/
```

Scripts:

```text
Step0_getOnlyPass.vcf.sh
Step1_ROH_VCFtoPLINK.sh
Step2_run_PLINK_plot.sh
Step3_JoinPlinkRunPlot.sh
plot_ROHStep2.R
submit_ROH_Step0-3.sh
```

Purpose:

1. retain PASS variants
2. convert VCF to PLINK format
3. call ROH with PLINK
4. merge and classify ROH by length
5. generate individual-level summaries and plots

ROH categories used in the study:

```text
short:        0.1–1 Mb
intermediate: 1–10 Mb
long:         >10 Mb
```

Long ROH are interpreted as being most consistent with recent parental relatedness, whereas shorter ROH reflect older demographic processes. Exact PLINK parameters should be copied into the Methods and retained in this README.

---

## F. Predicted deleterious variation

Directory:

```text
12_Demography/DeltVariation/
```

Scripts:

```text
getAlleleGenotCounts.py
run_SubsetVCF_getAlleleGenotCounts.PumaUCSC.sh
submit_run_SubsetVCF_getAlleleGenotCounts.PumaUCSC.sh
```

Purpose:

- subset annotated variants by functional class
- count homozygous-reference, heterozygous, and homozygous-derived genotypes
- compare genotype counts among individuals

Functional categories include:

- loss-of-function
- missense
- synonymous

Important interpretive caveat:

These annotations are predictions, not direct measurements of organismal fitness. Variant effects may depend on genetic background, linkage, epistasis, environment, and annotation quality. Results should therefore be described as **predicted functional burden** or **predicted deleterious variation**, not as experimentally demonstrated fitness effects.

---

## G. MSMC demographic history

Directory:

```text
12_Demography/msmc/
```

Scripts:

```text
getOnlyPass.Step_0_.Pumas.sh
submit_Step_1_PrepMSMCMAGIC.concise.Pumas.sh
submit_Step_2_runMSMC.Pumas.sh
```

Purpose:

1. retain high-confidence PASS variants
2. create chromosome-specific MSMC input files
3. run MSMC
4. scale inverse coalescence rates using the assumed mutation rate and generation time

Record explicitly:

- mutation rate
- generation time
- chromosome set
- callable-site masks
- MSMC version
- time-segment pattern
- number of haplotypes included
- scaling equations used for time and effective population size

MSMC trajectories should be interpreted as inverse-coalescence-based demographic reconstructions rather than literal census population sizes.

---

## Quality-control checkpoints

At minimum, inspect the following after every major stage:

### Raw reads

```bash
fastqc SAMPLE_R1.fastq.gz SAMPLE_R2.fastq.gz
```

### BAM files

```bash
samtools quickcheck
samtools flagstat
samtools stats
samtools depth
```

### Variant files

```bash
bcftools stats
bcftools query -l
bcftools view -m2 -M2 -v snps
```

### Population analyses

Confirm that:

- all individuals have expected sample names
- close relatives are handled consistently
- missingness is not strongly population-specific
- LD pruning is applied before PCA/structure analyses
- chromosome and scaffold filters match the manuscript
- autosomes and sex chromosomes are treated explicitly
- the reference and ancestral alleles are not conflated

---

## Recommended execution order

Each `submit_*.sh` script is a site-specific SLURM launcher. Edit it before submission.

```bash
cd Puma_concolor_workflow

bash 02_FastqToSam/submit_run_FastqToSam.sh
bash 03_MarkIlluminaAdapters/submit_run_MarkIlluminaAdapters.sh
bash 04_AlignCleanBam/submit_run_AlignCleanBam.sh
bash 05_MarkDuplicates/submit_run_MarkDuplicates.sh
bash 06_RemoveBadReads/submit_run_RemoveBadReads.sh
bash 08_HaplotypeCaller/submit_run_GATK_HC_Pumas.sh
bash 09_Genotype_gVCFs/submit_9a_JOINT_run_GATK_GenoGVCFs_PumasUCSC.sh
bash 09_Genotype_gVCFs/submit_9b_JOINT_GATK_TrimAlt_AddAnnot_Pumas.sh
bash 11_FilterVCF/submit_MaskVCFtrimAnot.pumas.sh
```

Run downstream analyses only after validating the final filtered VCF.

---

## Suggested sample manifest

A manifest prevents sample-name and read-group inconsistencies.

```text
sample_id	read1	read2	read_group	library	platform_unit	sequencing_center	population
Verus	/path/Verus_R1.fastq.gz	/path/Verus_R2.fastq.gz	Verus1a	Lib1	H5THTDSXY	Macrogen	Mindo
```

A future revision of the workflow could parse this manifest and submit a SLURM job array rather than requiring one manually edited command per sample.

---

## Known limitations and recommended improvements

1. **Hard-coded paths**  
   Replace absolute institutional paths with a shared configuration file.

2. **HPC-specific scheduler settings**  
   SLURM partitions, QOS, memory, wall time, and email directives must be adapted locally.

3. **No environment lock file**  
   Add Conda, Mamba, Docker, or Singularity/Apptainer definitions.

4. **Tool versions are not uniformly recorded**  
   Add a `software_versions.txt` file generated during analysis.

5. **No automated sample manifest**  
   Replace manually edited submission scripts with a manifest-driven loop or job array.

6. **Limited input validation**  
   Add `set -euo pipefail`, argument checks, file-existence checks, and informative error messages.

7. **Temporary files and logs**  
   Use sample-specific temporary directories and job-ID-specific log filenames.

8. **Missing provenance metadata**  
   Record Git commit, reference accession, mask version, command line, and date for each run.

9. **Demographic and functional interpretations are model-dependent**  
   MSMC, ROH, and predicted deleterious-variant analyses should be interpreted together with landscape, historical, and biological evidence.

---

## Minimal Bash safety template

For future script revisions:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <input> <output>" >&2
    exit 1
fi

INPUT=$1
OUTPUT=$2

[[ -s "$INPUT" ]] || {
    echo "ERROR: Input file not found or empty: $INPUT" >&2
    exit 1
}

mkdir -p "$(dirname "$OUTPUT")"
```

---

## Reproducibility recommendations for publication

For an archived release associated with the paper, include:

- exact reference-genome accession and assembly version
- reference FASTA checksum
- sample metadata table
- raw-read accession numbers
- all software versions
- exact filtering thresholds
- final callable-genome mask
- final analysis VCF checksum
- random seeds for stochastic analyses
- figure-generation scripts
- a tagged GitHub release
- a Zenodo DOI

---

## Citation

When using this workflow, cite the associated puma genomics manuscript and the original software packages used in each analysis.

Suggested repository citation:

```text
Chavez, D. E. et al. Puma concolor whole-genome processing and
population-genomic analysis workflow. GitHub repository (2026).
```

Replace this provisional citation with the final article citation and repository DOI after publication.

---

## Contact

For questions about the workflow or the associated study, open a GitHub issue or contact the corresponding author listed in the manuscript.

---

## License

Copyright (c) 2026
Daniel E. Chavez Viteri

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
Copyright (c) 2026
Daniel E. Chavez Viteri

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE..
