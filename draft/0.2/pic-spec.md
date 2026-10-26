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

## Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals.

Documents and implementations claiming conformance with PIC **MUST** faithfully
preserve the invariants defined by the PIC Model as expressed by this
Specification. Anything that violates these invariants is **not PIC-compliant**,
regardless of naming or intent.

Subordinate specifications:

- MUST NOT redefine, extend, or alter the invariants of the PIC Model,
- MUST incorporate the [PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md) by reference,
- are canonical only in the version designated by the Specification Steward.

# Core Invariants

This section is normative.

A PIC-conformant specification, profile, or implementation MUST preserve all of
the following invariants:

1. A root PIC Context of Authority establishes the upper authority bound for its
   lineage.
2. Every accepted non-root advancement MUST continue exactly one causal
   predecessor.
3. The selected profile MUST establish the required Proof of Relationship
   (PoR) relation between the predecessor and successor.
4. Successor authority MUST be no greater than predecessor authority under the
   selected profile's attenuation order. For set-valued authority, successor
   authority is a subset of predecessor authority.
5. Authority from unrelated lineages MUST NOT be imported into a valid
   continuation.
6. A Proof of Continuity is the composition of valid hops that preserve these
   invariants.

When a selected profile carries a relational executor envelope or execution
contract, the predecessor envelope governs admission of the successor, the
successor profile MUST satisfy it under sound evidence, and the carried
successor envelope MUST preserve or strengthen it. In logical notation,
`rho(i+1) => rho(i)`. Withholding profile evidence MUST NOT widen admission
[[4]](#references).

When a selected profile generalizes carried state to several ordered security
coordinates, every ordinary transition MUST be non-expansive in every
coordinate under that coordinate's declared semantic order. Any
non-conservative coordinate change is an explicit authorized relaxation, not
an ordinary continuation [[5]](#references).

These invariants define full PIC continuity. A concrete profile or
implementation MUST NOT claim a Proof of Continuity, the PIC confused-deputy
exclusion result, or full PIC conformance merely because it authenticates
artifacts, links checkpoint bytes, proves control of a key, or enforces
non-expansion. Its receiving predicate MUST also soundly establish the
profile's concrete realization of the abstract PoR relation. An implementation
that establishes only a strict subset MAY describe those properties as a
partial or `artifact-linked` assurance level, but MUST identify the missing
refinement obligations and MUST NOT present that level as full PIC continuity
[[4]](#references).

Claims about concrete protected effects require additional realization
obligations: the modeled causal dependencies MUST be complete for the stated
threat model, evidence for causal edges MUST be sound, and every protected
effect in scope MUST be mediated against the authority state of its occurrence.
PIC continuity alone does not prove that hidden state, an omitted physical
path, or an unmediated effect was represented [[4]](#references) [[5]](#references).

The exactly-one-predecessor rule applies to an ordinary linear advancement.
Forks produce separate valid paths. A profile that represents an ordinary
multi-parent causal join MUST keep the child security state no more permissive
than every parent; for set-valued authority, the child authority is therefore
a subset of the intersection of the parent authorities. A composition, grant,
endorsement, or other non-conservative transition MUST be explicit and
separately authorized and MUST NOT masquerade as an ordinary continuation
[[5]](#references).

# Documents

| Document | Description | Status | Date |
| --- | --- | --- | --- |
| [PIC Prover and Verifier](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md) | Normative requirements for PIC Provers and Verifiers: trusted roots, non-root continuity advancements, Proof of Relationship, ordered Verifier checks including profile-conditional request/execution binding, authority as an abstract attenuation domain, profile-selected continuity representations, and explicit separation between full PIC continuity and partial artifact-linked assurance. Current Profile 0.2 uses centralized settlement with PIC Token JWTs carrying settled PIC Continuity COSE, PIC PCA COSE checkpoints, and workload-signed candidate advancement artifacts. | Draft 0.2 | 2026-07-15 |
| [PIC Revocation](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md) | Revocation around stable lineage identifiers, path positions, lineage-depth and causal cutoffs, optional authenticated selectors, position or ancestry witnesses, revocation authorization, and authenticated revocation state. PIC-X 0.2.3 exposes useful signed coordinates but implements no PIC revocation state. | Draft 0.2 | 2026-07-18 |
| [PIC Sandboxed Execution](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md) | Sandboxed Execution as an outer `ENFORCE` PIC continuity governing a Composition Collection of independently verifiable PIC continuities. The collection is bound exactly, members remain independent, and no authority union is created. PIC-X 0.2.3 does not implement this profile. | Draft 0.2 | 2026-08-12 |
| [PIC Architecture and Deployment](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-architecture-deployment-spec.md) | Profile-selected PIC deployment architectures, including trusted continuity services, hybrid enterprise topologies, service meshes, and optional interoperability through selected exchange profiles. Current Profile 0.2 settlement is centralized; PIC-X implements its current artifact-linked settlement subset, while future or other profiles may define other modes. | Draft 0.2 | 2026-08-12 |

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
- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
- [4] Gallo, N. (2026). *Beyond Proof of Possession: A Relational Theory of Authority*.
- [5] Gallo, N. (2026). *Full Provenance on the COSS Causal Axis: An Event-Level Closure of Causal Attribution and Confused-Deputy Exclusion*.
