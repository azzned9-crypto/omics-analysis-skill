# omics-analysis

Cross-omics downstream analysis skill set for clean matrices after QC.

## Included Skills

- `omics-analysis`
  Main entry skill for omics analysis and module dispatch.
- `omics-qc-process`
  QC review module before entering downstream analysis.
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

## Design

This repository separates:

- main workflow entry
- QC review
- method modules
- visualization
- assay-specific profiles

The goal is to constrain AI analysis behavior by forcing:

- assay confirmation
- matrix-state confirmation
- contrast confirmation
- threshold recording
- audit-aware outputs

## Notes

- Skill folder names remain in English for portability.
- Skill bodies and configuration content are written in Chinese.
