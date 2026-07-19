# Provenance Identity Continuity (PIC) Model Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-15  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md)

## Abstract

This document is the **PIC Specification**: the entry point of the PIC
specification set. It defines the normative semantics of the
**Provenance Identity Continuity (PIC) Model** and indexes the subordinate
specifications that cover specific domains.

The PIC Specification expresses the execution invariants of the PIC Model in
normative form, without redefining, extending, or altering the underlying
theoretical model. In case of conflict, the **PIC Model** publications remain
authoritative for the theoretical framework, while this **PIC Specification**
is authoritative for normative requirements and conformance language.

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Documents](#2-documents)  
3. [Legal Notices](#3-legal-notices)  

## 1. Introduction

- The **PIC Model** defines the foundational execution theory and invariants
  (see [References](#references)).
- The **PIC Specification** (this document and its subordinate specifications)
  defines the normative semantics of the PIC Model.

Documents and implementations claiming conformance with PIC **MUST** faithfully
preserve the invariants defined by the PIC Model as expressed by this
Specification. Anything that violates these invariants is **not PIC-compliant**,
regardless of naming or intent.

Subordinate specifications:

- MUST NOT redefine, extend, or alter the invariants of the PIC Model,
- MUST incorporate the [PIC Legal Appendices](./pic-legal.md) by reference,
- are canonical only in the version designated by the Specification Steward.

## 2. Documents

| Document | Description | Status | Date |
| --- | --- | --- | --- |
| [PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) | Normative requirements for PIC Provers and Verifiers: the per-hop Proof of Relationship and successor-PCA construction, the ordered Verifier checks (including executed-vs-signed) that enforce the PIC invariants, authority as an abstract attenuation domain with a PDP boundary, and the chain representations — full hash chain, the snapshot hash chain it orients on, and succinct proofs. | Draft 0.2 | 2026-07-15 |
| [PIC Revocation Specification](./pic-revocation-spec.md) | Revocation coordinates (`lineageId`, `grantId`, `lineageCounter`, `originIssuer`, and `branchId` in branch-capable profiles) and their hop-by-hop continuity, the requirements for turning a historical selector into a causal cutoff, and revocation-authorization and revocation-state requirements. | Draft 0.2 | 2026-07-18 |
| [PIC Execution Guardrail Specification](./pic-lineage-guardrail-spec.md) | A **Lineage Execution** is a single-origin PIC execution; a **Multi-Lineage Execution** carries one or more of them together for one proposed transition. **Execution Guardrails** — invoked by trusted sandboxes — validate the participating PCAs, evaluate configured policy over semantic scopes, and enforce permit or deny; permitted crossings travel in a guardrail envelope. *Participation, not authority mixing.* | Draft 0.2 | 2026-07-19 |
| [PIC Architecture and Deployment Specification](./pic-architecture-deployment-spec.md) | Centralized (**Trust Plane**) and decentralized architectures, their fit to trusted and untrusted environments, hybrid enterprise topologies and service meshes, and interoperability with existing token infrastructures through an OAuth token-exchange profile. | Draft 0.1 | 2026-07-19 |

## 3. Legal Notices

The appendices governing:

- **A.** Use of Automated Language Assistance,
- **B.** Authorship, Stewardship, Attribution, and Derivative Works,
- **C.** Disclaimer and Limitation of Liability,
- **D.** Acknowledgements,

are maintained in a single canonical document, the
**[PIC Legal Appendices](./pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth
herein.

In case of conflict between this document and the PIC Legal Appendices, the
PIC Legal Appendices prevail for legal, governance, licensing, and attribution
matters.

## References

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
