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
date: 2026-08-12

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
**Published:** 2026-08-12
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

--- to_be_removed_note_Work_In_Progress

**Work in Progress — Experimental Design**

The deployment and architecture model described in this document is under active development.

This model may change substantially before a later stable revision.

Implementers MUST NOT assume wire compatibility, semantic compatibility, or backward compatibility with future revisions.

Future drafts may introduce breaking changes to terminology, data structures, processing rules, profile bindings, and
interoperability requirements.

The current text is published for design review, experimentation, and implementation feedback.

--- note_Editors

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- note_Contributors

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Contributors](#contributors)).*

--- abstract

This document is the **PIC Architecture and Deployment Specification**, a subordinate specification of the
[PIC Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md). It describes how the components defined by the
[PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md) and the
[PIC Sandboxed Execution Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md) are arranged and operated in concrete systems: the two deployment
architectures - **centralized**, where a trusted central continuity service validates continuation requests and issues or authenticates the
resulting continuity state, and **decentralized**, where permitted nodes advance continuity locally according to profile rules - their fit
to trusted and untrusted environments, hybrid enterprise compositions of the two, and interoperability with existing token infrastructures
through a profile-defined OAuth token-exchange binding.

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
[PIC Sandboxed Execution Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md).

## Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" are to be interpreted as described in BCP 14 [[2]](#references) [[3]](#references) when, and only when, they appear in all capitals,
and only within the normative sections of this document. Examples are illustrative and non-normative.

# Architectures

This section is non-normative. This specification defines two deployment topologies, centralized and decentralized; within each, different
chain-validation profiles ([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Sections 5 and 7) provide different
cost and assurance properties.

Deployment topology and semantic assurance are independent axes. A central service does not establish PoR merely because it signs a
checkpoint, and a decentralized verifier does not lose PoR merely because it validates locally. A full-continuity deployment must identify
the trusted observation boundary and concrete evidence that soundly establishes the predecessor-to-successor relation. A deployment that
validates only predecessor artifacts, workload-key control, non-expansion, and executor-profile conformance has `artifact-linked`
assurance and must not claim observed handoff, request causation, complete mediation, or the full PIC confused-deputy result
[[5]](#references).

## Centralized

In the centralized architecture, a current continuity state and continuation input are submitted to a trusted central continuity service. The
service validates the predecessor state, the proposed advancement, revocation state, non-expansion, request/execution binding when required,
and any profile-required evidence. If validation succeeds, it issues or authenticates the next continuity state according to the selected profile.
The rest of this document uses **Trust Plane** for such a centralized trusted service.

In PIC Profile 0.2, centralized continuity is:

~~~text
trusted settled PIC Token JWT N
`-- pic.root = settled PIC Continuity COSE N
    +-- root.pca = exact signed PIC PCA COSE N bytes
    `-- transitions = null

workload-signed candidate PIC Token JWT
`-- pic.root = workload-signed candidate PIC Continuity COSE
    +-- root.pca = exact signed PIC PCA COSE N bytes
    `-- transitions = [ exactly one PIC Continuity Transition COSE N+1 ]

trusted central validation / settlement

trusted settled PIC Token JWT N+1
`-- pic.root = settled PIC Continuity COSE N+1
    +-- root.pca = exact signed PIC PCA COSE N+1 bytes
    `-- transitions = null
~~~

The trusted settlement service validates the workload-signed candidate and PIC Continuity Transition COSE. It does not centrally sign the
workload's Transition COSE; after successful validation it signs the new PIC PCA COSE checkpoint, settled PIC Continuity COSE, and settled
PIC Token JWT. PIC-X 0.2.3 is a concrete implementation of this settlement and artifact-processing role, not a required component of the
abstract PIC model. Its current assurance level is `artifact-linked`: it does not yet observe the concrete handoff or bind a trusted request
occurrence, and its configured PIC revocation hook is a no-op. Those implementation gaps do not weaken the requirements of a full PIC
profile.

~~~text
+--------+        +--------+        +--------+
| HOP 1  |        | HOP 2  |        | HOP 3  |
+--------+        +--------+        +--------+
     \                 |                 /
      \                |                /
       v               v               v
      +---------------------------------+
      |           TRUST PLANE           |
      | validates continuation state    |
      | issues/authenticates continuity |
      | uses profile-defined state      |
      +---------------------------------+

centralized advancement produces the next
profile-defined continuity state
~~~

## Decentralized

In the decentralized architecture, a local prover, runtime, or workload advances continuity according to the selected profile without
contacting a central service for every hop. The resulting continuity state remains subject to ordinary verification by the receiver and by
any later central validation or re-issuance step defined by the profile.

This topology is not part of the current PIC Profile 0.2 centralized realization. Profile 0.2 currently defines settlement-authority-mediated
advancement only. A future or separate profile may define local advancement, holder-signed settled artifacts, transition-history transport,
or other decentralized mechanisms, but those mechanisms are not advertised as Profile 0.2 behavior by this document.

~~~text
+-------------+       +-------------+       +-------------+
| HOP 1       |------>| HOP 2       |------>| HOP 3       |
| local P + V |  PoR  | local P + V |  PoR  | local P + V |
+-------------+       +-------------+       +-------------+

no central component on every hop;
advancement and verification follow the selected profile
~~~

Central validation or re-issuance of locally advanced state is a possible future or separate-profile mechanism, distinct from advancement.
It is not part of current Profile 0.2. Such a profile could validate and re-issue the same continuity state:

~~~text
locally issued profile-defined continuity state M
        |
        v
central validation
        |
        v
centrally re-issued profile-defined continuity state M
~~~

Such same-position re-issuance would create no new transition and would not increment position. Current Profile 0.2 does not define this
decentralized subchain re-issuance behavior.

## Consecutive Collusion and History

An incremental or history-limited profile is secure hop by hop under its selected trust assumptions, with one documented limit
([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Section 6.8): two or more consecutive colluding hops cannot be
detected when the receiving Verifier lacks authenticated evidence of the earlier lineage prefix.

~~~text
+-------+      +---------+      +---------+      +-------+
| HOP 1 |----->| HOP 2 X |----->| HOP 3 X |----->| HOP 4 |
+-------+      +---------+      +---------+      +-------+

colluding hops: without the history, HOP 4
cannot re-check the step from HOP 1 to HOP 2
~~~

Continuity history or validation state can be held by the Trust Plane, carried in the continuity artifact, authenticated by external state,
checkpointed, compacted, referenced, or committed to by a succinct proof
([PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Sections 5.1–5.3). Carrying the complete prefix makes size and
validation cost grow linearly with lineage length, so it is unsuitable as the default lightweight profile; a deployment may nevertheless
select full-chain validation when its stronger independent-verification property justifies the O(n) cost. A succinct proof keeps
verification cheap but moves the cost to proof generation and adds the proof-system, setup, and availability assumptions.

| Topology and profile | Central component | History | Cost | Consecutive collusion |
| --- | --- | --- | --- | --- |
| Centralized: Trust Plane | yes | profile-defined history or authenticated validation state | profile-defined | resisted under the Trust Plane assumptions |
| Other-profile decentralized, history-limited | none | profile-defined local state or artifact state | profile-defined | not resisted without authenticated prefix evidence |
| Other-profile decentralized, full-history | none | complete prefix carried or otherwise available | O(n) size and verification unless compacted | resisted |
| Other-profile decentralized, succinct proof | none | proof commits to the validated prefix | succinct verification; generation cost per proof system | resisted under the proof-system assumptions |

The profile trade-offs are analyzed in the [PIC Prover and Verifier Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md), Sections 6.8 and 7.

# Trusted and Untrusted Environments

This section is non-normative. The choice between the two architectures follows the environment.

In a **trusted environment** — one whose hops the deployment threat model accepts as trustworthy — consecutive collusion is out of scope:
decentralized incremental validation may be sufficient, with no central dependency. In an **untrusted environment** where consecutive
collusion is in scope, the deployment must select a profile that independently authenticates the relevant lineage prefix: a Trust Plane,
full-history validation, authenticated checkpoints, or an approved succinct-proof profile (Section 2.3). The Trust Plane is one operational
choice for bounded validation without advanced cryptography, but not the only profile the model permits.
Trust is a property of the deployment threat model, its trust anchors, and the adopted profile — a single administrative domain is not
trusted by itself.

Declaring a segment trusted also does not silently discharge causal completeness, handoff observation, request binding, or protected-effect
mediation. If a deployment relies on those assumptions for a full-continuity or confused-deputy claim, it must state which component observes
and enforces them and what failures remain outside scope [[5]](#references) [[6]](#references).

| Environment | Threat assumption | Suitable topology and profile |
| --- | --- | --- |
| Trusted | consecutive collusion out of scope | decentralized incremental may be sufficient |
| Untrusted or high-risk | consecutive collusion in scope | Trust Plane with authenticated history, full-chain validation, or an approved succinct-proof profile |

Sandboxed Execution may be required at selected high-risk boundaries by deployment policy. Trusted segments may use ordinary continuity
without wrapping every hop in a Sandboxed Execution, while an untrusted boundary may require the outer `ENFORCE` continuity defined by the
[PIC Sandboxed Execution Specification](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md). These are
deployment choices, not protocol-defined “sandbox” and “non-sandbox” modes.

# Hybrid Enterprise Architectures

This section is non-normative. Enterprise deployments are rarely uniform: one execution may cross segments with different threat
assumptions in the same chain. While execution crosses a segment in which consecutive collusion is out of scope, decentralized incremental
verification may be used; when it enters a segment in which consecutive collusion is in scope, the deployment uses the selected
collusion-resistant profile - Trust Plane validation, full-history validation, authenticated checkpoints, or an approved succinct-proof
profile (Section 3). The PIC
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

This section is non-normative. OAuth is one possible entry mechanism for PIC, not a dependency of the PIC model. A profile may define an
OAuth Token Exchange binding that derives initial PIC authority from a validated OAuth access token under an exchange profile and local
policy, with execution constraints supplied by the initial continuity proposal when defined by that binding.

~~~text
OAUTH INFRASTRUCTURE                      PIC

+--------------+     token exchange      +----------------------+
| ACCESS TOKEN |------------------------>| PIC Token JWT        |   enter PIC
+--------------+                         +----------------------+

the trusted PIC PCA COSE checkpoint and settled PIC Continuity COSE
are created inside the exchange
~~~

In the Profile 0.2 / PIC-X realization, the exchange returns a settled PIC Token JWT. The initial PIC PCA COSE is created as the trusted
checkpoint inside that process, carried as exact signed bytes in `root.pca` by the settled PIC Continuity COSE, and referenced by
`root.pca_hash`. The PIC Continuity COSE is carried by the returned PIC Token JWT in `pic.root`. The returned PIC Token JWT is not an OAuth
Bearer token merely because OAuth Token Exchange carries it in an `access_token` response member. Transport of PIC continuity artifacts is a
profile-defined binding; for HTTP, a deployment may use a `PIC-Token` header.

The interoperable parameter names, token-type identifiers, request members, and response semantics for a Profile 0.2 OAuth Token Exchange
binding are defined by the selected Profile 0.2 exchange binding specification, not by this informational architecture section.

# Security Considerations

This document describes deployment topology and trust placement; it does not replace the security requirements of the PIC Prover and Verifier
Specification or the PIC Revocation Specification. Deployments need to evaluate trusted-service compromise, trust-boundary assumptions,
history availability, collusion resistance, and revocation-state availability separately from artifact integrity.

Centralized profiles rely on the correctness and availability of the trusted settlement or continuity service. Decentralized and hybrid
profiles need to define what each Verifier independently validates, what prior validation or checkpoint state it trusts, and how failures are
handled. Transport protections such as TLS, mTLS, broker authentication, or service-mesh policy protect channels and operational exposure, but
they do not replace PIC continuity validation, non-expansion checks, freshness checks, or authenticated revocation evaluation.

For claims about accepted physical effects, deployments additionally need sound causal evidence, causal completeness for the stated threat
model, and complete mediation of the protected effects in scope. Artifact verification or centralized settlement alone does not supply
those properties. Multi-parent ordinary joins must preserve every participating parent bound; a non-conservative composition must be an
explicit, separately authorized event rather than an ordinary continuation [[6]](#references).

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
- [5] Gallo, N. (2026). *Beyond Proof of Possession: A Relational Theory of Authority*.
- [6] Gallo, N. (2026). *Full Provenance on the COSS Causal Axis: An Event-Level Closure of Causal Attribution and Confused-Deputy Exclusion*.
