# omics-analysis

Updated: 2026-07-03

Cross-omics analysis skill set for QC, downstream analysis, and visualization.

## Included Skills

- `omics-analysis`
  Main entry skill for task intake, mandatory questioning, module dispatch, and audit-aware routing.
- `omics-qc-process`
  QC module with workflow-based rules for proteomics and bulk RNA-seq, including risk-sample reporting and special-condition branching.
- `omics-differential-analysis`
  Differential analysis module for DEG, DEP, and DEM style tasks.
- `omics-enrichment-analysis`
  Enrichment analysis module for GO, KEGG, ORA, and GSEA.
- `omics-time-series-analysis`
  Time-series module for Mfuzz-style workflows.
- `omics-network-analysis`
  Network module for WGCNA-style workflows.
- `omics-visualization`
  Visualization module for volcano plots, heatmaps, enrichment plots, trend plots, and network figures.

## 2026-07-03 Updates

- Renamed the main workflow concept to `omics-analysis` and removed the old `omics-downstream-analysis` copy from the repository.
- Shrunk `omics-qc-process/SKILL.md` into an entry-rule document and moved detailed procedures into workflow files.
- Added `workflow-proteomics.md` and `workflow-bulk-rnaseq.md` under `omics-qc-process/references/`.
- Added explicit risk-sample policy: default is mark and report, not auto-remove.
- Added unified risk levels in `SKILL.md`:
  - `低风险`: no QC step abnormal
  - `中风险`: one QC step abnormal
  - `高风险`: two or more QC steps abnormal
- Added HTML and audit presentation rules for risk samples.
- Added proteomics-specific QC branches for sample type and platform:
  - plasma
  - serum
  - urine
  - CSF
  - saliva and other body fluids
  - DIA, DDA, TMT, label-free
- Added bulk RNA-seq-specific QC branches for library strategy and sample context:
  - polyA
  - ribo-depletion / total RNA
  - stranded / unstranded
  - 3 prime / capture
  - whole transcriptome
  - FFPE
  - blood RNA
  - low-input and degraded RNA
- Added independent reference files:
  - `references-proteomics.md`
  - `references-bulk-rna.md`
- Updated the main `omics-analysis` entry skill so the first round must confirm:
  - assay type
  - sample type
  - platform or library strategy
  - matrix state
  - contrast
  - batch
  - whether a special-condition branch is triggered

## Design

This repository separates:

- main workflow entry
- QC workflow control
- method modules
- visualization
- assay-specific and workflow-specific references

The goal is to constrain AI analysis behavior by forcing:

- assay confirmation
- sample-type confirmation
- platform or library-strategy confirmation
- matrix-state confirmation
- contrast confirmation
- threshold recording
- risk-sample reporting
- audit-aware outputs

## Notes

- Skill folder names remain in English for portability.
- Skill bodies and configuration content are written in Chinese.