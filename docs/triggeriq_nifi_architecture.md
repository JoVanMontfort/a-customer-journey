# 📥 TriggerIQ NiFi-Based Ingestion Architecture

This document outlines a complete ingestion architecture for TriggerIQ, combining Apache NiFi, smart retry mechanics, and Spring Boot-based fallback logic.

---

## 🎯 Goal
To ingest data from unreliable third-party APIs into TriggerIQ's data platform with resilience, traceability, and fallback safety.

---

## 📦 Components Overview

| Component            | Role                                                |
|---------------------|-----------------------------------------------------|
| **Apache NiFi**      | Visual orchestration & flow management              |
| **NiFi Retry Queue** | Buffer & retry transient failures with delays       |
| **Spring Boot Microservice** | Handle fallback logic (caching, defaults, audit logs) |
| **Prometheus + Grafana** | Monitoring for success/failure, retries, backpressure |

---

## 🔁 NiFi Ingestion Flow Diagram (Conceptual)

```
[GenerateFlowFile (TimerTrigger)]
        ↓
[InvokeHTTP → 3rd-party API]
        ↓
[RouteOnAttribute: responseCode]
    ├── 200 → [Parse JSON] → [Validate] → [PutDatabaseRecord]
    ├── 5xx or timeout → [Put into RetryQueue]
    ├── Malformed → [Log] → [Send to FallbackService (Spring Boot)]
    └── 404/410 → [Drop or Archive]
```

---

## 🔁 NiFi Retry Queue Mechanics

### ✅ Design
- Use a **FlowFile attribute** like `retry.count`
- Route to a **self-loop with delay** using `Wait/Notify` or `Wait + ExecuteScript`
- Limit retries with a check (`retry.count > 3 → fallback`)

### 🧠 Example Processors
```
[RouteOnAttribute: retry.count > 3?]
    ├── true → [FallbackService call]
    └── false → [Wait 1–5 min] → [Re-InvokeHTTP]
```

### 💡 Implementation Tips
- Use `UpdateAttribute` to increment `retry.count`
- Use `Wait` with `ReleaseSignalIdentifier` tied to timestamp logic or an external signal

---

## 🧩 Spring Boot Microservice – Fallback API

### 📌 Purpose
- Receive fallback data from NiFi
- Optionally pull from cache or static defaults
- Log failed payloads to database (audit)
- Provide an override path for re-ingestion

### 🔧 API Contract
`POST /fallback/triggers`
```json
{
  "source": "TriggerAPI-X",
  "payload": { ... },
  "errorType": "MalformedResponse",
  "timestamp": "2025-06-07T18:03:00Z"
}
```

### 🛠 Responsibilities
- Store raw payloads
- Return a fallback object to NiFi (if needed)
- Emit metrics/logs via Prometheus or ELK

---

## 📊 Monitoring & Observability
- Use **Prometheus JMX Exporter** on NiFi
- Track:
  - Retry count histogram
  - Flowfile queue size
  - Error type breakdown (timeouts, 500s, parse fails)
- Visualize in **Grafana Dashboards**

---

## 🧠 Conclusion
This hybrid architecture allows TriggerIQ to ingest unreliable third-party data **safely, observably, and automatically**, with fallback resilience and clear accountability.
