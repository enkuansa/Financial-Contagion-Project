# 📊 Examining Financial Contagion in Modern Times

This project asks a simple but consequential question: **if the U.S. stock market crashes, does the rest of the world fall with it?** It replicates and extends Forbes and Rigobon's (2002) influential paper, *No Contagion, Only Interdependence*, testing whether their findings on the 1987 crash still hold — and whether the same logic applies to the dotcom bubble, the 2008 financial crisis, and more recent shocks including COVID-19, the 2022 policy tightening period, and 2024–2025 market uncertainty.

---

## Tools and Methods

* **Python** -- data acquisition through financial and macroeconomic APIs
* **Excel** -- structuring and cleaning raw time-series data
* **STATA** -- core econometric analysis
* **Vector Autoregressive (VAR) Models** -- base model specification, following Forbes & Rigobon (2002)
* **Hypothesis Testing** -- one-sided t-tests and Fisher z-tests to evaluate changes in correlation

---

## What the project explores

The starting point follows Forbes and Rigobon's central insight: correlation between markets naturally rises during periods of high volatility, and unless this is corrected for, almost everything looks like contagion. The project is built around testing that correction directly.

**Replicating the original framework**
The 1987 crash is re-examined using the same VAR specification, residual extraction, and correlation tests as the original study, to confirm the methodology is sound and reproducible.

**Conditional vs. unconditional correlation**
A key distinction throughout is between *conditional* correlation (raw, biased upward by crisis volatility) and *unconditional* correlation (corrected for heteroskedasticity). Many apparent cases of contagion disappear once this correction is applied.

**Testing across multiple crises**
Rather than stopping at 1987, the analysis extends the same framework to the dotcom crash, the 2008 financial crisis, COVID-19, the 2022 rate-tightening period, and 2024–2025 market uncertainty -- asking whether U.S.-led contagion is a persistent feature of modern markets or a rare exception.

**Sensitivity to index choice**
The dotcom analysis is run twice, once using the S&P 500 and once using the NASDAQ Composite, to check whether conclusions about contagion depend on which benchmark is used to represent the U.S. market.

---

## How the work was done

The process began with collecting daily price and short-term interest rate data for the U.S. and a set of partner countries (UK, Canada, Australia, and later France, Germany, Japan, Hong Kong, and Switzerland), sourced from Yahoo Finance, Investing.com, FRED, and several national central banks.

For each country pair, a VAR model with five lags of returns and five exogenous lags of money market rates was estimated separately over a *stable* period, a *turmoil* period, and the *full* period combining both. Residual variances and covariances from these VARs were used to compute conditional correlations between markets.

A one-sided t-test and a Fisher z-test were then applied to determine whether the correlation in the turmoil period was statistically higher than in the full period -- the formal test for contagion under Forbes and Rigobon's definition. Finally, their heteroskedasticity correction was applied to recover the unconditional correlation, and the same tests were re-run to see whether the contagion signal survived the correction.

This entire pipeline was repeated for each crisis period under study.

---

## What came out of it

* The 1987 replication largely confirms Forbes and Rigobon's original conclusion: most apparent contagion (Canada, UK) disappears once corrected for heteroskedasticity, leaving little evidence of true contagion.
* In the dotcom crash, Germany is the only market showing contagion under both conditional and unconditional correlation -- but this result is sensitive to whether the S&P 500 or NASDAQ is used as the U.S. benchmark.
* In 2008, conditional correlations suggest contagion in Germany and Hong Kong, but this evidence vanishes entirely once the correction is applied.
* Across the more recent shocks (COVID, 2022 tightening, 2025 uncertainty), conditional correlation flags isolated cases (Australia, Canada), but none survive correction.
* Taken together, evidence for genuine U.S.-led contagion -- as opposed to ordinary interdependence -- is rare and inconsistent across nearly four decades of crises.

---

## What I learned from it

* Forbes and Rigobon's correction is not a minor technical adjustment -- it changes the substantive conclusion in almost every period tested.
* The choice of index (S&P 500 vs. NASDAQ) and the choice of crisis window genuinely affects whether a market is classified as experiencing contagion, which makes replication a useful check on how fragile published results can be to specification choices.
* Treating stable, turmoil, and full-period correlation estimates as independent is a simplification, since the full period nests the turmoil observations -- a tradeoff made for tractability rather than ignored.
* Bilateral, correlation-based frameworks like this one are simple to interpret but cannot speak to *why* a shock transmits, only whether co-movement increased.

---

## Limitations

* The analysis is correlation-based and cannot establish a causal transmission mechanism.
* Results are sensitive to how stable/turmoil windows are defined and which benchmark index is chosen.
* Stable, turmoil, and full-period correlation estimates are treated as independent for inference purposes, even though the full period overlaps with the turmoil period.
* Some countries (e.g., Germany, France, Japan, Netherlands) had missing short-term interest rate data in earlier periods, requiring forward-filling or exclusion (the Netherlands was dropped entirely from the 1995–2002 window for this reason).
* The framework does not separate U.S.-specific shocks from common global shocks (e.g., the Russia-Ukraine war, COVID-era supply chain disruptions), which may also drive co-movement.

---

## Possible extensions

Impulse response functions and Granger causality tests could clarify the direction and magnitude of cross-market effects rather than just whether correlation increased.

Factor models, such as those in Bekaert, Harvey, and Ng (2005), could help disentangle global, regional, and country-specific sources of contagion.

Higher-frequency data could offer a more granular view of how shocks propagate within a crisis window.

A systematic sensitivity analysis across multiple benchmark indices and window definitions would help establish how robust the "no contagion" conclusion really is.

---

## Reproducibility

All STATA do-files and data sources used in this study are included in this repository. Code is organized by crisis period (1987 replication, dotcom, 2008, and the extension periods), so each analysis can be run independently. Data can be re-downloaded from the original sources cited in the references, or used as provided.

---

## Context

This project was completed as an independent research study in financial econometrics at the University of North Dakota, replicating and extending Forbes and Rigobon's (2002) framework for measuring financial contagion across nearly four decades of market crises.

**Reference:** Forbes, K. J., & Rigobon, R. (2002). No contagion, only interdependence: Measuring stock market comovements. *The Journal of Finance*, 57(5), 2223–2261.

---
## Visuals
The table below summarises the final hypothesis test results across all crisis periods.

N = No evidence of contagion
C = Evidence of contagion

<img width="986" height="272" alt="image" src="https://github.com/user-attachments/assets/f2d6d1f2-a633-417d-b37a-825eb4ee8708" />
