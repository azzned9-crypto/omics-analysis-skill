# omics-analysis-skill

Cross-omics analysis skill set for QC, downstream analysis, and visualization.

![omics-analysis-skill architecture](assets/omics-skill-comic.jpg)

## Included Skills

- `omics-analysis`
  Main entry skill for task intake, mandatory questioning, module dispatch, and audit-aware routing.
- `omics-qc-process`
  QC module with workflow-based rules for proteomics, bulk RNA-seq, metabolomics and single-cell RNA-seq, including risk-sample reporting and special-condition branching.
- `omics-scrna-process`
  **New (2026-07-07).** Single-cell RNA-seq downstream analysis module: multi-sample integration, clustering, cell-type annotation, differential expression, trajectory (Monocle3 / CellRank2), cell-cell communication (CellChat) and stemness prediction (CytoTRACE2).
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

## 2026-07-07 Updates (scRNA release)

- Added `omics-scrna-process` — a new downstream module for single-cell RNA-seq.
  - `SKILL.md`: mandatory questioning on tissue type, species, expected markers, integration method, clustering resolution, annotation strategy, trajectory / communication / stemness options.
  - `workflow.md`: 10-step downstream flow (merge → Harmony integration → multi-resolution clustering → marker identification → annotation → DEG → Monocle3 / CellRank2 → CellChat → CytoTRACE2 → save).
  - `references.md`: 12 key references (Seurat, Harmony, Scanpy, SingleR, CellTypist, Azimuth, Monocle3, CellRank2, CellChat, CytoTRACE2, Luecken & Theis).
- Extended `omics-qc-process` with a single-cell RNA-seq QC branch.
  - `references/workflow-scrna.md`: 11-section QC workflow covering 10X Genomics and MGI DNBelab C4 platforms (Read10X vs ReadPISA), cell filtering, and DoubletFinder.
  - `references/references-scrna.md`: 10 key references (Seurat, DoubletFinder, Scanpy, Harmony, Luecken & Theis, SCTransform, EmptyDrops, DNBC4tools, 10X).
  - `SKILL.md`: added `scrna` as a 4th QC branch and mandatory data-source-platform confirmation (10X vs MGI C4).
- Registered single-cell RNA-seq in the main entry `omics-analysis`.
  - Module list now includes `omics-scrna-process`.
  - New assay profile `references/profiles/scrna.md` (matrix states, special-condition questions, defaults, common risks).
  - Added scRNA-specific 必问项 (platform, tissue type, expected markers, species) and special-condition branches (snRNA-seq, tissue-specific QC).

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
- platform or library-strategy confirmation (incl. scRNA data-source platform)
- matrix-state confirmation
- contrast confirmation
- threshold recording
- risk-sample reporting
- audit-aware outputs

## Notes

- Skill folder names remain in English for portability.
- Skill bodies and configuration content are written in Chinese.
