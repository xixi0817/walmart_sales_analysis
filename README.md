# Walmart Retail Sales Performance Analysis

Statistical analysis of Walmart weekly sales data to identify key drivers of store performance, using regression modeling and association analysis in R.

**Course:** STA9750 — Software Tools for Data Analysis (Spring 2026)
**Type:** Solo final project
**Author:** Xixi Lin (MS Data Analytics, Baruch College)

---

## 📊 Project Overview

This project investigates how external economic and seasonal factors influence Walmart's weekly retail sales across 45 stores. The goal is to identify which variables — unemployment rate, fuel price, temperature, CPI, holiday periods — have measurable relationships with sales performance, and to evaluate the predictive power of linear regression models on retail sales data.

**Dataset:** Walmart Sales Dataset from Kaggle (6,434 rows × 8 variables)
**Time period:** Feb 2010 – Oct 2012
**Tools:** R, RStudio, `regclass`, `ggplot2`, base R

---

## 🔍 Analysis Workflow

1. **Data cleaning & exploration** — handled missing values, formatted dates, examined distributions of all 8 variables.
2. **Association analysis** — used the `associate()` function from `regclass` to examine relationships between weekly sales and each predictor, supported by 5 diagnostic plots.
3. **Regression modeling** — built and compared three multiple linear regression models:
   - `model_unemployment` — single-predictor baseline
   - `model_all` — full model with all predictors
   - `model_reduced` — refined model after diagnostic review
4. **Model evaluation** — compared R², residual diagnostics, and predictor significance across models.

---

## 📈 Key Findings

- **Unemployment rate** showed the strongest individual association with weekly sales, but the relationship was weaker than expected from economic theory.
- **Holiday weeks** produced significant sales spikes, but the binary holiday indicator alone explained limited variance.
- The best regression model achieved **R² ≈ 2.5%**, suggesting that the available macroeconomic and seasonal variables capture only a small fraction of sales variation. Store-level and product-level effects likely drive the majority of variance — a finding consistent with retail analytics literature.
- The analysis demonstrates the importance of pairing statistical modeling with domain context: low R² is not a failure but a signal that richer features (store characteristics, product mix, local demographics) are needed.

---

## 📁 Repository Contents

```
├── Group11_walmart_final_project.R    # Full R analysis script
├── Group11_walmart_final_report.docx  # Written report
├── Group11_STA9750_Walmart_Presentation.pptx  # Presentation slides
├── Walmart.csv                         # Source dataset (Kaggle)
├── Rplot*.png                          # Output plots from R session
└── README.md                           # This file
```

---

## 🚀 How to Reproduce

1. Clone this repository
2. Open `Group11_walmart_final_project.R` in RStudio
3. Install required packages:
   ```r
   install.packages(c("regclass", "ggplot2"))
   ```
4. Set working directory to the repo folder and run the script top to bottom

---

## 📚 Data Source

Walmart Sales Dataset, [Kaggle](https://www.kaggle.com/datasets/yasserh/walmart-dataset). Public dataset used for academic purposes.

---

## 👤 About the Author

Xixi Lin is an MS Data Analytics student at Baruch College (CUNY), expected graduation Spring 2027. Interests span retail analytics, geospatial analysis, and AI applications in data work.

**Other projects:**
- 🏙️ [NYC Property Market Dashboard](https://github.com/xixi0817/nyc_property_dashboard) — Plotly Dash interactive dashboard analyzing 498K NYC property transactions
- 🎨 [Art & Web Design Portfolio](https://xixi0817.github.io/art_portfolio/) — Illustration, vector design, and creative web pages
