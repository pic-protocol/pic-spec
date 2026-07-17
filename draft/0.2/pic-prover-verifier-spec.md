# PIC Prover and Verifier Specification

**Version:** 0.2 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2026-07-15  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.2/pic-prover-verifier-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.2/pic-prover-verifier-spec.md)  
**Editors:**

- **Nicola Gallo** (Nitro Agility S.r.l.)
- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 5](#5-contributors)).*

**Contributors:**

- *Add your name via pull request (individual or organization) — listing is subject to editor approval (see [Section 5](#5-contributors)).*

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
  - [4. Chain Representations](#4-chain-representations)
    - [4.1 Hash Chain](#41-hash-chain)
    - [4.2 Snapshot](#42-snapshot)
    - [4.3 Zero-Knowledge Proofs (SNARKs)](#43-zero-knowledge-proofs-snarks)
  - [5. Contributors](#5-contributors)
  - [6. Legal Notices](#6-legal-notices)
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
server. Section 4 describes these representations; the model and its guarantees are the same in either case.

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

### 1.5 The Execution Flow as Part of the Security Model

The PIC Model resolves the N+1 Executor Problem by bringing the execution flow itself, including the not-yet-existing executor `n+1`, into
the security model, rather than leaving the gap between `x` and `x + y` to application logic. What must hold across that gap is not the
identity of the successor, but that its authority is a valid continuation of the context that caused it. At time `x` the Prover of executor
`n` emits PoR and PoC addressed to an unknown successor. At time `x + y` whichever executor materializes as `n+1` presents them to its
Verifier, which accepts the hop only if both are valid. The temporal gap is therefore not an application concern to be patched with
perimeter assumptions or out-of-band coordination. It is the object the security model is built around: authority crosses it only as
verified continuity, never as possession by a pre-existing holder.

> **To be completed:** roles of the Prover and Verifier in the Trust Plane, and relationship to CAT and Federation Bridge components.

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
document that carries the **invariants** of a lineage, that is, the `operations` that may continue and the `executionContract` that
executors must satisfy. The PCA of the origin, **PCA0**, contains no Proof of Relationship: there is no predecessor to relate to. Every
later hop continues, and may only attenuate, the invariants granted by the PCA0.

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
  "issuedAt": "2026-07-17T10:00:00Z",
  "expiresAt": "2026-07-18T10:00:00Z"
}
```

Each PCA0 starts a distinct lineage with its own invariants, and no later hop can expand them. These are the two lineages of Section 1.4.

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
3. include a **Proof of Relationship** binding the current execution to the predecessor;
4. carry **invariants** equal to or more restrictive than the predecessor invariants;
5. be **integrity-protected as a whole** by the current executor.

The first requirement is what keeps the *cross-lineage composition* of Section 1.4 out of the model: a PCA that continues two lineages at
once cannot be constructed. The construction below is a *minimal profile* chosen for clarity.

### 2.1 Prover Procedure

Given a predecessor PCA, the Prover MUST perform the following steps and MUST NOT emit a successor PCA if any of them fails:

1. validate the predecessor PCA (Section 2.2);
2. construct, sign, and verify the Proof of Relationship (Section 2.3);
3. keep or attenuate the invariants (Section 2.4);
4. sign the invariants, assemble the PCA, and sign it as a whole (Section 2.5);
5. emit the signed PCA to the next hop.

```text
receive PCA[n-1]
      |
      v
validate predecessor
      |
      v
construct, sign, and verify PoR
      |
      v
keep or attenuate invariants
      |
      v
assemble and sign PCA[n]
      |
      v
emit PCA[n]
```

The following sections define each step.

### 2.2 Predecessor Validation

The Prover MUST validate the predecessor PCA by applying the Verifier procedure of Section 3. If validation fails, the Prover MUST NOT
emit a successor PCA. The rest of this section assumes a valid predecessor.

### 2.3 Proof of Relationship

The **PoR** is a *self-contained signed object*, carried in the clear inside the successor PCA as the `proofOfRelationship` field, so that a
Verifier can extract it and check it on its own against the DID that signed it. Its payload carries three things:

- **`previousPcaHash`** — the hash of the predecessor PCA, binding this step to *exactly one* lineage;
- **`executor`** and **`operation`** — the executor identifier and the operation performed at the current hop;
- **`executorAttestation`** — the *conformance evidence*: the executor attestation of Section 1.6, embedded in full, proving that the
  executor satisfies the execution contract.

Continuing the running scenario, the backup service performing `BACKUP` produces the following PoR:

```json
{
  "type": "PIC-PoR-Embedded-v0",
  "previousPcaHash": "sha256:4f6c...",
  "executor": "did:example:workloads:eu:backup-service",
  "operation": "BACKUP",
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
  },
  "proof": {
    "type": "Ed25519Signature2020",
    "verificationMethod": "did:example:workloads:eu:backup-service#key-1",
    "signature": "base64url..."
  }
}
```

The executor MUST sign the PoR payload with the key bound to its identifier, and the Prover MUST **verify the PoR before proceeding**: if the
executor does not satisfy the predecessor execution contract, or `previousPcaHash` does not match the predecessor, the PoR is *invalid* and
the Prover MUST stop. Continuing would be pointless, since a PCA carrying an invalid PoR is rejected at the next hop. The successor
invariants are *not* part of the PoR: they are a second self-contained signed object, and the assembly of Section 2.5 binds the two
together. The only external artifact is the predecessor PCA, presented with the chain.

> **Note — proof mechanism agility.** This hash-and-signature construction is a *non-normative example*, chosen to make the model easy to
> follow. Implementations MAY realize the PoR and the PCA integrity protection with other mechanisms — signed hash chains, Merkle proofs,
> accumulators, recursive or zero-knowledge proofs, hardware-backed attestations — including ones that do not disclose the evidence in the
> clear, provided they preserve the normative semantics: binding to *exactly one* predecessor lineage, binding to the current execution,
> non-expansion of the invariants, and integrity of the successor PCA as a whole.

### 2.4 Invariant Monotonicity

Once the PoR holds, the Prover determines the successor invariants. At each hop the invariants are either *kept unchanged* or *attenuated*,
**never expanded**:

- every entry in **`operations`** MUST also be present in the predecessor `operations`;
- every constraint of the predecessor **`executionContract`** MUST be preserved or strengthened.

A Prover **MAY** drop operations, add constraints, or shorten the validity period. A Prover **MUST NOT** add operations, relax constraints,
or extend the validity period. *What is dropped at a hop is lost:* no later hop can reintroduce it.

The predecessor **PCA0** (Section 1.8) granted `READ-ALL` and `BACKUP`. The backup service needs only read access downstream, so it drops
`BACKUP` and signs the attenuated `invariants`:

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
  },
  "proof": {
    "type": "Ed25519Signature2020",
    "verificationMethod": "did:example:workloads:eu:backup-service#key-1",
    "signature": "base64url..."
  }
}
```

### 2.5 Successor PCA Construction

The Prover assembles the successor PCA from the two signed objects just built — the **`proofOfRelationship`** of Section 2.3 and the
attenuated **`invariants`** of Section 2.4 — and MUST sign the assembled document as a whole through an outer **`proof`**. Both parts are
shown here collapsed, since each appears in full above; what this section highlights is the wrapper and its signatures:

```json
{
  "proofOfRelationship": { "…": "the PoR of Section 2.3" },
  "invariants":          { "…": "the attenuated invariants of Section 2.4" },
  "issuedAt": "2026-07-17T10:01:00Z",
  "expiresAt": "2026-07-18T10:00:00Z",
  "proof": {
    "type": "Ed25519Signature2020",
    "verificationMethod": "did:example:workloads:eu:backup-service#key-1",
    "signature": "base64url..."
  }
}
```

The result carries **three signatures**: one inside `proofOfRelationship`, one inside `invariants`, and the outer `proof` over the whole
document. Each part is therefore verifiable *on its own* against the executor DID, every attenuation is *attributable* to the executor that
signed it, and replacing any part invalidates the outer signature. This structure is what forbids the cross-lineage composition of
Section 1.4: a `proofOfRelationship` and an `invariants` block signed under *different* lineages cannot be assembled into one valid PCA.

## 3. Verifier Requirements

A **PIC Verifier** validates the PCA presented at a hop *before any authority is exercised*. Validation is not local to the received PCA: it
covers the **whole chain back to the origin**. The Verifier walks back to the origin **PCA0**, validates it, and then validates each later
PCA forward against its immediate predecessor. A Verifier MUST:

1. establish and validate the origin **PCA0**;
2. validate every hop from **PCA1** onward against its immediate predecessor;
3. accept the hop only if **every** step of the chain is valid; otherwise reject.

The authority a Verifier may authorize at the current hop is exactly the `invariants` of the last PCA. By monotonicity (Section 2.4) these
are bounded by the origin, so a privilege absent from PCA0 can never be authorized downstream. The construction below mirrors the minimal
profile of Section 2.

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
  validate PCA[i] against PCA[i-1]   <-- integrity, PoR, hash, non-expansion
      |
      v
all valid ?  accept and authorize invariants of PCA[n]  :  reject
```

The following sections define each step.

### 3.2 Origin Validation (PCA0)

The origin **PCA0** (Section 1.8) is validated *differently* from later hops: it carries no Proof of Relationship and no predecessor hash,
because there is no predecessor. The Verifier MUST:

- verify the **signature** of PCA0 against its issuer — in the running scenario, Alice (the signature is elided in the Section 1.8 examples
  for brevity);
- confirm PCA0 is within its **validity period** (`issuedAt` / `expiresAt`).

The `invariants` of PCA0 are the *origin grant* and are taken as authoritative: they define the **upper bound** of authority for the whole
lineage. There is nothing earlier to check them against.

### 3.3 Hop Validation (PCA1 onward)

Each PCA from **PCA1** onward continues its predecessor and is validated against it. Given a PCA and its *already-validated* predecessor, the
Verifier MUST perform the following checks and MUST reject the whole chain if any fails:

- **integrity** — the outer `proof` is valid over the whole document, and the inner `proofOfRelationship` and `invariants` signatures are
  valid on their own (Section 2.5);
- **causal linkage** — the `previousPcaHash` inside the PoR equals the hash of the predecessor PCA, and the PoR signature is valid
  (Section 2.3);
- **non-expansion** — the `invariants` are equal to or more restrictive than the predecessor `invariants` (Section 2.4);
- **validity period** — the PCA is within its `issuedAt` / `expiresAt` window.

The **PoR is checked first**: only if it is valid, so that the hop genuinely continues the lineage, does the Verifier proceed to the hash
and non-expansion checks. An invalid PoR ends validation, since a step that does not continue the predecessor has no lineage to bound it.

This is the check that closes the cross-lineage composition of Section 1.4: an `invariants` block whose privileges are not present in the
predecessor fails the *non-expansion* check, and a PoR carrying a `previousPcaHash` from a different lineage fails the *causal linkage*
check. Neither can be accepted as a valid hop.

## 4. Chain Representations

A PIC chain can be implemented and validated in more than one way. The choice does not change the model — the invariants and the checks of
Section 3 stay the same — but it changes the *cost of validation* at a hop and the *trust assumptions*. This section is non-normative; an
implementation profile selects one representation. It expands on the proof mechanism agility of Section 2.3.

### 4.1 Hash Chain

Each PCA references its predecessor by hash, as in the minimal profile of Section 2. The Verifier walks the chain from **PCA0** to the
current hop, checking every hop as described in Section 3. Validation cost is therefore *linear* in the length of the chain, **O(n)** for a
chain of `n` hops. No external component is required: the chain, with the hashes and proofs each hop needs, is presented with the request.

```text
PCA0 <--hash-- PCA1 <--hash-- PCA2 <--hash-- PCA[n]
 |                                             |
 +------------ verify every hop --------------+
                    cost: O(n)
```

### 4.2 Snapshot

Every so many hops, a trusted server validates the chain so far and issues a signed **snapshot** attesting that the chain up to some
`PCA[k]` is valid. A Verifier presented with a snapshot verifies the *snapshot signature* and then validates only the hops after it, instead
of walking all the way back to PCA0. Validation cost drops to the distance from the last snapshot, **O(hops since the last snapshot)**. The
trade-off is an *external trusted component* — the snapshot server — added to the trust model.

```text
PCA0 ... PCA[k]  ==>  snapshot (signed by trusted server)
                          |
                          +--> verify only PCA[k+1] ... PCA[n]
                               cost: O(hops since snapshot)
```

### 4.3 Zero-Knowledge Proofs (SNARKs)

The validity of the whole chain can be compressed into a single succinct proof, for example a **SNARK**, that a Verifier checks without
walking the chain and without seeing its contents. Each hop produces a proof that the chain up to that hop is valid; verifying it is
**O(1)** in the length of the chain, and the underlying evidence need not be disclosed. The construction of such proofs is out of scope
here; this section only records that the model admits them.

```text
PCA0 ... PCA[n]  -->  succinct proof (SNARK)  -->  Verifier
                                                   check: O(1)
```

## 5. Contributors

The editors and contributors of this document are listed in the **document header** above. Listing is governed by Appendix B.7 of the
[PIC Legal Appendices](./pic-legal.md).

## 6. Legal Notices

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
