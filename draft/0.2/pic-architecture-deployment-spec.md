---
title: "PIC Architecture and Deployment"
abbrev: "PIC Architecture and Deployment"
docname: pic-architecture-deployment-02
category: info
ipr: none
submissiontype: independent
stand_alone: yes
smart_quotes: false
pi: [toc, sortrefs, symrefs]
date: 2026-07-19

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
**Document:** pic-architecture-deployment-02
**Version:** 0.2 (Draft)
**Document Status:** Public Draft
**Intended Use:** Informational and Experimental
**Published:** 2026-07-19
**Editor(s):** Nicola Gallo (Nitro Agility S.r.l.)
**Steward:** Nitro Agility S.r.l.
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-architecture-deployment-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-architecture-deployment-spec.md)

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

--- note_Editors

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- note_Contributors

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- abstract

This document is the **PIC Architecture and Deployment Specification**, a subordinate specification of the
[PIC Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md). It describes how the components defined by the
[PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md) and the
[PIC Execution Guardrail Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md) are arranged and operated in concrete systems: the two deployment
architectures — **centralized**, where a trusted central server, the **Trust Plane**, validates every transition against the lineage
history it holds, and **decentralized**, where every hop proves and verifies locally — their fit to trusted and untrusted environments,
hybrid enterprise compositions of the two,
and interoperability with existing token infrastructures through an OAuth token-exchange profile to be defined in a future specification.

This revision describes the architectures; the normative deployment requirements will be developed in forthcoming revisions. This document
does not redefine, extend, or alter the PIC Model or the normative semantics defined by the PIC Specification. In case of conflict, the
**PIC Specification** is authoritative.

--- middle

# Introduction

This section is non-normative.

This specification describes the architectures of PIC systems and their deployment types: centralized and decentralized (Section 2),
their fit to trusted and untrusted environments (Section 3), hybrid enterprise compositions (Section 4), and interoperability with
existing token infrastructures (Section 5). The components deployed are those of the
[PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md) and the
[PIC Execution Guardrail Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md).

## Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals,
and only within the normative sections of this document. Examples are illustrative and non-normative.

# Architectures

This section is non-normative. This specification defines two deployment topologies, centralized and decentralized; within each, different
chain-validation profiles ([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Sections 5 and 7) provide different
cost and assurance properties.

## Centralized

In the centralized architecture the hops work exactly as in the decentralized one — each executor constructs, signs, and remains the
signer of its own PCA — but every proposed transition is submitted to a trusted central server, the **Trust Plane**, which acts as the
Verifier of the `n+1` transition ([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Sections 3 and 5.2): it
validates the transition against the lineage history it holds and may add its own signature — a validation attestation, receipt, envelope,
or checkpoint. That signature attests Trust Plane validation; it does not replace, and must not be interpreted as, the executor signature.
Where a profile lets the Trust Plane materially construct a PCA, the final signature is still produced by the executor or through an
explicit, normatively defined signing delegation. The rest of this document uses Trust Plane for the centralized trusted server.

~~~text
+--------+        +--------+        +--------+
| HOP 1  |        | HOP 2  |        | HOP 3  |
+--------+        +--------+        +--------+
     \                 |                 /
      \                |                /
       v               v               v
      +---------------------------------+
      |           TRUST PLANE           |
      |   validates every transition    |
      |   signs validation attestations |
      |   holds the lineage history     |
      +---------------------------------+

executors sign their own PCAs;
the Trust Plane signs its validation
~~~

## Decentralized

Each hop runs its own PIC Prover and PIC Verifier locally: no central component is required, and every transition is proved and verified
at the hop that performs it.

~~~text
+-------------+       +-------------+       +-------------+
| HOP 1       |------>| HOP 2       |------>| HOP 3       |
| local P + V |  PoR  | local P + V |  PoR  | local P + V |
+-------------+       +-------------+       +-------------+

no central component; every hop proves and verifies locally
~~~

## Consecutive Collusion and History

The decentralized incremental profile is secure hop by hop, with one documented limit
([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Section 6.8): two or more consecutive colluding hops cannot be
detected when the receiving Verifier lacks authenticated evidence of the earlier lineage prefix.

~~~text
+-------+      +---------+      +---------+      +-------+
| HOP 1 |----->| HOP 2 X |----->| HOP 3 X |----->| HOP 4 |
+-------+      +---------+      +---------+      +-------+

colluding hops: without the history, HOP 4
cannot re-check the step from HOP 1 to HOP 2
~~~

The history can be held by the Trust Plane, carried inside the PCA chain, or committed to by a succinct proof
([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Sections 5.1–5.3). Carrying the complete prefix makes size and
validation cost grow linearly with lineage length, so it is unsuitable as the default lightweight profile; a deployment may nevertheless
select full-chain validation when its stronger independent-verification property justifies the O(n) cost. A succinct proof keeps
verification cheap but moves the cost to proof generation and adds the proof-system, setup, and availability assumptions.

| Topology and profile | Central component | History | Cost | Consecutive collusion |
| --- | --- | --- | --- | --- |
| Centralized: Trust Plane | yes | history or authenticated validation state held by the Trust Plane | O(1) per hop | resisted under the Trust Plane assumptions |
| Decentralized, incremental | none | immediate transition only | O(1) | not resisted |
| Decentralized, full-chain | none | complete prefix carried or otherwise available | O(n) size and verification | resisted |
| Decentralized, succinct proof | none | proof commits to the validated prefix | succinct verification; generation cost per proof system | resisted under the proof-system assumptions |

The profile trade-offs are analyzed in the [PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Sections 6.8 and 7.

# Trusted and Untrusted Environments

This section is non-normative. The choice between the two architectures follows the environment.

In a **trusted environment** — one whose hops the deployment threat model accepts as trustworthy — consecutive collusion is out of scope:
decentralized incremental validation may be sufficient, with no central dependency. In an **untrusted environment** where consecutive
collusion is in scope, the deployment must select a profile that independently authenticates the relevant lineage prefix: a Trust Plane
with authenticated history, full-chain validation, or an approved succinct-proof profile (Section 2.3). The Trust Plane is the
operationally preferred choice — collusion resistance at O(1) without advanced cryptography — but not the only profile the model permits.
Trust is a property of the deployment threat model, its trust anchors, and the adopted profile — a single administrative domain is not
trusted by itself.

| Environment | Threat assumption | Suitable topology and profile |
| --- | --- | --- |
| Trusted | consecutive collusion out of scope | decentralized incremental may be sufficient |
| Untrusted or high-risk | consecutive collusion in scope | Trust Plane with authenticated history, full-chain validation, or an approved succinct-proof profile |

The same segmentation drives the guardrail deployment modes of the
[PIC Execution Guardrail Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md) (Section 3.4): trusted segments may operate hops in non-sandbox
mode; untrusted or high-risk segments use sandbox mode.

# Hybrid Enterprise Architectures

This section is non-normative. Enterprise deployments are rarely uniform: one execution may cross segments with different threat
assumptions in the same chain. While execution crosses a segment in which consecutive collusion is out of scope, decentralized incremental
verification may be used; when it enters a segment in which consecutive collusion is in scope, the deployment uses the selected
collusion-resistant profile — Trust Plane validation, full-chain validation, or an approved succinct-proof profile (Section 3). The PIC
invariants are the same everywhere ([PIC Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md);
[PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Sections 2.4 and 3.3); only the validation topology, the
chain-validation profile, and the resulting assurance assumptions change.

The following diagram illustrates the Trust Plane variant of a hybrid deployment.

~~~text
        TRUSTED SEGMENT           |          UNTRUSTED SEGMENT
                                  |
+-----------+    +-----------+    |    +-----------+    +-----------+
| HOP 1     |--->| HOP 2     |-------->| HOP 3     |--->| HOP 4     |
| local P+V |    | local P+V |    |    |           |    |           |
+-----------+    +-----------+    |    +-----+-----+    +-----+-----+
                                  |          |                |
                                  |          v                v
                                  |     +-------------------------+
                                  |     |       TRUST PLANE       |
                                  |     |  validates transitions  |
                                  |     +-------------------------+
~~~

The segment boundary is an assurance boundary. The receiving Trust Plane is not required to retroactively validate the entire preceding
trusted segment unless the selected profile requires full-history validation: assurance for the preceding prefix derives from the trust
domain that produced it — presented at the boundary as a checkpoint, snapshot, authenticated state commitment, or full history — and
accepted under the receiving side's trust policy. Trust Plane guarantees begin at the accepted boundary. How validation state transfers
across Trust Plane boundaries — trust anchors, checkpoint signatures, prefix coverage, key rotation, revocation, trust-domain recognition,
optional full-history verification or succinct proofs, and coordinated single-use across domains — will be defined by a future Trust Plane
federation profile.

## Service Meshes

A service mesh — one administrative domain operating workload identity, mutual authentication, and traffic policy — may be classified as a
trusted environment when the deployment threat model accepts it as such: hops inside the mesh then verify locally, as in the trusted
segment above.

# Interoperability

This section is non-normative. For interoperability with existing token infrastructures, the definition of an **OAuth Token Exchange
profile** is recommended: exchanging an Access Token for a PCA and a PCA for an Access Token, so that PIC enters and leaves existing
systems without integration friction. This is consistent with PCA0 derivation from existing credentials
([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Section 1.8) and builds on OAuth 2.0 Token Exchange
[[4]](#references). The profile will be defined in a future specification.

~~~text
OAUTH INFRASTRUCTURE                      PIC

+--------------+     token exchange      +--------------+
| ACCESS TOKEN |------------------------>| PCA0         |   enter PIC
+--------------+                         +--------------+

+--------------+     token exchange      +--------------+
| PCA          |------------------------>| ACCESS TOKEN |   leave PIC
+--------------+                         +--------------+

one profile, both directions
~~~

# Contributors {#contributors}

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md).

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

are maintained in a single canonical document, the **[PIC Legal Appendices](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth herein.

In case of conflict between this document and the PIC Legal Appendices, the PIC Legal Appendices prevail for legal, governance, licensing,
and attribution matters.

This specification is subordinate to the [PIC Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md), which defines the normative semantics of the PIC Model and is
the entry point of the specification set. This document does not introduce new conceptual authority, invariants, or authorship claims beyond
those defined in the PIC Legal Appendices.

# References {#references}

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
- [4] Jones, M., Nadalin, A., Campbell, B., Bradley, J., & Mortimore, C. (2020). *OAuth 2.0 Token Exchange*. RFC 8693. [rfc-editor.org/rfc/rfc8693](https://www.rfc-editor.org/rfc/rfc8693)
