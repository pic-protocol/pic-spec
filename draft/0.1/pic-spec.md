# Provenance Identity Continuity (PIC) Model Specification

**Version:** 1.0-draft  
**Date:** December 2025  
**Author:** Nicola Gallo

---

## Abstract

This specification defines the **Provenance Identity Continuity (PIC) Model**, an execution model that eliminates confused deputy vulnerabilities through verifiable causal continuity rather than artifact possession.

The PIC Model enforces that authority is derived from execution provenance, not from possession of credentials or tokens. Each execution hop maintains:
1. **Origin Immutability**: The initiating subject (`p_0`) remains constant throughout the transaction
2. **Authority Monotonicity**: Authority can only decrease or remain constant (`ops_i ⊆ ops_{i-1}`)
3. **Causal Binding**: Each hop is verifiably linked to its predecessor via a Trust Model
4. **Continuity Validation**: Transitions satisfy executor continuity requirements

The origin subject (`p_0`) may be a human user (authenticated via OAuth, SAML, OIDC, VC), a service/workload (identified via DID, SPIFFE, X.509), or anonymous (capability-based). The origin authority (`ops_0`) may derive from identity-based grants, capability tokens, or hybrid models.

As proven in "Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem" [[1]](#references), the confused deputy problem is structurally impossible in PIC-compliant systems—it cannot be formulated, not merely prevented.

**Trust Model Note**: This specification uses "cryptographic" as shorthand for "based on a Trust Model." Trust Models MAY be implemented via cryptographic primitives, hardware attestation, distributed consensus, or other mechanisms providing non-repudiable binding. The specific Trust Model is implementation-specific.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Terminology](#2-terminology)
3. [Architecture and Components](#3-architecture-and-components)
4. [Normative Data Structures and Processing Logic](#4-normative-data-structures-and-processing-logic)
5. [Adoption and Implementation Considerations](#5-adoption-and-implementation-considerations)
A. [Appendix A – Use of Automated Language Assistance](#appendix-a-use-of-automated-language-assistance)  
B. [Appendix B – Authorship, Attribution, and Derivative Works](#appendix-b-authorship-attribution-and-derivative-works)
R. [References](#references)

---

## 1. Introduction

### 1.1 Scope

This specification defines the Provenance Identity Continuity (PIC) Model for distributed execution systems. The PIC Model establishes causal invariants that MUST hold for any execution to be considered valid under its principles.

The PIC Model does not prescribe system architecture, deployment topology, trust boundaries, or specific protocol implementations. Instead, it defines execution semantics and causal invariants that eliminate confused deputy conditions by construction.

### 1.2 Normative Language

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this document are to be interpreted as described in RFC 2119 and RFC 8174.

### 1.3 Model Conventions

Throughout this specification, indices denote execution hops. Terms subscripted with *i* (e.g., Hop_i, E_i, PCA_i, PCC_i, PoC_i) refer to the same execution hop. Predecessor and successor hops are denoted by *i-1* and *i+1* respectively.

Textual references such as "hop *i*" refer to the execution hop denoted formally as **Hop_i**.

---

## 2. Terminology

### 2.1 Trust Model

A verifiable mechanism for establishing non-repudiable binding between execution states. A Trust Model MUST provide:

1. **Non-Forgeability**: Bindings cannot be fabricated, replayed, or transferred outside their causal context
2. **Causal Verification**: A successor state can be proven to derive from its predecessor
3. **Freshness**: Bindings are temporally bound to prevent replay attacks

Trust Models MAY be implemented via:
- Cryptographic primitives (signatures, MACs, hash chains)
- Hardware security modules (TPM, TEE, SGX)
- Distributed consensus mechanisms (blockchain, DAG)
- Zero-knowledge proof systems
- Quantum-resistant schemes
- Other mechanisms satisfying the three requirements

**Implementation Note**: Systems implementing PIC MUST specify which Trust Model they employ and demonstrate it satisfies the three requirements above.

### 2.2 Origin Subject (p_0)

The immutable reference to the entity that initiated the distributed transaction. The origin subject MUST remain constant throughout the entire execution chain and serves as the provenance anchor.

The origin subject MAY be:

**Human User** - Authenticated via:
- OAuth 2.0 / OpenID Connect
- SAML 2.0
- Verifiable Credentials (W3C VC)
- WebAuthn / FIDO2
- Certificate-based authentication
- Other identity protocols

**Service/Workload** - Identified via:
- Decentralized Identifiers (DID)
- SPIFFE ID
- X.509 certificates
- Service identity systems
- Other workload identity mechanisms

**Anonymous Origin**:
- Capability token hash
- Privacy-preserving identifier
- Anonymous credential system

**Critical Invariant**: Regardless of whether `p_0` is human, workload, or anonymous, it MUST NOT change during the transaction. Any attempt to alter `p_0` invalidates the execution chain.

**Examples:**
- Human (OIDC): `p_0 = sub:248289761001`
- Human (SAML): `p_0 = urn:saml:user:alice@example.com`
- Workload (SPIFFE): `p_0 = spiffe://trust-domain.com/workload/api`
- Workload (DID): `p_0 = did:web:api.example.com`
- Anonymous: `p_0 = cap:sha256:a3f5b9...`

### 2.3 Origin Authority Set (ops_0)

The initial authority under which the transaction executes at its origin. The origin authority set defines the complete set of operations available at the start of the execution chain.

Authority MAY derive from:

1. **Identity-Based Grants**: Permissions associated with the origin subject's identity
   - User roles and permissions (RBAC)
   - User attributes (ABAC)
   - Group memberships
   - Organizational roles

2. **Capability-Based Grants**: Authority conveyed through capability tokens
   - Capability tokens
   - Delegated credentials
   - Ambient authority

3. **Hybrid Models**: Combinations of the above
   - Identity-based roles intersected with capability constraints
   - Contextual restriction of role-based grants

**Authority Propagation**: Each subsequent hop *i* operates with `ops_i ⊆ ops_{i-1}` (monotonic restriction). Authority can only decrease or remain constant; it can never expand beyond `ops_0`.

**Critical Distinction**:
- `p_0` (origin subject) = WHO initiated the transaction (immutable)
- `ops_0` (origin authority) = WHAT operations are authorized (may be restricted at each hop)

**Examples:**
- Human with roles: `ops_0 = {read:/home/alice/*, write:/home/alice/docs/*, execute:/bin/gcc}`
- Service with role: `ops_0 = {read:/config/*, write:/logs/*, invoke:service-b}`
- Capability-based: `ops_0 = {execute:contract:0x123, transfer:token:XYZ}`
- Hybrid: `ops_0 = role_grants(p_0) ∩ capability_grants(token)`

### 2.4 Execution Hop (Hop_i)

A discrete execution step within a distributed transaction, representing a single bounded execution context in which an Executor operates. An execution hop forms the minimal unit of causal progression in PIC and is uniquely positioned in the provenance chain by its immediate causal predecessor and successor.

An execution hop is NOT a process, service, or container; it is a logical unit of execution whose validity is determined solely by its position in the provenance chain.

### 2.5 Executor (E_i)

An active execution entity responsible for performing computations at hop *i*. An Executor acts within a bounded execution context and participates in causal authority transitions.

Each Executor MUST:
1. **Preserve Origin**: Maintain immutable reference to origin subject `p_0`
2. **Operate Within Authority**: Execute only operations permitted by `ops_i` (where `ops_i ⊆ ops_0`)
3. **Demonstrate Continuity**: Provide valid Proof of Continuity (PoC_i) establishing causal derivation from hop *i-1*
4. **Bind to Environment**: Be verifiably bound to its execution environment

An Executor MAY provide:
- **Proof of Identity (PoI)**: Establishes executor's own identity
- **Proof of Possession (PoP)**: Demonstrates control over credentials or secrets

**Critical Distinction**:
- **Executor Identity**: WHO is performing computation at hop *i* (the service/workload executing code)
- **Origin Subject** (`p_0`): WHO initiated the transaction (immutable throughout)
- **Authority** (`ops_i`): WHAT operations executor may perform (derived from `ops_0`)

PoI and PoP establish executor verification but DO NOT:
- Grant authority beyond `ops_i`
- Alter origin subject `p_0`
- Establish execution continuity (requires PoC)
- Satisfy PIC requirements

Authority in PIC derives from causal execution state and provenance, not from executor identity or credential possession.

**Example Flow:**

```text
Origin: p_0 = alice@example.com (human via OIDC)
        ops_0 = {read:*, write:/home/alice/*}

Hop 1: E_1 = spiffe://trust/api-gateway
       ops_1 = {read:*, write:/home/alice/*}
       (inherits full ops_0)
       
Hop 2: E_2 = spiffe://trust/backend  
       ops_2 = {read:*}
       (restricted: removed write authority)
       
Hop 3: E_3 = did:web:processor.example.com
       ops_3 = {read:*}
       (MUST be ⊆ ops_2, cannot expand back to include write)

Throughout: p_0 = alice@example.com (immutable)
Monotonicity: ops_3 ⊆ ops_2 ⊆ ops_1 ⊆ ops_0
```

**Counter-Example (Invalid):**

```text
Origin: ops_0 = {read:*, write:/home/alice/*}

Hop 1: ops_1 = {read:*, write:/home/alice/*}
Hop 2: ops_2 = {read:*}  (restricted)
Hop 3: ops_3 = {read:*, write:/home/alice/public/*}  ❌ INVALID

Violation: ops_3 ⊄ ops_2
Reason: Once write authority is removed at hop 2, it cannot be 
        reintroduced at hop 3, even for a subset of resources.
        
The correct ops_3 MUST satisfy: ops_3 ⊆ ops_2 = {read:*}
```

### 2.6 Executor Characteristic (EC_i)

A non-transferable property of an Executor at hop *i* that is bound to its execution context. Executor Characteristics include environmental, platform, or runtime attributes such as:
- Trusted Execution Environment (TEE) attestation
- Container or pod identity
- Process attributes and security context
- Hardware platform measurements (TPM, secure boot state)
- Network location or zone
- Deployment region or availability zone
- Runtime namespace and labels

Executor Characteristics are used to validate executor continuity under the Trust Model. They do not constitute identity, authority, or decisions by themselves, but provide verifiable context for continuity validation.

### 2.7 Provenance (P)

The ordered, non-forgeable (under Trust Model) history of execution hops and authority derivations that causally led to a given execution state. Provenance forms the immutable foundation for continuity validation and provides complete auditability of authority flow.

Provenance includes:
- Complete chain of execution hops from origin to current state
- Origin subject `p_0` (immutable throughout)
- Authority evolution `ops_0 → ops_1 → ... → ops_i`
- Executor identities at each hop (if disclosed)
- Timestamps and temporal constraints
- Contextual metadata

### 2.8 Distributed Transaction (τ)

A causally linked sequence of execution hops forming a single logical operation across multiple execution contexts. Each hop participates in τ by verifying continuity with its immediate causal predecessor.

**Critical Note**: In PIC, a "transaction" encompasses the **entire distributed execution from origin to completion**, not merely BEGIN/COMMIT database semantics. A transaction may span:
- Multiple services and execution boundaries
- Multiple administrative domains
- Hours or days of processing time
- Asynchronous event-driven flows (Kafka streams, message queues)
- AI agent orchestrations with multiple API calls
- Human-initiated workflows across multiple systems

All execution within a single transaction maintains causal continuity under the same origin subject `p_0` and derives authority from the same origin authority set `ops_0`.

**Examples:**
- User clicks button → API Gateway → 5 microservices → Database → Function → Storage
- User submits document → Message queue → Stream processing → Multiple consumers → Storage
- User authorizes AI agent → Agent calls API₁ + API₂ + API₃ → Aggregates results

### 2.9 Causal Authority Transition (CAT)

A normative enforcement mechanism that validates Provenance Identity Continuity invariants by:
1. Issuing PIC Causal Challenges (PCC_i)
2. Verifying Proofs of Continuity (PoC_i)
3. Deriving successor PIC Causal Authority (PCA_{i+1}) states

The CAT is a logical mechanism that enforces continuity and may be implemented in-process, externally, or implicitly by a runtime environment, provided the PIC invariants are preserved.

The CAT ensures:
- **Monotonicity**: `ops_{i+1} ⊆ ops_i` (authority can only decrease or remain constant)
- **Causal Binding**: Each hop is verifiably linked to its predecessor under the Trust Model
- **Origin Preservation**: The immutable origin subject `p_0` is maintained throughout the execution chain

### 2.10 PIC Causal Authority (PCA_i)

The causally derived authority available to Executor E_i at hop *i*. PIC Causal Authority represents execution-bound capability and is neither possessed as an artifact nor transferable outside the execution chain.

PCA_i MUST include:

1. **Origin Subject** (`p_0`): Immutable reference to transaction initiator (human, workload, or anonymous)
2. **Authority Set** (`ops_i ⊆ ops_0`): Operations the executor may perform at hop *i*
3. **Executor Binding**: Verifiable binding to the specific executor E_i that guarantees the executor cannot be arbitrarily replaced or impersonated
4. **Provenance**: Reference to the complete causal chain from `p_0` to hop *i*

PCA_i MAY include additional dimensions:

- **Temporal Constraints**: Time-bound validity conditions (e.g., not-before, expiration timestamps, maximum duration)
- **Contextual Constraints**: Environmental or situational restrictions (e.g., network zones, deployment environments, execution contexts)
- **Resource Constraints**: Limits on resource consumption or scope
- **Other Dimensions**: Implementation-specific constraints that do not violate PIC invariants

**Key Properties**:
1. **Origin Immutability**: `p_0` does not change across hops
2. **Authority Monotonicity**: `ops_i ⊆ ops_{i-1}` for all *i*, which implies `ops_i ⊆ ops_0`
3. **Executor Binding**: Authority is bound to specific executor E_i
4. **Causal Derivation**: PCA_i provably derives from PCA_{i-1} under Trust Model
5. **Non-Transferability**: PCA_i is bound to hop *i* and cannot be used outside its causal context

**Critical Note**: The executor binding ensures that authority cannot be exercised by arbitrary entities. The specific mechanism for executor binding is Trust Model dependent but MUST prevent unauthorized executor substitution.

PCA_i is NOT a token, credential, or transferable artifact. It is a state property of the execution at hop *i*, derived from provenance continuity.

### 2.11 PIC Causal Challenge (PCC_i)

A freshness and causality challenge issued by the CAT at hop *i* to require a Proof of Continuity (PoC_i) from Executor E_i. The challenge mechanism is RECOMMENDED but not strictly required for all deployments.

**Purpose**:
1. **Freshness Binding**: Prevents replay of continuity proofs outside their intended temporal context
2. **Revocation Support**: Enables immediate invalidation of compromised executor identities

**Challenge Types**:

A PIC Causal Challenge MAY be implemented using:

1. **Dynamic Challenge-Response** (RECOMMENDED):
   - Fresh cryptographic nonce
   - Timestamp with validity window
   - Challenge derived from current execution state
   - Random challenge value requiring cryptographic response

2. **Static Executor Binding**:
   - Executor identity (SPIFFE ID, DID)
   - Shared secret bound to executor
   - Pre-established executor credentials
   - Environment-specific identifiers

3. **Hybrid Approaches**:
   - Executor identity + fresh nonce
   - Static credentials + timestamp validation
   - Environment binding + dynamic challenge

**Challenge Structure** (protocol-specific):
- Freshness element (nonce, timestamp, or sequence number) - RECOMMENDED
- Reference to predecessor state (PCA_{i-1} or its digest)
- Required continuity constraints
- Expected authority bounds
- Executor validation requirements

**Revocation Support**:

The challenge mechanism SHOULD support executor revocation:
- CAT maintains list of revoked executor identities
- Challenges to revoked executors are rejected immediately
- Compromised workload identities can be invalidated without waiting for credential expiry
- Revocation can occur at any point in the execution chain

**Implementation Note**: While the challenge mechanism is optional, its absence reduces protection against replay attacks, compromised executor detection, and temporal validity enforcement. Systems operating without challenge mechanisms MUST implement alternative controls to address these risks.

### 2.12 Proof of Continuity (PoC_i)

A non-forgeable proof (under the Trust Model) produced by Executor E_i at hop *i* that demonstrates:

1. **Valid Causal Continuation**: Execution at hop *i* derives from hop *i-1*
2. **Authority Bounds**: Operations requested at hop *i* satisfy `ops_i ⊆ ops_{i-1}`
3. **Executor Requirements**: Executor satisfies continuity constraints (environment, characteristics)
4. **Origin Preservation**: Origin subject `p_0` is maintained unchanged
5. **Challenge Response** (if PCC_i issued): Cryptographically valid response to PCC_i

PoC_i is **the fundamental primitive** that distinguishes PIC from possession-based models.

**Challenge Response Requirements**:

If a PIC Causal Challenge (PCC_i) is issued, the PoC_i MUST include a cryptographically valid response to PCC_i demonstrating:

- **Freshness**: Response is bound to the specific challenge (cannot be replayed)
- **Executor Binding**: Executor demonstrates authorized identity (not revoked)
- **Temporal Validity**: Response is within the challenge's validity window

The specific response mechanism depends on the challenge type:
- **Dynamic Challenge**: Cryptographic signature over challenge nonce + execution state
- **Static Binding**: Proof of possession of executor credentials + state binding
- **Hybrid**: Combination of the above

If no challenge is issued (deployment-specific decision), the PoC_i MUST still demonstrate:
- Causal linkage to predecessor state
- Authority bound satisfaction (`ops_i ⊆ ops_{i-1}`)
- Origin preservation

**Non-Transferability**:

PoC_i cannot be:
- Replayed outside its causal context (prevented by challenge or state binding)
- Transferred to another execution chain (bound to specific predecessor)
- Reused after validity period (temporal constraints)
- Forged without detection (Trust Model guarantees)
- Used by revoked executors (challenge mechanism rejects revoked identities)

**Binding Properties**:

PoC_i is bound to:
- Specific execution hop *i*
- Specific predecessor state (PCA_{i-1})
- Specific executor E_i (with revocation support if challenge used)
- Specific challenge PCC_i (if issued)
- Immutable origin `p_0`
- Temporal validity window (if enforced)

### 2.13 Proof of Identity (PoI)

A proof that asserts or validates a claimed identity, typically by demonstrating control over an identifying artifact (e.g., DID signature verification, SPIFFE SVID validation, X.509 certificate chain verification).

PoI establishes "who" the executor claims to be but is insufficient to establish authority continuity in PIC-compliant execution models.

PoI MAY be used as input to executor verification (to validate identity claims) but does not replace or constitute Proof of Continuity.

PoI DOES NOT:
- Grant authority
- Establish causal continuity
- Prevent confused deputy scenarios
- Satisfy PIC requirements

### 2.14 Proof of Possession (PoP)

A proof that demonstrates control or possession of an artifact, credential, or secret (e.g., JWT signature, OAuth bearer token, capability token, private key signature).

PoP establishes ownership or control but does not provide:
- Causal continuity with predecessor state
- Authority derivation from execution origin
- Prevention of confused deputy scenarios
- Monotonic authority restriction

In PIC, PoP MAY contribute to executor verification (e.g., proving control over a signing key) but does not constitute or replace Proof of Continuity.

PoP-based systems are fundamentally distinct from PIC: they derive authority from artifact possession rather than execution provenance, making them vulnerable to confused deputy attacks as proven in [[1]](#references).

---

## 3. Architecture and Components

This section introduces the architectural components and their relationships within the Provenance Identity Continuity (PIC) Model. The PIC Model separates **untrusted execution** (where computations occur) from **trusted authority verification** (where continuity is validated). This separation is fundamental to preventing confused deputy scenarios.

---

## 3.1 Core Components

### 3.1.1 Executor (Untrusted Component)

An **Executor** is an **untrusted** computational entity that performs operations at a specific execution hop. Executors are considered untrusted because:
- They may be compromised
- They operate in potentially hostile environments
- They may attempt to exceed their authority
- They may be subject to confused deputy vulnerabilities

Because Executors are untrusted, they **MUST NOT**:
- Self-assert their own authority
- Validate their own continuity proofs
- Expand authority beyond what is inherited
- Bypass causal validation

Executors **MUST** obtain authority validation through the trusted CAT component.

### 3.1.2 Causal Authority Transition (CAT) / Trust Plane

The **Causal Authority Transition (CAT)**, also referred to as the **Trust Plane**, is a **trusted** enforcement component that validates Provenance Identity Continuity invariants.

**Terminology Note**: "CAT" and "Trust Plane" refer to the same logical component. "Trust Plane" emphasizes its role as a trusted authority layer, analogous to how Identity Providers (IdPs) function as trusted identity layers.

The CAT/Trust Plane is trusted because it:
- Enforces PIC invariants independently of Executors
- Cannot be bypassed by Executors
- Validates continuity proofs using the Trust Model
- Provides cryptographically verifiable decisions
- Operates as a neutral validator and generator (no business logic)

**CAT Responsibilities**:
1. Issue PIC Causal Challenges (PCC_i) upon request
2. Verify Proofs of Continuity (PoC_i) using the Trust Model
3. Validate Proof of Identity (PoI) from executors
4. Validate Proof of Possession (PoP) from executors
5. Validate authority monotonicity (`ops_{i+1} ⊆ ops_i`)
6. Consult Policy Decision Point (PDP) for authority constraints
7. Maintain executor revocation lists
8. Generate and sign valid PCA_{i+1} if all validations succeed

**Implementation Models**:

The CAT MAY be implemented as:
- **Centralized Service**: Single trusted service (e.g., authorization server, API gateway)
- **Decentralized System**: Distributed ledger, blockchain, or consensus-based network
- **Federated Model**: Multiple CATs with inter-CAT trust verification

**Critical Property**: The CAT operates in a **separate trust boundary** from Executors and acts as a **neutral validator** - it has no business logic, only validation and generation logic.

---

## 3.2 Authority Flow Between Hops

The following diagram illustrates how authority flows between executors through CAT validation:

```text
                ┌───────────────────────────┐
                │   Execution Hop_{n-1}     │
                │                           │
                │   Executor E_{n-1}        │
                │   operates with PCA_{n-1} │
                └───────────┬───────────────┘
                            │
                            │ E_{n-1} passes PCA_n
                            │ to E_n (after generating
                            │ PCA_n via CAT)
                            ▼
    ┌──────────────────────────────────────────────────┐
    │              Execution Hop_n                     │
    │                                                  │
    │   ┌──────────────┐                               │    ┌─────────────┐
    │   │   Executor   │ (1) Request PCC_{n+1}         │    │     CAT     │
    │   │      E_n     │  ────────────────────────────▶│    │ (Trust      │
    │   │              │                               │    │  Plane)     │
    │   │  Received    │ (2) Receive PCC_{n+1}         │    │             │
    │   │  PCA_n       │  ◀────────────────────────────│    │  Neutral    │
    │   │  from E_{n-1}│                               │    │  Validator  │
    │   │              │ (3) Submit PoC_{n+1}          │    │             │
    │   │              │     + PoI + PoP               │    │             │
    │   │              │  ────────────────────────────▶│───▶│   Consults  │
    │   │              │                               │    │     PDP     │
    │   │              │ (4) Receive PCA_{n+1}         │    │             │
    │   │              │     (if valid)                │    │  Validates  │
    │   │              │  ◀────────────────────────────│    │  & Signs    │
    │   └──────┬───────┘                               │    └─────────────┘
    │          │                                       │
    │          │  (5) Execute with PCA_n               │
    │          │  (6) Pass PCA_{n+1} to E_{n+1}        │
    │          │      or multiple E_{n+1,a}, E_{n+1,b} │
    │          │      (fork scenario)                  │
    └──────────┼───────────────────────────────────────┘
               │
               │ E_n passes PCA_{n+1} to successor(s)
               ▼
    ┌────────────────────────┐
    │  Execution Hop_{n+1}   │
    │                        │
    │  Executor E_{n+1}      │
    │  receives PCA_{n+1}    │
    │  (or multiple          │
    │   executors in fork)   │
    └────────────────────────┘
```

**Key Flow Steps**:

1. **E_n receives PCA_n** from E_{n-1} (direct transfer)
2. **E_n initiates transition**: Requests PCC_{n+1} from CAT to generate authority for next hop
3. **CAT issues PCC_{n+1}**: Challenge for freshness and binding
4. **E_n constructs PoC_{n+1}**: Proves continuity from PCA_n, includes PoI (executor identity) and PoP (credential control)
5. **CAT validates**:
   - Verifies PoC_{n+1} against PCA_n using Trust Model
   - Validates PoI (executor identity legitimate)
   - Validates PoP (executor controls credentials)
   - Checks `ops_{n+1} ⊆ ops_n` (monotonicity)
   - Consults PDP for policy constraints
   - Verifies E_n not revoked
6. **CAT generates PCA_{n+1}**: If all validations succeed, signs and issues PCA_{n+1}
7. **E_n receives PCA_{n+1}**: Can now pass to successor(s)
8. **E_n passes PCA_{n+1}**: To E_{n+1} or multiple successors (fork scenario)

**Fork Scenario Note**: 

When E_n forks execution to multiple successors (E_{n+1,a}, E_{n+1,b}, etc.):
- E_n requests multiple PCA_{n+1} from CAT (one per successor)
- Each PCA_{n+1} is bound to **executor characteristics** (not specific executor ID)
- Executor characteristics define criteria (e.g., "runs in TEE", "in prod namespace")
- This preserves monotonicity: specific executor IDs would prevent further transitions
- Each successor independently validates with CAT using its own characteristics

---

## 3.3 Trust Boundaries and Validation Flow

The following diagram shows the complete validation flow with PDP integration:

```text
┌──────────────────────────────────────────────────────────────────┐
│                    Security Boundary                             │
│                     (Untrusted Execution)                        │
│                                                                  │
│   ┌────────────────────────────────────────────┐                 │
│   │         Executor E_n (UNTRUSTED)           │                 │
│   │                                            │                 │
│   │  State:                                    │                 │
│   │  - Has PCA_n (received from E_{n-1})       │                 │
│   │  - Needs PCA_{n+1} for successor           │                 │
│   │  - Cannot self-validate                    │                 │
│   │  - Initiates transition                    │                 │
│   └────────────────┬───────────────────────────┘                 │
│                    │                                             │
│                    │ (1) Request PCC_{n+1}                       │
│                    │                                             │
└────────────────────┼─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Trust Boundary                                │
│                   (Trusted Validation)                           │
│                                                                  │
│   ┌────────────────────────────────────────────┐                 │
│   │    CAT / Trust Plane (TRUSTED)             │                 │
│   │         Neutral Validator                  │                 │
│   │                                            │                 │
│   │  - Issues PCC_{n+1} (challenge)            │                 │
│   └────────────────┬───────────────────────────┘                 │
│                    │                                             │
│                    │ (2) Issue PCC_{n+1}                         │
│                    │                                             │
└────────────────────┼─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Security Boundary                             │
│                     (Untrusted Execution)                        │
│                                                                  │
│   ┌────────────────────────────────────────────┐                 │
│   │         Executor E_n (UNTRUSTED)           │                 │
│   │                                            │                 │
│   │  - Constructs PoC_{n+1}:                   │                 │
│   │    * References PCA_n                      │                 │
│   │    * Proves ops_{n+1} ⊆ ops_n              │                 │
│   │    * Maintains p_0 unchanged               │                 │
│   │    * Challenge response                    │                 │
│   │  - Provides PoI (executor identity)        │                 │
│   │  - Provides PoP (credential control)       │                 │
│   └────────────────┬───────────────────────────┘                 │
│                    │                                             │
│                    │ (3) Submit PoC_{n+1} + PoI + PoP            │
│                    │                                             │
└────────────────────┼─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Trust Boundary                                │
│                   (Trusted Validation)                           │
│                                                                  │
│   ┌────────────────────────────────────────────┐                 │
│   │    CAT / Trust Plane (TRUSTED)             │                 │
│   │                                            │     ┌─────────┐ │
│   │  Validates:                                │     │   PDP   │ │
│   │  ✓ PoC_{n+1} using Trust Model             │────▶│ (Policy │ │
│   │  ✓ PoI (executor identity)                 │     │Decision │ │
│   │  ✓ PoP (credential control)                │     │ Point)  │ │
│   │  ✓ PCA_n signature                         │◀────│         │ │
│   │  ✓ ops_{n+1} ⊆ ops_n                       │     └─────────┘ │
│   │  ✓ p_0 unchanged                           │                 │
│   │  ✓ Challenge response                      │                 │
│   │  ✓ E_n not revoked                         │                 │
│   │  ✓ Policy constraints (via PDP)            │                 │
│   │                                            │                 │
│   │  If all valid: Generates & signs PCA_{n+1} │                 │
│   └────────────────┬───────────────────────────┘                 │
│                    │                                             │
│                    │ (4) Issue signed PCA_{n+1}                  │
│                    │                                             │
└────────────────────┼─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Security Boundary                             │
│                     (Untrusted Execution)                        │
│                                                                  │
│   ┌────────────────────────────────────────────┐                 │
│   │         Executor E_n (UNTRUSTED)           │                 │
│   │                                            │                 │
│   │  - Receives signed PCA_{n+1} from CAT      │                 │
│   │  - Executes operations with PCA_n          │                 │
│   │  - Passes PCA_{n+1} to E_{n+1}             │                 │
│   │    (or multiple successors if fork)        │                 │
│   └────────────────────────────────────────────┘                 │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

**Critical Properties**:

1. **Executor Initiates**: E_n starts the process, not CAT
2. **CAT is Neutral**: No business logic, only validates and generates
3. **PDP Integration**: Policy decisions are separate concern
4. **Multi-proof Validation**: PoC + PoI + PoP all validated
5. **Trust Model Verification**: Signatures validated cryptographically
6. **Monotonicity Enforced**: ops_{n+1} ⊆ ops_n checked
7. **Revocation Checked**: Executor not in revocation list

---

## 3.4 Trust Plane Deployment Models

### 3.4.1 Centralized Trust Plane

Single CAT service in a trust domain:

```text
┌───────────────────────────────────────────────────────────┐
│                     Trust Domain                          │
│                                                           │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │Executor  │───▶│Executor  │───▶│Executor  │             │
│  │  E_{n-1} │    │   E_n    │    │  E_{n+1} │             │
│  │          │    │          │    │          │             │
│  │Has       │    │Receives  │    │Receives  │             │
│  │PCA_{n-1} │    │PCA_n     │    │PCA_{n+1} │             │
│  │          │    │          │    │          │             │
│  │Generates │    │Generates │    │Generates │             │
│  │PCA_n  ───┼───▶│PCA_{n+1}─┼───▶│PCA_{n+2} │             │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘             │
│       │               │               │                   │
│       │  via CAT      │  via CAT      │  via CAT          │
│       │               │               │                   │
│       └───────────────┼───────────────┘                   │
│                       │                                   │
│                       ▼                                   │
│         ┌──────────────────────────────┐                  │
│         │   Centralized Trust Plane    │                  │
│         │          (CAT)               │                  │
│         │                              │                  │
│         │  - Validates PoC + PoI + PoP │                  │
│         │  - Consults PDP              │                  │
│         │  - Signs PCA                 │                  │
│         │  - Maintains revocation      │                  │
│         └──────────────────────────────┘                  │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

**Use Cases**: Single organization, microservices in one domain

### 3.4.2 Decentralized Trust Plane

CAT implemented as distributed system:

```text
┌───────────────────────────────────────────────────────┐
│              Decentralized Trust Plane                │
│                                                       │
│    ┌─────────┐      ┌─────────┐      ┌─────────┐      │
│    │ CAT     │◀────▶│ CAT     │◀────▶│ CAT     │      │
│    │ Node A  │      │ Node B  │      │ Node C  │      │
│    └────┬────┘      └────┬────┘      └────┬────┘      │
│         │                │                │           │
│    Consensus / Distributed Ledger / Blockchain        │
│         │                │                │           │
└─────────┼────────────────┼────────────────┼───────────┘
          │                │                │
          ▼                ▼                ▼
     ┌────────┐       ┌────────┐       ┌────────┐
     │  E_n   │       │  E_n   │       │  E_n   │
     │(Region │       │(Region │       │(Region │
     │   A)   │       │   B)   │       │   C)   │
     └────────┘       └────────┘       └────────┘
```

**Use Cases**: Multi-region, trustless environments, blockchain-based systems

**Implementation Examples**:
- **Blockchain**: Smart contract validates PoC and issues PCA
- **Distributed Ledger**: Consensus validates transitions
- **Federated Service Mesh**: Multiple CATs with shared trust

### 3.4.3 Federated Trust Planes (Cross-Domain)

Multiple CATs across trust domains:

```text
┌──────────────────────────────┐       ┌──────────────────────────────┐
│      Trust Domain A          │       │      Trust Domain B          │
│                              │       │                              │
│  ┌──────────┐                │       │                ┌──────────┐  │
│  │Executor  │ PCA_n          │       │      PCA_{n+1} │Executor  │  │
│  │  E_{n-1} │────────────────┼───────┼───────────────▶│   E_n    │  │
│  │          │                │       │                │          │  │
│  │Has       │                │       │                │Receives  │  │
│  │PCA_{n-1} │                │       │                │PCA_n     │  │
│  └────┬─────┘                │       │                └────┬─────┘  │
│       │                      │       │                     │        │
│       │ Generate PCA_n       │       │       Generate PCA_{n+1}     │
│       ▼                      │       │                     ▼        │
│  ┌─────────────┐             │       │             ┌─────────────┐  │
│  │Trust Plane  │             │       │             │Trust Plane  │  │
│  │   (CAT_A)   │◀────────────┼───────┼────────────▶│   (CAT_B)   │  │
│  │             │ Trust Model │       │ Trust Model │             │  │
│  │             │ Verification│       │ Verification│             │  │
│  └─────────────┘             │       │             └─────────────┘  │
│                              │       │                              │
└──────────────────────────────┘       └──────────────────────────────┘
                                  
        Inter-CAT Trust Model Verification
        (DID Document, SPIFFE Bundle, etc.)
```

**Cross-Domain Flow**:
1. E_{n-1} (Domain A) generates PCA_n via CAT_A
2. E_{n-1} passes PCA_n to E_n (Domain B)
3. E_n requests CAT_B to validate and generate PCA_{n+1}
4. CAT_B verifies PCA_n signature using CAT_A's Trust Model
5. CAT_B validates PoC_{n+1} and generates PCA_{n+1}

---

## 3.5 Execution Flow Summary

```text
E_{n-1}                    E_n                      E_{n+1}
(has PCA_{n-1})       (receives PCA_n)         (receives PCA_{n+1})
  │                         │                          │
  │ (1) Request PCC_n       │                          │
  ├─────────▶ CAT           │                          │
  │ (2) Receive PCC_n       │                          │
  │◀─────────               │                          │
  │ (3) Submit PoC_n        │                          │
  │    + PoI + PoP          │                          │
  ├─────────▶ CAT───▶PDP    │                          │
  │ (4) Receive PCA_n       │                          │
  │◀─────────               │                          │
  │                         │                          │
  │ PCA_n                   │                          │
  ├────────────────────────▶│                          │
  │                         │                          │
  │                         │ (1) Request PCC_{n+1}    │
  │                         ├─────────▶ CAT            │
  │                         │ (2) Receive PCC_{n+1}    │
  │                         │◀─────────                │
  │                         │ (3) Submit PoC_{n+1}     │
  │                         │    + PoI + PoP           │
  │                         ├─────────▶ CAT───▶PDP     │
  │                         │ (4) Receive PCA_{n+1}    │
  │                         │◀─────────                │
  │                         │                          │
  │                         │ Execute with PCA_n       │
  │                         │                          │
  │                         │ PCA_{n+1}                │
  │                         ├─────────────────────────▶│
  │                         │                          │
  │                         │                          │ (1) Request PCC_{n+2}
  │                         │                          ├────────▶ CAT
  │                         │                          │ (2) Receive PCC_{n+2}
  │                         │                          │◀────────
  │                         │                          │ (3) Submit PoC_{n+2}
  │                         │                          │    + PoI + PoP
  │                         │                          ├────────▶ CAT───▶PDP
  │                         │                          │ (4) Receive PCA_{n+2}
  │                         │                          │◀────────
  │                         │                          │
  │                         │                          │ Execute with PCA_{n+1}
```

**Key Properties**:
1. **Executor initiates** each transition
2. **Executor receives** PCA_i from predecessor
3. **Executor generates** PCA_{i+1} via CAT validation
4. **Executor passes** PCA_{i+1} to successor(s)
5. **CAT validates** PoC + PoI + PoP
6. **CAT consults PDP** for policy
7. **Monotonicity enforced** (ops_{i+1} ⊆ ops_i)

---

## 3.6 Separation of Concerns

| Component | Trust Level | Responsibilities | Cannot Do |
|-----------|-------------|------------------|-----------|
| **Executor** | Untrusted | - Initiate transitions<br>- Receive PCA_i from predecessor<br>- Request PCC_{i+1} from CAT<br>- Construct PoC_{i+1} + provide PoI + PoP<br>- Receive PCA_{i+1} from CAT<br>- Pass PCA_{i+1} to successor(s)<br>- Execute within ops_i | - Forge PCA signature<br>- Expand authority<br>- Bypass CAT validation<br>- Self-validate continuity<br>- Pass PCA_i (only i+1) |
| **CAT / Trust Plane** | Trusted | - Issue PCC upon request<br>- Validate PoC using Trust Model<br>- Validate PoI (executor identity)<br>- Validate PoP (credential control)<br>- Enforce monotonicity<br>- Consult PDP for policy<br>- Sign valid PCA_{i+1}<br>- Maintain revocation<br>- Operate as neutral validator | - Be bypassed<br>- Grant authority without valid PoC<br>- Have business logic<br>- Be compromised by executor |
| **PDP** | Trusted | - Evaluate policies<br>- Provide policy decisions to CAT<br>- Apply contextual constraints | - Issue PCA<br>- Validate PoC<br>- Replace CAT validation |

**Architectural Principle**: Executors **initiate** transitions and **exchange** PCAs. CAT **validates** and **signs** new PCAs based on cryptographic proof and policy. PDP provides policy decisions. This separation ensures no single untrusted component can compromise authority flow.

---

## 4. Normative Data Structures and Processing Logic

[WORK IN PROGRESS]

---

## 5. Adoption and Implementation Considerations

This section addresses common concerns regarding PIC Model adoption and demonstrates that PIC introduces no fundamental computational overhead beyond existing widely-deployed authorization patterns.

---

## 5.1 Trust Boundary Separation: Untrusted and Trusted Components

**Concern**: "You cannot have trusted components (CAT) interact with untrusted components (Executors) - this creates a security vulnerability."

**Response**: This concern fundamentally misunderstands security architecture. **All practical security systems rely on trusted components validating requests from untrusted components.** This is not a weakness; it is the foundation of security architecture.

**Universal Pattern in Production Systems**:

| System | Untrusted Component | Trusted Component | Interaction |
|--------|-------------------|-------------------|-------------|
| OAuth 2.0 | Client Application | Authorization Server | Client requests token, AS validates and issues |
| TLS/SSL | Client | Certificate Authority | Client requests certificate validation |
| Kerberos | Service | Key Distribution Center (KDC) | Service requests ticket validation |
| SPIFFE | Workload | SPIFFE Server | Workload requests SVID validation |
| JWT | API Consumer | Token Issuer | Consumer submits JWT for validation |
| PIC | Executor | CAT (Trust Plane) | Executor requests PCA validation |

**The CAT-Executor interaction is identical in nature to OAuth Authorization Server validating client requests.** If this pattern were fundamentally insecure, the entire internet would be insecure.

The security property is not "trusted and untrusted cannot interact" but rather:
- Untrusted components **cannot bypass** trusted validation
- Untrusted components **cannot forge** trusted signatures
- Trusted components **enforce invariants** independently

PIC maintains these properties through:
1. **Cryptographic signatures** (CAT signs PCA, Executor cannot forge)
2. **Challenge-response** (prevents replay)
3. **Revocation** (compromised Executors immediately invalidated)
5. **Monotonicity enforcement** (CAT validates ops_{i+1} ⊆ ops_i)

---

## 5.2 Computational Overhead: Token Exchange Equivalence

**Concern**: "PIC requires CAT validation at every hop, introducing unacceptable performance overhead."

**Response**: PIC's computational model is **functionally identical** to OAuth 2.0 Token Exchange (RFC 8693), which is widely deployed in production systems at scale.

**OAuth 2.0 Token Exchange Flow**:

```text
Client                  Authorization Server
  │                            │
  │ (1) Request token          │
  ├───────────────────────────▶│
  │ (2) Validate request       │
  │     Check credentials      │
  │     Check policies         │
  │     Generate token         │
  │     Sign token             │
  │◀───────────────────────────┤
  │ (3) Receive signed token   │
```

**PIC Causal Authority Transition Flow**:
```
Executor                CAT
  │                      │
  │ (1) Request PCC      │
  ├─────────────────────▶│
  │ (2) Issue PCC        │
  │◀─────────────────────┤
  │ (3) Submit PoC       │
  ├─────────────────────▶│
  │ (4) Validate PoC     │
  │     Check signature  │
  │     Check policies   │
  │     Generate PCA     │
  │     Sign PCA         │
  │◀─────────────────────┤
  │ (5) Receive PCA      │
```

**Computational Comparison**:

| Operation | OAuth Token Exchange | PIC CAT Validation |
|-----------|---------------------|-------------------|
| Request validation | ✓ | ✓ |
| Credential verification | ✓ (client credentials) | ✓ (PoI + PoP) |
| Policy evaluation | ✓ (scopes, audience) | ✓ (PDP consultation) |
| Token generation | ✓ (JWT creation) | ✓ (PCA creation) |
| Cryptographic signing | ✓ (JWT signature) | ✓ (PCA signature) |
| Response delivery | ✓ | ✓ |

**Conclusion**: PIC introduces **zero additional computational overhead** compared to OAuth 2.0 Token Exchange. Both require:
- Cryptographic operations (signing, verification)
- Policy evaluation
- Token generation and validation

If OAuth Token Exchange is acceptable for production systems (which it demonstrably is - it powers most modern API ecosystems), then PIC is equally acceptable.

---

## 5.3 Validation Frequency: Flexibility vs. Security Trade-off

**Concern**: "Requiring validation at every hop is too restrictive and introduces latency."

**Response**: PIC does **not mandate validation at every hop**. Like all authorization systems, PIC allows implementers to make **security-performance trade-offs** based on their threat model.

**PIC Validation Strategies**:

### 5.3.1 Full Validation (Maximum Security)

Validate at every hop:
```
E_0 → [CAT] → E_1 → [CAT] → E_2 → [CAT] → E_3
```

**When to use**:
- High-security environments (financial, healthcare, government)
- Cross-trust-domain transitions
- Untrusted execution environments
- Compliance requirements (SOC 2, PCI-DSS, HIPAA)

**Overhead**: Equivalent to OAuth Token Exchange at each hop

### 5.3.2 Selective Validation (Balanced)

Validate only at trust boundaries:
```
E_0 → [CAT] → E_1 → E_2 → E_3 → [CAT] → E_4
      ↑                           ↑
   Boundary                    Boundary
```

**When to use**:
- Internal microservices (same trust domain)
- Performance-critical paths
- Known execution environments

**Security property**: Hops E_1 → E_2 → E_3 operate without CAT validation, **but PCA_1 remains cryptographically valid and non-forgeable**. Compromise of E_2 cannot expand authority beyond ops_1.

### 5.3.3 Deferred Validation (Performance-Optimized)

Validate asynchronously or in batches:
```
E_0 → E_1 → E_2 → E_3
│                   │
└───[CAT validates retroactively]
```

**When to use**:
- Audit and compliance logging
- Non-critical operations
- High-throughput event processing

**Security property**: Execution proceeds optimistically; violations detected post-facto for audit and remediation.

### 5.3.4 No Validation (Trust-Based)

Skip validation entirely within trusted zones:
```
E_0 → [CAT] → E_1 → E_2 → E_3 → E_4
      ↑
   Once at entry
```

**When to use**:
- Tightly controlled environments (single process, trusted infrastructure)
- Development/testing
- Performance-critical legacy systems

**Security property**: Equivalent to traditional authorization models where tokens are validated once at entry and trusted thereafter.

---

## 5.4 Comparison to Existing Authorization Protocols

**The key insight**: PIC's validation frequency is **no different** from existing authorization protocols. All authorization systems face the same trade-off:

| Protocol | Validation Strategy | PIC Equivalent |
|----------|-------------------|----------------|
| **OAuth 2.0** | Validate token at each API call | Full Validation (5.3.1) |
| **JWT + Trust** | Validate signature once, trust thereafter | Selective Validation (5.3.2) |
| **API Keys** | Validate key at entry, trust internally | No Validation (5.3.4) |
| **Session Cookies** | Validate cookie once, session ID trusted | No Validation (5.3.4) |
| **mTLS** | Validate certificate at connection, trust session | Selective Validation (5.3.2) |

**PIC provides the same flexibility as existing protocols**, but with **provable security properties** that prevent confused deputy vulnerabilities.

**The choice is yours**:
- Want maximum security? Validate at every hop (like OAuth validates every API call)
- Want performance? Validate only at boundaries (like JWT signature verification)
- Want legacy compatibility? Validate once at entry (like session cookies)

**But here's what PIC guarantees that others don't**:
- Authority cannot expand (ops_{i+1} ⊆ ops_i is structurally enforced)
- Confused deputy is impossible (proven in [[1]](#references))
- Provenance is auditable (complete causal chain maintained)

---

## 5.5 Adopting PIC: No Architectural Disruption

**Concern**: "Adopting PIC requires rebuilding our entire authorization infrastructure."

**Response**: False. PIC is designed to **augment existing authorization systems**, not replace them.

**Integration Patterns**:

### 5.5.1 OAuth 2.0 + PIC
```
User → OAuth AS → Client
         ↓
      issues JWT (p_0 = user_id, ops_0 = scopes)
         ↓
Client → CAT (validates JWT, issues PCA_1)
         ↓
PCA_1 → Executor_1 → Executor_2 → ...
```

**Migration**: Replace token validation with CAT validation. OAuth AS becomes origin of authority.

### 5.5.2 SPIFFE + PIC
```
Workload → SPIFFE Server → SVID
            ↓
         CAT uses SVID as PoI
            ↓
         Issues PCA with SPIFFE ID as p_0
```

**Migration**: CAT validates SPIFFE SVIDs. No changes to SPIFFE infrastructure.

### 5.5.3 API Gateway + PIC
```
Client → API Gateway (CAT role)
         ↓
      validates credentials
         ↓
      issues PCA_0
         ↓
      forwards to backend services
```

**Migration**: API Gateway becomes CAT. Backend services validate PCA instead of gateway-issued tokens.

**Key Point**: PIC adapts to **your existing infrastructure**. You choose where to deploy CAT validation based on your security and performance requirements.

---

## 5.6 Response to "It's Too Complex"

**Concern**: "PIC is more complex than current authorization models."

**Response**: PIC's **conceptual model** is simpler than existing approaches:

**Current Authorization** (confused deputy vulnerable):
- Token issuance (OAuth, JWT, API keys)
- Token validation (signatures, expiry, scopes)
- Ambient authority (services trust tokens blindly)
- **No provenance** (cannot trace authority origin)
- **No monotonicity** (tokens can be escalated, reused)

**PIC Model**:
- Authority issuance (CAT issues PCA)
- Continuity validation (PoC proves causal link)
- Explicit derivation (ops_{i+1} ⊆ ops_i enforced)
- **Complete provenance** (p_0 → hop_1 → hop_2 → ... auditable)
- **Structural security** (confused deputy impossible by design)

**What PIC adds**:
1. Causal continuity (PoC)
2. Monotonic authority (ops_i ⊆ ops_{i-1})
3. Origin preservation (p_0 immutable)

**What PIC removes**:
1. Ambient authority vulnerabilities
2. Token escalation attacks
3. Confused deputy scenarios
5. Authority provenance ambiguity

**Complexity vs. Security**: PIC trades **implementation flexibility** (you must validate continuity) for **structural security guarantees** (confused deputy cannot occur). This is the same trade-off as TLS (must perform handshake) or OAuth (must validate tokens).

---

## 5.7 Final Rebuttal: The Security Argument

**If your criticism is**: "PIC forces validation at every hop, this is impractical"

**Our response is**: No more impractical than OAuth 2.0, which **already requires validation at every API boundary** and is deployed successfully at global scale (Google, Microsoft, AWS, etc.).

**If your criticism is**: "PIC's CAT-Executor interaction is insecure"

**Our response is**: Then OAuth Authorization Servers, TLS Certificate Authorities, Kerberos KDCs, and every other trusted validation service in production is also insecure. This criticism rejects the **entire foundation of modern security architecture**.

**If your criticism is**: "We want performance, not security"

**Our response is**: PIC provides the **same performance-security trade-offs** as existing protocols (see Section 5.3). You can skip validation where appropriate - but you cannot escape the consequences of ambient authority vulnerabilities.

**The fundamental question is not**:
- "Is PIC faster than OAuth?" (Answer: Equivalent computational cost)
- "Is PIC simpler than JWT?" (Answer: Simpler conceptual model, proven security)
- "Can I skip validation?" (Answer: Yes, same as any protocol)

**The fundamental question is**:
- "Do you want to eliminate confused deputy vulnerabilities?"

If yes → PIC is the **only model** with a formal proof that confused deputy is impossible [[1]](#references).

If no → Continue using possession-based models and accept the security risk.

**There is no middle ground.** Confused deputy is either possible (PoP) or impossible (PoC). Choose accordingly.

---

## References

[1] N. Gallo. "Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem." Zenodo, 2025. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)

---

## Appendix A. Use of Automated Language Assistance

The authors have used automated language assistance tools solely to improve grammar, clarity, and phrasing. All substantive technical content, including the conceptual model, formal results, and proofs, is the exclusive work of the authors.

---

## Appendix B. Authorship, Attribution, and Derivative Works

The **Provenance Identity Continuity (PIC) Model**, including its core concepts, terminology, execution semantics, and structural invariants, originates from the original theoretical work of **Gallo, N.**, in particular:

- Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo.  
- Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems*. Zenodo.

This specification consolidates, formalizes, and extends that work under the stewardship of the **PIC Spec Contributors**, without altering authorship of the underlying model.

> Authorship of the PIC Model is historical and independent of repository ownership, governance structure, maintainer status, or editorial roles.

---

### B.1 License and Use

This document is published under the **Creative Commons Attribution 5.0 International (CC BY 5.0)** license.  
Under this license, copying, redistribution, and adaptation are permitted, **provided that appropriate attribution is given** in accordance with the terms below.

---

### B.2 Mandatory Attribution Requirements

The PIC Model and the PIC Spec are canonically defined by this document as published in the official PIC Spec repositories (the "Official PIC Spec").  
Forks and derivative specifications MAY exist, but MUST NOT represent themselves as the canonical PIC Model, the canonical PIC Spec, or the normative reference for PIC unless explicitly designated by the PIC Spec Contributors.

Any implementation, specification, library, framework, or document that:

- uses the **PIC Model** as defined in this specification, or  
- claims compatibility with, conformance to, or derivation from the **PIC Model** or the **PIC Spec**
  (e.g., "PIC-compliant", "PIC-based", "PIC-inspired", "implements the PIC Spec"),

**MUST** provide clear, visible, and unambiguous attribution to:

1. **Gallo, N.** as the original author of the **PIC Model** and the associated Authority Propagation framework; and  
2. this specification (the **PIC Spec**) and its maintainers, the **PIC Spec Contributors**, as the editors and custodians of the normative specification.

Attribution **MUST NOT** omit the original author in favor of contributors, implementers, or downstream projects.

These attribution requirements DO NOT restrict contribution, experimentation, or the creation of forks and derivative works; they only ensure that conceptual authorship and normative provenance remain explicit as the ecosystem evolves.

An acceptable attribution statement includes, for example:

> "This work is based on the Provenance Identity Continuity (PIC) Model created by 
> Nicola Gallo. The model and its initial specification originate from this work. 
> Maintenance of the PIC Spec and related PIC Protocol documents is performed over 
> time by the PIC Spec Contributors, with authorship of the model remaining with 
> Nicola Gallo."

---

### B.3 Derivative Works and Implementations

Derivative works, including modified specifications, extensions, profiles, or specialized adaptations:

- **MUST** clearly state that they are *derivative works* of the PIC Spec, and  
- **SHOULD** document any substantive semantic, security, or continuity-relevant changes.

Implementations (software libraries, SDKs, middleware, gateways, or services) **MAY** claim authorship of the implementation itself, **but MUST NOT** claim authorship of the PIC Model, its invariants, or its foundational design.

---

### B.4 Use of PIC Terminology

The terms **"PIC Model"**, **"Provenance Identity Continuity"**, **"PIC Spec"**, **"PIC-compliant"**, and similar designations **MUST NOT** be used in a way that:

- obscures the original authorship of the model,  
- implies independent invention of the core PIC invariants, or  
- attributes the foundational execution semantics to parties other than those cited in this document.

Projects that do not wish to comply with these attribution requirements **MAY** implement similar ideas, but **MUST NOT** represent themselves as implementing or conforming to the PIC Model.

---

### B.5 Rationale

These requirements exist to preserve the integrity, traceability, and academic provenance of the PIC Model as a formal execution framework.  
They do not restrict implementation, experimentation, or adoption; they ensure that conceptual authorship remains explicit as the ecosystem evolves.

---

### B.6 Authorship and Roles

Changes in organizational control, hosting infrastructure, or repository
ownership do not alter (a) the authorship of the PIC Model, (b) the canonical
status of the Official PIC Spec and any Official PIC Protocol specifications as
normative references for the PIC Model, or (c) the attribution and licensing
requirements defined in this document for the PIC Model, the PIC Spec, and PIC
Protocol documents. Any future maintainers or stewards of the PIC repositories
or specifications acquire operational and editorial responsibilities only; they
do not acquire conceptual authorship of the PIC Model or original authorship of
the PIC Spec or PIC Protocol designs.

This document is licensed under the Creative Commons Attribution 5.0 International (CC BY 5.0) license (see Section B.1).

**PIC Spec Author:** 

- **Nicola Gallo**: Original author of the Provenance Identity Continuity (PIC) Model, and all foundational proofs and invariants.

**PIC Spec Editors and Maintainers (PIC Spec Contributors):** 

- Nicola Gallo (Lead Editor)

**PIC Spec Contributors:** 

The following individuals have contributed to the specification text, reviews, examples, or discussions. Contribution does not imply authorship of the PIC Model.

- <add your name here via pull request>  

### B.7 Relationship to PIC Protocol Specifications

"PIC Protocol" documents, when published, will define concrete protocol encodings and interoperability profiles that implement the PIC Model as specified in the PIC Spec.  
Such protocol documents do not alter the authorship, canonicity, or normative status of the PIC Model or the PIC Spec, which remain defined exclusively by the Official PIC Spec.

### B.8 Immutability of Authorship and Canonical Status

The authorship of the PIC Model, the designation of the canonical PIC Spec, and
the attribution requirements defined in this appendix are **normative and
foundational**.

No modification to this specification, including edits proposed via pull
request, repository change, fork, or editorial revision, may alter, redefine,
or reassign:

- authorship of the PIC Model,
- authorship of the initial PIC Spec,
- the canonical status of the Official PIC Spec,
- or the mandatory attribution requirements defined herein.

Any text that purports to modify these elements is **non-normative**, **invalid**,
and **MUST be disregarded**, unless explicitly authored by the original PIC
Model author and consistent with this appendix.

This clause applies regardless of hosting platform, repository ownership,
governance structure, or maintainer roles.

---

## References

[1] N. Gallo. "Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem." Zenodo, 2025. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)

[2] N. Gallo. "PIC Model — Provenance Identity Continuity for Distributed Execution Systems." Zenodo, 2025. [doi.org/10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)

[3] N. Gallo. "Authority is a Continuous System." Zenodo, 2025. [doi.org/10.5281/zenodo.17860199](https://doi.org/10.5281/zenodo.17860199)

[4] N. Hardy. "The Confused Deputy." Operating Systems Review, 1988.

[5] NIST. "Zero Trust Architecture." Special Publication 800-207, 2020.

[6] RFC 2119. "Key words for use in RFCs to Indicate Requirement Levels."

[7] RFC 8174. "Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words."