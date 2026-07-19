# PIC Architecture and Deployment Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-19  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-architecture-deployment-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-architecture-deployment-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 6](#6-contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 6](#6-contributors)).*

## Abstract

This document is the **PIC Architecture and Deployment Specification**, a subordinate specification of the
[PIC Specification](./pic-spec.md). It describes how the components defined by the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and the
[PIC Execution Guardrail Specification](./pic-lineage-guardrail-spec.md) are arranged and operated in concrete systems: the two deployment
architectures — **centralized**, where a trusted central server, the **Trust Plane**, validates every transition against the lineage
history it holds, and **decentralized**, where every hop proves and verifies locally — their fit to trusted and untrusted environments,
hybrid enterprise compositions of the two,
and interoperability with existing token infrastructures through an OAuth token-exchange profile to be defined in a future specification.

This revision describes the architectures; the normative deployment requirements will be developed in forthcoming revisions. This document
does not redefine, extend, or alter the PIC Model or the normative semantics defined by the PIC Specification. In case of conflict, the
**PIC Specification** is authoritative.

## Table of Contents

- [PIC Architecture and Deployment Specification](#pic-architecture-and-deployment-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 Requirements Notation](#11-requirements-notation)
  - [2. Architectures](#2-architectures)
    - [2.1 Centralized](#21-centralized)
    - [2.2 Decentralized](#22-decentralized)
    - [2.3 Consecutive Collusion and History](#23-consecutive-collusion-and-history)
  - [3. Trusted and Untrusted Environments](#3-trusted-and-untrusted-environments)
  - [4. Hybrid Enterprise Architectures](#4-hybrid-enterprise-architectures)
    - [4.1 Service Meshes](#41-service-meshes)
  - [5. Interoperability](#5-interoperability)
  - [6. Contributors](#6-contributors)
  - [7. Legal Notices](#7-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative.

This specification describes the architectures of PIC systems and their deployment types: centralized and decentralized (Section 2),
their fit to trusted and untrusted environments (Section 3), hybrid enterprise compositions (Section 4), and interoperability with
existing token infrastructures (Section 5). The components deployed are those of the
[PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md) and the
[PIC Execution Guardrail Specification](./pic-lineage-guardrail-spec.md).

### 1.1 Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals,
and only within the normative sections of this document. Examples are illustrative and non-normative.

## 2. Architectures

This section is non-normative. Two deployment architectures cover the space.

### 2.1 Centralized

In the centralized architecture the hops work exactly as in the decentralized one — each executor constructs, signs, and remains the
signer of its own PCA — but every proposed transition is submitted to a trusted central server, the **Trust Plane**, which acts as the
Verifier of the `n+1` transition ([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Sections 3 and 5.2): it
validates the transition against the lineage history it holds and may add its own signature — a validation attestation, receipt, envelope,
or checkpoint. That signature attests Trust Plane validation; it does not replace, and must not be interpreted as, the executor signature.
Where a profile lets the Trust Plane materially construct a PCA, the final signature is still produced by the executor or through an
explicit, normatively defined signing delegation. The rest of this document uses Trust Plane for the centralized trusted server.

```text
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
```

### 2.2 Decentralized

Each hop runs its own PIC Prover and PIC Verifier locally: no central component is required, and every transition is proved and verified
at the hop that performs it.

```text
+-------------+       +-------------+       +-------------+
| HOP 1       |------>| HOP 2       |------>| HOP 3       |
| local P + V |  PoR  | local P + V |  PoR  | local P + V |
+-------------+       +-------------+       +-------------+

no central component; every hop proves and verifies locally
```

### 2.3 Consecutive Collusion and History

The decentralized architecture is secure hop by hop, with one documented limit
([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Section 6.8): two or more consecutive colluding hops cannot be
detected without the lineage history.

```text
+-------+      +---------+      +---------+      +-------+
| HOP 1 |----->| HOP 2 X |----->| HOP 3 X |----->| HOP 4 |
+-------+      +---------+      +---------+      +-------+

colluding hops: without the history, HOP 4
cannot re-check the step from HOP 1 to HOP 2
```

The history can live in two places: on the Trust Plane, or inside the PCA chain itself. Carrying it in the chain makes size and validation
cost grow without bound, so it is discarded as the working option; minimal implementations may still choose it, but they remain very
limited.

| Architecture | Central component | History | Per-hop cost | Consecutive collusion |
| --- | --- | --- | --- | --- |
| Centralized | Trust Plane (Verifier + validation attestation) | held by the Trust Plane | O(1) | resisted |
| Decentralized | none | not carried | O(1) | not resisted |
| Decentralized, full history in the chain | none | carried in every PCA chain | grows without bound | resisted — viable only for very limited, minimal implementations |

## 3. Trusted and Untrusted Environments

This section is non-normative. The choice between the two architectures follows the environment.

In a **trusted environment** — one whose hops the deployment threat model accepts as trustworthy — collusion among hops is out of scope:
the decentralized architecture fits, with no central dependency. In an **untrusted environment** collusion is a real threat: the
centralized architecture fits, because the Trust Plane holds the history; carrying the full history in the chain remains possible but not
convenient (Section 2.3). Trust is a property of the deployment threat model, its trust anchors, and the adopted profile — a single
administrative domain is not trusted by itself.

| Environment | Collusion | Architecture |
| --- | --- | --- |
| Trusted | out of scope | decentralized: local Prover and Verifier at every hop |
| Untrusted | a real threat | centralized: Trust Plane with the lineage history |

The same segmentation drives the guardrail deployment modes of the
[PIC Execution Guardrail Specification](./pic-lineage-guardrail-spec.md) (Section 3.4): trusted segments may operate hops in non-sandbox
mode; untrusted or high-risk segments use sandbox mode.

## 4. Hybrid Enterprise Architectures

This section is non-normative. Enterprise deployments are rarely uniform: one execution may cross trusted and untrusted segments in the
same chain. The two architectures compose: while execution crosses a trusted segment, hops verify locally; when it enters an untrusted
segment, hops use the Trust Plane. The PIC invariants are the same everywhere
([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Section 5); only the validation topology changes.

```text
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
```

The segment boundary is an assurance boundary. The receiving Trust Plane is not required to retroactively validate the entire preceding
trusted segment unless the selected profile requires full-history validation: assurance for the preceding prefix derives from the trust
domain that produced it — presented at the boundary as a checkpoint, snapshot, authenticated state commitment, or full history — and
accepted under the receiving side's trust policy. Trust Plane guarantees begin at the accepted boundary. How validation state transfers
across Trust Plane boundaries — trust anchors, checkpoint signatures, prefix coverage, key rotation, revocation, trust-domain recognition,
optional full-history verification or succinct proofs, and coordinated single-use across domains — will be defined by a future Trust Plane
federation profile.

### 4.1 Service Meshes

A service mesh — one administrative domain operating workload identity, mutual authentication, and traffic policy — may be classified as a
trusted environment when the deployment threat model accepts it as such: hops inside the mesh then verify locally, as in the trusted
segment above.

## 5. Interoperability

This section is non-normative. For interoperability with existing token infrastructures, the definition of an **OAuth Token Exchange
profile** is recommended: exchanging an Access Token for a PCA and a PCA for an Access Token, so that PIC enters and leaves existing
systems without integration friction. This is consistent with PCA0 derivation from existing credentials
([PIC Prover and Verifier Specification](./pic-prover-verifier-spec.md), Section 1.8) and builds on OAuth 2.0 Token Exchange
[[4]](#references). The profile will be defined in a future specification.

```text
OAUTH INFRASTRUCTURE                      PIC

+--------------+     token exchange      +--------------+
| ACCESS TOKEN |------------------------>| PCA0         |   enter PIC
+--------------+                         +--------------+

+--------------+     token exchange      +--------------+
| PCA          |------------------------>| ACCESS TOKEN |   leave PIC
+--------------+                         +--------------+

one profile, both directions
```

## 6. Contributors

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## 7. Legal Notices

The appendices governing:

- **A.** Use of Automated Language Assistance,
- **B.** Authorship, Stewardship, Attribution, and Derivative Works,
- **C.** Disclaimer and Limitation of Liability,
- **D.** Acknowledgements,

are maintained in a single canonical document, the **[PIC Legal Appendices](./pic-legal.md)** (`draft/0.2/pic-legal.md`), and are
**incorporated into this specification by reference** as if fully set forth herein.

In case of conflict between this document and the PIC Legal Appendices, the PIC Legal Appendices prevail for legal, governance, licensing,
and attribution matters.

This specification is subordinate to the [PIC Specification](./pic-spec.md), which defines the normative semantics of the PIC Model and is
the entry point of the specification set. This document does not introduce new conceptual authority, invariants, or authorship claims beyond
those defined in the PIC Legal Appendices.

## References

- [1] Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906 [cs.CR]. [arxiv.org/abs/2607.08906](https://arxiv.org/abs/2607.08906)
- [2] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [3] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
- [4] Jones, M., Nadalin, A., Campbell, B., Bradley, J., & Mortimore, C. (2020). *OAuth 2.0 Token Exchange*. RFC 8693. [rfc-editor.org/rfc/rfc8693](https://www.rfc-editor.org/rfc/rfc8693)
