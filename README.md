# MarketSense-AI: Automated Executive Intelligence Pipeline

**MarketSense-AI** is an end-to-end data architecture that automates the transition from raw API market data to executive-ready insights. This project replaces manual analysis with a robust pipeline involving Python-based ingestion, BigQuery warehousing, and a custom App Script integration with Google Gemini 2.5 Flash to synthesize market narratives.

## 🛠️ Tech Stack & Architecture

### 1. Ingestion Layer (Zapier & Python)
A scheduled **Zapier Code** step executes a Python script to fetch the top 20 cryptocurrencies via the **CoinMarketCap API**. 
* **Key Feature:** The script flattens complex JSON data into a serialized `line_item` format to ensure reliable transmission into Google Sheets.
* **Logic:** Fetches price, market cap, and performance metrics across multiple timeframes (1h, 24h, 30d, 60d, 90d).

### 2. Warehousing & Transformation (BigQuery SQL)
Data is synced to **BigQuery**, where it initially lands as raw serialized strings. A complex SQL transformation query reconstructs the data.
* **Strategic Pivot:** Utilized `WITH` clauses and `UNNEST` logic combined with `OFFSET` to ensure data integrity—guaranteeing every asset name correctly matches its corresponding price and metrics.
* **Deduplication:** Applied `ROW_NUMBER()` window functions to isolate only the most recent refresh cycle.

### 3. Intelligence Layer (App Script & Google Gemini)
Transformed data is extracted to a reporting sheet where a custom-built **Google App Script** (`MY_GEMINI`) bridges to **Gemini 2.5 Flash**.
* **Custom Function:** Developed a reusable `=MY_GEMINI()` function taking real-time cell metrics as arguments.
* **Prompt Engineering:** Synthesizes 30-day vs. 60-day performance contrasts relative to price into a single executive narrative.

### 4. Executive UI/UX (Looker Studio)
The final dashboard joins three distinct data streams:
1. **Transformed Market Data:** High-fidelity metrics from BigQuery.
2. **AI Narrative Layer:** Synthesized qualitative insights from the App Script.
3. **Regional Context:** Mapping of most-traded assets by country.

---

## 🛠️ Engineering Challenges & Workarounds

### 1. API Rate Limiting & High-Demand Latency
* **Challenge:** Using the free tier of the Gemini API often resulted in "Model Busy" errors or 503 blocks during peak hours.
* **Solution:** Engineered **Exponential Backoff & Retry Logic** within the App Script. The script catches errors and pauses execution for 2 seconds, attempting up to 3 retries before failing.

### 2. Data Serialization & "String-Blob" Ingestion
* **Challenge:** Python sends data as a flattened object, making standard relational queries impossible in the raw BigQuery landing zone.
* **Solution:** Developed a **SQL Transformation Layer** using `UNNEST` and `OFFSET` logic. By treating the incoming data as an array and mapping indices, I reconstructed the relational integrity of the data.

### 3. Automated State Management
* **Challenge:** "New or Updated Row" triggers risked recursive loops where an AI update would re-trigger the automation.
* **Solution:** Implemented **Primary Key Scoping**. The pipeline triggers only on a specific "Update Column" (Asset Name), decoupling ingestion from the AI's write-back process.

---

## 🚀 Key Learning: Resilient Systems
This project demonstrates the ability to build enterprise-grade reliability on limited infrastructure. By utilizing technical workarounds—like SQL array-splitting and custom JS error handling—I delivered a high-uptime insight engine without the need for premium proprietary middleware.
