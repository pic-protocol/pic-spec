---
title: "Provenance Identity Continuity (PIC) Model Specification"
abbrev: "PIC Specification"
docname: pic-specification-02
category: info
ipr: none
submissiontype: independent
stand_alone: yes
smart_quotes: false
pi: [toc, sortrefs, symrefs]
date: 2026-07-15

author:
  - ins: N. Gallo
    name: Nicola Gallo
    org: Nitro Agility S.r.l.
    email: nicola.gallo@nitroagility.com

normative: {}
informative: {}
---

--- note_Document_Status

**Project:** PIC Protocol
**Project Website:** [www.pic-protocol.org](https://www.pic-protocol.org/)
**Document:** pic-specification-02
**Version:** 0.2 (Draft)
**Document Status:** Public Draft
**Intended Use:** Informational and Experimental
**Published:** 2026-07-15
**Editor(s):** Nicola Gallo (Nitro Agility S.r.l.)
**Steward:** Nitro Agility S.r.l.
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md)

--- note_About_This_Document

> **Public Draft — Not a Standard**
>
> This document is an independently developed specification published as part of the PIC Protocol and maintained by Nitro Agility
> S.r.l. in its role as Specification Steward.
>
> It has not been adopted, endorsed, approved, or published by the IETF, IRTF, IAB, RFC Editor, ISO, IEC, W3C, CNCF, OpenID
> Foundation, or any other standards-development organization, unless a later version explicitly states otherwise.
>
> It is not an RFC, an Internet Standard, or an official work item of any working group or standards body.
>
> This document is published for public review, research, experimentation, implementation feedback, and possible future
> standardization work. It may be revised, replaced, or withdrawn at any time.
>
> Implementers use this draft at their own risk. Any implementation, interoperability statement, or conformance claim applies only
> to the exact document version identified above.
>
> Publication of this draft does not constitute certification, endorsement, security approval, interoperability assurance,
> regulatory approval, or standards-body recognition.
>
> Current project information and published specifications are available at `https://www.pic-protocol.org/`.

--- abstract

This document is the **PIC Specification**: the entry point of the PIC
specification set. It defines the normative semantics of the
**Provenance Identity Continuity (PIC) Model** and indexes the subordinate
specifications that cover specific domains.

The PIC Specification expresses the execution invariants of the PIC Model in
normative form, without redefining, extending, or altering the underlying
theoretical model. In case of conflict, the **PIC Model** publications remain
authoritative for the theoretical framework, while this **PIC Specification**
is authoritative for normative requirements and conformance language.

--- middle

# Introduction

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
- MUST incorporate the [PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md) by reference,
- are canonical only in the version designated by the Specification Steward.

# Documents

| Document | Description | Status | Date |
| --- | --- | --- | --- |
| [PIC Prover and Verifier](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md) | Normative requirements for PIC Provers and Verifiers: the per-hop Proof of Relationship and successor-PCA construction, the ordered Verifier checks (including executed-vs-signed) that enforce the PIC invariants, authority as an abstract attenuation domain with a PDP boundary, and the chain representations — full hash chain, the snapshot hash chain it orients on, and succinct proofs. | Draft 0.2 | 2026-07-15 |
| [PIC Revocation](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md) | Revocation coordinates (`lineageId`, `grantId`, `lineageCounter`, `originIssuer`, and `branchId` in branch-capable profiles) and their hop-by-hop continuity, the requirements for turning a historical selector into a causal cutoff, and revocation-authorization and revocation-state requirements. | Draft 0.2 | 2026-07-18 |
| [PIC Execution Guardrail](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md) | A **Lineage Execution** is a single-origin PIC execution; a **Multi-Lineage Execution** carries one or more of them together for one proposed transition. **Execution Guardrails** — invoked by trusted sandboxes — validate the participating PCAs, evaluate configured policy over semantic scopes, and enforce permit or deny; permitted crossings travel in a guardrail envelope. *Participation, not authority mixing.* | Draft 0.2 | 2026-07-19 |
| [PIC Architecture and Deployment](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-architecture-deployment-spec.md) | Centralized (**Trust Plane**) and decentralized architectures, their fit to trusted and untrusted environments, hybrid enterprise topologies and service meshes, and interoperability with existing token infrastructures through an OAuth token-exchange profile. | Draft 0.2 | 2026-07-19 |

# Acknowledgement

The **Provenance Identity Continuity (PIC) Model** — the theoretical framework this specification expresses in normative form — was created
by **Nicola Gallo**. It first appeared on Zenodo on 1 December 2025 and is developed in full in the Proof-of-Continuity paper:

- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Zenodo.
  [zenodo.org/records/17777421](https://zenodo.org/records/17777421) (DOI: 10.5281/zenodo.17777421).
- Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. Zenodo.
  [zenodo.org/records/21285112](https://zenodo.org/records/21285112) (DOI: 10.5281/zenodo.21285112).

Authorship of the PIC Model remains with Nicola Gallo; the PIC specifications are published and maintained by **Nitro Agility S.r.l.** as
Specification Steward. Any work that references, implements, or claims conformance with PIC must preserve this attribution, distinguishing the
**PIC Model** (author: Nicola Gallo) from the **PIC Specifications** (steward: Nitro Agility S.r.l.), as required by the
**[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md)** (Appendix B, Attribution; Appendix D,
Acknowledgements), which are incorporated into this specification by reference.

# Legal Notices

The appendices governing:

- **A.** Use of Automated Language Assistance,
- **B.** Authorship, Stewardship, Attribution, and Derivative Works,
- **C.** Disclaimer and Limitation of Liability,
- **D.** Acknowledgements,

are maintained in a single canonical document, the
**[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth
herein.

In case of conflict between this document and the PIC Legal Appendices, the
PIC Legal Appendices prevail for legal, governance, licensing, and attribution
matters.

# References {#references}

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
