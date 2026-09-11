---
title: "PIC and A2A-Layer Protocols — Scope Boundary"
abbrev: "PIC Scope Boundary"
docname: pic-scope-boundary-a2a-layer-00
category: info
status: Informational note — not a specification
date: 2026-09-11

author:
  - org: Nitro Agility S.r.l.
    email: opensource@nitroagility.com
---

> **Informational note — not a specification.** This document states the scope
> boundary between PIC and protocols that operate at the agent-to-agent layer
> (A2A, cA2A, MCP-based orchestration, and similar). It does not redefine, extend,
> or alter the PIC Model or the PIC Specification; in case of conflict, the PIC
> Specification is authoritative.
>
> Origin: discussion in cA2A issue #150 (https://github.com/agentrust-io/ca2a/issues/150).
> cA2A (https://github.com/agentrust-io/ca2a) is an independent project of agentrust-io,
> with its own license and attribution terms. This document references it as the
> context of that discussion; it does not reproduce, restate, or interpret the cA2A
> specification.
>
> License: CC BY 4.0. The PIC Legal Appendices
> (https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md) are
> incorporated by reference. PIC Model: Nicola Gallo. PIC Specifications: stewarded by
> Nitro Agility S.r.l.

# 0. Terms, as defined in PIC

The acronym PIC is also used by an unrelated standard, "Provenance & Intent
Contracts". Throughout this document, and in the PIC Specification set, **PIC means
Provenance Identity Continuity**. Two of its terms are defined here because they are
easily read with other meanings.

**Permissioned entity.** An entity that holds a set of permissions `Priv(p)`: a human
identity, a non-human identity — a workload, a service, an AI agent — a role, a service
account, or any other authenticated entity with permissions.

**Intent.** The act by which a permissioned entity selects a subset of its permissions
and the execution constraints under which they may be exercised. From that selection
authority is created: the entity is the origin, and the selected subset becomes the
origin authority context `C0 ⊆ Priv(p)` that is propagated through execution and bounds
everything that follows. Intent is where authority comes from in the model; nothing
downstream can exceed it.

**Identity.** The identity of authority at its origin — the permissioned entity whose
permissions, selected by an intent, bound the execution. The lineage is anchored to it.
It is not user identity propagated as the authorization primitive at every hop:
executor eligibility at later hops is established by Proof of Relationship evidence,
and authorization is decided by continuity.

These definitions first appeared in the PIC Model published on Zenodo on 1 December
2025 (DOI 10.5281/zenodo.17777421). In the Proof-of-Continuity paper, arXiv:2607.08906
(version of 8 July 2026), the definition is in §1, Model: "When a permissioned entity
p expresses such an intent, it selects a subset of Priv(p); that subset becomes the
origin authority context C0 ⊆ Priv(p) for a new execution lineage"; and in §8,
Discussion: "A lineage begins when a permissioned entity expresses an intent within
its privileges, creating an origin authority context C0". The PIC Prover and Verifier
Specification §1.8 restates it with "principal" for "permissioned entity". The
project page https://www.pic-protocol.org/why-pic/authority-propagation gives the
same definition in prose.

# 1. Layering

```text
agent-to-agent layer        A2A / cA2A / MCP orchestration:
                            agent identity for discovery and routing,
                            message semantics, governance,
                            post-hoc analysis of agent behaviour
        |
        | carries the PIC Token
        v
PIC                         authority continuity:
                            origin, advancement, PoR, non-expansion,
                            settlement, revocation, composition
        |
        v
transport                   HTTP / A2A messages / Kafka / queues / workflows
```

PIC is an orthogonal, transport-independent security layer. It is not an
agent-to-agent protocol and does not model one. An agent-to-agent protocol does not
need to model authority continuity: it carries the PIC Token and reads the settled
state.

# 2. What PIC covers

This section is a snapshot, not a ceiling. It records what the PIC Specification set
covers at the date of this note, split into what is normative, proved and implemented
today and what is specified as direction. Nothing here limits what PIC may cover in
later revisions: the set may extend to any item of §2.2, to bindings for specific
protocols including A2A (§5), and to further profiles, evidence formats and tooling
consistent with the model. When it does, this note is updated.

## 2.1 Covered today — Profile 0.2

Specified normatively in the PIC Specification set, with the invariants proved at model
level (Lean: origin-bounded authority, non-expansion, exclusion of the confused-deputy
state, refinement under the PoR bridge assumption; symbolic analyses in Tamarin and
ProVerif), and implemented in PIC-X:

| Property | Where |
| --- | --- |
| Origin authority context (root PCA, `C0`), including derivation from an existing credential via the OAuth Token Exchange binding | Prover and Verifier §1.8, §5.4; PIC-X |
| Exactly one causal predecessor per advancement, inside the signed material (`predecessor.hash` over the exact signed predecessor PIC PCA COSE bytes; challenge continuity) | Prover and Verifier §2, §5.2; PIC-X |
| Proof of Relationship (`sd-jwt` typed evidence identifying the eligible workload key) | Prover and Verifier §2.3; PIC-X |
| Non-expansion under the profile's attenuation order; dropped authority cannot reappear | Prover and Verifier §2.4, §4; Lean; PIC-X |
| Centralized settlement into signed checkpoints; ordinary verification of settled state | Prover and Verifier §3, §5.1; PIC-X |
| Request/execution binding | Prover and Verifier §3.3 — specified, profile-conditional (optional in 0.2) |

## 2.2 Specified as direction — drafts and work in progress

Published or announced on the PIC side, not yet at the level of §2.1. Each carries its
own status notice and may change:

| Property | Where | Status |
| --- | --- | --- |
| Revocation coordinates `(PCA ID, position)`, revocation authorization, append-only authenticated state | Revocation Specification | Draft with Work In Progress notice; not wired in PIC-X |
| Joint participation of independent lineages without authority union | Sandboxed Execution | Draft with Work In Progress notice; beyond Profile 0.2; not implemented |
| Protocol-level policy enforcement and authority reduction: guardrails and PIC Trusted Anchors, with the outcome bound inside the signed advancement | Sandboxed Execution; PIC-X realm discovery (`trust_anchors_endpoint`, `attestations_endpoint`) | Work in progress in PIC, as PIC-X itself is. The Trusted Anchor specification is being written; the component is already part of the published PIC-X design: realm discovery advertises `trust_anchors_endpoint` and describes PIC Trusted Anchors as protocol-level trust policy engines (Designing PIC-X: .well-known configuration, 1 August 2026). Today the Prover and Verifier §4.3 places the policy decision with the application (see §3.1); the Trusted Anchor profile moves that boundary and §4.3 will be aligned when it is published |
| Deployment topologies: Trust Plane, decentralized and hybrid segments, service meshes | Architecture and Deployment | Descriptive; normative deployment requirements are forthcoming. PIC-X realizes the centralized Profile 0.2 topology |

Both tables are PIC's. A protocol above PIC does not re-derive, re-specify, or re-verify
any of it; it relies on §2.1 and tracks §2.2.

# 3. What PIC does not cover today

Two groups. The first is what the PIC Specifications themselves place outside PIC; the
second is what belongs to the agent-to-agent layer.

## 3.1 Outside PIC by its own specifications

| Concern | Where stated | Belongs to |
| --- | --- | --- |
| Attestation issuance and runtime attestation soundness. PIC consumes attestation as PoR or executor evidence; it does not establish that the attestation is sound | Prover and Verifier §6.5 (external assumption); Sandboxed Execution, trusted elements | the attestation infrastructure and its issuers |
| Transport confidentiality, payload confidentiality, sealed channels, and physical path enforcement | Prover and Verifier §6.7; Sandboxed Execution §"Non-PIC-Aware Target"; Architecture and Deployment, Security Considerations | the deployment and its operator |
| The application authorization decision: does this authority permit this concrete operation. PIC establishes that the authority is a valid, non-expansive continuation; whether it permits the operation is application policy | Prover and Verifier §4.3 ("Using a PDP is an application choice, not part of PIC") | the application or its PDP — with the Trusted Anchor direction of §2.2 noted |
| The authority vocabulary and its attenuation order, and the obligation that the order be monotone with respect to the vocabulary's meaning | Prover and Verifier §4.2, §4.3 | the selected profile; the semantic-monotonicity obligation is not discharged by the Lean proof |

## 3.2 The agent-to-agent layer

| Concern | Belongs to |
| --- | --- |
| Agent identity for discovery and routing, capability cards | the agent-to-agent protocol |
| Message and task semantics between agents | the agent-to-agent protocol |
| Governance: who may deploy, which agents may talk, organizational policy | the agent-to-agent protocol and its operator |
| Post-hoc analysis of agent behaviour (which agent did what, message content, task outcomes) | the agent-to-agent protocol, reading PIC settled checkpoints and revocation coordinates as evidence where authority is concerned |

Four concerns, all about agents: who they are, what they say, who governs them, and
what is reconstructed about them afterwards. PIC does not decide any of them today. It
decides whether the authority an agent exercises is a valid continuation of the
execution that caused the action. The history of that authority — checkpoints,
positions, attenuations, revocation coordinates, position witnesses, retrospective
verification — is PIC evidence and stays on the PIC side; an agent-layer analysis
consumes it, it does not replace it.

Both tables in this section describe the current allocation, not a permanent one.
They state where each concern sits in the published PIC Specifications as of this
note; they do not commit the PIC Specification set to leaving any of them outside.
Where the model supports it and the Specification Steward decides it, PIC may take on
bindings, profiles, evidence formats or tooling that touch these areas, and this note
is superseded to that extent.

One distinction to keep clear. The *Identity* in Provenance Identity Continuity is the
identity of authority at its origin: the permissioned entity — human, non-human,
workload, AI agent, role, service account, anything that holds permissions — that,
through an intent, selects a subset of its permissions and thereby creates the origin
authority context that bounds the execution. That origin identity is part of PIC and
is what the lineage is anchored to; executor eligibility at later hops is established
by Proof of Relationship evidence. What PIC does not define is agent identity as the
agent-to-agent layer needs it for discovery, routing and capability description. The
two are different objects and the boundary runs between them.

# 4. Consequence for an agent-to-agent protocol

A protocol at the agent-to-agent layer that wants authority continuity has exactly
two things to define on its side:

1. **Transport binding.** How its messages carry the PIC Token (the HTTP binding is
   the `PIC-Token` header; an A2A binding would be the equivalent in A2A messages).
2. **Evidence consumption.** How its analysis and governance read PIC settled state:
   position, `root.pca_hash`, materialized authority, revocation coordinates.

Everything in §2 — origin, advancement, PoR, non-expansion, settlement today; revocation,
composition, protocol-level policy enforcement, deployment as direction — is on the PIC
side. It is used, not integrated. Everything in §3.1 is outside PIC by PIC's own
specifications and is not thereby handed to the agent-to-agent layer either: it belongs
to the attestation infrastructure, the deployment, the application, or the selected
profile.

Conversely, a protocol that re-specifies any of these on its own side is no longer
using PIC; it is building a second authority model, whose invariants and proofs it
then owns. Nothing prevents that. It is a scope decision, and it should be made
knowingly.

# 5. Who writes the binding

PIC has no A2A binding profile today. Nothing in this document precludes one, from
either side:

- the PIC Specification set may define an A2A transport binding for the PIC Token,
  as it has defined the OAuth Token Exchange binding, under the same stewardship and
  attribution terms;
- an agent-to-agent protocol may define its own binding to PIC, referencing the PIC
  Specifications as the normative source.

The two are not exclusive and neither is implied by this document. What is fixed here
is the boundary towards a protocol that uses PIC: the binding carries the PIC Token and
reads settled state; it does not re-specify authority continuity. Which party writes a
given binding, for which protocol, and what else the PIC Specification set chooses to
cover, remains open on the PIC side.

The same holds for analysis of authority history. The PIC Specifications already
define the evidence (settled checkpoints, positions, revocation coordinates, position
witnesses, retrospective verification under trusted time) and may define further
representations and tooling for analyzing it. An agent-layer analysis of that history
is welcome and consumes PIC evidence; it does not become the place where that evidence
is defined.

# 6. Attribution

Any document, profile, or implementation that uses PIC carries the attribution set
out by CC BY 4.0 and the PIC Legal Appendices: the PIC Model by Nicola Gallo; the PIC
Specifications published and stewarded by Nitro Agility S.r.l. The PIC Specifications
remain the normative reference; a protocol binding references them, it does not
reproduce them.

# 7. Status

The PIC Specifications are public drafts. PIC-X today covers OAuth Token Exchange into
PIC and single-lineage propagation under centralized Profile 0.2 settlement; revocation
wiring and multi-lineage composition are not yet implemented. No wire or semantic
compatibility should be assumed.

# 8. References

- PIC Specification: https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-spec.md
- PIC Prover and Verifier: https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md
- PIC Revocation: https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-revocation-spec.md
- PIC Sandboxed Execution: https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-lineage-guardrail-spec.md
- PIC Architecture and Deployment: https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-architecture-deployment-spec.md
- PIC Legal Appendices: https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-legal.md
- Formal model: https://www.pic-protocol.org/formal-model
- PIC-X: https://github.com/pic-protocol/pic-x
- Gallo, N. (2026). *Designing PIC-X: Exposing Configuration through .well-known/pic-x-configuration* (1 August 2026): https://www.ngallo.it/blog/2026-08-01/pic-x-well-known-config/
- cA2A — agentrust-io/ca2a: https://github.com/agentrust-io/ca2a (independent project; its own license and attribution apply). Discussion: https://github.com/agentrust-io/ca2a/issues/150
- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Zenodo, 1 December 2025. DOI 10.5281/zenodo.17777421
- Gallo, N. (2025). *Authority is a Continuous System*. Zenodo. DOI 10.5281/zenodo.17860199
- PIC — Authority Propagation: https://www.pic-protocol.org/why-pic/authority-propagation
- Gallo, N. (2026). *Proof-of-Continuity: A Temporal Model for Authority Propagation in Distributed Systems and AI Agents*. arXiv:2607.08906.
