# PIC Prover and Verifier Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-15  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-prover-verifier-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.) Lead Editor
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 9](#9-contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 9](#9-contributors)).*

## Abstract

This document is the **PIC Prover and Verifier Specification**, a subordinate specification of the [PIC Specification](./pic-spec.md). It
defines the normative requirements for the two complementary components of Proof of Continuity handling:

- **PIC Provers**: the components that construct Proofs of Continuity for an execution hop;
- **PIC Verifiers**: the trusted components that validate Proofs of Continuity and enforce the invariants of the
  **Provenance Identity Continuity (PIC) Model** at verification time.

At every hop, a node acts in both roles: it **verifies** the proof received from its predecessor and **proves** continuity to its successor
by constructing a new proof, which the next node in turn verifies.

This document does not redefine, extend, or alter the PIC Model or the normative semantics defined by the PIC Specification.

In case of conflict, the **PIC Specification** is authoritative.

## Table of Contents

- [PIC Prover and Verifier Specification](#pic-prover-and-verifier-specification)
  - [Abstract](#abstract)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
    - [1.1 Security Guarantees of the Model](#11-security-guarantees-of-the-model)
    - [1.2 Delegating the Future](#12-delegating-the-future)
    - [1.3 The N+1 Executor Problem (Canonical Execution Model)](#13-the-n1-executor-problem-canonical-execution-model)
    - [1.4 Cross-Lineage Authority Composition](#14-cross-lineage-authority-composition)
    - [1.5 The Execution Flow as Part of the Security Model](#15-the-execution-flow-as-part-of-the-security-model)
    - [1.6 Attribute Attestations](#16-attribute-attestations)
    - [1.7 Requirements Notation](#17-requirements-notation)
    - [1.8 Origin Authority Context (PCA0)](#18-origin-authority-context-pca0)
  - [2. Prover Requirements](#2-prover-requirements)
    - [2.1 Prover Procedure](#21-prover-procedure)
    - [2.2 Predecessor Validation](#22-predecessor-validation)
    - [2.3 Proof of Relationship](#23-proof-of-relationship)
    - [2.4 Invariant Monotonicity](#24-invariant-monotonicity)
    - [2.5 Successor PCA Construction](#25-successor-pca-construction)
  - [3. Verifier Requirements](#3-verifier-requirements)
    - [3.1 Verifier Procedure](#31-verifier-procedure)
    - [3.2 Origin Validation (PCA0)](#32-origin-validation-pca0)
    - [3.3 Hop Validation (PCA1 onward)](#33-hop-validation-pca1-onward)
  - [4. Authority Domains and Attenuation Profiles](#4-authority-domains-and-attenuation-profiles)
    - [4.1 Authority as an Abstract Domain](#41-authority-as-an-abstract-domain)
    - [4.2 Attenuation Profiles](#42-attenuation-profiles)
    - [4.3 Policy Decision Point (PDP) Integration](#43-policy-decision-point-pdp-integration)
  - [5. Chain Representations](#5-chain-representations)
    - [5.1 Full Hash Chain](#51-full-hash-chain)
    - [5.2 Snapshot Hash Chain](#52-snapshot-hash-chain)
    - [5.3 Succinct Proofs (Zero-Knowledge)](#53-succinct-proofs-zero-knowledge)
  - [6. Security Considerations](#6-security-considerations)
    - [6.1 Freshness, Replay, and Fan-out](#61-freshness-replay-and-fan-out)
    - [6.2 Origin (PCA0) Trust Boundary](#62-origin-pca0-trust-boundary)
    - [6.3 Temporal Rules and Per-Hop Expiry](#63-temporal-rules-and-per-hop-expiry)
    - [6.4 Canonicalization and Cryptographic Agility](#64-canonicalization-and-cryptographic-agility)
    - [6.5 Formal Scope](#65-formal-scope)
    - [6.6 Proof of Possession (Optional)](#66-proof-of-possession-optional)
    - [6.7 Transport Separation and Confidentiality](#67-transport-separation-and-confidentiality)
    - [6.8 Incremental Verification and Trusted Hops](#68-incremental-verification-and-trusted-hops)
  - [7. Deployment Models](#7-deployment-models)
  - [8. Zero Trust](#8-zero-trust)
  - [9. Contributors](#9-contributors)
  - [10. Legal Notices](#10-legal-notices)
  - [References](#references)

## 1. Introduction

This section is non-normative. It describes the problem this specification addresses and is independent of any concrete implementation.
Normative requirements are defined in Section 2 (Prover) and Section 3 (Verifier).

Current authorization models lack a formal execution continuity model: they define who may hold authority, but not how authority remains
valid across the steps of a distributed execution. This specification defines how the **Provenance Identity Continuity (PIC) Model** is
implemented at each execution hop to close that gap. The model, including
**Proof of Relationship (PoR)**, **Proof of Continuity (PoC)**, and the resulting safety guarantees, is formally defined in the companion
paper [[1]](#references) and formally verified with the Lean theorem prover [[2]](#references). The paper treats PoR as an abstract,
unforgeable primitive. This document specifies the two components that realize it:

- The **PIC Prover** constructs the PoR, the evidence binding the current execution step to its causal predecessor, and uses it to construct
  the PoC handed to the next hop. A PoC is valid only if it satisfies the PIC invariants: causal linkage witnessed by PoR at every hop, and a
  non-expansive authority context.
- The **PIC Verifier** validates both proofs at the receiving hop: the PoR, which establishes that the incoming step is a genuine
  continuation of its predecessor, and the PoC, which establishes that the invariants hold along the entire received lineage. If either
  proof is invalid, the hop is rejected before any authority is exercised.

PIC **does not require a central server**. Depending on deployment topology and implementer choice, a chain can be validated *fully
decentralized* — each hop carrying everything the next needs to verify it — or with the help of a trusted component such as a snapshot
server. Section 5 describes these representations; the PIC *invariants* are the same in every case, but the concrete assurance and trust
assumptions differ by profile (Sections 6.8, 7) — the profiles are not equivalent.

PIC also draws a **clean line between the security model and transport**. The guarantees come from the signed continuity chain, not from how
it travels: an implementation MUST NOT rely on the transport — a TLS session, a network perimeter, a message bus — to obtain them. Transport
is only transport. A compromised channel can read or drop messages but cannot forge a valid PCA; confidentiality and attack-surface concerns
belong to transport and are addressed in Section 6.7. This separation is what lets the same model run unchanged over HTTP, over messaging
systems such as Apache Kafka, or over any other carrier.

### 1.1 Security Guarantees of the Model

An authority-propagation protocol guarantees the validity of authority states, not the physical behavior of executors. PIC guarantees that
no actor can cause another executor to create, accept, or propagate an invalid authority state: an operation is accepted only if it can be
represented as a valid continuation of the authority carried by the request.

Physical behavior is outside this guarantee, for PIC as for any security protocol. No authorization model can guarantee that an application
is free of bugs or that an executor behaves correctly: an executor that receives authority to `READ`, ignores it, and physically performs
`DELETE` fails as an implementation, locally. What the protocol guarantees is that such a fault remains local: executor `n+1` cannot
continue, as valid, an authority state that the model defines as invalid.

The same applies to the cryptographic assumptions. Capability and token systems, such as OAuth, rest on the unforgeability of their
credentials: if the underlying cryptography is broken, none of their properties survive. PIC rests on the same cryptographic assumptions,
and so does the Proof of Relationship: the relationship evidence is assumed unforgeable, and a break of the underlying cryptography is
outside the model, as it is for every protocol in this space.

This boundary is what distinguishes PIC. If authority from two independent lineages can be composed into a new state that remains valid
under a model, that model relies on correct executor behavior to avoid the composition. Under PIC such a mixed state is invalid by
construction: the damage of a buggy or compromised executor is confined to its local step and cannot propagate as valid authority at the
next hop.

### 1.2 Delegating the Future

Software that must support implementations that do not exist yet does not hard-code future components. It defines an interface. The
interface specifies the contract, and any future implementation can participate, provided it proves that it satisfies the contract.

PIC applies the same principle to distributed execution. A continuation does not name or preselect its successor. It defines the execution
contract instead:

- the authority that may continue;
- the constraints that must remain non-expansive;
- the execution characteristics the successor must satisfy;
- the causal relationship with the previous execution state.

When a successor materializes, it proves that it satisfies those conditions and may continue the execution. No identity needs to be known
in advance, and nothing binds the contract to a single successor: a continuation may be taken up by zero, one, or many executors, possibly
in parallel. The future being delegated ranges from no continuation at all to an unbounded number of them. Identity may still support
authentication, audit, and accountability, but it is not the primitive that preserves authority across execution.

The contract defines the continuation. The executor proves conformance. Continuity, not identity, delegates the future.

### 1.3 The N+1 Executor Problem (Canonical Execution Model)

The N+1 Executor Problem is future delegation made concrete. This specification is explained and defined around this single canonical
execution model. Execution is a chain of discrete steps performed by executors, such as services, workloads, functions, tools, or agents.
Each executor receives a request, processes it, and may cause a further step:

```text
+----------------+      |      +----------------+      |      +----------------+
|  EXECUTOR n-1  |------|----->|   EXECUTOR n   |------|----->|  EXECUTOR n+1  |
+----------------+      |      +----------------+      |      +----------------+
                                    time x                        time x + y
```

Each `|` marks a hop boundary: the point where the predecessor's Prover emits its proofs and the successor's Verifier validates them. Each
boundary is an act of future delegation, and the linear chain is the minimal case: a step may delegate to several successors in parallel.

The problem is the executor at position n+1. Executor `n` acts at time `x`. Executor `n+1` acts at a later time `x + y`, and at time `x` it
does not yet exist as a known party: it need not be known, selected, instantiated, or provisioned when executor `n` completes its step.
Consequently, no security mechanism that requires pre-binding authority to a concrete successor (its identity, its key, or its channel) can
be applied at time `x`: there is no holder yet to bind to.

The problem does not require a long chain: it already holds for `n = 0`. The first hop, from the origin that expresses an intent to the
first executor that serves it, crosses the same temporal gap, since that executor too may not exist or be known at the time the intent is
expressed. A single-hop execution is the smallest instance of the N+1 Executor Problem. Multi-hop chains repeat it at every boundary, where
its consequences become most visible.

### 1.4 Cross-Lineage Authority Composition

An executor may serve more than one lineage at the same time. Each lineage carries its own authority context, attenuated along its own
chain. A bug, or an adversarially influenced agent, can compose authority across those lineages: a privilege carried by one lineage is
attached to the continuation of another.

```text
LINEAGE A:  { READ-ALL, BACKUP }       ---->  { READ-ALL }
                                                   |
                                                   |  cross-lineage composition (bug)
                                                   v
LINEAGE B:  { READ-FOO, SHARE-FILES }  ---->  { SHARE-FILES }  ---->  { READ-ALL, SHARE-FILES }
                                                                         EXECUTOR n+1
```

In a possession-based model the resulting state is valid. Every privilege presented at executor `n+1` is genuinely possessed and correctly
signed; nothing in the model distinguishes them by origin. The bug has created a valid security state, and `READ-ALL` combined with
`SHARE-FILES` is now exercisable in a lineage that was never granted it.

Under PIC the same state cannot be represented as valid. `READ-ALL` is absent from the origin context of lineage B, and no valid
continuation can expand an authority context: the composed proof does not satisfy the lineage, and the Verifier at executor `n+1` rejects
it. The bug can still execute locally, as stated in Section 1.1, but the state it produces is invalid and stops at that hop.

This is a *structural* elimination of the confused deputy, and it is what PIC shares with the object-capability approach: a capability
removes the mismatch by construction at a single hop, by fusing designation and authority at invocation; PIC extends the same by-construction
guarantee across the whole lineage, so the mismatch is not a state a valid chain can represent at any hop. It is ruled out by construction,
not caught by runtime vigilance — and this is exactly the property the Lean formalization verifies [[2]](#references).

### 1.5 The Execution Flow as Part of the Security Model

The PIC Model resolves the N+1 Executor Problem by bringing the execution flow itself, including the not-yet-existing executor `n+1`, into
the security model, rather than leaving the gap between `x` and `x + y` to application logic. What must hold across that gap is not the
identity of the successor, but that its authority is a valid continuation of the context that caused it. The temporal gap is therefore not
an application concern to be patched with perimeter assumptions or out-of-band coordination: it is the object the security model is built
around, and authority crosses it only as verified continuity, never as possession by a pre-existing holder.

### 1.6 Attribute Attestations

To describe the model, this specification uses one illustrative construct: the signed attribute attestation. It is a document, signed by an
issuer, that binds a subject to a set of attributes for a validity period. The examples in this document follow a single running scenario:
a backup service operating in the European region under compliance constraints, authorized for the operations `READ-ALL` and `BACKUP`.

```json
{
  "subject": "did:example:workloads:eu:backup-service",
  "attributes": {
    "role": "backup-service",
    "compliance": ["GDPR"],
    "accountableParty": "Example Corp",
    "serviceAgreements": [
      "https://legal.example.com/agreements/dpa-2026-001"
    ],
    "environment": "production",
    "region": "eu-1",
    "availabilityZone": "eu-1a",
    "executionModel": "deterministic"
  },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-08-17T10:00:00Z",
  "issuer": "did:example:org-authority"
}
```

The scenario includes a second executor: a summary service implemented as an AI agent. It produces summaries of documents, and its
execution is not deterministic. Its attestation differs in role, accountable party, network placement, and execution model:

```json
{
  "subject": "did:example:workloads:eu:summary-service",
  "attributes": {
    "role": "summary-service",
    "compliance": ["GDPR"],
    "accountableParty": "Acme AI Ltd",
    "serviceAgreements": [
      "https://legal.acme.example/agreements/asa-2026-042"
    ],
    "environment": "production",
    "region": "eu-1",
    "availabilityZone": "eu-1b",
    "executionModel": "agentic"
  },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-08-17T10:00:00Z",
  "issuer": "did:example:org-authority"
}
```

The identifiers in the examples use DIDs, but this is a *presentational* choice, not a requirement. **PIC does not depend on any identifier
scheme; what it needs are the signed attestations themselves.** A bare public/private key pair, with no identifier at all, is enough to sign
and verify them. An identifier such as a DID only makes the examples easier to read and to cross-reference: it *helps* the specification, it
is **not necessary** for the model.

For the same reason, this document deliberately does not use Verifiable Credentials, X.509 certificates, or similar formats. They would work,
but understanding them is not required to understand PIC, and depending on them would tie the model to a particular identity technology. The
specification uses a plain signed attestation on purpose — a *minimalist approach* that keeps it accessible and free of unnecessary
prerequisites.

### 1.7 Requirements Notation

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in BCP 14 [[3]](#references) [[4]](#references) when, and only when, they
appear in all capitals, as shown here.

Examples in this document are illustrative and non-normative.

### 1.8 Origin Authority Context (PCA0)

A lineage begins when a principal expresses an intent within its privileges. The result is a **PIC Context of Authority (PCA)**: the signed
document that carries the **invariants** of a lineage, that is, the authority that may continue (`operations`) and the `executionContract`
that executors must satisfy. The PCA of the origin, **PCA0**, contains no Proof of Relationship: there is no predecessor to relate to. Every
later hop continues, and may only attenuate, the invariants granted by the PCA0.

The examples represent authority as an `operations` set — the reference profile, matching the operation-resource privileges of the model
[[1]](#references). PIC does not require this representation, nor does it define the application's authorization vocabulary; Section 4
covers authority as an abstract domain (roles, labels, scopes, policy references) and its relationship to a Policy Decision Point.

In the running scenario, Alice connects to the backup SaaS. The service agreement confirms that the service is operated in Europe by an
accountable party and does not use agentic execution. On those terms she grants access to all her files for backup. Her client produces a
PCA0, signed by Alice:

```json
{
  "issuer": "did:example:users:alice",
  "invariants": {
    "operations": ["READ-ALL", "BACKUP"],
    "executionContract": {
      "role": "backup-service",
      "compliance": ["GDPR"],
      "serviceAgreements": [
        "https://legal.example.com/agreements/dpa-2026-001"
      ],
      "executionModel": "deterministic"
    }
  },
  "continuation": {
    "challenge": "base64url-random-256-bit-value",
    "mode": "single-use",
    "expiresAt": "2026-07-17T10:05:00Z"
  },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-07-18T10:00:00Z"
}
```

Later, Alice uses the same SaaS to summarize a document. The terms are different this time: the service runs in the United States and uses
an AI agent. She accepts them, but only for the file `foo`. The resulting PCA0 grants less and constrains differently:

```json
{
  "issuer": "did:example:users:alice",
  "invariants": {
    "operations": ["READ-FOO", "SHARE-FILES"],
    "executionContract": {
      "role": "summary-service",
      "serviceAgreements": [
        "https://legal.acme.example/agreements/asa-2026-042"
      ],
      "executionModel": "agentic"
    }
  },
  "continuation": {
    "challenge": "base64url-random-256-bit-value",
    "mode": "single-use",
    "expiresAt": "2026-07-17T10:05:00Z"
  },
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-07-18T10:00:00Z"
}
```

Each PCA0 starts a distinct lineage with its own invariants, and no later hop can expand them. These are the two lineages of Section 1.4.
The `continuation` block is the challenge each PCA emits for its next hop, consumed in the Proof of Relationship (Section 2.3).

A PCA0 may be **minted directly** by an authenticated permissioned entity, or **derived from an existing credential** — for example from an
OAuth access token, or from a JWT through a custom token-exchange profile. These derivations are *out of scope* for this specification, but
they are in line with it, and one point must be clear: **PIC does not change authentication.** Identity and authentication mechanisms remain
exactly as they are and establish the *origin*; PIC governs only how authority propagates *after* that origin exists. Wherever it comes from,
the derivation is where a PCA0 is born, and execution starts from there.

## 2. Prover Requirements

A **PIC Prover** constructs the **PIC Context of Authority (PCA)** for the next execution hop. Except for the origin **PCA0** (Section 1.8),
every PCA produced by a Prover MUST:

1. identify **exactly one** predecessor PCA;
2. include a **cryptographic reference** to that predecessor;
3. include a **Proof of Relationship** that responds to the predecessor's continuation challenge and binds the current execution to it;
4. carry **invariants** equal to or more restrictive than the predecessor invariants;
5. be **integrity-protected as a whole** by a single signature of the current executor.

The first requirement is what keeps the *cross-lineage composition* of Section 1.4 out of the model: a PCA that combines authority from two
lineages cannot be *validated as a conforming continuation*. An executor can always assemble arbitrary bytes locally; what it cannot do is
have such a document accepted (Section 1.1). The construction below is a *minimal profile* chosen for clarity.

### 2.1 Prover Procedure

Given a predecessor PCA, the Prover MUST perform the following steps and MUST NOT emit a successor PCA if any of them fails:

1. validate the predecessor PCA (Section 2.2);
2. build the Proof of Relationship, responding to the predecessor's continuation challenge (Section 2.3);
3. keep or attenuate the invariants (Section 2.4);
4. assemble the PCA — PoR, invariants, and a fresh continuation challenge — and sign it as a whole (Section 2.5);
5. emit the signed PCA to the next hop.

```text
receive PCA[n-1]
      |
      v
validate predecessor
      |
      v
build PoR (respond to predecessor challenge)
      |
      v
keep or attenuate invariants
      |
      v
assemble and sign PCA[n]  (single signature)
      |
      v
emit PCA[n]
```

The following sections define each step.

### 2.2 Predecessor Validation

The Prover MUST validate the predecessor PCA by applying the Verifier procedure of Section 3. If validation fails, the Prover MUST NOT
emit a successor PCA. The rest of this section assumes a valid predecessor.

### 2.3 Proof of Relationship

The **PoR** is the payload that binds the current execution to *exactly one* predecessor. It is carried in the clear inside the successor PCA
as the `proofOfRelationship` field and is covered by the single PCA signature (Section 2.5). It carries:

- **`previousPcaHash`** — the hash of the predecessor PCA, binding this step to exactly one lineage;
- **`continuationResponse`** — the predecessor's emitted `continuation.challenge` (Section 2.5) with a random value the executor generates
  locally. It proves the executor **observed and holds** the predecessor PCA (it has the challenge) and keeps the response fresh. It does
  **not** prove that the request causally required this step, nor that this executor was designated as the successor;
- **`executor`** and **`request`** — the executor identifier and the *request binding*: the `operation`, its `target` (resource), the
  `securityDomain` (tenant), and `requestDigest` / `payloadDigest` when the decision depends on the request or its payload. Signing these
  ties the authority to the **concrete action**, so enforcement can check that what is executed matches what was signed (Section 3);
- **`executorAttestation`** — the *conformance evidence*: the executor attestation of Section 1.6, embedded in full (it carries its own
  issuer signature, elided in the examples), proving that the executor satisfies the predecessor execution contract.

Continuing the running scenario, the backup service performing `BACKUP` produces the following PoR payload:

```json
{
  "type": "PIC-PoR-v0",
  "previousPcaHash": "sha256:4f6c...",
  "continuationResponse": {
    "predecessorChallenge": "base64url... (from the predecessor's continuation)",
    "executorNonce": "base64url-random-256-bit-value"
  },
  "executor": "did:example:workloads:eu:backup-service",
  "request": {
    "operation": "BACKUP",
    "target": "eu-1/tenant-42/dataset/backups",
    "securityDomain": "tenant-42",
    "requestDigest": "sha256:...",
    "payloadDigest": "sha256:..."
  },
  "executorAttestation": {
    "subject": "did:example:workloads:eu:backup-service",
    "attributes": {
      "role": "backup-service",
      "compliance": ["GDPR"],
      "accountableParty": "Example Corp",
      "serviceAgreements": [
        "https://legal.example.com/agreements/dpa-2026-001"
      ],
      "environment": "production",
      "region": "eu-1",
      "availabilityZone": "eu-1a",
      "executionModel": "deterministic"
    },
    "issuedAt": "2026-07-17T10:00:00Z",
    "expiresAt": "2026-08-17T10:00:00Z",
    "issuer": "did:example:org-authority"
  }
}
```

The Prover MUST check its own PoR before proceeding: if the executor does not satisfy the predecessor execution contract, or
`previousPcaHash` does not match the predecessor, or the challenge response is not built from the predecessor's challenge, the PoR is
*invalid* and the Prover MUST stop — a PCA carrying an invalid PoR is rejected at the next hop anyway. The predecessor's challenge is
*single-use* by default (Section 6.1): it prevents replay within a Verifier's state or a coordinated system, but does not guarantee global
uniqueness across independent Verifiers.

**Continuation is open by default.** Because the PCA and its challenge travel in the clear, *any* executor that observes the PCA and holds a
conforming attestation can produce a valid successor with its own key — the challenge proves it saw the PCA, not that it was chosen. This
*open* continuation is the core behavior of the N+1 case, where the successor is unknown at delegation time. What is executed is still pinned:
the `request` block fixes the concrete action, and the executed-vs-signed rule holds **unconditionally** (Section 3.3) — an executor cannot
sign one request and then change target, tenant, or payload at execution. Constraints on *who* may continue — a known recipient, key, or
channel — are extension profiles, out of scope here (Section 6.6).

**Out of scope.** The canonical form of the `request`, digest construction, streaming and partial payloads, and request-binding construction
are defined by a separate specification. The core keeps only the mandatory executed-vs-signed check (Section 3.3).

> **Note — proof mechanism agility.** This hash-and-signature construction is a *non-normative example*, chosen to make the model easy to
> follow. Implementations MAY realize the PoR and the PCA integrity protection with other mechanisms — signed hash chains, Merkle proofs,
> accumulators, recursive or zero-knowledge proofs, hardware-backed attestations — including ones that do not disclose the evidence in the
> clear, provided they preserve the normative semantics: binding to *exactly one* predecessor lineage, responding to the predecessor's
> continuation challenge, non-expansion of the invariants, and integrity of the successor PCA as a whole.
>
> Carrying the attestation in the clear is a property of this minimal profile only. **Selective disclosure** — revealing just the attributes
> the execution contract requires — is out of scope here and is a separate implementation concern, but it is **RECOMMENDED** for production
> profiles that handle sensitive attributes (Section 6.4).

### 2.4 Invariant Monotonicity

Once the PoR holds, the Prover determines the successor invariants. At each hop the invariants are either *kept unchanged* or *attenuated*,
**never expanded**:

- every entry in **`operations`** MUST also be present in the predecessor `operations`;
- every constraint of the predecessor **`executionContract`** MUST be preserved or strengthened.

A Prover **MAY** drop operations, add constraints, or shorten the validity period. A Prover **MUST NOT** add operations, relax constraints,
or extend the validity period. *What is dropped at a hop is lost:* no later hop can reintroduce it.

The predecessor **PCA0** (Section 1.8) granted `READ-ALL` and `BACKUP`. The backup service needs only read access downstream, so it drops
`BACKUP` and sets the attenuated `invariants` (covered by the single PCA signature of Section 2.5):

```json
{
  "operations": ["READ-ALL"],
  "executionContract": {
    "role": "backup-service",
    "compliance": ["GDPR"],
    "serviceAgreements": [
      "https://legal.example.com/agreements/dpa-2026-001"
    ],
    "executionModel": "deterministic"
  }
}
```

The order that decides "more restrictive" is defined by the profile (Section 4): here `operations` uses subset inclusion and the
`executionContract` fields use the reference profile's order.

### 2.5 Successor PCA Construction

The Prover assembles the successor PCA from the **`proofOfRelationship`** of Section 2.3 and the attenuated **`invariants`** of Section 2.4,
adds a fresh **`continuation`** challenge for the next hop, and signs the whole document with a **single** executor signature (the outer
`proof`). Both parts are shown here collapsed, since each appears in full above; this section highlights the wrapper, the emitted challenge,
and the one signature:

```json
{
  "proofOfRelationship": { "…": "the PoR payload of Section 2.3" },
  "invariants":          { "…": "the attenuated invariants of Section 2.4" },
  "chain":               { "…": "prefix representation — profile choice (Section 5)" },
  "continuation": {
    "challenge": "base64url-random-256-bit-value",
    "mode": "single-use",
    "expiresAt": "2026-07-17T10:06:00Z"
  },
  "issuedAt": "2026-07-17T10:01:00Z",
  "expiresAt": "2026-07-18T10:00:00Z",
  "proof": {
    "type": "Ed25519Signature2020",
    "verificationMethod": "did:example:workloads:eu:backup-service#key-1",
    "signature": "base64url..."
  }
}
```

One signature covers everything: predecessor reference, challenge response, executor evidence, attenuated invariants, the `chain`
representation, the emitted `continuation`, and the temporal fields. It is *attributable* — the whole hop is signed by the executor that
made it — and *tamper-evident*: changing any field invalidates it.

`chain` holds the **prefix representation**, and its content is a profile choice (Section 5): in the incremental profile it is a bare
reference or omitted — the predecessor bytes travel in the envelope — while snapshot, full-chain, and succinct-proof profiles put a snapshot
reference, the predecessor list, or a succinct proof here. It never embeds the whole envelope recursively (that would be quadratic); it is
the compact evidence a Verifier uses to reach back beyond the immediate predecessor. This is what forbids the cross-lineage composition of Section 1.4: a PoR that responds to one lineage's
challenge cannot be paired with `invariants` drawn from another and still verify, so the combined document *cannot be validated as a
conforming continuation*. The only other signature a Verifier checks is the issuer's, inside the embedded attestation; that one belongs to
the attestation, not to PIC. Profiles that must transport or verify the PoR or the invariants independently MAY add internal signatures
(Section 5).

**Handoff: the envelope.** A PCA is a *self-contained* signed object: its signature is valid on its own, without any wrapper. Forwarding is
done by an **envelope**, signed by the forwarding workload, that carries the predecessor PCA together with the new PCA:

```json
{
  "envelope": {
    "forwardedBy": "did:example:workloads:eu:backup-service",
    "predecessor":       { "…": "PCA[n-1], self-contained, signed by n-1" },
    "predecessorDigest": "sha256:… (content id of PCA[n-1])",
    "current":           { "…": "PCA[n], self-contained, signed by n" },
    "currentDigest":     "sha256:… (content id of PCA[n])"
  },
  "proof": {
    "type": "Ed25519Signature2020",
    "verificationMethod": "did:example:workloads:eu:backup-service#key-1",
    "signature": "base64url..."
  }
}
```

Both `predecessor` and `current` are PCAs — same shape, one the continuation of the other — so the envelope names them symmetrically. The
next hop unwraps the envelope, takes `current` (`PCA[n]`) **unchanged** — its signature still verifies, since the bytes were never altered —
and places it as the `predecessor` of its own envelope, alongside the PCA it creates. Envelopes are **never nested**: the new envelope
re-carries the PCA, not the old envelope, so size stays bounded. The envelope signature is the *handoff* proof — it attributes the forwarding
to the workload and MAY also bind the transport or request (Section 6.6) — and is separate from the PCA's own continuity signature.

`predecessorDigest` and `currentDigest` are the content-addressed identifiers of the two carried PCAs. A PCA cannot contain its own hash
(that would be self-referential), so these digests live in the envelope, where they serve as the PCAs' ids for linking, logging, and
deduplication — `currentDigest` is what the next hop places in its `previousPcaHash`. They are a **convenience, not trusted input**: a
Verifier MUST recompute each digest from the PCA bytes, reject a mismatch, and check that `predecessorDigest` equals the `previousPcaHash`
carried inside `current`. Security rests on that recomputation and on the signatures, never on the supplied digests.

By default the envelope carries only the immediate transition — the predecessor and the new PCA. `n+1` verifies that one step (Section 3.3),
which already catches any single misbehaving hop. It does not re-verify the earlier chain; it trusts that each earlier hop verified its own
predecessor. The trade-offs of that trust — and when to carry the full chain or a succinct proof instead — are covered in Section 6.8, and
how the chain is represented is a profile choice (Section 5).

## 3. Verifier Requirements

A **PIC Verifier** validates the PCA presented at a hop *before any authority is exercised*. The **per-hop checks** of Section 3.3 are the
same in every profile; what differs is how far the Verifier walks. In the **full-chain** profile it validates the whole chain back to the
origin: it walks to **PCA0**, validates it, and validates each later PCA against its immediate predecessor. In the **incremental** profile
(Section 6.8) it validates the immediate transition carried in the envelope and relies on inductive validity — each hop having validated its
own predecessor. A Verifier MUST:

1. establish and validate the origin **PCA0** (full-chain profile) or the immediate predecessor (incremental profile);
2. validate every hop it walks against its immediate predecessor;
3. accept the hop only if **every** step it validates is valid; otherwise reject.

The authority a Verifier may authorize at the current hop is exactly the `invariants` of the last PCA. By monotonicity (Section 2.4) these
are bounded by the origin, so a privilege absent from PCA0 can never be authorized downstream. The procedure below is written for the
full-chain profile; the incremental profile applies steps 3 and following to the single received transition.

### 3.1 Verifier Procedure

Given a received PCA and the chain behind it, the Verifier MUST perform the following steps and MUST reject the hop if any of them fails:

1. walk back to the origin PCA0;
2. validate PCA0 (Section 3.2);
3. for each PCA from PCA1 to the received one, validate the hop against its predecessor (Section 3.3);
4. accept, and authorize the `invariants` of the last PCA.

```text
receive PCA[n] and the chain behind it
      |
      v
walk back to PCA0
      |
      v
validate PCA0            <-- origin: signature only, no PoR, no hash
      |
      v
for i = 1 .. n:
  validate PCA[i] against PCA[i-1]   <-- integrity, binding, challenge,
                                         attestation, conformance,
                                         non-expansion, temporal, request
      |
      v
all valid ?  accept and authorize invariants of PCA[n]  :  reject
```

The following sections define each step. This walk-the-whole-chain procedure is the *illustrative* one for the hash-chain profile;
alternative chain-validation methods — snapshots and succinct proofs — establish the same checks by other means and at lower cost
(Section 5).

### 3.2 Origin Validation (PCA0)

The origin **PCA0** (Section 1.8) is validated *differently* from later hops: it carries no Proof of Relationship and no predecessor hash,
because there is no predecessor. The Verifier MUST:

- verify the **signature** of PCA0 against its issuer — in the running scenario, Alice (the signature is elided in the Section 1.8 examples
  for brevity);
- confirm PCA0 is within its **validity period** (`issuedAt` / `expiresAt`).

The `invariants` of PCA0 are the *origin grant* and are taken as authoritative: they define the **upper bound** of authority for the whole
lineage. There is nothing earlier to check them against. Like any PCA, PCA0 emits a `continuation` challenge that its first successor must
answer (Section 2.3); who may validly originate a PCA0 is a trust-boundary question addressed in Section 6.2.

### 3.3 Hop Validation (PCA1 onward)

Each PCA from **PCA1** onward continues its predecessor. Given a PCA and its *already-validated* predecessor, the Verifier MUST perform the
following checks **in order** and MUST reject the whole chain if any fails:

1. **integrity** — the outer `proof` is a valid single signature over the whole document under the profile's canonical encoding
   (Section 6.4);
2. **predecessor binding** — `previousPcaHash` equals the hash of the *presented* predecessor PCA, and the challenge answered, the
   `invariants` attenuated, and the `executionContract` checked all belong to **that same** predecessor: they MUST be one concrete
   transition, never fields stitched together from different PCAs;
3. **continuation** — the `continuationResponse` carries the predecessor's emitted challenge, the challenge is unexpired and, when
   `single-use`, has not already been consumed (Section 6.1);
4. **attestation** — the embedded executor attestation is valid: its issuer signature verifies, the issuer is trusted for the asserted
   attributes, it is within its validity period, and its `subject` matches `executor`, which matches the key that signed the PCA;
5. **conformance** — the attested attributes satisfy the predecessor `executionContract` under the profile's conformance function
   (Section 4); for example a `deterministic` contract rejects an `agentic` executor;
6. **non-expansion** — the `invariants` are equal to or more restrictive than the predecessor `invariants` under the profile's attenuation
   order (Section 4);
7. **temporal** — the PCA is within its `issuedAt` / `expiresAt` window and that window is contained in the predecessor's (Section 6.3);
8. **request match** — the operation, target, tenant, parameters, and digests actually served or executed match those signed in the PoR
   `request` (Section 2.3); mandatory in every profile (see enforcement below).

A valid signature establishes *integrity*, not *semantic validity*: checks 2–8 are separate and the Verifier MUST NOT skip them because the
signature verified. The Verifier does **not** trust that the Prover already performed these checks; it repeats them independently.

**Executed-vs-signed, always.** Independently of the profile — *open* included — a verified PCA authorizes the *signed* action and no other:
the reference monitor MUST verify that the operation, target, tenant, parameters, and digests actually executed match those bound in the PoR
`request` (Section 2.3), and MUST refuse any action that differs, even if the PCA verified. Signing one request and executing another is
always a violation. This is distinct from *who* may continue (continuation is open, check 3) and from *whether* policy allows the action:
authorizing the concrete action against the authority context is a profile or PDP decision (Section 4), not a core rule — the core requires
only non-expansion (Section 4.1) and this executed-vs-signed match.

This is where the cross-lineage composition of Section 1.4 fails: an `invariants` block with privileges absent from the predecessor fails
*non-expansion* (6), and a PoR that does not answer the predecessor's challenge fails *continuation* (3) or *predecessor binding* (2). Such
a document *cannot be validated as a conforming continuation*, even though an executor can always assemble arbitrary bytes locally.

## 4. Authority Domains and Attenuation Profiles

### 4.1 Authority as an Abstract Domain

PIC does not define the application's authorization vocabulary and does not replace its access-control system. It preserves the *causal
continuity* and *non-expansion* of an authority context whose meaning is defined by the application or by an applicable PIC profile. That
context may be represented as operation-resource pairs, roles, labels, scopes (for example lifted from an OAuth token), capability classes,
or policy references. Normatively the requirement is only:

```text
authority(i+1)  ≤  authority(i)
```

where `≤` is an *attenuation order* defined by the profile. The `operations` set with subset inclusion, used in the examples, is the
**reference profile**: it corresponds to the operation-resource privileges of the model [[1]](#references).

A label may *denote* authority without listing it: `EU-BACKUP-READONLY` denotes a set of operation-resource permissions and carries that
meaning by reference. This keeps the confused-deputy result intact rather than discarding it — a label is defined to denote a semantic set
(in the reference case an O×R set), and the label order is required to **refine** the subset order on those denotations. O×R is thus the
profile where non-expansion is immediate, and any other profile inherits the guarantee exactly to the extent that its order refines its
denotation order.

### 4.2 Attenuation Profiles

Every profile that introduces an authority representation or an execution contract MUST define its syntax, its equivalence relation, its
attenuation order `≤`, and the conformance function that checks an executor against a contract. For example:

```text
role:               current == predecessor
allowedRegions:     current ⊆ predecessor
requiredCompliance: current ⊇ predecessor
executionModel:     current ⊆ predecessor
expiresAt:          current ≤ predecessor
```

The core uses the abstract relation `Attenuates(current, predecessor, profile)`; a Verifier MUST reject a PCA whose profile is unknown or does not
define a deterministic comparison. Concrete profiles for specific domains are defined by separate specifications. Translation between
*heterogeneous* authority domains is out of scope here; consistent with the model, an overly permissive translation is a profile error, not
a violation of the continuity invariant.

### 4.3 Policy Decision Point (PDP) Integration

PIC and access control answer different questions:

```text
PIC:            is this authority state a valid non-expansive continuation
                of the state that caused the execution?
Access control: does this authority state authorize this concrete operation
                under the application policy?
```

Using a PDP is an **application choice**, not part of PIC. An executor MAY evaluate policy locally, or it MAY pass the authority context to a
**Policy Decision Point** — Cedar, Rego, XACML, or another engine — that interprets the label's semantics and renders the access decision.
The two decisions MAY run in one component or in separate ones. PIC neither requires a PDP nor defines one; this section exists only for
implementers who choose that path.

Whoever takes that path takes an obligation with it, and it is **theirs, not PIC's**: the declared attenuation order on labels MUST be
*monotone with respect to their semantics*. If `current ≤ predecessor` in the label order but the meaning of `current` is not contained in the
meaning of `predecessor`, PIC's non-expansion is vacuous — the labels shrink while what they authorize grows. Establishing that the label order refines
its denotation order is up to the application or its PDP. It does **not inherit the Lean proof** [[2]](#references): the proof covers
non-expansion of the *abstract* order only; semantic monotonicity of a concrete vocabulary is a separate proof obligation that PIC does not
discharge. This is the same boundary the model already draws for heterogeneous translation, and it is a natural point of standardization —
label vocabularies with provably semantic-monotone orders, and the PIC↔PDP interface that carries the obligation.

## 5. Chain Representations

A PIC chain can be implemented and validated in more than one way. The choice does not change the model — the invariants and the checks of
Section 3 stay the same — but it changes the *cost of validation* at a hop and the *trust assumptions*. This section is non-normative; an
implementation profile selects one representation. It expands on the proof mechanism agility of Section 2.3. A representation does not
inherit the Lean proof automatically: each MUST show that its concrete acceptance predicate implies the abstract PoC (Section 6.5).

### 5.1 Full Hash Chain

Each PCA references its predecessor by hash. The Verifier walks the chain from **PCA0** to the current hop, checking every hop as described
in Section 3. Validation cost is *linear* in the length of the chain, **O(n)** for a chain of `n` hops. No external component is required:
the chain, with the hashes and proofs each hop needs, is presented with the request.

```text
PCA0 <--hash-- PCA1 <--hash-- PCA2 <--hash-- PCA[n]
 |                                             |
 +------------ verify every hop --------------+
                    cost: O(n)
```

This is the reference baseline and the decentralized, collusion-resistant fallback (Section 7). It is, however, **too slow to be a working
default**: cost and message size grow without bound with the chain length. The specification therefore does not build on it for practical
multi-hop deployments — it remains available where its O(n) cost is acceptable and full independent re-verification is required.

### 5.2 Snapshot Hash Chain

Every so many hops, a trusted party validates the chain so far and issues a signed **snapshot** attesting that the chain up to some `PCA[k]`
is valid. A Verifier presented with a snapshot verifies the *snapshot signature* and then validates only the hops after it, instead of
walking all the way back to PCA0. Validation cost drops to the distance from the last snapshot, **O(hops since the last snapshot)**. The
trade-off is an *external trusted component* — the snapshot issuer — added to the trust model.

```text
PCA0 ... PCA[k]  ==>  snapshot (signed by trusted issuer)
                          |
                          +--> verify only PCA[k+1] ... PCA[n]
                               cost: O(hops since snapshot)
```

**This is the profile the specification orients on.** Forthcoming versions develop their normative constructions on the snapshot hash chain:
it keeps validation bounded without requiring advanced cryptography. The choice stays non-normative — an implementation MAY use the full
hash chain (5.1) or a succinct proof (5.3) and adapt accordingly — but the worked examples and constructions of this specification assume
this profile.

### 5.3 Succinct Proofs (Zero-Knowledge)

The validity of the whole chain can be compressed into a single **succinct proof** — for example a zero-knowledge SNARK — that a Verifier
checks without walking the chain and without seeing its contents. Verifying is **O(1)** in the length of the chain, and the underlying
evidence need not be disclosed. The **SNARK is only an example**: any cryptographic construction that soundly proves the chain's validity
would serve. The choice of construction, and the verification of its soundness, are **out of scope** for this document.

```text
PCA0 ... PCA[n]  -->  succinct proof (e.g. ZK-SNARK)  -->  Verifier
                                                           check: O(1)
```

## 6. Security Considerations

### 6.1 Freshness, Replay, and Fan-out

Freshness protects against **replay**. Because a PCA travels in the clear, anyone who observes one could otherwise present it again as if it
were continuing the lineage now. The authority it carries is still bounded by the origin, so replay cannot *escalate* — but it could re-run a
past action, or run it in a context that no longer applies. Freshness closes that window by making each continuation answer something the
predecessor issued specifically for this hop.

The `continuation` block declares how a challenge may be consumed:

```json
{
  "continuation": {
    "challenge": "base64url-random-256-bit-value",
    "mode": "single-use",
    "maxUses": 1,
    "expiresAt": "2026-07-17T10:06:00Z"
  }
}
```

The `continuation` carries no recipient selector. In the core, continuation is **open**: any executor conforming to the predecessor's
`executionContract` may continue, and the concrete action is always identified by the `request` block in the PoR (Section 2.3). `mode` and
`maxUses` govern consumption, replay, and fan-out — not *who* may continue. Recipient-, key-, or channel-constrained continuations are future
extension profiles (Section 6.6).

For a `single-use` challenge, a Verifier MUST prevent it from being consumed twice, keeping state or an equivalent mechanism; this is what
stops a public predecessor PCA from being replayed as a fresh continuation. Note the scope: `maxUses` enforced per Verifier is a *local*
bound — it does not cap total uses across independent Verifiers. A global limit needs shared state or coordination, whose delivery semantics
(at-most-once vs at-least-once) are out of scope for this document. **Fan-out** is the case where reuse is intentional: several
successors continue the same predecessor, which is permitted provided each branch references that predecessor, each branch is individually
valid, and no branch composes authority from — or recovers authority attenuated by — another branch. Authorized fan-out is therefore
distinct from unauthorized replay: the difference is declared by `mode`/`maxUses` and enforced by the Verifier.

The continuation challenge is **one** freshness mechanism, not a mandatory one. A profile MAY meet the same goal differently — a monotonic
per-lineage counter, a server-issued single-use ticket, a bounded acceptance window (Section 6.3), or a transport-level anti-replay control
— provided a stale or duplicated continuation cannot be accepted. What is normative is the *property* (no replayed or duplicated continuation
is accepted), not the specific method.

### 6.2 Origin (PCA0) Trust Boundary

PIC governs propagation *after* an origin authority context has been validly established. It does not by itself determine whether an actor
was entitled to originate that context. Minting or deriving a PCA0 (Section 1.8) MUST be permissioned, policy-controlled, attributable, and
auditable. In particular, distinguishing a request-caused action from an action an executor re-originates as a new lineage of its own is a
responsibility of the origination policy and the enforcement architecture, not of the continuity invariant: a compromised executor that
re-originates authority is outside the guarantee.

### 6.3 Temporal Rules and Per-Hop Expiry

For every non-origin PCA a Verifier MUST check:

```text
current.issuedAt    ≥ predecessor.issuedAt
current.expiresAt   ≤ predecessor.expiresAt
current.issuedAt    ≤ verificationTime < current.expiresAt
challenge.expiresAt ≤ predecessor.expiresAt
```

Beyond this lineage bound, each hop SHOULD carry its **own short expiry**, set from its creation time and distinct from the lineage's total
validity. The lineage `expiresAt` bounds the whole chain; a tighter per-hop window bounds a single continuation. This second, shorter expiry
limits the damage of a replay: even if a continuation is duplicated within the lineage's total validity, it is accepted only for the brief
window after its creation, not for the full remaining lifetime of the lineage. PCA0 need not carry the tighter window; later hops SHOULD.

Allowed clock skew is a profile parameter. Online verification uses the current time; retrospective (audit) verification requires
trusted-time evidence for the execution instant and is left to a profile.

### 6.4 Canonicalization and Cryptographic Agility

The byte representation covered by a hash or signature MUST be unambiguous and deterministically reproducible under the selected profile.
Each profile MUST state its canonical encoding, hash algorithm, signature algorithm, domain-separation rules, and a suite identifier. The
illustrative profile uses canonical JSON, SHA-256, and Ed25519; these are not required of every implementation.

PIC is not tied to JSON. A profile MAY carry and sign PCAs with established envelopes such as **JOSE** (JWS/JWT) or **COSE**, or with any
canonical binary encoding. For network-heavy or resource-constrained infrastructure, a binary format is RECOMMENDED — in particular
**CBOR** (with COSE for signing) — to reduce size and parsing cost; deterministic CBOR gives the reproducible byte representation this
section requires. Selective-disclosure or zero-knowledge mechanisms MAY replace full-attestation signing, provided the Verifier can still
establish the required attributes, issuer validity, subject binding, validity period, and conformance. Such mechanisms do not change PIC
semantics, but they may change the cryptographic trust model.

### 6.5 Formal Scope

The Lean formalization [[2]](#references) proves the logical safety properties of the abstract model and, through a refinement mapping, that
any chain accepted under the modeled verifier assumptions satisfies the abstract PIC invariants. The computational security of the chosen
cryptographic primitives, and the semantic monotonicity of a concrete authority profile (Section 4.3), remain **external assumptions**. It
is not claimed that Lean proves the security of a cryptographic implementation.

### 6.6 Proof of Possession (Optional)

The core binds a hop to its executor through the PCA signature and pins the action through the `request` block (Section 2.3). A profile MAY
add a **proof of possession** of the request or channel — for example **DPoP** [[5]](#references), **HTTP Message Signatures**
[[6]](#references), or an equivalent signed request binding — or otherwise constrain the recipient or channel. These are **not core
continuation modes** and are **not needed for the N+1 model**, whose successor is unknown; they serve profiles that require additional
presentation constraints.

> Profiles MAY define recipient- or channel-constrained continuations when the successor or presentation key is known in advance. Such
> profiles remain PIC-compatible but do not address the unknown-successor case that motivates the core N+1 model, and are outside the scope
> of this specification.

### 6.7 Transport Separation and Confidentiality

The security model is independent of transport (Section 1): the guarantees rest on the signed chain, and an implementation MUST NOT rely on
the channel to obtain them. Transport nonetheless matters for **confidentiality and attack surface**, exactly as it does for OAuth. A
man-in-the-middle on an unprotected channel cannot forge a valid PCA — the signatures prevent that — but it can read message contents,
including the result of a command, and attempt interception. That is a transport problem, addressed by transport, not by PIC.

PIC is carrier-agnostic: the same chain runs over HTTP, over messaging systems such as Apache Kafka, or over any other transport. For
messaging in particular, channels SHOULD be encrypted. A *plain outsider* who reads a PCA cannot continue it — minting a valid successor
needs a conforming attestation. But in the **open core** (Section 2.3), any conforming executor that observes the PCA *can* continue it: the
core does not restrict *who* continues. What it does pin is the *action* (the request binding) and the fact that authority cannot grow
(non-expansion); constraints on recipient or channel are future profiles (Section 6.6). Encryption here protects payload confidentiality and
reduces the man-in-the-middle surface — it is not a source of the model's integrity, and it is not what prevents continuation.

### 6.8 Incremental Verification and Trusted Hops

The **incremental** profile (Section 2.5) forwards only the immediate transition in the envelope, `[PCA[n-1], PCA[n]]`, and validates that
one transition at each hop. Global validity back to PCA0 is then *inductive*: a valid `PCA[n]` implies its predecessor was validated by the
hop that produced it, and so on to the origin. The per-hop checks — hash link, non-expansion, conformance, PoR (Section 3.3) — catch **any
single** hop that expands authority or fails its contract, at the next honest hop: the next Verifier holds both PCAs of that transition and
rejects it.

This profile makes one explicit assumption: **each hop is a trusted verifier.** It resists a single compromised or buggy hop, but not two
or more *consecutive colluding* hops. If `PCA[n-1]` is minted already expanded by a compromised `n-1` and forwarded by a complicit `n`, then
`n+1` — lacking `PCA[n-2]` — cannot re-verify the `n-2 → n-1` step and would accept it.

The predecessor hashes do **not** close this gap, and it is worth being precise about why. They prove *linkage and order* — that each PCA
follows the one it names, unaltered, so history cannot be reordered or rewritten. They do **not** prove *non-expansion of content*. Checking
that a step did not expand needs the `invariants` of the predecessor — its bytes — and a hash is one-way: a downstream verifier holds
`H(PCA[n-2])` (inside `PCA[n-1]`) but not `I(n-2)`, so it cannot re-check a step whose PCA it does not carry. The colluding hops do not
rewrite history and do not forge any honest DID; they sign two expanded PCAs with their **own** keys, and the next honest hop never holds the
earlier bytes to notice. This is the same trust model as a snapshot (Section 5.2): the incremental profile is, in effect, a decentralized
per-hop snapshot, each envelope attesting that its signer validated its predecessor. A deployment that must resist consecutive collusion MUST use the **full-chain** profile — the envelope carries `[PCA0 … PCA[n]]`
and the Verifier re-validates every step independently — or a succinct proof that commits to the whole prefix (Section 5.3). Safety against a
single faulty hop holds in all profiles; the choice is only how much independent re-verification the deployment wants to pay for.

## 7. Deployment Models

PIC runs the same model in different topologies. The trade-off is between three properties the lightweight profile cannot maximize at once:
**decentralization**, **low per-hop cost**, and **resistance to consecutive colluding hops** (Section 6.8). A single faulty hop is contained
in *every* model (Section 1.1); deployment only decides how much — and on what — to spend to also resist collusion among
compromised-but-authorized parties.

| Model | Central party | Per-hop cost | Consecutive collusion |
| --- | --- | --- | --- |
| Decentralized, incremental (default) | none | O(1) | not resisted |
| Decentralized, full-chain | none | O(n) | resisted |
| Central / snapshot validator | yes | O(1) | resisted |
| Succinct proof (e.g. SNARK) | none | O(1) verify | resisted |

- **Decentralized, incremental** (Section 2.5). Each hop forwards only the immediate transition; no central component; O(1). Resists a single
  faulty hop but not consecutive collusion. Right when every hop is a trusted verifier and group compromise is out of scope.
- **Decentralized, full-chain.** The envelope carries `[PCA0 … PCA[n]]` and every hop re-validates every step. No central party, and
  consecutive collusion is resisted — the honest verifier holds the earlier bytes and the colluders cannot forge the honest DIDs — at O(n)
  size and validation cost per hop.
- **Central (or snapshot) validator.** A trusted service validates each hop against the lineage history it holds, or issues periodic signed
  snapshots (Section 5.2). Workloads forward at O(1), and the validator catches an expansion even under hop collusion because it holds the
  earlier invariants. This is the practical way to resist collusion at O(1) without advanced cryptography — at the cost of a central trust
  anchor and an availability dependency.
- **Succinct proof.** A succinct proof — for example a SNARK or accumulator — proves non-expansion over the whole prefix (Section 5.3): decentralized, O(1) to verify, and
  collusion-resistant, all at once — at the cost of proof-generation complexity and a heavier cryptographic profile.

Stated plainly: **to resist collusion among compromised-but-authorized hops while keeping O(1) forwarding and no advanced cryptography, use a
central or federated validator.** The decentralized alternatives that also resist it are full-chain (pay O(n)) or succinct proofs (pay in
cryptography). Fully decentralized *and* lightweight means trusting each hop — the incremental profile and its documented limit (Section 6.8).

## 8. Zero Trust

PIC is zero-trust in a precise, checkable sense, not as a label. Each property below is a concrete consequence of the model, not an
aspiration.

- **No implicit trust from network location.** Authorization comes from the signed continuity chain, never from where a request originates. A
  caller inside the perimeter has exactly the authority its lineage carries, and no more (Section 6.7).
- **Every hop is verified, never assumed.** No step is trusted because a previous one was: the Verifier re-checks the transition it holds —
  signature, predecessor link, challenge, attestation, conformance, non-expansion, time (Section 3.3) — and never assumes the Prover already
  did. The full-chain profile re-checks *every* hop; the incremental profile re-checks the immediate transition and trusts prior verifiers
  inductively (Section 6.8).
- **Least privilege by construction.** Authority only attenuates; each hop carries the smallest context it needs and can never regain what an
  ancestor dropped (Section 2.4). A privilege absent from the origin cannot appear anywhere downstream.
- **Assume breach, contain it.** A buggy or compromised executor can act arbitrarily in its own step, but it cannot propagate an invalid
  authority state as a valid continuation (Section 1.1). The blast radius is one hop, not the chain.
- **Per-request, contextual decisions.** Each continuation is authorized against the context that caused it, with freshness (Section 6.1) and
  time bounds (Section 6.3) making the decision specific to this request rather than a standing grant.
- **Identity is not authority.** Authenticating who acts does not by itself grant continuation; the authority exercised must be a valid
  continuation of the lineage (Section 1.2). Compromising an identity does not confer authority the lineage never delegated to it.

These hold against a single faulty hop in every profile. The two that quantify over the *whole* chain — explicit verification of every hop,
and end-to-end non-expansion — hold absolutely only when the whole prefix is verified: the full-chain profile, a trusted snapshot, or a
succinct proof. In the incremental profile they hold *inductively*, trusting each prior verifier (Section 6.8). The result is not "trust
nothing" as a slogan but a model where trust is *earned per hop, verified explicitly, and bounded by construction*.

## 9. Contributors

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## 10. Legal Notices

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
- [2] Gallo, N. (2026). *PIC Lean Verification*. Lean 4 formalization of the definitions and theorems of [1]. [github.com/ngallo/pic-model/draft/0.1/pic-model-math/pic-lean](https://github.com/ngallo/pic-model/tree/main/draft/0.1/pic-model-math/pic-lean)
- [3] Bradner, S. (1997). *Key words for use in RFCs to Indicate Requirement Levels*. BCP 14, RFC 2119. [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119)
- [4] Leiba, B. (2017). *Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words*. BCP 14, RFC 8174. [rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174)
- [5] Fett, D., Campbell, B., Bradley, J., Lodderstedt, T., Jones, M. B., & Waite, D. (2023). *OAuth 2.0 Demonstrating Proof of Possession (DPoP)*. RFC 9449. [rfc-editor.org/rfc/rfc9449](https://www.rfc-editor.org/rfc/rfc9449)
- [6] Backman, A., Richer, J., & Sporny, M. (2024). *HTTP Message Signatures*. RFC 9421. [rfc-editor.org/rfc/rfc9421](https://www.rfc-editor.org/rfc/rfc9421)
