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
date: 2026-10-26

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
**First Published:** 2026-07-15
**Last Updated:** 2026-10-26
**Editor(s):** Nicola Gallo (Nitro Agility S.r.l.)
**Steward:** Nitro Agility S.r.l.
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md)

--- note_About_This_Document

> **Public Draft — Not a Standard**
>
> This document is an independently developed specification published as part of the PIC Protocol and maintained by Nitro Agility
> S.r.l. in its role as Specification Steward.
>
> It has not been adopted, endorsed, approved, or published by a standards-development organization. It is published for public review,
> research, experimentation, implementation feedback, and possible future standardization work. It may be revised, replaced, or withdrawn
> at any time.
>
> Implementers use this draft at their own risk. Any implementation, interoperability statement, or conformance claim applies only
> to the exact document version identified above.
>
> Publication does not constitute certification, endorsement, security approval, interoperability assurance, or regulatory approval.
>
> Current project information and published specifications are available at `https://www.pic-protocol.org/`.

--- note_Feedback_and_Issue_Tracking

The source for this document and the issue tracker for technical discussion are maintained at
[github.com/pic-protocol/pic-spec](https://github.com/pic-protocol/pic-spec). Changes are accepted through the repository contribution
process. Published releases, tags, and immutable research references identify the version to which a review or conformance statement applies.

--- note_Copyright_and_License

This document is made available under the Creative Commons Attribution 4.0 International license. See the repository
[LICENSE](https://github.com/pic-protocol/pic-spec/blob/main/LICENSE) and [NOTICE](https://github.com/pic-protocol/pic-spec/blob/main/NOTICE.md).
This notice does not add restrictions to that license.

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
- MUST identify the version of this specification on which they depend,
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
| [PIC Prover and Verifier](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md) | Normative, implementation-independent requirements for PIC Provers and Verifiers: logical objects, trusted roots, non-root continuity advancements, Proof of Relationship, ordered Verifier checks, authority attenuation, request/execution binding, conformance, and profile-selected representations. | Draft 0.2 | 2026-07-15 |
| [PIC Revocation](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md) | Revocation around stable lineage identifiers, path positions, lineage-depth and causal cutoffs, optional authenticated selectors, position or ancestry witnesses, revocation authorization, and authenticated revocation state. | Draft 0.2 | 2026-07-18 |
| [PIC Sandboxed Execution](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md) | Sandboxed Execution as an outer `ENFORCE` PIC continuity governing a Composition Collection of independently verifiable PIC continuities. The collection is bound exactly, members remain independent, and no authority union is created. | Draft 0.2 | 2026-07-20 |
| [PIC Architecture and Deployment](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-architecture-deployment-spec.md) | Profile-selected PIC deployment architectures, including trusted continuity services, decentralized validation, hybrid enterprise topologies, service meshes, and optional interoperability through selected exchange profiles. | Draft 0.2 | 2026-08-12 |

Implementation mappings, product coverage reports, and deployment-specific interoperability notes are maintained outside the normative
specification set. They may demonstrate conformance but do not define PIC semantics or modify a profile's requirements.

# Origins, Authorship, and Historical Record

This section is informative.

The **Provenance Identity Continuity (PIC) Model** was originally developed by **Nicola Gallo** as a formal framework for reasoning about causal
authority propagation across distributed execution. Its development introduced Proof of Relationship (PoR), Proof of Continuity (PoC),
authority non-expansion, relational attenuation, and event-level causal provenance as connected parts of the framework. The PIC
Specifications translate those formal results into technical requirements and are published and maintained by **Nitro Agility S.r.l.** as
Specification Steward.

## Historical References

The publicly verifiable research record is:

- **1 December 2025 — initial public PIC Model working paper.** *PIC Model — Provenance Identity Continuity for Distributed Execution
  Systems*, Zenodo record 17777421 [[7]](#references). That archived draft is retained for historical reference and is not an implementation
  specification.
- **5 December 2025 — authority-propagation analysis.** *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*,
  Zenodo record 17833000 [[6]](#references).
- **9 July 2026 — formal Proof-of-Continuity paper.** *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed
  Systems and AI Agents*, arXiv:2607.08906 [[1]](#references).
- **25 September 2026 — relational authority theory.** *Beyond Proof of Possession: A Relational Theory of Authority*, Zenodo record
  23102206 [[4]](#references).
- **2 October 2026 — event-level causal closure.** *Full Provenance on the COSS Causal Axis: An Event-Level Closure of Causal Attribution
  and Confused-Deputy Exclusion*, Zenodo record 23102373 [[5]](#references).

The PIC Specification 0.2 family was first published on **15 July 2026** and subsequently revised as the formal record developed. Published
tags and immutable records identify the exact text applicable to a review or conformance claim. Researchers and implementers are encouraged
to cite the primary publication that supports the formal property they discuss. Copyright attribution for reuse of PIC specification
materials is governed separately by the applicable CC BY 4.0 license.

# Security Considerations

The security consequences of PIC depend on the concrete profile and its realization of PoR, non-expansion, freshness, request or execution
binding, revocation, and complete mediation. Authentication of artifacts or possession of keys alone does not establish causal continuity.
The subordinate specifications define the detailed security requirements for their respective mechanisms.

# Privacy Considerations

Continuity identifiers, causal relationships, authority contexts, executor evidence, and revocation state can enable correlation across
services or execution steps. Profiles and deployments should disclose only the evidence required by the receiving Verifier, scope stable
identifiers to the smallest suitable trust domain, and define retention and access controls for continuity records. Data minimization must
not remove evidence required for a claimed security property.

# Registry Considerations

This version defines no shared protocol registry and requests no external registry action. A future wire-format or interoperability profile
may define registries for identifiers, algorithms, evidence types, or error values.

# References {#references}

## Normative References

- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)

## Informative References

- [1] Gallo, N. (9 July 2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
- [4] Gallo, N. (25 September 2026). *Beyond Proof of Possession: A Relational Theory of Authority*. Zenodo. DOI: [10.5281/zenodo.23102206](https://doi.org/10.5281/zenodo.23102206)
- [5] Gallo, N. (2 October 2026). *Full Provenance on the COSS Causal Axis: An Event-Level Closure of Causal Attribution and Confused-Deputy Exclusion*. Zenodo. DOI: [10.5281/zenodo.23102373](https://doi.org/10.5281/zenodo.23102373)
- [6] Gallo, N. (5 December 2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. DOI: [10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [7] Gallo, N. (1 December 2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Archived working paper. Zenodo. DOI: [10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)

# Document History

This section is informative.

- **0.2 — 15 July 2026.** Initial publication of the 0.2 specification family.
- **0.2 revision — 26 October 2026.** Aligned concrete assurance claims, relational authority, event-level causal provenance, fan-out, and
  multi-parent composition with the cited formal record; separated the research history from repository licensing and governance; and
  established the standalone origin, authorship, and historical record used across the specification family.

# Acknowledgments

Acknowledgments recognize review, discussion, or editorial assistance and do not define authorship, conformance, endorsement, or technical
responsibility. Names are added only when a concrete contribution has been identified and the person agrees to be listed.

# Contributors {#contributors}

The editor and current contributors are identified in the document header and repository history. Contribution credit is distinct from the
historical origin of the PIC Model and from stewardship of the PIC Specifications.
