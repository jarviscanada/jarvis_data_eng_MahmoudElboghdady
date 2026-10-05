# RBC GAM - Monthly Reporting Dashboard | Business Requirements Document

A Business Systems Analyst engagement delivered in the Jarvis BSA track. The objective was to elicit and document the requirements for an automated Monthly Performance Reporting dashboard for RBC Global Asset Management (GAM), Data & Insights.

## Business Problem

GAM's Data & Insights team produced a Monthly Performance Report for ~40 senior leaders entirely by hand: three analysts spent ~25-27 hours each cycle extracting and reconciling data across five systems. The process was slow, low-adoption (only 3-5 of 40 leaders read it), and error-prone - an undetected headcount error (1,872 vs 1,856) recently reached the CFO and forced a reissue.

## My Role and Approach

As the BSA, I owned requirements end to end:

- **Elicitation** - ran a structured interview with the sponsoring Managing Director and routed current-state questions to the Data Analyst and technical-feasibility questions to the Development Lead.
- **Business Requirements Document** - authored all 13 sections, with testable functional and non-functional requirements (Given/When/Then), MoSCoW prioritisation, a RACI matrix, dependency and risk registers, cost-benefit analysis, and a burn-down tracker.
- **Scope and change control** - handled a CFO real-time-feed request as a formal change request, recommending it as a Phase 2 enhancement rather than absorbing it into scope.
- **Risk and dependency management** - logged a broken vendor API (PipelineDB) with three integration options and a compliance review for direct deal-data access; assigned owners and recommended a path for every open item.
- **Executive communication** - delivered a 10-minute stakeholder presentation recommending sign-off within the governance cycle.

## Deliverables

- [Business Requirements Document (v0.1)](./BRD_RBC_GAM_Monthly_Reporting_Dashboard.pdf)
- [Stakeholder Presentation](./Stakeholder_Presentation_RBC_GAM.pptx)

## Target Outcomes

| Measure | Today | Proposed |
|---|---|---|
| Report production time | 25-27 hours / cycle | under 3 hours |
| Undetected published errors | at least 1 | 0 |
| Adoption | ~10% | 80% |
| Analyst capacity recovered | - | ~270 hours / year |

Built on the bank's existing enterprise Power BI, at no new platform cost.

## Skills Demonstrated

Requirements elicitation, BRD authoring, stakeholder management, MoSCoW prioritisation, RACI, risk and dependency management, scope and change control, Agile/Scrum, and executive communication.
