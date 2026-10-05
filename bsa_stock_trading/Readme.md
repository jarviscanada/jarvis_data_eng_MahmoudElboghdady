# Business Systems Analysis (BSA) Project

This folder contains business and software requirements documentation produced as part of
the Jarvis Business Systems Analyst track. It demonstrates end-to-end requirements
engineering, from eliciting high-level business needs to authoring detailed functional and
non-functional software requirements.

**Author:** Mahmoud Elboghdady
**Organization:** Jarvis Consulting Group
**Role:** Business Systems Analyst

## Contents

| Document | File | Type | Version | Status |
|----------|------|------|---------|--------|
| Linux Cluster Monitoring System | `BRD_Linux_Cluster_Monitoring.docx` | Business Requirements Document (BRD) | v1.0 | Final, Submitted for Review |
| Retail Stock Trading Platform | `SRD_Stock_Trading_Platform.docx` | Software Requirements Document (SRD) | v0.1 Draft | Pending Stakeholder Review |

---

## 1. Business Requirements Document - Linux Cluster Monitoring System

A BRD defining the business case for a Linux Cluster Resource Monitoring System to track
hardware utilization across a 500-server on-premises data center, giving the Linux Cluster
Administration (LCA) team the data needed for capacity planning and incident response.

**Highlights**

- SMART-framed project objectives with a hard go-live target of June 1, 2026.
- Four core capability areas: data collection (per-node hardware metrics), centralized data
  storage for historical trend analysis, daily reporting and analytics (delivered by 6:10 PM
  each business day), and real-time alerting (server offline or CPU/RAM above 90%).
- A self-service web subscription portal for managing report and alert preferences.
- Clear in-scope / out-of-scope boundaries (e.g. excludes app-level monitoring, network/security
  monitoring, cloud-hosted servers, and ITSM integration).
- Stakeholder responsibilities, a phased seven-milestone schedule across DEV/QC/PRE-PROD/PROD
  environments, and a cost-benefit analysis supporting the investment decision.

## 2. Software Requirements Document - Retail Stock Trading Platform

An SRD defining functional and non-functional requirements for a self-directed retail stock
trading platform commissioned by a Canadian bank, delivered as a responsive web app and native
mobile app for an expected launch base of 150,000-200,000 clients.

**Highlights**

- Tagged functional requirements grouped by domain: authentication and account setup, portfolio
  and multi-account management (TFSA / RRSP / Cash), market data and stock discovery, trade
  execution, trade history, watchlist, notifications, and the open "Quest" page.
- Atomic trade transactions with full rollback on any failure to guarantee data integrity.
- Strict buy/sell constraints (no buying without funds, no selling beyond holdings) and a
  mandatory pre-submission confirmation screen.
- Third-party market data API integration on a 5-minute refresh cadence, limited to North
  American listed stocks and ETFs (TSX, NYSE, NASDAQ).
- Non-functional requirements targeting high security (TLS 1.2+, encryption at rest, salted
  password hashing, MFA, RBAC, audit logging), 99.9% availability, sub-5-second trade
  submission, and horizontal scalability to 200,000 concurrent users.
- Open items and assumptions explicitly logged for stakeholder resolution (e.g. account
  funding, market data vendor, notification channel, trading-hours enforcement, Quest page).

---

## Skills Demonstrated

Requirements elicitation, stakeholder analysis, BRD and SRD authoring, scope definition,
functional and non-functional requirements specification, SMART objectives, cost-benefit
analysis, and traceability between business needs and software specifications.
