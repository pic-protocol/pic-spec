# Provenance Identity Continuity (PIC) Model Specification

**Version:** 0.1 (Draft)  
**Status**: Draft – Not a Standard  
**Date:** 2025-12-11  
**Publisher / Steward:** Nitro Agility S.r.l.  
**Model Origin (Theoretical):** PIC Model (Nicola Gallo)  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.1/pic-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.1/pic-spec.md)

---

## Abstract

Possession-based authorization systems rely on **Proof of Possession (PoP)**: authority derives from holding an artifact—a token, a certificate, a key.
This works for a single hop. It fails catastrophically across chains.

**The problem**: Service A holds a token. *Service A* calls *Service B*. *Service B* obtains a token—its own, exchanged, or delegated. *Service B* calls *Service C*.

At each hop, the system asks: "Do you possess a valid artifact?" The artifact may carry identity. It may carry claims. It may reference the origin. But possession of the artifact is sufficient to exercise authority.
No one enforces: Can this execution *only* continue within origin bounds? Can authority *only* shrink? Each hop restarts trust on possession, not on causal continuity.

This is why AI agents, microservice meshes, and multi-cloud workflows are structurally vulnerable to Proof of Possession protocols.
PoP cannot model relationships that survive multiple hops. It verifies artifacts, not continuity.

**The solution**: This specification defines the **Provenance Identity Continuity (PIC) Model**, which replaces the question "what do you possess?" with "can you prove you can continue this chain?"

PIC enforces three invariants at every execution hop:

- **Provenance**: The causal chain is always traceable and auditable. From origin to end, unbroken. If it breaks, execution stops.

- **Identity**: The origin identity (`p_0`) is immutable. It is the source of authority. It cannot change throughout the chain.

- **Continuity**: Continuity is proven at every step. Authority can only decrease (`ops_i ⊆ ops_{i-1}`). It never expands.

Under these invariants, the confused deputy problem is not mitigated—it becomes **structurally inexpressible**.
As proven in [[1]](#references), PIC eliminates entire attack classes inherent to possession-based models: confused deputy, privilege escalation, token substitution, and ambient authority exploitation.

> **CLARIFICATION**: The confused deputy is not a bug or misconfiguration.
> It is a structural vulnerability inherent to Proof of Possession: a privileged service uses its own authority on behalf of a less-privileged caller.
> Under PIC, this cannot happen—not because of careful coding, but because the protocol makes it impossible.
> Authority derives from the origin, not from the executor's credentials.

**NOTE**: This specification uses "cryptographic" as shorthand for "verifiable under a Trust Model."
Trust Models MAY be implemented via cryptographic primitives, hardware attestation, distributed consensus, or other mechanisms providing non-repudiable binding.

**Proof of Continuity** replaces Proof of Possession. This is PIC.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Terminology](#2-terminology)
3. [Architecture and Components](#3-architecture-and-components)
4. [Data Structures](#4-data-structures)
5. [Transport, Communication, and Request Binding](#5-transport-communication-and-request-binding)
6. [Deployment and Adoption](#6-deployment-and-adoption)
7. [Security Considerations](#7-security-considerations)

A. [Use of Automated Language Assistance](#appendix-a--use-of-automated-language-assistance)  
B. [Authorship, Stewardship, Attribution, and Derivative Works](#appendix-b--authorship-stewardship-attribution-and-derivative-works)  
C. [Disclaimer and Limitation of Liability](#appendix-c--disclaimer-and-limitation-of-liability)  
D. [Acknowledgements](#appendix-d--acknowledgements)  
R. [References](#references)  

---

## 1. Introduction

This section defines the scope, applicability, and conventions used throughout the specification.

### 1.1 Scope

This specification defines the Provenance Identity Continuity (PIC) Model for distributed execution systems. The specification includes:

1. **Formal Model**: Causal invariants and execution semantics that MUST hold for any execution to be considered PIC-compliant
2. **Architecture and Components**: Reference architecture defining the separation between untrusted execution (Executors) and trusted validation (CAT/Trust Plane)
3. **Deployment and Adoption**: Deployment patterns, integration strategies, and performance trade-offs for practical adoption

The PIC Model establishes a foundational execution model that eliminates confused deputy conditions by construction. While the specification provides reference architecture and implementation guidance, it does not mandate specific protocol encodings, wire formats, or cryptographic primitives. These are defined in separate PIC Protocol specifications.

> **Applicability**: PIC is not limited to distributed systems.
> The model applies wherever execution crosses trust boundaries: microservices, OS kernels, process isolation, browser sandboxes, embedded systems, smart contracts, AI agent orchestration.
> Any system with causal execution chains can enforce PIC invariants.

**Normative vs. Informative**:

- Sections 1-3 define **normative** requirements (terminology, architecture, invariants)
- Sections 4-6 provide **informative** guidance (data model examples, Deployment and Adoption)
- Appendices provide **informative** context (authorship, references)

### 1.2 Normative Language

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this document are to be interpreted as described in RFC 2119 and RFC 8174.

### 1.3 Model Conventions

Throughout this specification, indices denote execution hops. Terms subscripted with *i* (e.g., Hop_i, E_i, PCA_i, PCC_i, PoC_i) refer to the same execution hop. Predecessor and successor hops are denoted by *i-1* and *i+1* respectively.

Textual references such as "hop *i*" refer to the execution hop denoted formally as **Hop_i**.

---

## 2. Terminology

This section defines the core concepts and terms used throughout the PIC specification.

### 2.1 Trust Model

A verifiable mechanism for establishing non-repudiable binding between execution states.

A Trust Model MUST provide:

1. **Non-Forgeability**: Bindings cannot be fabricated, replayed, or transferred outside their causal context
2. **Causal Verification**: A successor state can be proven to derive from its predecessor
3. **Freshness**: Bindings are temporally bound to prevent replay attacks

Trust Models MAY be implemented via cryptographic primitives, hardware attestation, distributed consensus, or other mechanisms satisfying these requirements.

> **IMPLEMENTATION NOTE**: Systems implementing PIC MUST specify which Trust Model they employ.

### 2.2 Provenance Principal (p_0)

The immutable reference to the entity that initiated the transaction.
It serves as the provenance anchor from which all authority derives.

The provenance principal MAY be human, workload, or anonymous.
It MUST NOT change during the transaction.
Any attempt to alter `p_0` invalidates the execution chain.

### 2.3 Provenance Authority Set (ops_0)

The initial authority under which the transaction executes.
It defines the complete set of operations available at the start of the execution chain.

Each subsequent hop *i* operates with `ops_i ⊆ ops_{i-1}` (monotonic restriction).
Authority can only decrease or remain constant; it can never expand beyond `ops_0`.

**Critical Distinction**:

- `p_0` = WHO initiated the transaction (immutable)
- `ops_0` = WHAT operations are authorized (may be restricted at each hop)

### 2.4 Execution Hop (Hop_i)

A discrete execution step within a transaction.
It represents a single bounded execution context and forms the minimal unit of causal progression in PIC.

An execution hop is NOT a process, service, or container.
It is a logical unit whose validity is determined solely by its position in the provenance chain.

### 2.5 Executor (E_i)

An active entity responsible for performing computations at hop *i*.

Each Executor MUST:

1. **Preserve Origin**: Maintain immutable reference to `p_0`
2. **Operate Within Authority**: Execute only operations permitted by `ops_i`
3. **Demonstrate Continuity**: Provide valid Proof of Continuity (PoC_i)
4. **Bind to Environment**: Be verifiably bound to its execution context

An Executor MAY provide Executor Attestations (EA) with associated Proof of Possession (PoP).
These establish executor verification but DO NOT grant authority, alter `p_0`, or establish continuity.

Authority derives from causal execution state, not from executor identity or credential possession.

### 2.6 Executor Characteristic (EC_i)

A non-transferable property of an Executor bound to its execution context: TEE attestation, container identity, hardware measurements, network location, runtime namespace.

Executor Characteristics validate executor context, not authority.
They are inputs to continuity validation, not substitutes for it.

### 2.7 Provenance (P)

The ordered, non-forgeable history of execution hops and authority derivations that causally led to a given execution state.

Provenance includes: the complete chain from origin to current state, immutable `p_0`, authority evolution `ops_0 → ops_1 → ... → ops_i`, and contextual metadata.

### 2.8 Transaction (τ)

A causally linked sequence of execution hops forming a single logical operation.

In PIC, a "transaction" encompasses the entire execution from origin to completion—not merely database BEGIN/COMMIT semantics.
A transaction may span multiple services, administrative domains, hours of processing, or asynchronous flows.

All execution within a single transaction maintains causal continuity under the same `p_0` and derives authority from `ops_0`.

### 2.9 Causal Authority Transition (CAT)

The enforcement mechanism that validates PIC invariants.

The CAT:

1. Issues PIC Causal Challenges (PCC_i)
2. Verifies Proofs of Continuity (PoC_i)
3. Derives successor authority states (PCA_{i+1})

The CAT ensures:

- **Monotonicity**: `ops_{i+1} ⊆ ops_i`
- **Causal Binding**: Each hop is verifiably linked to its predecessor
- **Origin Preservation**: `p_0` is maintained throughout

The CAT is a logical mechanism.
It may be implemented in-process, externally, or implicitly by a runtime environment.

### 2.10 Federation Bridge

A component that translates external credentials into PCA_0.

The Federation Bridge:

- Validates external credentials (JWT, SVID, VP, X.509)
- Derives `p_0` and `ops_0` from credential claims
- Issues the initial PCA_0 that starts the transaction

Federation Bridge is the **entry point** to PIC. CAT handles **subsequent transitions** (PCA_i → PCA_{i+1}).

> **NOTE**: A single deployment MAY combine Federation Bridge and CAT in one component (e.g., API Gateway).

### 2.11 VC Bridge

A component that converts identity credentials (SVID, JWT, X.509) into portable Verifiable Credentials for cross-federation scenarios.

VC Bridge is NOT a Federation Bridge. It does not issue PCA—it issues VCs that can be presented to a Federation Bridge in another domain.

### 2.12 PIC Causal Authority (PCA_i)

The causally derived authority available to Executor E_i at hop *i*.

PCA_i MUST include:

1. **Origin Principal** (`p_0`): Immutable reference to transaction initiator
2. **Authority Set** (`ops_i`): Operations permitted at hop *i*, where `ops_i ⊆ ops_0`
3. **Executor Binding**: Verifiable binding to E_i
4. **Provenance**: Reference to the causal chain from `p_0` to hop *i*

PCA_i MAY include temporal, contextual, or resource constraints.

PCA_i is NOT a token or transferable artifact.
It is a state property of execution, derived from provenance continuity.

### 2.13 PIC Causal Challenge (PCC_i)

A freshness challenge issued by the CAT to require a Proof of Continuity from Executor E_i.

Purpose:

1. **Freshness Binding**: Prevents replay of continuity proofs
2. **Revocation Support**: Enables immediate invalidation of compromised executors

The challenge mechanism is RECOMMENDED but not strictly required.
Systems without challenges MUST implement alternative replay protection.

### 2.14 Proof of Continuity (PoC_i)

A non-forgeable proof produced by Executor E_i demonstrating:

1. **Valid Causal Continuation**: Execution at hop *i* derives from hop *i-1*
2. **Authority Bounds**: `ops_i ⊆ ops_{i-1}`
3. **Origin Preservation**: `p_0` is unchanged
4. **Challenge Response** (if issued): Valid response to PCC_i

PoC_i is **the fundamental primitive** that distinguishes PIC from possession-based models.

PoC_i cannot be replayed, transferred, reused, or forged.
It is bound to the specific hop, predecessor, executor, and origin.

### 2.15 Executor Attestation (EA)

A verifiable document that attests properties of an Executor: identity, environment, or capabilities.

Executor Attestations MAY include:

- **Identity credentials**: SPIFFE SVID, X.509 certificate, DID document
- **Verifiable presentations**: VP containing one or more VCs
- **Environment attestations**: TEE quotes, hardware measurements

Each Executor Attestation:

1. Contains or references the public key bound to the attested property
2. MAY require Proof of Possession to demonstrate control
3. Is validated by the CAT according to its type

Executor Attestations establish "who" or "what" the executor is.
They DO NOT: grant authority, establish continuity, prevent confused deputy, or satisfy PIC requirements alone.

> **NOTE**: The public key for signature verification is extracted from the attestation credential itself.
> No separate `key_material` field is required.

### 2.16 Proof of Possession (PoP)

A proof that demonstrates control over a credential presented in an Executor Attestation.

PoP is **per-attestation**: each attestation that requires holder binding includes its own proof of possession.

| Attestation Type | PoP Required? | Mechanism                              |
|------------------|---------------|----------------------------------------|
| SPIFFE SVID      | Yes           | Signature with certificate private key |
| VP (holder-bound)| No            | VP signature is implicit PoP           |
| TEE Quote        | No            | Hardware-bound, non-transferable       |
| JWT + DPoP       | Yes           | DPoP proof                             |
| Bearer token     | No            | No binding (insecure)                  |

PoP MUST sign contextual data (protected header + payload) to prevent replay and rebinding attacks.

PoP establishes credential control but does not provide causal continuity, authority derivation from origin, or monotonic restriction.

### 2.17 Authority Scope and Application Logic

An Executor MAY hold multiple authorities simultaneously:

- Its **own authority** (credentials, tokens, service identity)
- **Delegated authority** via PCA (derived from transaction origin)

These authorities are **orthogonal**. PIC governs only the delegated authority chain.

**What PIC enforces**:

- Operations validated by CAT respect `ops_i ⊆ ops_{i-1}`
- Origin `p_0` cannot change
- Authority cannot expand within the transaction

**What PIC does not enforce**:

- How an Executor uses its own authority outside the transaction
- What intermediate results an Executor generates internally
- Application logic correctness

**Example**:

```text
Bob has:
  - Own authority: {read: /sys/*}
  - Received PCA: p_0 = Alice, ops = {read: /user/*}

Scenario A (PIC blocked):
  Bob requests CAT to read /sys/syslog.txt under Alice's PCA
  CAT rejects: {read: /sys/*} ⊄ {read: /user/*}
  ✓ PIC enforced

Scenario B (Application bug):
  Bob reads /sys/syslog.txt using own authority (outside PCA)
  Bob includes result in response to Alice
  PIC not violated—CAT never saw the operation
  ✗ Application bug: Bob leaked privileged data

```

**Key Distinction**:

- **Protocol violation**: Attempting unauthorized ops through CAT → blocked
- **Application bug**: Using own authority to leak data → not PIC's scope

PIC guarantees that **authority flow through CAT** is correct.
PIC does not prevent an application from misusing its own resources.

> **CLARIFICATION**: If Bob uses privileged data (read with own authority) to construct a response for Alice, this is an application-level bug—not a confused deputy in the PIC sense.
> The confused deputy occurs when the **protocol** allows authority confusion. PIC makes that structurally impossible. Application logic errors remain the responsibility of the application.

### Realizability via Zero-Knowledge Proofs

**Example.** Proof of Relationship and Proof of Continuity may be realized using zero-knowledge proof systems, including but not limited to SNARKs, STARKs, Bulletproofs, or any equivalent zero-knowledge construction, in order to prove relational continuity without revealing the underlying relational state or history.

---

## 3. Architecture and Components

The PIC Model separates **untrusted execution** (Executors) from **trusted validation** (CAT).
This separation is fundamental to preventing confused deputy scenarios.

---

### 3.1 Core Components

#### 3.1.1 Executor

A computational entity that performs operations at a specific execution hop.

Executors MAY be trusted or untrusted depending on deployment.
Regardless of trust level, Executors **MUST NOT**:

- Self-assert authority
- Validate their own continuity proofs
- Expand authority beyond what is inherited

Executors **MUST** obtain authority validation through the CAT.

#### 3.1.2 Causal Authority Transition (CAT) / Trust Plane

The enforcement component that validates PIC invariants.

The CAT:

- MAY issue challenges (PCC_i) for freshness
- Validates Proofs of Continuity (PoC_i)
- Enforces monotonicity (`ops_{i+1} ⊆ ops_i`)
- Generates signed authority states (PCA_{i+1})
- MAY maintain revocation lists
- MAY consult Governance for policy constraints

> **CRITICAL PROPERTY**: The CAT has no application logic—only validation and generation.
> Validation of Executor Attestation and PoP formats is protocol-specific.

#### 3.1.3 Governance

An external layer that defines what is **currently permitted**.

Governance MAY be implemented via:

- Policy Decision Points (PDP)
- Pre-authorization artifacts (e.g., Verifiable Credentials)
- Revocation lists or status registries
- External policy engines

Governance applies constraints but cannot issue PCA, bypass CAT validation, or expand authority.

#### 3.1.4 Federation Bridge

Translates external credentials into PCA_0.

The Federation Bridge:

- Validates external credentials (JWT, SVID, VP, X.509)
- Derives `p_0` and `ops_0` from credential claims
- Issues signed PCA_0

Federation Bridge handles **entry**. CAT handles **transitions**.

> **NOTE**: Federation Bridge and CAT MAY be co-located in a single component.

---

### 3.2 Authority Flow

```text
E_{n-1}                         E_n                          E_{n+1}
   │                             │                              │
   │  ──── PCA_n ──────────────▶ │                              │
   │                             │                              │
   │                             │ (1) Request PCC_{n+1}        │
   │                             ├────────────▶ CAT             │
   │                             │ (2) Receive PCC_{n+1}        │
   │                             │◀────────────                 │
   │                             │ (3) Submit PoC + EA + PoP    │
   │                             ├────────────▶ CAT ──▶ Gov     │
   │                             │ (4) Receive PCA_{n+1}        │
   │                             │◀────────────                 │
   │                             │                              │
   │                             │  ──── PCA_{n+1} ───────────▶ │

```

**Flow**:

1. E_n receives PCA_n from predecessor
2. E_n requests challenge (PCC_{n+1}) from CAT
3. E_n constructs PoC_{n+1} (proving continuity) with Executor Attestations and per-attestation PoP
4. CAT validates all proofs under Trust Model, enforces monotonicity, MAY consult Governance
5. CAT generates and signs PCA_{n+1}
6. E_n executes with PCA_n, passes PCA_{n+1} to successor(s)

---

### 3.3 Deployment Models

The CAT MAY be deployed in different configurations depending on trust boundaries.

#### Centralized

```text
┌─────────────────────────────────────────┐
│              Trust Domain               │
│                                         │
│   E_{n-1} ───▶ E_n ───▶ E_{n+1}         │
│      │          │          │            │
│      └──────────┼──────────┘            │
│                 ▼                       │
│          ┌─────────────┐                │
│          │     CAT     │                │
│          └─────────────┘                │
└─────────────────────────────────────────┘

```

Single CAT service.
Typical for microservices, cloud-native applications.

#### Decentralized

```text
┌─────────────────────────────────────────┐
│        Decentralized Trust Plane        │
│                                         │
│   CAT_A ◀────▶ CAT_B ◀────▶ CAT_C       │
│     │           │           │           │
│  Consensus / Ledger / Blockchain        │
└─────────────────────────────────────────┘
       │           │           │
       ▼           ▼           ▼
      E_n         E_n         E_n

```

Distributed validation.
Typical for trustless environments, blockchain systems.

#### Federated

```text
┌─────────────────┐     ┌─────────────────┐
│  Trust Domain A │     │  Trust Domain B │
│                 │     │                 │
│  E_{n-1} ──PCA_n┼─────┼─▶ E_n           │
│     │           │     │     │           │
│     ▼           │     │     ▼           │
│   CAT_A ◀───────┼─────┼──▶ CAT_B        │
│                 │ Trust Model           │
└─────────────────┘ Verification          │
                        └─────────────────┘

```

Cross-domain execution.
CAT_B verifies PCA_n using CAT_A's Trust Model.

#### Embedded

CAT hosted within trusted Executors (TEE, IoT, service mesh).
Logical flow unchanged; deployment boundary collapsed.

---

### 3.4 Separation of Concerns

| Component      | Does                                                       | Cannot Do                                           |
|----------------|------------------------------------------------------------|-----------------------------------------------------|
| **Executor**   | Initiate transitions, construct PoC, execute within ops_i  | Forge PCA, expand authority, bypass CAT             |
| **CAT**        | Validate PoC, enforce monotonicity, sign PCA               | Be bypassed, grant authority without PoC            |
| **Governance** | Evaluate policies, apply constraints, revoke               | Issue PCA, replace CAT validation, expand authority |

Executors **initiate** and **exchange**. CAT **validates** and **signs**. Governance **constrains**.

No single untrusted component can compromise authority flow.

---

### 3.5 PIC and Governance

PIC enforces **structural invariants**:

- Origin immutability (`p_0` unchanged)
- Authority monotonicity (`ops_{i+1} ⊆ ops_i`)
- Executor continuity (valid PoC)
- Temporal and contextual bounds

PIC defines what **can never happen**: authority expansion, origin substitution, continuity forgery.

**Governance** defines what **is currently permitted**: revocation, policy changes, emergency stops, pre-authorization requirements.

| Layer          | Responsibility        | Characteristic                          |
|----------------|-----------------------|-----------------------------------------|
| **PIC**        | Structural continuity | Mandatory, invariant                    |
| **Governance** | Policy decisions      | Optional, cacheable, authority-reducing |

Governance sits **above** PIC:

- Governance MAY require pre-authorization before accepting a PoC
- Governance MAY terminate executions via revocation
- Governance MAY deny future continuations based on policy changes

These are governance decisions, not continuity violations.
PIC guarantees that **if** execution continues, it respects the invariants.
Governance decides **whether** execution may continue.

> **KEY DISTINCTION**: Continuity is structural and mandatory.
> Governance is policy and optional.
> Governance artifacts do not grant authority or reconstruct continuity—they gate execution.
> CAT validates PIC invariants; Governance constrains permissions.

---

## 4. Data Structures

This section defines data structures for PIC.
Examples are **informative**. Protocol encodings are defined in separate PIC Protocol specifications.

> **NOTE**: This section is **informative**. Field names, JSON structures, and table requirements describe recommended characteristics for interoperable implementations. They are not normative requirements of the PIC Model. Concrete field names, encodings, and serialization formats are defined in PIC Protocol specifications.

> **NOTE**: Identifiers in examples use HTTPS URLs for neutrality.  
> PIC is identifier-agnostic. Implementations MAY use DIDs, URNs, SPIFFE IDs, X.509 subjects, or any identifier scheme that satisfies the Trust Model requirements.  
> Concrete identifier formats are defined in PIC Protocol specifications.

---

### 4.1 PIC Causal Authority (PCA)

Authority state at execution hop *i*.

- PCA_0 MUST be signed by Federation Bridge
- PCA_{i>0} MUST be signed by CAT

**Recommended Characteristics**:

| Characteristic             | Requirement | Description                                             |
|----------------------------|-------------|---------------------------------------------------------|
| `alg`                      | Required    | Signature algorithm (in protected header)               |
| `kid`                      | Required    | Key identifier of signing entity (Federation Bridge or CAT) |
| `signature`                | Required    | Cryptographic signature over payload                    |
| `hop`                      | Required    | Position in causal chain (0 for PCA_0)                  |
| `p_0`                      | Required    | Immutable reference to origin principal                 |
| `ops`                      | Required    | Operation set (`ops_i ⊆ ops_{i-1}`)                     |
| `executor`                 | Required    | Binding for executing entity                            |
| `executor.binding`         | Required    | Executor identity (federation, namespace, service)      |
| `provenance`               | Required    | Causal chain reference (null for PCA_0)                 |
| `provenance.cat`           | Required    | Predecessor PCA kid and signature                       |
| `provenance.executor`      | Required    | Predecessor executor kid and signature                  |
| `constraints`              | Optional    | Bounds on PCA validity                                  |
| `constraints.temporal`     | Optional    | Time constraints (iat, exp, nbf)                        |
| `constraints.environment`  | Optional    | Contextual constraints                                  |

> **NOTE**: Concrete field names, encodings, and serialization formats are defined in PIC Protocol specifications.

**Example PCA_0 (INFORMATIVE)**:

The following JSON illustrates one possible encoding. This structure is non-normative.

```json
{
  "protected": {
    "alg": "EdDSA",
    "kid": "https://federation.example.com/keys/1"
  },
  "payload": {
    "hop": 0,
    "p_0": "https://idp.example.com/users/alice",
    "ops": ["read:/user/*", "write:/user/*"],
    "executor": {
      "binding": {
        "federation": "https://trust.example.com",
        "namespace": "prod",
        "service": "api-gateway"
      }
    },
    "provenance": null,
    "constraints": {
      "temporal": {
        "iat": "2025-12-11T10:00:00Z",
        "exp": "2025-12-11T11:00:00Z"
      },
      "environment": {
        "regions": ["eu-west-1"]
      }
    }
  },
  "signature": "base64url..."
}

```

**Example PCA_n (INFORMATIVE)**:

```json
{
  "protected": {
    "alg": "EdDSA",
    "kid": "https://cat.example.com/keys/1"
  },
  "payload": {
    "hop": 2,
    "p_0": "https://idp.example.com/users/alice",
    "ops": ["read:/user/*"],
    "executor": {
      "binding": {
        "federation": "https://trust.example.com",
        "namespace": "prod",
        "service": "service-a"
      }
    },
    "provenance": {
      "cat": {
        "kid": "https://cat.example.com/keys/1",
        "signature": "base64url..."
      },
      "executor": {
        "kid": "spiffe://trust.example.com/ns/prod/sa/api-gateway",
        "signature": "base64url..."
      }
    },
    "constraints": {
      "temporal": {
        "iat": "2025-12-11T10:00:00Z",
        "exp": "2025-12-11T11:00:00Z"
      }
    }
  },
  "signature": "base64url..."
}

```

**Key properties**:

- `hop`: Position in causal chain (immutable per PCA)
- `p_0`: Unchanged throughout chain (immutability)
- `ops`: Monotonically restricted (`ops_i ⊆ ops_{i-1}`)
- `provenance.cat`: Verifies predecessor PCA was legitimately issued
- `provenance.executor`: Verifies PoC was signed by authorized executor
- `constraints`: Monotonically restricted (⊆ predecessor constraints)

---

### 4.2 PIC Causal Challenge (PCC)

Freshness challenge issued by CAT. Structure is **protocol-specific**.

A PCC MUST provide:

1. **Freshness**: Prevent replay
2. **Binding**: Link to transition context
3. **Revocation**: Enable detection of revoked executors

---

### 4.3 Proof of Continuity (PoC)

Proof constructed by Executor, submitted to CAT.

PoC uses COSE_Sign1 structure with challenge in the protected header.

**Recommended Characteristics**:

| Characteristic                | Location         | Requirement | Description                                        |
|-------------------------------|------------------|-------------|----------------------------------------------------|
| `alg`                         | Protected header | Required    | Signature algorithm (e.g., EdDSA, ES256)           |
| `kid`                         | Protected header | Required    | Key identifier (SPIFFE ID, DID, URL, fingerprint)  |
| `challenge`                   | Protected header | If issued   | Response to PCC (nonce from CAT)                   |
| `predecessor`                 | Payload          | Required    | Full PCA received from predecessor                 |
| `successor`                   | Payload          | Required    | Proposed authority for next hop                    |
| `successor.ops`               | Payload          | Required    | Requested operations (⊆ predecessor.ops)           |
| `successor.executor`          | Payload          | Optional    | Next executor binding (if known)                   |
| `successor.constraints`       | Payload          | Optional    | Restricted constraints (⊆ predecessor.constraints) |
| `attestations`                | Payload          | Required    | Executor Attestations array                        |
| `attestations[].type`         | Payload          | Required    | Attestation type (spiffe_svid, vp, tee_quote, etc) |
| `attestations[].credential`   | Payload          | Required    | The credential (contains public key)               |
| `attestations[].pop`          | Payload          | If required | Proof of Possession for this attestation           |
| `signature`                   | COSE structure   | Required    | Signature over protected header + payload          |

> **NOTE**: Concrete field names and encodings are defined in PIC Protocol specifications.

**PoP binding**: Each `attestations[].pop` MUST sign `hash(protected_header + payload)` to bind the attestation to this specific PoC context. This prevents detachment and rebinding attacks.

**Validation rules for `successor`**:

- `ops_{i+1} ⊆ ops_i`
- `constraints_{i+1} ⊆ constraints_i` (temporal: exp ≤ prev.exp, nbf ≥ prev.nbf)
- `executor.binding` attributes ⊆ predecessor binding scope

**Example (INFORMATIVE)**:

The following illustrates one possible COSE_Sign1 encoding. This structure is non-normative.

```json
{
  "protected": {
    "alg": "EdDSA",
    "kid": "spiffe://trust.example.com/ns/prod/sa/service-a",
    "challenge": "abc123..."
  },
  "payload": {
    "predecessor": {
      "protected": {
        "alg": "EdDSA",
        "kid": "https://cat.example.com/keys/1"
      },
      "payload": {
        "hop": 1,
        "p_0": "https://idp.example.com/users/alice",
        "ops": ["read:/user/*", "write:/user/*"],
        "executor": {
          "binding": {
            "federation": "https://trust.example.com",
            "namespace": "prod",
            "service": "service-a"
          }
        },
        "provenance": {
          "cat": {
            "kid": "https://federation.example.com/keys/1",
            "signature": "base64url..."
          },
          "executor": {
            "kid": "spiffe://trust.example.com/ns/prod/sa/api-gateway",
            "signature": "base64url..."
          }
        },
        "constraints": {
          "temporal": {
            "iat": "2025-12-11T10:00:00Z",
            "exp": "2025-12-11T11:00:00Z"
          }
        }
      },
      "signature": "base64url..."
    },
    "successor": {
      "ops": ["read:/user/*"],
      "executor": {
        "binding": {
          "federation": "https://trust.example.com",
          "namespace": "prod"
        }
      },
      "constraints": {
        "temporal": {
          "exp": "2025-12-11T10:30:00Z"
        }
      }
    },
    "attestations": [
      {
        "type": "spiffe_svid",
        "credential": "base64url<X.509 certificate>...",
        "pop": "base64url<signature over hash(protected+payload)>..."
      },
      {
        "type": "vp",
        "credential": "base64url<Verifiable Presentation>..."
      },
      {
        "type": "tee_quote",
        "credential": "base64url<SGX/TDX quote>..."
      }
    ]
  },
  "signature": "base64url..."
}

```

> **NOTE**: In this example, `predecessor` is shown expanded for clarity.  
> PIC Protocol specifications MAY define compact representations (e.g., base64-encoded signed structure or hash reference).

**Key properties**:

- `protected.kid`: Identifies which key verifies the PoC signature (resolved from attestation)
- `protected.challenge`: Freshness binding, covered by signature
- `attestations[]`: Multiple attestations supported (identity, environment, capabilities)
- `attestations[].pop`: Per-attestation proof of possession, signs full context
- `attestations[].credential`: Contains public key for PoP verification
- `signature`: COSE signature over `protected || payload`, proves possession of key identified by `kid`

**CAT Verification Flow**:

```text
1. Parse protected header, extract kid and challenge
2. Locate attestation matching kid
3. Extract public key from attestation.credential
4. Verify PoC signature using extracted public key
5. For each attestation requiring PoP:
   a. Compute context_hash = hash(protected || payload)
   b. Extract public key from attestation.credential
   c. Verify attestation.pop against context_hash
6. Validate predecessor PCA signature
7. Enforce monotonicity: successor.ops ⊆ predecessor.ops
8. If challenge issued: verify protected.challenge matches PCC
9. If all valid → issue PCA_{i+1}

```

---

### 4.4 Protocol Encodings

This specification does not mandate encodings. PIC Protocol specifications MUST define:

1. Serialization (JSON, CBOR, etc.)
2. Signatures (JOSE, COSE, etc.)
3. CAT identifier format
4. Challenge-response mechanism
5. Wire format (HTTP, gRPC, etc.)
6. Executor Attestation and PoP validation rules

---

## 5. Transport, Communication, and Request Binding

This section defines transport and request binding requirements for PIC implementations.

> **INFORMATIVE**: Examples and mechanisms are non-normative. Concrete algorithms and encodings are defined in PIC Protocol specifications.

---

### 5.1 Overview

PIC requires two complementary protection layers:

| Layer             | Purpose                             | Requirement |
|-------------------|-------------------------------------|-------------|
| **Transport**     | Channel confidentiality & integrity | RECOMMENDED |
| **Request Binding**| Authority chain binding            | REQUIRED    |

Request binding is REQUIRED regardless of transport security.

---

### 5.2 Transport Security (INFORMATIVE)

Implementations SHOULD use secure transport (mTLS, encrypted messaging).

> **NOTE**: Without transport encryption, payload content may be visible. Request binding still prevents tampering and impersonation.

---

### 5.3 Request Binding (REQUIRED)

Every request MUST be cryptographically signed by the sending executor.

#### 5.3.1 Executor Key Binding

Executor keys are declared in PoC attestations and recorded in PCA provenance for chain verification:

| Location                          | Description                                    |
|-----------------------------------|------------------------------------------------|
| `PoC.protected.kid`               | Identifies signing key (SPIFFE ID, DID, etc.)  |
| `PoC.attestations[].credential`   | Contains public key for verification           |
| `PCA.provenance.executor.kid`     | Recorded from PoC for future chain verification|

**Key chain across hops**:

```text
PCA_0:  provenance = null (origin)
        
PoC_1:  protected.kid = "spiffe://...service-a"
        attestations[0].credential contains K_0
        
PCA_1:  provenance.executor.kid = "spiffe://...service-a"
        
PoC_2:  protected.kid = "spiffe://...service-b"
        attestations[0].credential contains K_1
        CAT verifies: K_1 matches authorized executor
        
PCA_2:  provenance.executor.kid = "spiffe://...service-b"
  ...

```

**Verification flow**:

1. Executor receives PCA_n
2. Executor creates PoC with `protected.kid` and matching attestation
3. CAT extracts public key from attestation credential
4. CAT verifies PoC signature using extracted public key
5. CAT verifies attestation PoP (if required) against `hash(protected + payload)`
6. CAT creates PCA_{n+1} with `provenance.executor.kid` from PoC

#### 5.3.2 Signature Requirements

| Element     | Purpose                  | Requirement |
|-------------|--------------------------|-------------|
| `payload`   | Prevents tampering       | Required    |
| `pca` hash  | Binds to authority chain | Required    |
| `timestamp` | Freshness validation     | Required    |
| `nonce`     | Replay protection        | Recommended |

#### 5.3.3 Verification

```text
1. Extract provenance.executor.kid from PCA
2. Resolve public key from kid (via attestation or key resolution)
3. Verify signature using public key
4. Check timestamp freshness
5. If valid → accept; if invalid → reject

```

---

### 5.4 Communication Flow (INFORMATIVE)

```text
E_{n-1}                              E_n                              E_{n+1}
   │                                  │                                  │
   │  ── signed_request + PCA_n ────▶ │                                  │
   │                                  │                                  │
   │                    (1) Verify signature (provenance.executor.kid).  │
   │                    (2) Validate PCA_n                               │
   │                    (3) Process request                              │
   │                                  │                                  │
   │                                  │  ── signed_request + PCA_{n+1} ─▶│
   │                                  │                                  │
   │                                  │         (1) Verify signature     │
   │                                  │         (2) Validate PCA_{n+1}   │
   │                                  │         (3) Process request      │

```

---

### 5.5 Security Comparison

| System         | Request Binding | Chain Binding | Interception Protection |
|----------------|-----------------|---------------|-------------------------|
| OAuth (bearer) | ✗ None          | ✗ None        | ✗ Vulnerable            |
| OAuth + DPoP   | ✓ Token↔Key     | ✗ None        | ◐ Single hop            |
| mTLS only      | ✗ None          | ✗ None        | ◐ Transport only        |
| Macaroons      | ◐ Caveats       | ◐ Partial     | ◐ Partial               |
| **PIC**        | ✓ Signature     | ✓ Full chain  | ✓ End-to-end            |
| **PIC + mTLS** | ✓ Signature     | ✓ Full chain  | ✓✓ Defense in depth     |

**Legend**: ✗ None | ◐ Partial | ✓ Full

---

### 5.6 Interception Attack Protection

**Scenario**: Attacker intercepts PCA_n

```text
1. Attacker intercepts PCA_n in transit
2. Attacker creates malicious request with intercepted PCA_n
3. Recipient extracts provenance.executor.kid from PCA_n
4. Recipient verifies signature → Attacker lacks private key → FAILS
5. Request REJECTED

✓ PCA possession insufficient without private key

```

---

### 5.7 PCA Key Binding Example (INFORMATIVE)

```json
{
  "protected": {
    "alg": "EdDSA",
    "kid": "https://cat.example.com/keys/1"
  },
  "payload": {
    "hop": 2,
    "p_0": "https://idp.example.com/users/alice",
    "ops": ["read:/user/*"],
    "executor": {
      "binding": {
        "federation": "https://trust.example.com",
        "namespace": "prod",
        "service": "service-b"
      }
    },
    "provenance": {
      "cat": {
        "kid": "https://cat.example.com/keys/1",
        "signature": "base64url..."
      },
      "executor": {
        "kid": "spiffe://trust.example.com/ns/prod/sa/service-a",
        "signature": "base64url..."
      }
    },
    "constraints": {
      "temporal": {
        "iat": "2025-12-11T10:00:00Z",
        "exp": "2025-12-11T10:30:00Z"
      }
    }
  },
  "signature": "base64url..."
}

```

**Verification**:

- `provenance.cat` → verifies PCA_1 was legitimately signed
- `provenance.executor` → verifies PoC_2 was signed by service-a
- `signature` → verifies this PCA_2 is authentic

---

### 5.8 Summary

```text
┌─────────────────────────────────────────────────────────────┐
│                    PIC Security Layers                      │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: Authority Chain    p_0 immutable, ops monotonic   │
│  Layer 2: Request Binding    Signature over payload + PCA   │
│  Layer 1: Transport          mTLS / Encrypted (optional)    │
└─────────────────────────────────────────────────────────────┘

```

> **DEFENSE IN DEPTH**: Each layer provides independent protection.

---

## 6. Deployment and Adoption

This section addresses deployment topologies, integration with existing authorization systems, validation strategies, and adoption considerations.

---

### 6.1 Computational Overhead

PIC validation overhead is at most equivalent to OAuth 2.0 Token Exchange (RFC 8693). Embedded CAT deployments (shared memory, TEE) eliminate network round-trips entirely:

| Operation               | OAuth Token Exchange | PIC CAT Validation    |
|-------------------------|----------------------|-----------------------|
| Request validation      | Required             | Required              |
| Credential verification | Required             | Required (EA+PoP)     |
| Policy evaluation       | Required             | Required (Governance) |
| Signature creation      | Required             | Required              |

---

### 6.2 Deployment Topologies

#### Federated (Public Internet)

Each organization operates its own Federation Bridge and CAT. Cross-domain trust established dynamically:

```text
┌─────────────────────────┐           ┌─────────────────────────┐
│      Organization A     │           │      Organization B     │
│                         │           │                         │
│  User → Fed Bridge_A    │           │       Fed Bridge_B      │
│              │          │           │            │            │
│              ▼          │           │            ▼            │
│           PCA_0         │           │         PCA_n           │
│              │          │           │            │            │
│        E_1 → E_2 ───────┼───────────┼─────────▶ E_3           │
│         │     │         │  public   │            │            │
│        CAT   CAT        │  internet │           CAT           │
│                         │           │                         │
│  Trust Plane A          │◀─────────▶│    Trust Plane B        │
│                         │  dynamic  │                         │
│                         │federation │                         │
└─────────────────────────┘           └─────────────────────────┘

```

**Characteristics**:

- Each organization operates independent Trust Plane
- Federation Bridges validate cross-domain PCAs via Trust Model verification
- No shared infrastructure required
- Dynamic trust establishment (VC exchange, DID resolution, mutual attestation)

**Cross-domain flow**:

1. User authenticates to Organization A
2. Federation Bridge_A issues PCA_0
3. Execution crosses to Organization B via public internet
4. Federation Bridge_B validates PCA_n signature against Trust Plane A
5. CAT_B issues PCA_{n+1} for local execution

> **NOTE**: Cross-domain PCA validation requires inter-organizational trust agreement (key exchange, VC issuance, or DID-based discovery).

#### Network-Internal (Trusted Zone)

Federation Bridge at entry, embedded CAT for internal transitions:

```text
                         ENTRY (once)
User → OAuth/OIDC → JWT → Federation Bridge issues PCA_0
                                   │
                         ──────────┼──────────────────
                                   │  INTERNAL
                                   ▼
                         ┌─────────────────────────┐
                         │  Trusted Zone (K8s/TEE) │
                         │                         │
                         │  E_1 ──→ E_2 ──→ E_3    │
                         │   │      │      │       │
                         │  CAT    CAT    CAT      │
                         │      (embedded)         │
                         │                         │
                         │ ZERO external IdP calls │
                         └─────────────────────────┘

```

#### Embedded (Shared Memory)

PCA transitions via memory copy, zero network overhead:

```text
┌─────────────────────────────────────┐
│       Embedded Device / IoT         │
│                                     │
│  ┌─────┐   ┌─────┐   ┌─────┐        │
│  │ E_1 │──▶│ E_2 │──▶│ E_3 │        │
│  │+CAT │   │+CAT │   │+CAT │        │
│  └─────┘   └─────┘   └─────┘        │
│      │         │         │          │
│      └─────────┴─────────┘          │
│         Shared Memory / Bus         │
└─────────────────────────────────────┘

```

#### IoT Ring (Local Network)

User presents VC, Federation Bridge issues PCA_0, PCA flows device-to-device:

```text
                     User arrives with VC
                              │
                              ▼
                       Federation Bridge
                       issues PCA_0
                              │
                              ▼
                ┌────────────────────────────┐
                │      IoT Local Network     │
                │                            │
                │   ┌───────┐    ┌───────┐   │
                │   │Device │───▶│Device │   │
                │   │  A    │    │  B    │   │
                │   │ +CAT  │    │ +CAT  │   │
                │   └───────┘    └───────┘   │
                │       ▲            │       │
                │       │            ▼       │
                │   ┌───────┐    ┌───────┐   │
                │   │Device │◀───│Device │   │
                │   │  D    │    │  C    │   │
                │   │ +CAT  │    │ +CAT  │   │
                │   └───────┘    └───────┘   │
                │                            │
                │   ZERO cloud round-trips   │
                └────────────────────────────┘

```

---

### 6.3 Validation Strategies

| Strategy                 | Pattern                                         | Use Case                    |
|--------------------------|-------------------------------------------------|-----------------------------|
| **Full** *(RECOMMENDED)* | `E_0 → [CAT] → E_1 → [CAT] → E_2 → [CAT] → E_3` | Cross-domain, high-security |
| **Selective**            | `E_0 → [CAT] → E_1 → E_2 → [CAT] → E_3`         | Trust boundaries only       |
| **Edge**                 | `[CAT] → E_0 → E_1 → E_2 → [CAT]`               | Entry + exit validation     |
| **Entry-Point**          | `[CAT] → E_0 → E_1 → E_2 → E_3`                 | Trusted environments        |

> **NOTE**: Between validations, PCA remains cryptographically signed—authority cannot expand.

---

### 6.4 Integration Patterns

#### OAuth 2.0

Federation Bridge validates JWT and issues PCA_0:

```text
User → OAuth AS → JWT → Federation Bridge issues PCA_0 → Executor chain

```

#### SPIFFE

Federation Bridge validates SVID and issues PCA:

```text
Workload → SPIFFE Server → SVID → Federation Bridge issues PCA_0 → Executor chain

```

#### DID / Verifiable Credentials

Federation Bridge validates VP and issues PCA_0:

```text
User → Wallet → VP → Federation Bridge issues PCA_0 → Executor chain

```

#### Cross-Federation: SPIFFE to VC

Workload exchanges SVID for VC via VC Bridge, then presents VC to Federation Bridge in another domain:

```text
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  Workload         VC Bridge         Federation Bridge    │
│  (Domain A)      (Domain A)           (Domain B)         │
│     │                  │                   │             │
│     │───── SVID ──────▶│                   │             │
│     │                  │                   │             │
│     │                  │ issues VC         │             │
│     │                  │                   │             │
│     │◀───── VC ────────│                   │             │
│     │                  │                   │             │
│     │─────────────── VC (as EA) ──────────▶│             │
│     │                  │                   │             │
│     │                  │      validates VC, issues PCA   │
│     │                  │                   │             │
│     │◀─────────────── PCA ─────────────────│             │
│                                                          │
└──────────────────────────────────────────────────────────┘

```

**Components**:

- **VC Bridge**: Converts identity credentials (SVID, JWT, X.509) into portable VCs
- **Federation Bridge**: Validates VCs (or other credentials) and issues PCA_0

#### API Gateway

Gateway acts as Federation Bridge, issues PCA_0, forwards to backend:

```text
Client → API Gateway (acts as Federation Bridge) → PCA_0 → Backend services

```

---

### 6.4.1 Identity Mapping Summary

| Source           | p_0 derivation | ops_0 derivation       | EA format   |
|------------------|----------------|------------------------|-------------|
| OAuth/OIDC       | `sub` claim    | `scope` claim          | JWT         |
| SPIFFE           | SPIFFE ID      | Trust domain policy    | SVID        |
| DID/VC           | DID URI        | VC claims              | VP          |
| X.509            | Subject DN     | Certificate extensions | Certificate |
| Cross-Federation | Original p_0   | VC claims              | VC          |

> **NOTE**: Regardless of source, PIC invariants apply: `p_0` immutable, `ops_i ⊆ ops_{i-1}`.

---

### 6.5 PIC Federation

#### 6.5.1 Overview

PIC Federation enables composition of multiple Trust Planes across security boundaries while preserving all PIC invariants.

Organizations can decompose monoliths into microservices, restructure internal boundaries, and evolve topology—without altering the security model. If bridge invariants hold, the mathematical guarantees hold.

Typical federated deployments operate two or more planes:

- **External Trust Plane**: federated, cross-organization, internet-facing, cryptographic verification at each hop
- **Internal Trust Plane**: enterprise-local, low latency, in-memory or embedded CAT

The boundary between planes is managed by **Ingress** and **Egress Bridges** that translate PCAs while preserving PIC invariants.

#### 6.5.2 Architecture

```text
EXTERNAL TRUST PLANE (federated / internet)
        │
        ▼ PCA_ext_in
   ┌─────────────┐
   │   INGRESS   │ ◄── validates PCA_ext_in against external CAT
   │   BRIDGE    │ ◄── issues PCA_int_0 under internal CAT
   └─────────────┘
        │
        ▼ PCA_int_0
┌─────────────────────────────────────────────────────┐
│         INTERNAL TRUST PLANE (enterprise)           │
│                                                     │
│    ┌───────────┐    ┌───────────┐    ┌───────────┐  │
│    │ Service A │───►│ Service B │───►│ Service C │  │
│    └───────────┘    └───────────┘    └───────────┘  │
│          │               │               │          │
│          └───────────────┴───────────────┘          │
│                          │                          │
│                    Internal CAT                     │
│              (in-memory / embedded / sidecar)       │
└─────────────────────────────────────────────────────┘
        │
        ▼ PCA_int_n
   ┌─────────────┐
   │   EGRESS    │ ◄── validates PCA_int_n against internal CAT
   │   BRIDGE    │ ◄── issues PCA_ext_out under external CAT
   └─────────────┘
        │
        ▼ PCA_ext_out
EXTERNAL TRUST PLANE (federated / internet)
```

#### 6.5.3 Bridge Invariants

Ingress and Egress Bridges MUST satisfy the following invariants to preserve PIC guarantees across trust plane boundaries.

| Invariant                  | Requirement                                                | Description                                                            |
|----------------------------|------------------------------------------------------------|------------------------------------------------------------------------|
| **Origin Preservation**    | `p_0(PCA_T₂) = p_0(PCA_T₁)`                                | Origin principal MUST remain identical. Silent substitution forbidden. |
| **Monotonicity**           | `ops(PCA_T₂) ⊆ ops(PCA_T₁)`                                | Authority can only decrease or remain constant.                        |
| **No Expansion**           | `∀(o,r): (o,r) ∈ ops(PCA_T₂) → (o,r) ∈ ops(PCA_T₁)`        | Bridges MUST NOT recreate, expand, or fabricate authority.             |
| **Provenance Continuity**  | `provenance(PCA_T₂)` references `PCA_T₁`                   | Causal chain MUST remain verifiable across the bridge.                 |

If all bridge transitions satisfy these invariants, the composed multi-plane system preserves PIC guarantees: `ops_final ⊆ ops_0` and confused deputy remains non-formulable across federated planes.

#### 6.5.4 Formal Model

Let `Π = {T_ext, T_int₁, T_int₂, ...}` be a set of Trust Planes.

Let `B: PCA_Tᵢ → PCA_Tⱼ` be a bridge function between planes.

A bridge function B is **valid** if and only if::

```text
B(PCA) = PCA' where:
  p_0(PCA') = p_0(PCA)
  ops(PCA') ⊆ ops(PCA)
  provenance(PCA') ⊇ provenance(PCA)
```

**Guarantee:** For any federated execution crossing multiple trust planes:

```text
ops(PCA_final) ⊆ ops(PCA_initial)
p_0(PCA_final) = p_0(PCA_initial)
```

The federation is transparent to PIC invariants.

#### 6.5.5 Refactoring-Invariant Security

Traditional systems couple security to topology. Decomposing a monolith into microservices requires security review, new threat models, and often weaker guarantees.

PIC Federation inverts this relationship:

| Traditional Approach                            | PIC Federation                                   |
|-------------------------------------------------|--------------------------------------------------|
| Topology change → Security review               | Topology change → Same security model            |
| Monolith → Microservices = new attack surface   | Monolith → Microservices = same invariants       |
| Security coupled to deployment                  | Security decoupled from deployment               |
| Refactoring breaks security assumptions         | Refactoring preserves security by construction   |

A security model is **refactoring-invariant** when:

```text
For any valid topological transformation T: Architecture₁ → Architecture₂
If Bridge Invariants hold:
  SecurityProperties(Architecture₁) = SecurityProperties(Architecture₂)
```

PIC Federation provides this property. Both a monolith and its microservices decomposition receive the same `PCA_ext_in`, preserve the same `p_0`, enforce `ops_i ⊆ ops_{i-1}` at every hop, and emit `PCA_ext_out` where `ops_ext_out ⊆ ops_ext_in`. The external trust plane observes identical security properties regardless of internal topology.

> **Practical Implication**: Architects can evolve system topology based on operational requirements without security team re-certification of the authorization model.

#### 6.5.6 Performance Model

The following are estimated order-of-magnitude values. Actual performance depends on deployment topology, hardware, network conditions, and CAT implementation.

| Operation              | External Trust Plane         | Internal Trust Plane                |
|------------------------|------------------------------|-------------------------------------|
| **CAT Validation**     | Network round-trip (1-100ms) | In-memory / embedded (< 200μs)      |
| **PCA Issuance**       | Cryptographic signing        | Cryptographic signing               |
| **Bridge Translation** | O(1)                         | O(1)                                |

Internal Trust Plane MAY be deployed as:

- **In-memory**: shared memory, zero network overhead
- **Embedded**: CAT co-located with executor (sidecar, library)
- **Enclave**: TEE-based CAT (SGX, TDX, SEV) for hardware-enforced isolation
- **Local network**: dedicated low-latency CAT cluster

Internal hops avoid external network latency. Only boundary crossings incur external CAT cost.

For an enterprise processing n internal hops:

```text
Traditional (external CAT per hop): n × RTT_external
PIC Federation: 2 × RTT_external + n × T_internal
```

| Scenario         | Traditional (n=100)      | PIC Federation (n=100)          |
|------------------|--------------------------|----------------------------------|
| RTT_ext = 10ms   | 100 × 10ms = **1000ms**  | 2 × 10ms + 100 × 0.1ms = **30ms**|
| RTT_ext = 50ms   | 100 × 50ms = **5000ms**  | 2 × 50ms + 100 × 0.1ms = **110ms**|

> **Result**: For 100 internal hops, PIC Federation reduces authorization latency by **~30-50x** compared to traditional per-hop external validation.

Where:

- `RTT_external` = external CAT round-trip (network-dependent)
- `T_internal` ≈ 116μs (in-memory CAT, measured on reference implementation)

#### 6.5.7 Deployment Models

| Model              | External CAT | Internal CAT      | Use Case                       |
|--------------------|--------------|-------------------|--------------------------------|
| **Single Plane**   | Centralized  | —                 | Simple deployments             |
| **Dual Plane**     | Federated    | Embedded/Sidecar  | Enterprise with partners       |
| **Multi Plane**    | Federated    | Multiple internal | Large enterprise, multi-region |
| **Nested Planes**  | Federated    | Hierarchical      | Multi-tenant, regulated        |

#### 6.5.8 Bridge Implementation

Bridges are typically implemented at:

- API Gateways (ingress)
- Edge proxies (ingress/egress)
- Service mesh boundaries
- Cloud interconnects

**Bridge Requirements:**

1. Validate incoming PCA against source trust plane
2. Verify PoC if required
3. Issue new PCA bound to destination trust plane
4. Preserve `p_0` and enforce `ops` monotonicity
5. Maintain provenance chain
6. Log translations for audit

#### 6.5.9 Example: Multi-Partner Enterprise Flow

```text
Partner A                         Enterprise                          Partner B
(Trust Plane A)              (Internal Trust Plane)               (Trust Plane B)
     │                                │                                  │
     │ PCA_A                          │                                  │
     │ p_0 = alice@partner-a          │                                  │
     │ ops = {read, write}            │                                  │
     ├───────────────────────────────►│                                  │
     │                        [Ingress Bridge]                           │
     │                                │                                  │
     │                          PCA_int_0                                │
     │                          p_0 = alice@partner-a                    │
     │                          ops = {read, write} ∩ {read} = {read}    │
     │                                │                                  │
     │                   ┌────────────┴────────────┐                     │
     │                   ▼                         ▼                     │
     │              Service X                 Service Y                  │
     │              ops = {read}              ops = {read}               │
     │                   │                         │                     │
     │                   └────────────┬────────────┘                     │
     │                                │                                  │
     │                          PCA_int_n                                │
     │                          p_0 = alice@partner-a                    │
     │                          ops = {read}                             │
     │                                │                                  │
     │                        [Egress Bridge]                            │
     │                                │                                  │
     │                                │ PCA_B                            │
     │                                │ p_0 = alice@partner-a            │
     │                                │ ops = {read}                     │
     │                                ├─────────────────────────────────►│

Invariants verified:
  ✓ p_0 preserved: alice@partner-a throughout
  ✓ ops monotonic: {read, write} → {read} → {read}
  ✓ No expansion: ops_B ⊆ ops_A
  ✓ Confused deputy: non-formulable across all planes
```

#### 6.5.10 Summary

> "Multiple Trust Planes can be composed by treating the enterprise boundary as a re-anchoring step: ingress/egress bridges re-bind the same p_0 and monotonically restrict ops, enabling low-latency internal continuity while preserving federated external continuity."

PIC Federation transforms authorization from a topology-coupled constraint into a topology-independent invariant.

---

### 6.6 Adoption Path

| Phase          | Actions                                                                             |
|----------------|-------------------------------------------------------------------------------------|
| **Assessment** | Identify confused deputy risks, map authorization flows, determine trust boundaries |
| **Pilot**      | Deploy Federation Bridge, integrate with OAuth/SPIFFE, validate at boundaries       |
| **Expansion**  | Extend to additional domains, increase validation frequency, implement revocation   |
| **Full**       | System-wide PIC enforcement, deprecate possession-based patterns                    |

---

### 6.7 AI Agents and Tool Orchestration

No new concepts. AI agents are executors. Tools are executors. PIC applies unchanged.

Agent calls tools, tools call APIs, authority only decreases:

```text
Alice (Human User)
  │
  │  PCA_0 (p_0 = Alice, ops_0) via Federation Bridge
  ▼
AI Agent A
  │
  │  PCA_1 ⊆ PCA_0
  ├──────────────────▶ Tool / API
  │
  │  PCA_2 ⊆ PCA_0
  └──────────────────▶ AI Agent B
                          │
                          │  PCA_3 ⊆ PCA_2
                          └────────▶ Tool / API

```

**What is a Tool?**

Any executor that validates PCA: external APIs, microservices, databases, OS services, cloud services, other AI agents.

**Why this matters**:

| Traditional AI Agents        | PIC AI Agents                 |
|------------------------------|-------------------------------|
| Execute with own credentials | Execute within user's `ops_0` |
| Ambient authority            | No independent authority      |
| Confused deputy possible     | Confused deputy impossible    |
| No origin traceability       | `p_0` immutable throughout    |

> **MENTAL MODEL**: AI agents are executors in a PIC transaction graph.
> If an API call is safe under PIC, an AI agent calling that API is equally safe.

---

## 7. Security Considerations

This section analyzes PIC's security properties, threat model, and attack resistance compared to possession-based systems.

---

### 7.1 Threat Model

**Trusted**: Federation Bridge, CAT, Trust Model, Governance

**Untrusted**: Executors, network, execution environments

**Attacker capabilities**: Eavesdropping, tampering, executor compromise, credential theft, replay

**Out of scope**: CAT compromise, cryptographic breaks, side-channels, social engineering

> **NOTE**: If VC Bridge is deployed for cross-federation credential conversion, it MUST also be trusted.

---

### 7.2 Confused Deputy Attack

The classic problem (Hardy, 1988): a privileged service uses its own authority on behalf of a less-privileged client.

**Scenario**: Alice (client) cannot read `/sys/*`. Bob (archive service) can.

```text
┌───────────────────────────────────────────────────────────────┐
│                         Actors                                │
├───────────────────────────────────────────────────────────────┤
│  Alice (Human User)                                           │
│    Authority (via OAuth): {read:/user/*, write:/user/*}       │
│                                                               │
│  Bob (Archive Service)                                        │
│    Own authority: {read:/sys/*, write:/sys/*}                 │
│                                                               │
│  Carol (Storage Service)                                      │
│    Executes ALL file operations strictly based on PCA         │
└───────────────────────────────────────────────────────────────┘

```

**Token-Based (VULNERABLE)**:

Alice exploits Bob's elevated authority:

```text
1. Alice sends: process("/sys/syslog.txt", "my content")
2. Bob uses OWN credentials to call Carol
3. Carol checks Bob's token: can read /sys/*? Yes.
4. Carol reads /sys/syslog.txt (system secrets)
5. Alice receives output containing system secrets

✗ CONFUSED DEPUTY

```

**PIC Model (IMMUNE)**:

Authority bound to origin, Bob's privileges don't exist in Alice's transaction:

```text
1. Gateway (as Federation Bridge) issues PCA_0: p_0 = Alice, ops_0 = {read:/user/*, write:/user/*}
2. Bob receives PCA_1 (p_0 = Alice, ops_1 ⊆ ops_0)
3. Alice sends: process("/sys/syslog.txt", "my content")
4. Carol validates: {read:/sys/*} ⊆ {read:/user/*, write:/user/*}? NO
5. Read blocked. Alice receives only her own content.

✓ IMMUNE

```

Authority scoped to transaction origin:

| Transaction Origin    | read /user/* | read /sys/* | write /user/* |
|-----------------------|--------------|-------------|---------------|
| Bob (own transaction) | ✗            | ✓           | ✗             |
| Alice (via PCA)       | ✓            | ✗           | ✓             |

---

### 7.3 Attack Comparison Summary

| Attack                    | Token-Based              | PIC          | Mechanism                           |
|---------------------------|--------------------------|--------------|-------------------------------------|
| **Confused Deputy**       | ✗ Vulnerable             | ✓ Immune     | Authority from origin, not executor |
| **Token Theft**           | ✗ Possession = authority | ✓ Resistant  | Executor binding mismatch           |
| **Privilege Escalation**  | ✗ No monotonicity        | ✓ Immune     | `ops_{i+1} ⊆ ops_i` enforced        |
| **Ambient Authority**     | ✗ Service uses own token | ✓ Immune     | Authority scoped to `ops_0`         |
| **Token Substitution**    | ✗ No chain verification  | ✓ Immune     | PoC binds to previous PCA           |
| **Replay**                | ✗ Valid until expiry     | ✓ Resistant  | Challenge + temporal binding        |
| **Credential Forwarding** | ✗ Unrestricted           | ✓ Controlled | CAT validation per hop              |
| **Impersonation**         | ✗ Possession = identity  | ✓ Resistant  | EA must match binding               |
| **MITM Modification**     | △ Depends on JWT sig     | ✓ Immune     | Bundle signature required           |
| **Revocation Delay**      | ✗ Valid until expiry     | ✓ Responsive | Checked at next hop                 |

**Legend**: ✗ Vulnerable | △ Depends | ✓ Resistant/Immune

---

### 7.4 Residual Risks

| Risk                             | Mitigation                                                      |
|----------------------------------|-----------------------------------------------------------------|
| **Federation Bridge Compromise** | HSM/TEE deployment, credential validation hardening, monitoring |
| **CAT Compromise**               | HSM/TEE deployment, distributed CAT, monitoring                 |
| **Trust Model Weakness**         | Battle-tested crypto, agility, post-quantum readiness           |
| **Denial of Service**            | Rate limiting, batching, distributed CAT                        |
| **Policy Misconfiguration**      | Testing, formal verification, least-privilege defaults          |

---

### 7.5 Security Design Principles

1. **Least Privilege**: Authority monotonically decreases
2. **Separation of Concerns**: Untrusted execution / trusted validation
3. **Defense in Depth**: PoC + EA + PoP + Governance
4. **Fail-Safe Defaults**: Rejected unless authorized
5. **Complete Mediation**: CAT validates every transition
6. **Audit Trail**: Complete provenance tracking
7. **Revocation**: Immediate at next hop

---

### 7.6 Formal Security Properties

| Property                          | Statement                                           |
|-----------------------------------|-----------------------------------------------------|
| **Origin Immutability**           | ∀i: `p_i = p_0`                                     |
| **Authority Monotonicity**        | ∀i: `ops_i ⊆ ops_{i-1}`                             |
| **Confused Deputy Impossibility** | ∀E_i: cannot exercise `ops_j` where `ops_j ⊄ ops_i` |
| **Causal Provenance**             | ∀PCA_i: ∃ chain `PCA_0 → ... → PCA_i`               |
| **Non-Transferability**           | ∀PCA_i: bound to E_i, unusable by E_j               |

**Formal Proof**: See [[1]](#references)

---

## Appendix A. Use of Automated Language Assistance

The PIC Specification has used automated language assistance tools solely to improve grammar, clarity, and phrasing. All substantive technical content and editorial decisions remain the responsibility of the PIC Spec Contributors under the stewardship of Nitro Agility S.r.l.

---

## Appendix B. Authorship, Stewardship, Attribution, and Derivative Works

### B.1 Scope and Roles

This appendix defines the separation between:

- the **PIC Model** (theoretical framework and foundational results), and
- the **PIC Specification** (this document: terminology, normative requirements, structure, examples, and maintenance process).

This separation is intentional and MUST be preserved in references, derivative works, and claims of conformance.

---

### B.2 PIC Model — Authorship (Theoretical Framework)

The **Provenance Identity Continuity (PIC) Model**, including its formal definitions, invariants, execution semantics, and foundational proofs (including the structural resolution of the confused deputy class under the PIC assumptions), originates from the original theoretical work of **Nicola Gallo**.

Authorship of the PIC Model is independent of repository ownership, maintainer status, stewardship of the specification, or any publishing entity.

Primary references for the PIC Model include:

- Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. DOI: 10.5281/zenodo.17833000  
- Gallo, N. (2025). *Authority is a Continuous System*. Zenodo. DOI: 10.5281/zenodo.17860199  
- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Zenodo. DOI: 10.5281/zenodo.17777421  

---

### B.3 PIC Specification — Stewardship, Publication, and Canonical Status

This document (the **PIC Specification**) is authored, developed, published, maintained, and stewarded by:

**Nitro Agility S.r.l.** (the "Specification Steward")

All normative text of this PIC Specification — including structure, terminology, requirements, examples, editorial content, and all subsequent edits incorporated into the canonical version — is produced and maintained under the stewardship of Nitro Agility S.r.l.

The Specification Steward is responsible for:

- publication and maintenance of the PIC Specification,
- editorial decisions and normative text,
- contribution review and acceptance,
- release management and designation of canonical versions,
- specification governance and process.

The canonical PIC Specification is the version designated by the Specification Steward in the official PIC Spec repositories.

---

### B.4 License

The PIC Model references and this PIC Specification are published under the **Creative Commons Attribution 4.0 International (CC BY 4.0)** license.

CC BY 4.0 governs copyright and redistribution only.  
It does not imply any warranty, support obligation, operational responsibility, or professional services.

---

### B.5 Mandatory Attribution and Correct Referencing

Any academic, technical, or commercial work that references, implements, or claims conformance with PIC MUST clearly distinguish between:

1. **The PIC Model (theoretical framework)**  
   **Author:** Nicola Gallo

2. **The PIC Specification (this document)**  
   **Publisher and Steward:** Nitro Agility S.r.l.

A compliant reference MUST acknowledge both roles.

**Example attribution (acceptable):**

> "Based on the Provenance Identity Continuity (PIC) Model created by Nicola Gallo.  
> Conforms to the PIC Specification published and maintained by Nitro Agility S.r.l."

Attribution MUST NOT:

- omit the PIC Model author when referencing the PIC Model, or
- attribute the PIC Model's foundational concepts and proofs to parties other than its author, or
- represent a fork or derivative as the canonical PIC Specification without Steward designation.

---

### B.6 Derivative Works, Forks, and Implementations

Derivative works (modified specifications, extensions, profiles, or adaptations):

- MUST clearly state they are **derivative works** of the PIC Specification,
- MUST preserve the attribution requirements in B.5,
- SHOULD document any substantive semantic or security-relevant changes,
- MUST NOT claim to be the canonical PIC Specification unless explicitly designated by the Specification Steward.

Implementations (software libraries, SDKs, middleware, gateways, services):

- MAY claim authorship of the implementation code,
- MUST NOT claim authorship of the PIC Model's foundational concepts, invariants, or proofs.

---

### B.7 Contributors and Responsibility Boundaries

#### B.7.1 PIC Spec Contributors

"PIC Spec Contributors" are individuals or organizations that contribute text, reviews, examples, or discussion to the PIC Specification repositories.

Contributions by **Nicola Gallo**, **Antonio Radesca**, and **any other employee, associate, contractor, or co-founder of Nitro Agility S.r.l.** to the PIC Specification are made **on behalf of Nitro Agility S.r.l.**, and **not in a personal capacity**. All such contributions are incorporated as part of the Nitro Agility–stewarded specification.

For avoidance of doubt: where Nicola Gallo contributes to the PIC Specification repositories, he does so as a representative of Nitro Agility S.r.l. for purposes of the specification text and its maintenance. This does not alter or diminish his independent authorship of the underlying **PIC Model**.

**Contribution does not imply:**

- authorship of the PIC Model, or
- acceptance of operational responsibility, warranty, or liability for the PIC Specification.

The Specification Steward (Nitro Agility S.r.l.) retains full editorial and governance control over what becomes normative in the PIC Specification.

#### B.7.2 External Contributors

External contributors (i.e., contributors not acting on behalf of Nitro Agility S.r.l.) contribute on an "as-is" basis.

External contributors:

- do not become stewards, publishers, or operators by contributing,
- do not provide warranties or professional advice,
- are not responsible for maintenance, release management, or governance of the PIC Specification.

Operational and editorial responsibility for the PIC Specification remains with the Specification Steward.

---

### B.8 Credits

**PIC Model Author (Theoretical Framework):**

- **Nicola Gallo** (in personal capacity)

**PIC Specification Steward / Publisher:**

- **Nitro Agility S.r.l.**

**PIC Spec Contributors (non-exhaustive, in order of appearance):**

1. **Nicola Gallo (on behalf of Nitro Agility S.r.l.)** — contributor to specification text and examples  
2. **Nitro Agility S.r.l.** — specification stewardship, editorial maintenance, governance  
3. *Add your name here via pull request (individual or organization)*

---

### B.9 Stewardship Transfer

Stewardship of the PIC Specification MAY be transferred by Nitro Agility S.r.l. to another organization.

Such a transfer does not affect:

- authorship of the PIC Model (Nicola Gallo),
- the CC BY 4.0 license terms,
- the attribution requirements defined in this appendix.

The new steward (if any) becomes the Specification Steward for canonical designation and maintenance of the PIC Specification.

---

## Appendix C. Disclaimer and Limitation of Liability

THIS SPECIFICATION IS PROVIDED **"AS IS" AND "AS AVAILABLE"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.

THIS SPECIFICATION **DOES NOT GUARANTEE SECURITY, CORRECTNESS, OR FITNESS FOR ANY PARTICULAR IMPLEMENTATION OR DEPLOYMENT CONTEXT**.  
SECURITY, SAFETY, AND CORRECT BEHAVIOR DEPEND ENTIRELY ON PROPER IMPLEMENTATION, CONFIGURATION, AND OPERATION.

IN NO EVENT SHALL THE AUTHORS, CONTRIBUTORS, ACKNOWLEDGED INDIVIDUALS, OR COPYRIGHT HOLDERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL, OR PUNITIVE DAMAGES (INCLUDING BUT NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, LOSS OF USE, DATA, PROFITS, OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SPECIFICATION, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

USE OF THIS SPECIFICATION, INCLUDING ANY CLAIMS OF CONFORMANCE OR COMPATIBILITY, **DOES NOT IMPLY ENDORSEMENT** BY THE AUTHORS OR PIC SPEC CONTRIBUTORS UNLESS EXPLICITLY STATED IN WRITING.

IMPLEMENTERS AND USERS ASSUME **ALL RISKS** ASSOCIATED WITH THE USE OF THIS SPECIFICATION AND ANY IMPLEMENTATIONS OR DERIVATIVE WORKS BASED UPON IT.

THIS DISCLAIMER SHALL BE GOVERNED BY AND CONSTRUED IN ACCORDANCE WITH APPLICABLE LAW, WITHOUT REGARD TO CONFLICT OF LAW PRINCIPLES.

IF ANY PROVISION OF THIS DISCLAIMER IS HELD TO BE UNENFORCEABLE, THE REMAINING PROVISIONS SHALL CONTINUE IN FULL FORCE AND EFFECT.

THE AUTHORS AND CONTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, PATCHES, OR CORRECTIONS.

THIS SPECIFICATION DOES NOT CONSTITUTE LEGAL, SECURITY, OR PROFESSIONAL ADVICE.

### Responsibility and Legal Context

This specification is published and maintained by **Nitro Agility S.r.l.** as the **Specification Steward**.

Nothing in this document creates a contractual relationship between any **individual contributor** and any user of this specification.  
No duty of care is assumed or created by publication of this document.

To the **maximum extent permitted by applicable law**, any claims, disputes, or legal actions arising from:

- the use of this specification,
- any claim of conformance, compatibility, or derivation from PIC,
- any implementation, deployment, product, or service that references or relies on this specification,

should be directed to the **Specification Steward (Nitro Agility S.r.l.)** and/or the relevant **implementer**, as applicable.

For avoidance of doubt, implementers and operators remain solely responsible for their own implementations, deployments, products, services, security, and compliance claims.

### Exclusion of Personal Liability (PIC Model Author)

**Nicola Gallo**, as the author of the underlying **PIC Model** (theoretical framework), is recognized solely for **academic authorship** of that theoretical work.

This recognition does **not**:

- create any personal liability for this specification or its use,
- create any warranty, support, maintenance, or professional services obligation,
- create any contractual, fiduciary, advisory, or professional relationship with users,
- constitute endorsement of this specification or of any implementation or deployment.

To the maximum extent permitted by applicable law, **Nicola Gallo** disclaims all liability for any loss or damages arising from the use of this specification or from any implementation, deployment, product, or service based on it.

The PIC Model author's role is strictly limited to authorship of academic publications referenced by this specification.  
All operational, legal, and commercial responsibility for this specification rests with the **Specification Steward (Nitro Agility S.r.l.)**, and for implementations with their respective **implementers/operators**.

---

## Appendix D. Acknowledgements

The PIC Model author thanks the following individuals for discussions and feedback during the development of the theoretical framework.

### D.1 Acknowledged Individuals

- **Alan Karp** — for rigorous analysis and critical feedback on authority propagation semantics that helped stress-test the theoretical model's formal properties.

### D.2 Scope and Limitations of Acknowledgement

Acknowledgement in this appendix:

1. **Recognizes informal contribution** to early-stage theoretical discussions only
2. **Does NOT imply**:
   - co-authorship of the PIC Model
   - co-authorship of this PIC Specification
   - contribution to the PIC Specification text, structure, or normative content
   - endorsement of the PIC Model, PIC Specification, or any implementation
   - affiliation with the Specification Steward (Nitro Agility S.r.l.)
   - any ongoing involvement or advisory role
3. **Does NOT create**:
   - any legal, contractual, or fiduciary relationship
   - any responsibility for errors, omissions, or defects in the PIC Model or PIC Specification
   - any liability for implementations, deployments, or uses of this specification
   - any obligation to provide support, maintenance, or updates

### D.3 Disclaimer for Acknowledged Individuals

ACKNOWLEDGED INDIVIDUALS ARE RECOGNIZED SOLELY FOR INFORMAL DISCUSSIONS RELATED TO THE THEORETICAL PIC MODEL.

THEY BEAR **NO RESPONSIBILITY** FOR:

- the correctness, completeness, or security of the PIC Model,
- the content, accuracy, or fitness of this PIC Specification,
- any implementation, deployment, or use based on this specification,
- any claims, damages, or liabilities arising from the PIC Model or PIC Specification.

ACKNOWLEDGEMENT IS **INFORMATIONAL ONLY** AND SHALL NOT BE CONSTRUED AS CREATING ANY LEGAL OBLIGATION, WARRANTY, OR LIABILITY ON THE PART OF ACKNOWLEDGED INDIVIDUALS.

Any claims, disputes, or legal actions related to the **PIC Specification** or any implementation, deployment, or use thereof  
MUST be directed exclusively to the **Specification Steward (Nitro Agility S.r.l.)**.

Any reference to the **original theoretical PIC Model** is made solely in its capacity as an **academic work of authorship**.  
The PIC Model is provided **for scholarly and informational purposes only**, and **creates no warranty, duty of care, or legal obligation of any kind** toward any third party.

To the **maximum extent permitted by applicable law**, the PIC Model author **disclaims all liability** for any claim, loss, or damages arising from any specification, implementation, deployment, product, service, security outcome, or commercial use that references or relies on this specification or the PIC Model, **whether framed in contract, tort, negligence, strict liability, or any other theory of liability**.

Accordingly, responsibility for any such claims rests with the **Specification Steward** and/or the relevant **implementer or operator**, as applicable.

Acknowledged individuals are explicitly excluded from **all** such claims.

---

## References

- [1] Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [2] Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)
- [3] Gallo, N. (2025). *Authority is a Continuous System. (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17860199](https://doi.org/10.5281/zenodo.17860199)
