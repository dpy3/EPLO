# EPLO Paper and Reproducibility Guide

- Paper PDF: `e:\postgraduate\first year\PPLO\EPLO-elsarticle.pdf`
- Code: `https://github.com/dpy3/EPLO`
- Release (code + data, v1.0.0): `https://github.com/dpy3/EPLO/releases/tag/v1.0.0`
- DOI: `https://doi.org/10.5281/zenodo.17972460`
- License: `MIT`

## Requirements
- OS: Windows 10/11
- MATLAB: R2021a or newer
- LaTeX: TeX Live 2025 (or compatible) with `latexmk`
- Compilers: Microsoft Visual C++ (if rebuilding `mex` files)

## Quick Start
1. Clone code or download the v1.0.0 release zip.
2. Open MATLAB at the repository root.
3. Add paths:
   - `addpath('EPLO')`
   - `addpath('IHBA_mountain-master\IHBA_mountain-master')`
   - `addpath('EPLO_figures')` or `addpath('eplo_figures')`
4. Run benchmarks:
   - CEC2022: `run('EPLO\main.m')`
   - UAV planning: `run('IHBA_mountain-master\IHBA_mountain-master\flyMountain.m')`

## Build the Paper (EPLO-elsarticle.pdf)
- Open a terminal in `e:\postgraduate\first year\PPLO` and run:
  - `latexmk -pdf -interaction=nonstopmode EPLO-elsarticle.tex`
- The output is saved as: `e:\postgraduate\first year\PPLO\EPLO-elsarticle.pdf`

## CEC2022 Benchmarks
- Script: `EPLO\main.m`
- Configure:
  - Population: `pop`
  - Iterations: `T`
  - Dimension: `dim`
  - Function index: `F_index` (1–30)
- Outputs:
  - `CEC2022_Results.mat`: mean, std, final fitness arrays
  - Figures: `EPLO_figures\*.png` or `eplo_figures\*.jpg`
- Notes:
  - Keep the same `MaxFEs`, population, and seeds across algorithms for fair comparison.

## Engineering Problems
- Tension/Compression Spring, Reducer, Gear Train, Multi-disk Clutch, Robot Gripper
- Each problem is included in the paper’s Methods/Results sections; reproduce via dedicated scripts in `EPLO` and result plotting utilities in `EPLO_figures`/`eplo_figures`.
- Ensure units, bounds, and penalty factors match the paper tables.

## Dynamic 3D UAV Path Planning & Scheduling
- Script: `IHBA_mountain-master\IHBA_mountain-master\flyMountain.m`
- Data files under `IHBA_mountain-master\IHBA_mountain-master\data\*.csv`
- Steps:
  - Load and cluster obstacles via DBSCAN
  - Generate initial paths (Dijkstra + B-spline smoothing)
  - Optimize trajectories and departure delays with EPLO
- Outputs:
  - Smoothed path CSVs: `smoothed_path_*.csv`
  - Figures: `EPLO_figures`/`eplo_figures`

## 3D WSN Localization (DV-Hop variants)
- Data preparation: synthetic or provided samples with anchors and unknowns
- Fitness: weighted normalized residual + boundary penalty
- Evaluate Average Localization Error (ALE) normalized by communication radius `R`
- Plot bars/boxplots from `EPLO_figures`/`eplo_figures`

## Statistical Tests & Ablations
- Recommended:
  - Wilcoxon signed-rank per function
  - Friedman average rank across functions with Holm/Hochberg correction
  - Ablations: disable modules (Sobol, migration, elite pool, opposition, L\'evy, gradient) and re-run
- Save tables to `CEC2022_Results.mat` and export CSVs for LaTeX.

## Directory Structure
- `EPLO/`: algorithm implementation and benchmark scripts
- `IHBA_mountain-master/IHBA_mountain-master/`: UAV planning code and data
- `EPLO_figures/` or `eplo_figures/`: generated plots and figures referenced by the paper
- `EPLO-elsarticle.tex`: LaTeX source of the paper
- `cover_letter_SWEVO_en.pdf` / `cover_letter_SWEVO_en.rtf`: English cover letter

## Troubleshooting
- LaTeX compile errors near `\end{frontmatter}`: ensure `hyperref` is loaded, and avoid unescaped special characters.
- Path issues: verify whether figures folder is `EPLO_figures` or `eplo_figures` and add that folder to MATLAB path.
- Mex rebuild: if needed, run MATLAB’s `mex -setup` and rebuild `cec*.cpp`.

## Citation
- Cite the software using the archived DOI: `https://doi.org/10.5281/zenodo.17972460`
