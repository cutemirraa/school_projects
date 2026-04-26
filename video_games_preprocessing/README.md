# Video Games Data Preprocessing (2000–2013)

## Project Description
Preprocessing and cleaning of historical video game sales data for further analysis. The goal is to prepare data for an article on IT resource about the evolution of the gaming industry.

## Data
- Source: `new_games.csv`
- Period: originally 1980–2016, filtered to 2000–2013
- Rows after preprocessing: 12,780

## Steps Performed

### 1. Data Loading & Overview
- Checked structure, data types, missing values
- Initial shape: 16,956 rows × 11 columns

### 2. Data Preprocessing
- Converted column names to `snake_case`
- Fixed data types (`year_of_release` → numeric, `eu_sales`, `jp_sales`, `user_score` → float)
- Replaced `"unknown"` and `"tbd"` with `NaN`
- Filled missing values in sales columns with mean by platform + year
- Normalized text columns (`genre`, `platform` → lowercase; `rating` → uppercase)
- Removed duplicates (242 rows)
- Removed rows with missing `name` or `genre` (2 rows)

### 3. Filtering
- Kept only games released between 2000 and 2013
- Final rows: **12,780**

### 4. Categorization
Created two new categorical columns based on scores:

| Category | Critic Score | User Score |
|----------|--------------|------------|
| high | >= 80 | >= 8 |
| medium | 30–79 | 3–7.9 |
| low | 0–29 | 0–2.9 |
| no score | missing | missing |

**Distribution:**

| Category | critic_category | user_category |
|----------|----------------|---------------|
| no score | 5,612 | 6,298 |
| high | 1,691 | 2,286 |
| medium | 5,422 | 4,080 |
| low | 55 | 116 |

### 5. Top Platforms (2000–2013)

| Platform | Game Count |
|----------|------------|
| PS2 | 2,127 |
| DS | 2,120 |
| Wii | 1,275 |
| PSP | 1,180 |
| X360 | 1,121 |
| PS3 | 1,086 |
| GBA | 811 |

## Files
- `video_games_preprocessing.ipynb` — Jupyter notebook with all code

## Author
Zaripova Almira  
Date: April 2026
