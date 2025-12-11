# Provenance Identity Continuity (PIC) Model Specification

**Version:** 0.1 (Draft)  
**Date:** 2025-12-11  
**Source:** [github.com/pic-protocol/pic-spec/draft/0.1/pic-spec.md](https://github.com/pic-protocol/pic-spec/blob/main/draft/0.1/pic-spec.md)

---

## Abstract

This specification defines the **Provenance Identity Continuity (PIC) Model**, an execution model for distributed systems that eliminates the confused deputy problem and entire classes of authorization vulnerabilities through verifiable causal continuity rather than artifact possession.

Unlike capability-based systems that provide delegatable objects for process-to-process authority transfer, PIC enforces **execution continuity** across complete distributed transactions—from origin to completion—spanning multiple services, clouds, and administrative domains. Where capabilities enable controlled delegation within bounded contexts, PIC maintains authority invariants across unbounded distributed executions: API gateways calling microservices, event streams processing through Kafka pipelines, AI agents orchestrating multiple API calls, or serverless functions chaining across cloud providers.

The PIC Model makes entire families of authorization bugs **structurally inexpressible** within a transaction by enforcing four invariants at every execution hop:

1. **Origin Immutability**: The initiating subject (`p_0`) remains constant throughout the transaction
2. **Authority Monotonicity**: Authority can only decrease or remain constant (`ops_i ⊆ ops_{i-1}`)
3. **Causal Binding**: Each hop is verifiably linked to its predecessor via a Trust Model
4. **Continuity Validation**: Transitions satisfy executor continuity requirements

**Distributed Coordination**: These invariants enable PIC to provide authorization semantics for distributed coordination patterns. PIC functions as an authorization layer for orchestration engines (Temporal, Apache Airflow, Step Functions), choreography systems (event-driven architectures, saga patterns), and agent frameworks (LangChain, AutoGPT, multi-agent systems). Where traditional authorization models require each service to independently verify credentials—creating coordination complexity and confused deputy risks—PIC provides a unified authority chain that flows through the entire coordination graph. An orchestrator receiving `PCA_n` can delegate to multiple workers, each receiving `PCA_{n+1}` with appropriately scoped authority, all traceable to the same `p_0` and subject to `ops_0` bounds.

**Impact**: This authorization model was previously impossible to implement: no existing system can maintain origin immutability and authority monotonicity across arbitrary distributed executions spanning multiple clouds, orchestration engines, and administrative domains. PIC provides the first formal framework where a user action in System A causally constrains execution in System Z through 100 intermediate hops, with mathematical guarantees that authority cannot expand and the confused deputy problem cannot occur.

A **transaction** in PIC encompasses the entire distributed execution from user initiation to completion, not merely database BEGIN/COMMIT semantics. A single transaction may span:

- Hundreds of execution hops across microservices, message queues, and serverless functions
- Multiple administrative domains and cloud providers
- Hours or days of asynchronous processing
- Event-driven flows (Kafka streams, message buses)
- AI agent orchestrations calling multiple external APIs
- Human-initiated workflows across heterogeneous systems

**Example transaction**:

```
User → API Gateway → microservice → Kafka → Stream processor → microservice
  → Lambda functions → Multiple APIs → S3 storage
(100+ hops, 3 clouds, 1 authority chain, 1 p_0, monotonic ops)
```

**AI agent example**:

```
User authorizes AI agent (ops_0 = {read:calendar, send:email, call:weather_api})
  → Agent orchestrates:
      → Calendar API (ops_1 = {read:calendar})
      → Weather API (ops_2 = {call:weather_api})
      → Email API (ops_3 = {send:email})
All three API calls operate within ops_0, enforced by CAT validation
```

The origin subject (`p_0`) may be a human user (authenticated via OAuth, SAML, OIDC, VC), a service/workload (identified via DID, SPIFFE, X.509), or anonymous (capability-based). The origin authority (`ops_0`) may derive from identity-based grants, capability tokens, or hybrid models.

As proven in "Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem" [[1]](#references), the confused deputy problem is structurally impossible in PIC-compliant systems—it cannot be formulated, not merely prevented. By making authority derivation dependent on execution provenance rather than credential possession, PIC eliminates confused deputy, privilege escalation, token substitution, ambient authority exploitation, and other attack classes that are inherent to possession-based authorization models.

**Trust Model Note**: This specification uses "cryptographic" as shorthand for "based on a Trust Model." Trust Models MAY be implemented via cryptographic primitives, hardware attestation, distributed consensus, or other mechanisms providing non-repudiable binding. The specific Trust Model is implementation-specific.

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Terminology](#2-terminology)  
3. [Architecture and Components](#3-architecture-and-components)  
4. [Normative Data Structures and Processing Logic](#4-normative-data-structures-and-processing-logic)  
5. [Deployment and Adoption Considerations](#5-implementation-considerations)  
6. [Security Considerations](#6-security-considerations)

**Appendices:**  
A. [Appendix A – Use of Automated Language Assistance](#appendix-a-use-of-automated-language-assistance)  
B. [Appendix B – Authorship, Attribution, and Derivative Works](#appendix-b-authorship-attribution-and-derivative-works)  
R. [References](#references)  

---

## 1. Introduction

### 1.1 Scope

This specification defines the Provenance Identity Continuity (PIC) Model for distributed execution systems. The specification includes:

1. **Formal Model**: Causal invariants and execution semantics that MUST hold for any execution to be considered PIC-compliant
2. **Architecture and Components**: Reference architecture defining the separation between untrusted execution (Executors) and trusted validation (CAT/Trust Plane)
3. **Deployment and Adoption Considerations**: Deployment patterns, integration strategies, and performance trade-offs for practical adoption

The PIC Model establishes a foundational execution model that eliminates confused deputy conditions by construction. While the specification provides reference architecture and implementation guidance, it does not mandate specific protocol encodings, wire formats, or cryptographic primitives. These are defined in separate PIC Protocol specifications.

**Normative vs. Informative**:

- Sections 1-3 define **normative** requirements (terminology, architecture, invariants)
- Sections 4-6 provide **informative** guidance (data model examples, deployment and adoption considerations)
- Appendices provide **informative** context (authorship, references)

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

### 3.1.1 Executor

An **Executor** is a computational entity that performs operations at a specific execution hop. The trust level of an Executor depends on the deployment model:

- In many deployments, Executors are considered **untrusted** because they may be compromised, operate in potentially hostile environments, or be subject to confused deputy vulnerabilities
- In other deployments (e.g., IoT devices with hardware security, trusted execution environments, Kubernetes clusters with trusted workloads, private networks, service mesh environments such as Istio Ambient Mesh), Executors MAY be considered **trusted** and MAY host the CAT internally

Regardless of trust level, Executors **MUST NOT**:

- Self-assert their own authority
- Validate their own continuity proofs
- Expand authority beyond what is inherited
- Bypass causal validation

Executors **MUST** obtain authority validation through the trusted CAT component.

### 3.1.2 Causal Authority Transition (CAT) / Trust Plane

The **Causal Authority Transition (CAT)**, also referred to as the **Trust Plane**, is the enforcement component that validates Provenance Identity Continuity invariants.

**Terminology Note**: "CAT" and "Trust Plane" refer to the same logical component. "Trust Plane" emphasizes its role as an authority validation layer, analogous to how Identity Providers (IdPs) function as identity validation layers.

The CAT/Trust Plane:

- Enforces PIC invariants
- Validates continuity proofs using the Trust Model
- Provides cryptographically verifiable decisions
- Operates as a neutral validator and generator (no business logic)

**Deployment Models**: The CAT MAY be deployed:

- **Externally**: As a separate service from Executors (typical in cloud/microservices where Executors are untrusted)
- **Internally**: Embedded within a trusted Executor (typical in IoT, TEE-based systems, Kubernetes-internal workloads, private networks, service mesh environments, or other trusted infrastructure)
- **Hybrid**: External CAT for untrusted Executors, internal CAT for trusted Executors within the same system

The choice of internal vs. external CAT depends on the trust model of the deployment environment, not on inherent properties of PIC.

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

**Deployment Note**: This diagram shows the CAT as a logically separate component. In deployments with trusted Executors, the CAT MAY be embedded within the Executor itself. The logical flow remains identical; only the deployment boundary changes.

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

## 3.3 Validation Flow

The following diagram shows the complete validation flow with PDP integration. The separation between Executor and CAT is shown as logical separation; in deployments with trusted Executors, these components MAY be co-located.

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
│                    Execution Boundary                            │
│                                                                  │
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
│                    Validation Boundary                           │
│                                                                  │
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

**Use Cases**: Single organization, microservices in one domain, cloud-native applications

**Note**: In trusted environments (e.g., Kubernetes clusters with trusted workloads, TEE-based systems, private networks, service mesh environments such as Istio Ambient Mesh), the CAT MAY be embedded within Executors rather than deployed as a separate service.

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

| Component | Responsibilities | Cannot Do |
|-----------|------------------|-----------|
| **Executor** | - Initiate transitions<br>- Receive PCA_i from predecessor<br>- Request PCC_{i+1} from CAT<br>- Construct PoC_{i+1} + provide PoI + PoP<br>- Receive PCA_{i+1} from CAT<br>- Pass PCA_{i+1} to successor(s)<br>- Execute within ops_i | - Forge PCA signature<br>- Expand authority<br>- Bypass CAT validation<br>- Self-validate continuity (unless CAT is internal)<br>- Pass PCA_i (only i+1) |
| **CAT / Trust Plane** | - Issue PCC upon request<br>- Validate PoC using Trust Model<br>- Validate PoI (executor identity)<br>- Validate PoP (credential control)<br>- Enforce monotonicity<br>- Consult PDP for policy<br>- Sign valid PCA_{i+1}<br>- Maintain revocation<br>- Operate as neutral validator | - Be bypassed<br>- Grant authority without valid PoC<br>- Have business logic |
| **PDP** | - Evaluate policies<br>- Provide policy decisions to CAT<br>- Apply contextual constraints | - Issue PCA<br>- Validate PoC<br>- Replace CAT validation |

**Note**: The trust level of each component depends on the deployment model. In untrusted environments, Executors require external CAT validation. In trusted environments (TEE, secure IoT, Kubernetes-internal workloads, private networks, service mesh, trusted infrastructure), Executors MAY host the CAT internally.

**Architectural Principle**: Executors **initiate** transitions and **exchange** PCAs. CAT **validates** and **signs** new PCAs based on cryptographic proof and policy. PDP provides policy decisions. This separation ensures no single untrusted component can compromise authority flow.

---

## 4. Normative Data Structures and Processing Logic

This section defines the normative data structures for the PIC Model. The examples provided are **informative and non-normative**. Concrete protocol encodings (JSON, CBOR, Protocol Buffers, etc.) are defined in separate PIC Protocol specifications.

---

## 4.1 PIC Causal Authority (PCA)

The PIC Causal Authority (PCA) represents causally derived authority at a specific execution hop. A PCA MUST be signed by the CAT.

### 4.1.1 Structure

A PCA MUST contain:

1. **CAT Signature**: Cryptographic signature by the issuing CAT
2. **CAT Identifier**: Reference to the CAT that signed this PCA (enables signature verification and key rotation)
3. **Payload**: The authority data structure

### 4.1.2 Payload Requirements

The PCA payload MUST include:

**Origin Subject (`p_0`)**:
- Immutable reference to transaction initiator
- MUST NOT change throughout execution chain

**Authority Set (`ops_i`)**:
- Operations the executor may perform at this hop
- MUST satisfy `ops_i ⊆ ops_{i-1}` (monotonicity)

**Executor Binding**:
- Characteristics that bind authority to executor
- MUST constrain to specific federation/attributes (NOT "any identity")
- MAY include: organizational attributes, environmental characteristics, federated identity domain
- In proposed PCA, executor attributes MUST be contained within (subset of) previous PCA's executor attributes (cannot add new attributes)

**Temporal Constraints** (OPTIONAL):
- MAY be expressed as start time + duration OR absolute time range

**Provenance Reference**:
- Link to causal chain (hash of previous PCA, ledger reference, etc.)

### 4.1.3 CAT Identifier

The CAT identifier MUST support:

1. Signature verification (public key retrieval)
2. Key rotation
3. Cross-domain federation

Common approaches: Key ID (kid), DID, X.509 certificate, SPIFFE Bundle.

### 4.1.4 Informative Example

```json
{
  "cat_signature": "base64url_encoded_signature",
  "cat_identifier": "https://cat.example.com/v1/keys/key-2024-12",
  "payload": {
    "origin_subject": "sub:alice@example.com",
    "authority_set": [
      "read:/*",
      "write:/home/alice/*"
    ],
    "executor_binding": {
      "federation": "spiffe://trust-domain.com",
      "namespace": "prod",
      "attributes": {
        "department": "engineering",
        "security_level": "high"
      }
    },
    "temporal": {
      "start_time": "2025-12-11T10:00:00Z",
      "duration_seconds": 3600
    },
    "provenance": {
      "previous_pca_hash": "sha256:a3f5b9c7...",
      "hop_index": 3
    },
    "issued_at": "2025-12-11T10:00:00Z"
  }
}
```

---

## 4.2 PIC Causal Challenge (PCC)

The PIC Causal Challenge (PCC) is issued by the CAT to establish freshness and enable revocation. The specific structure is **protocol-dependent** and NOT defined in this specification.

### 4.2.1 Requirements

A PCC, if used, MUST provide:
1. **Freshness**: Prevent replay of continuity proofs
2. **Revocation Support**: Enable detection of revoked executors
3. **Binding**: Link challenge to specific transition context

PIC Protocol specifications MUST define challenge structure and response mechanism.

---

## 4.3 Proof of Continuity (PoC)

The Proof of Continuity (PoC) is constructed by the Executor to demonstrate valid causal continuation and submitted to the CAT for validation.

### 4.3.1 Structure

A PoC MUST contain:

**Previous PCA**:
- The PCA received from predecessor (establishes causal state)

**Proposed PCA**:
- The PCA_{i+1} being requested
- MUST satisfy:
  - Same `origin_subject` (p_0 unchanged)
  - `ops_{i+1} ⊆ ops_i` (monotonicity)
  - Executor attributes MUST be subset of previous executor attributes (cannot add new attributes)
  - Temporal constraints respected

**Executor Proofs**:
- **Proof of Identity (PoI)**: Executor's identity credential (type + base64-encoded value)
- **Proof of Possession (PoP)**: Control over signing key (type + base64-encoded value)

**Challenge Response** (if PCC issued):
- Cryptographically valid response to PCC (type + base64-encoded value)

**Bundle Signature**:
- Entire PoC MUST be signed by executor (prevents tampering in transit)

### 4.3.2 Informative Example

```json
{
  "executor_signature": "base64url_encoded_signature_over_bundle",
  "bundle": {
    "previous_pca": {
      "cat_signature": "...",
      "cat_identifier": "https://cat.example.com/v1/keys/key-2024-12",
      "payload": {
        "origin_subject": "sub:alice@example.com",
        "authority_set": ["read:/*", "write:/home/alice/*"],
        "executor_binding": {
          "federation": "spiffe://trust-domain.com",
          "namespace": "prod",
          "attributes": {
            "department": "engineering",
            "security_level": "high",
            "team": "platform"
          }
        },
        "temporal": {
          "start_time": "2025-12-11T10:00:00Z",
          "duration_seconds": 3600
        },
        "provenance": {
          "previous_pca_hash": "sha256:...",
          "hop_index": 2
        }
      }
    },
    "proposed_pca": {
      "payload": {
        "origin_subject": "sub:alice@example.com",
        "authority_set": ["read:/*"],
        "executor_binding": {
          "federation": "spiffe://trust-domain.com",
          "namespace": "prod",
          "attributes": {
            "department": "engineering",
            "security_level": "high"
          }
        },
        "temporal": {
          "start_time": "2025-12-11T10:15:00Z",
          "duration_seconds": 3600
        },
        "provenance": {
          "previous_pca_hash": "sha256:a3f5b9c7...",
          "hop_index": 3
        }
      }
    },
    "executor_proofs": {
      "proof_of_identity": {
        "type": "spiffe_svid",
        "value": "base64_encoded_proof"
      },
      "proof_of_possession": {
        "type": "ecdsa_signature",
        "value": "base64_encoded_proof"
      }
    },
    "challenge_response": {
      "type": "hmac_sha256",
      "value": "base64_encoded_response"
    }
  }
}
```

**Key Properties**:
- `origin_subject`: Unchanged from previous PCA (immutability)
- `authority_set`: Reduced from `["read:/*", "write:/home/alice/*"]` to `["read:/*"]` (monotonicity enforced)
- `executor_binding.attributes`: Reduced from `{"department": "engineering", "security_level": "high", "team": "platform"}` to `{"department": "engineering", "security_level": "high"}` (attribute monotonicity - removed "team" attribute, cannot add new ones)
- `executor_proofs`: Opaque base64-encoded values with type hints (CAT interprets based on protocol)
- `challenge_response`: Opaque base64-encoded response with type hint (CAT validates based on challenge type)
- `executor_signature`: Prevents tampering during transit
- `hop_index`: Incremented from 2 to 3 (provenance tracking)

---

## 4.4 Protocol Encodings

This specification does not mandate specific encodings. PIC Protocol specifications MUST define:

1. Serialization format (JSON, CBOR, etc.)
2. Signature schemes (JOSE, COSE, etc.)
3. CAT identifier format
4. Challenge-response mechanism
5. Wire format (HTTP, gRPC, etc.)
6. Proof formats (PoI, PoP encoding and validation)

Example protocols: PIC-HTTP, PIC-gRPC, PIC-SPIFFE, PIC-Blockchain.

---

---

## 5. Deployment and Adoption Considerations

This section addresses practical deployment considerations and clarifies the relationship between PIC and existing authorization patterns.

---

## 5.1 Trust Architecture Pattern

The PIC Model follows separation-of-concerns patterns used in production authorization systems. The specific deployment depends on the trust model of the environment.

**External CAT Pattern** (for untrusted Executors):

In environments where Executors are untrusted, they submit requests to a separate CAT validation service:

| System | Requesting Component | Validation Service | Operation |
|--------|---------------------|-------------------|-----------|
| OAuth 2.0 | Client Application | Authorization Server | Token issuance and validation |
| TLS/SSL | Client | Certificate Authority | Certificate validation |
| Kerberos | Service | Key Distribution Center | Ticket validation |
| SPIFFE | Workload | SPIFFE Server | SVID issuance and validation |
| JWT | Resource Server | Token Issuer | Signature verification |
| PIC | Executor | CAT (Trust Plane) | Continuity validation and PCA issuance |

The CAT-Executor relationship in external deployments is functionally equivalent to Authorization Server-Client relationships in OAuth 2.0 and other widely-deployed protocols.

**Internal CAT Pattern** (for trusted Executors):

In environments where Executors are trusted (IoT with hardware security, TEE-based systems, trusted Kubernetes clusters, private networks, service mesh environments such as Istio Ambient Mesh), the CAT MAY be embedded within the Executor.
This eliminates network round-trips while preserving PIC invariants. The logical validation flow remains identical; only the deployment topology changes.

**Security Properties**:

The separation ensures:

1. Requesting components cannot bypass validation
2. Requesting components cannot forge trusted signatures
3. Validation services enforce invariants independently
4. Compromised requesters can be revoked without system-wide credential rotation

PIC maintains these properties through cryptographic signatures (CAT-signed PCA), challenge-response mechanisms (freshness), revocation support (compromised executor invalidation), and monotonicity enforcement (CAT validates ops_{i+1} ⊆ ops_i).

---

## 5.2 Computational Overhead Analysis

The PIC validation process is computationally equivalent to OAuth 2.0 Token Exchange (RFC 8693), a widely-deployed pattern in production environments.

**OAuth 2.0 Token Exchange**:

```text
Client                  Authorization Server
  │                            │
  │ Request token              │
  ├───────────────────────────▶│
  │ Validate credentials       │
  │ Evaluate policies          │
  │ Generate signed token      │
  │◀───────────────────────────┤
  │ Receive token              │
```

**PIC Authority Transition**:

```text
Executor                CAT
  │                      │
  │ Request PCC          │
  ├─────────────────────▶│
  │ Receive PCC          │
  │◀─────────────────────┤
  │ Submit PoC+PoI+PoP   │
  ├─────────────────────▶│
  │ Validate proofs      │
  │ Evaluate policies    │
  │ Generate signed PCA  │
  │◀─────────────────────┤
  │ Receive PCA          │
```

**Operation Comparison**:

| Operation | OAuth Token Exchange | PIC CAT Validation | Notes |
|-----------|---------------------|-------------------|-------|
| Request validation | Required | Required | Standard protocol overhead |
| Credential verification | Required | Required (PoI+PoP) | Cryptographic operation |
| Policy evaluation | Required | Required (PDP) | Application-specific logic |
| Token generation | Required | Required (PCA) | Cryptographic operation |
| Signature creation | Required | Required | Cryptographic operation |

**Conclusion**: PIC introduces no additional computational operations beyond those already required by OAuth 2.0 Token Exchange. Systems that successfully deploy OAuth at scale can deploy PIC with equivalent performance characteristics.

---

### 5.2.1 Performance in Trusted Environments (Network-Internal)

When deploying PIC with internal CAT in trusted network environments, authority transitions remain within the trusted zone but still traverse the network stack between nodes:

```text
                    ENTRY (once)
User → OAuth/OIDC → JWT → CAT derives PCA_0
                              │
                    ──────────┼────────────────────────
                              │  INTERNAL (trusted network)
                              ▼
                    ┌─────────────────────────────────┐
                    │   Trusted Zone (K8s/Mesh/TEE)   │
                    │                                 │
                    │   E_1 ──→ E_2 ──→ E_3 ──→ E_4   │
                    │     │       │       │       │   │
                    │    CAT     CAT     CAT     CAT  │
                    │ (embedded)(embedded)(embedded)  │
                    │                                 │
                    │   Internal network only         │
                    │   ZERO external IdP calls       │
                    │   Low-latency node-to-node      │
                    └─────────────────────────────────┘
```

With external CAT or Token Exchange, each hop requires a network round-trip to an external IdP. With internal CAT in a trusted zone, validation stays within the local network, eliminating external dependencies while preserving all PIC security guarantees.

---

### 5.2.2 Performance in Embedded Environments (Shared Memory)

In IoT devices or embedded systems, multiple executors MAY share memory or communicate via local bus, enabling PCA transitions with zero network overhead:

```text
┌─────────────────────────────────────────────────┐
│           Embedded Device / IoT Node            │
│                                                 │
│   ┌───────┐    ┌───────┐    ┌───────┐           │
│   │ E_1   │───▶│ E_2   │───▶│ E_3   │           │
│   │ +CAT  │    │ +CAT  │    │ +CAT  │           │
│   └───────┘    └───────┘    └───────┘           │
│       │            │            │               │
│       └────────────┴────────────┘               │
│              Shared Memory / Bus                │
│                                                 │
│   PCA transitions: memory copy only             │
│   ZERO serialization overhead                   │
│   ZERO network stack                            │
└─────────────────────────────────────────────────┘
```

In this deployment, PCA structures are passed directly via shared memory or hardware bus. Validation occurs in-process within each executor's embedded CAT, achieving minimal latency suitable for real-time and resource-constrained environments.

---

### 5.2.2 Performance in IoT Ring (Local Network)

In IoT deployments, devices on a local network MAY form a ring where requests propagate device-to-device. A user presenting a Verifiable Credential (VC) initiates the chain, and each device performs its operation before passing the PCA to the next:

```text
                         User arrives with VC
                                  │
                                  ▼
                    ┌─────────────────────────────┐
                    │      IoT Local Network      │
                    │                             │
                    │   ┌───────┐    ┌───────┐   │
                    │   │Device │───▶│Device │   │
                    │   │  A    │    │  B    │   │
                    │   │ +CAT  │    │ +CAT  │   │
                    │   └───────┘    └───────┘   │
                    │       ▲            │        │
                    │       │            ▼        │
                    │   ┌───────┐    ┌───────┐   │
                    │   │Device │◀───│Device │   │
                    │   │  D    │    │  C    │   │
                    │   │ +CAT  │    │ +CAT  │   │
                    │   └───────┘    └───────┘   │
                    │                             │
                    │   PCA flows in ring         │
                    │   Local network only        │
                    │   ZERO cloud round-trips    │
                    └─────────────────────────────┘
```

Each device validates the incoming PCA via its embedded CAT, performs its authorized operation (e.g., sensor read, actuator command), restricts authority if needed, and forwards the new PCA to the next device. The entire ring operates without external IdP calls, achieving low-latency coordination suitable for industrial IoT and smart home scenarios.

---

## 5.3 Validation Frequency Options

PIC does not mandate validation frequency. Implementations MAY choose validation strategies based on their security requirements and threat model, similar to existing authorization protocols.

**Note**: The validation strategies below apply to both external and internal CAT deployments. With internal CAT (embedded in trusted Executors), validation overhead is reduced as no network round-trip is required.

### 5.3.1 Validation Strategy: Full Validation

Validate at every hop transition:

```text
E_0 → [CAT] → E_1 → [CAT] → E_2 → [CAT] → E_3
```

**Characteristics**:

- Maximum security assurance
- Equivalent to validating OAuth tokens at every API call
- Appropriate for: cross-domain transitions, high-security environments, compliance requirements

**Overhead**: One validation per hop (equivalent to OAuth validation per API call)

### 5.3.2 Validation Strategy: Selective Validation

Validate at trust boundary transitions:

```text
E_0 → [CAT] → E_1 → E_2 → E_3 → [CAT] → E_4
      ↑                           ↑
   Boundary                    Boundary
```

**Characteristics**:

- Reduced validation overhead within trust domains
- Equivalent to JWT signature verification at boundaries
- PCA remains cryptographically valid between validations
- Appropriate for: internal microservices, performance-critical paths

**Security note**: Hops between validations operate with signed PCA. Authority cannot expand beyond ops_i even without intermediate validation.

### 5.3.3 Validation Strategy: Entry-Point Validation

Validate once at system entry:

```text
E_0 → [CAT] → E_1 → E_2 → E_3 → E_4
      ↑
   Entry point
```

**Characteristics**:

- Minimal validation overhead
- Equivalent to session-based authentication
- Appropriate for: trusted execution environments, legacy integration, development/testing

**Security note**: Equivalent trust model to traditional authorization where credentials are validated once and trusted thereafter.

### 5.3.4 Comparison to Existing Protocols

PIC provides equivalent flexibility to existing authorization protocols:

| Protocol | Typical Validation Pattern | PIC Equivalent |
|----------|---------------------------|----------------|
| OAuth 2.0 | Per API call | Full Validation (5.3.1) |
| JWT with trusted issuers | At boundary | Selective Validation (5.3.2) |
| Session cookies | At entry | Entry-Point Validation (5.3.3) |
| mTLS | Per connection | Selective Validation (5.3.2) |

**Implementation guidance**: Choose validation frequency based on:

- Trust boundaries in your architecture
- Performance requirements
- Compliance obligations
- Threat model

---

## 5.4 Integration with Existing Systems

PIC is designed to augment existing authorization infrastructure rather than replace it. This section provides integration patterns for common authorization systems.

### 5.4.1 OAuth 2.0 Integration

```text
User → OAuth AS → JWT (contains p_0, ops_0)
         ↓
Client → CAT (validates JWT, derives PCA_1)
         ↓
PCA_1 → Executor chain
```

**Integration approach**:

1. OAuth Authorization Server issues JWT with user identity and scopes
2. CAT validates JWT and derives initial PCA_0 (p_0 = user_id, ops_0 = scopes)
3. Subsequent hops use PIC validation
4. OAuth AS remains authoritative for identity and initial authorization

**Migration path**: Replace token validation endpoints with CAT validation while maintaining OAuth for user authentication and initial authorization.

### 5.4.2 SPIFFE Integration

```text
Workload → SPIFFE Server → SVID
            ↓
         CAT validates SVID (uses as PoI)
            ↓
         Issues PCA (p_0 = SPIFFE ID)
```

**Integration approach**:

1. SPIFFE Server issues SVIDs for workload identity
2. CAT validates SVID as Proof of Identity (PoI)
3. CAT derives PCA with SPIFFE ID as origin subject
4. Workload continues to use SPIFFE for identity

**Migration path**: No changes to SPIFFE infrastructure. CAT becomes additional validation layer that consumes SPIFFE identities.

### 5.4.3 API Gateway Integration

```text
Client → API Gateway (CAT role)
         ↓
      validates credentials
         ↓
      derives PCA_0
         ↓
      forwards to backend with PCA
```

**Integration approach**:

1. API Gateway performs existing authentication
2. Gateway acts as CAT, deriving initial PCA_0
3. Backend services validate PCA instead of gateway-issued tokens
4. Gateway remains single entry point

**Migration path**: Upgrade gateway to act as CAT. Backend services migrate from token validation to PCA validation incrementally.

---

## 5.5 Deployment Considerations

### 5.5.1 CAT Implementation Options

As described in Section 3.1.2, the CAT MAY be implemented as:

**Centralized Service**:

- Single authorization service
- Similar to OAuth Authorization Server deployment
- Appropriate for: single organization, centralized policy management

**Decentralized System**:

- Distributed consensus (blockchain, distributed ledger)
- Trust Model verified across nodes
- Appropriate for: multi-party systems, trustless environments

**Federated Model**:

- Multiple CATs with inter-CAT trust verification
- Each domain operates independent CAT
- Appropriate for: multi-organization systems, cross-domain authorization

### 5.5.2 Performance Optimization

**Caching**:

- PCA validation results MAY be cached within trust boundaries
- Cache invalidation required on revocation events
- Similar to JWT validation result caching

**Batching**:

- Multiple PCA requests MAY be batched for validation
- Reduces round-trips in high-throughput scenarios
- Similar to token introspection batching in OAuth

**Async Validation**:

- Validation MAY occur asynchronously for audit purposes
- Execution proceeds optimistically
- Violations detected post-facto
- Appropriate for: compliance logging, non-critical paths

---

## 5.6 Security-Performance Trade-offs

Like all authorization systems, PIC requires implementers to balance security and performance based on their threat model.

**Security Properties at Different Validation Frequencies**:

| Property | Full Validation | Selective Validation | Entry Validation |
|----------|----------------|---------------------|------------------|
| Confused deputy prevention | ✓ Enforced | ✓ Enforced | ✓ Enforced |
| Authority monotonicity | ✓ Validated each hop | ✓ Validated at boundaries | ✓ Initial only |
| Executor revocation | ✓ Immediate | ✓ At next boundary | ✗ Delayed |
| Audit trail completeness | ✓ Complete | ✓ Boundaries only | ✓ Entry only |
| Replay attack prevention | ✓ Strong | ✓ Boundary-level | ✓ Entry-level |

**Recommendation**: Validate at trust boundaries as minimum. Full validation provides maximum security assurance but incurs higher overhead.

---

## 5.7 Comparison to Possession-Based Models

The fundamental distinction between PIC (Proof of Continuity) and possession-based models (Proof of Possession):

**Possession-Based (PoP)**:

- Authority derives from artifact possession (token, certificate, key)
- Artifact can be used by any holder
- Confused deputy possible when service reuses client credentials
- No causal relationship to origin
- Ambient authority

**Continuity-Based (PoC)**:

- Authority derives from execution provenance
- Authority bound to specific execution context
- Confused deputy structurally impossible (proven in [[1]](#references))
- Causal chain to origin maintained
- Explicit authority derivation

**Security Implication**: PoP models require additional mechanisms (audience restrictions, token binding, etc.) to mitigate confused deputy. PIC eliminates the class of vulnerabilities by construction.

**Performance Implication**: PoC validation is computationally equivalent to PoP validation (both require cryptographic operations and policy evaluation). The difference is in the security guarantees, not computational cost.

---

## 5.8 Adoption Path

Organizations MAY adopt PIC incrementally:

**Phase 1 - Assessment**:

- Identify confused deputy risks in existing systems
- Map current authorization flows
- Determine trust boundaries

**Phase 2 - Pilot**:

- Deploy CAT in single trust domain
- Integrate with existing OAuth/SPIFFE
- Validate at boundaries only (5.3.2)
- Measure performance impact

**Phase 3 - Expansion**:

- Extend to additional domains
- Increase validation frequency in high-security paths
- Implement revocation mechanisms
- Complete audit trail integration

**Phase 4 - Full Deployment**:

- System-wide PIC enforcement
- Deprecated possession-based patterns in critical paths
- Continuous monitoring and validation

This incremental approach allows organizations to realize PIC security benefits while managing migration risk and maintaining operational continuity.

## 6. Security Considerations

This section analyzes the security properties of the PIC Model and compares its attack resistance to possession-based (token-based) authorization systems. The analysis demonstrates how PIC's continuity-based approach eliminates entire classes of attacks that are inherent to token possession models.

---

## 6.1 Threat Model

### 6.1.1 Assumptions

The PIC Model operates under the following security assumptions:

**Trusted Components**:
- The CAT (Trust Plane) is trusted and operates correctly
- The Trust Model (cryptographic primitives, TEE, consensus, etc.) provides non-forgeable bindings
- The Policy Decision Point (PDP) enforces policies correctly

**Untrusted Components**:
- Executors are untrusted and may be compromised
- Network communication may be intercepted (man-in-the-middle)
- Execution environments may be hostile

**Attacker Capabilities**:
- Network eavesdropping (passive attack)
- Network tampering (active attack)
- Executor compromise (malicious or vulnerable service)
- Credential theft (stolen keys, tokens, certificates)
- Replay attacks (captured messages reused)

### 6.1.2 Out of Scope

The following are considered out of scope for this threat model:
- Compromise of the CAT itself (trusted component)
- Breaking of cryptographic primitives (collision attacks on SHA-256, factoring RSA, etc.)
- Side-channel attacks on cryptographic implementations
- Social engineering attacks on end users
- Physical attacks on hardware security modules

---

## 6.2 Attacks Prevented by PIC

This section catalogs attacks that are **inherent** to token-based systems but are **structurally impossible** in PIC-compliant systems.

### 6.2.1 Confused Deputy Attack

**Attack Description**:

A confused deputy attack occurs when a service (deputy) with elevated privileges is tricked into performing an action on behalf of a less-privileged client, using the deputy's own authority rather than the client's authority.

**Token-Based Systems (VULNERABLE)**:

```
User (limited authority)
  │
  │ Request: "Delete my file: /home/user/doc.txt"
  ▼
Service (broad authority: delete:*)
  │
  │ Service uses its own token with delete:*
  │ Attacker manipulates path to: /admin/critical.txt
  ▼
Backend executes: DELETE /admin/critical.txt
  ❌ CONFUSED DEPUTY: Service's authority used, not user's
```

**Why Token-Based is Vulnerable**:
- Service holds token with authority `delete:*`
- Service uses same token for all operations
- Backend cannot distinguish "acting for user" from "acting as service"
- No causal link to user's original authority

**PIC Model (IMMUNE)**:

```
User (ops_0 = {delete:/home/user/*})
  │
  │ PCA_0 with ops_0 = {delete:/home/user/*}
  ▼
Service (receives PCA_1 with ops_1 ⊆ ops_0)
  │
  │ Service requests PCA_2 from CAT
  │ CAT enforces ops_2 ⊆ ops_1 ⊆ ops_0
  ▼
Backend receives PCA_2 with ops_2 = {delete:/home/user/*}
  ✓ IMMUNE: Backend can only delete within ops_0
  ✓ Attempt to delete /admin/critical.txt rejected by CAT (ops violation)
```

**Why PIC is Immune**:
- Authority derived from user's PCA_0, not service's credentials
- Monotonicity enforced: ops_2 ⊆ ops_1 ⊆ ops_0
- CAT validates all transitions, prevents authority expansion
- **Structural impossibility**: Service cannot exceed ops_0

**Formal Proof**: See [[1]](#references)

---

### 6.2.2 Token Theft and Reuse

**Attack Description**:

An attacker steals a token (bearer token, session cookie, API key) and reuses it to impersonate the legitimate holder.

**Token-Based Systems (VULNERABLE)**:

```
Legitimate User
  │ Token: "Bearer abc123..."
  ▼
[Network Intercept]
  │
Attacker steals token
  │ Reuses: "Bearer abc123..."
  ▼
Service accepts token
  ❌ IMPERSONATION SUCCESS
```

**Why Token-Based is Vulnerable**:
- Token validity independent of execution context
- Possession = authority (bearer token)
- No binding to specific execution flow
- Token usable anywhere, by anyone

**PIC Model (RESISTANT)**:

```
Executor E_n (has PCA_n)
  │
[Attacker intercepts PCA_n]
  │
Attacker attempts to use PCA_n
  │ Submits to CAT for PCA_{n+1}
  ▼
CAT validation:
  ✓ Validates PoI (attacker's identity)
  ✓ Validates PoP (attacker's credentials)
  ❌ REJECTED: Executor binding mismatch
  ❌ REJECTED: PoI doesn't match PCA_n's executor binding
```

**Why PIC is Resistant**:
- PCA bound to executor characteristics (federation, namespace, attributes)
- Attacker's PoI won't match expected executor binding
- Challenge-response (if used) requires attacker's credentials
- **Cannot reuse PCA outside its execution context**

**Additional Protection (with PCC)**:
- Fresh challenge prevents replay
- Challenge response requires executor's signing key
- Stolen PCA unusable without executor's private key

---

### 6.2.3 Privilege Escalation

**Attack Description**:

A service with limited authority escalates to higher privileges by manipulating tokens or exploiting validation gaps.

**Token-Based Systems (VULNERABLE)**:

```
Service A (token: read:*)
  │
  │ Calls Service B (token: write:*)
  │ Service B's token leaked to A
  ▼
Service A uses Service B's token
  │ Now has write:* authority
  ▼
Backend executes write operation
  ❌ PRIVILEGE ESCALATION
```

**Why Token-Based is Vulnerable**:
- No enforcement of authority monotonicity
- Token validity independent of caller chain
- Service can acquire higher-privilege tokens
- No structural guarantee against expansion

**PIC Model (IMMUNE)**:

```
Service A (PCA_1 with ops_1 = {read:*})
  │
  │ Requests PCA_2 from CAT
  │ Proposes ops_2 = {write:*}
  ▼
CAT validation:
  ✓ Checks ops_2 ⊆ ops_1
  ❌ REJECTED: {write:*} ⊄ {read:*}
```

**Why PIC is Immune**:
- **Monotonicity enforced**: ops_{i+1} ⊆ ops_i for all transitions
- CAT validates every authority transition
- Impossible to expand authority beyond ops_0
- **Structural guarantee**: authority can only decrease or remain constant

---

### 6.2.4 Ambient Authority Exploitation

**Attack Description**:

A service holds broad ambient authority (e.g., "admin" token) and an attacker exploits this to perform unauthorized operations by tricking the service into acting on malicious input.

**Token-Based Systems (VULNERABLE)**:

```
Service (token: admin, authority: *)
  │
  │ Attacker sends: "Process file: /etc/passwd"
  ▼
Service uses admin token
  │ Executes: READ /etc/passwd
  ▼
Backend accepts (token has authority)
  ❌ AMBIENT AUTHORITY EXPLOITED
```

**Why Token-Based is Vulnerable**:
- Service holds single token with broad authority
- All operations use same token regardless of origin
- No differentiation between legitimate and malicious requests
- Authority not scoped to original request

**PIC Model (IMMUNE)**:

```
User request (ops_0 = {read:/home/user/*})
  │
  │ PCA_0 with ops_0
  ▼
Service (receives PCA_1 with ops_1 = {read:/home/user/*})
  │
  │ Attacker manipulates input: "/etc/passwd"
  │ Service requests ops_2 = {read:/etc/passwd}
  ▼
CAT validation:
  ✓ Checks ops_2 ⊆ ops_1
  ❌ REJECTED: {read:/etc/passwd} ⊄ {read:/home/user/*}
```

**Why PIC is Immune**:
- Authority scoped to origin request (ops_0)
- Service cannot escape user's authority bounds
- CAT enforces monotonicity at every hop
- **No ambient authority**: every operation traceable to ops_0

---

### 6.2.5 Token Substitution Attack

**Attack Description**:

A malicious service substitutes the client's token with its own higher-privilege token to gain unauthorized access.

**Token-Based Systems (VULNERABLE)**:

```
Client (token_client: read:/data/*)
  │
  │ Sends: token_client
  ▼
Malicious Service
  │ Substitutes with token_service: read:*, write:*
  ▼
Backend receives token_service
  │ Executes write operation
  ▼
  ❌ TOKEN SUBSTITUTION SUCCESS
```

**Why Token-Based is Vulnerable**:
- No binding between tokens in a call chain
- Backend trusts any valid token
- No way to verify token derivation
- Service can replace client's token arbitrarily

**PIC Model (IMMUNE)**:

```
Client (PCA_0 with ops_0 = {read:/data/*})
  │
  │ Passes PCA_1 to service
  ▼
Malicious Service
  │ Attempts to substitute with higher-authority PCA
  │ Requests PCA_2 with ops_2 = {read:*, write:*}
  ▼
CAT validation:
  ✓ Checks PCA_1 signature
  ✓ Verifies PoC_2 references PCA_1
  ✓ Checks ops_2 ⊆ ops_1
  ❌ REJECTED: {read:*, write:*} ⊄ {read:/data/*}
```

**Why PIC is Immune**:
- PoC cryptographically binds to previous PCA
- CAT verifies causal chain (PCA_2 must derive from PCA_1)
- Monotonicity prevents authority expansion
- **Substitution detected**: PoC validation fails if PCA not in chain

---

### 6.2.6 Replay Attack

**Attack Description**:

An attacker captures a valid token and replays it later to gain unauthorized access.

**Token-Based Systems (VULNERABLE)**:

```
Legitimate request: "Bearer token123"
  │
[Attacker captures token]
  │
Attacker replays: "Bearer token123"
  │ (hours/days later)
  ▼
Service accepts token (still valid)
  ❌ REPLAY SUCCESS
```

**Why Token-Based is Vulnerable**:
- Long-lived tokens remain valid until expiry
- No binding to specific execution context
- No freshness mechanism (unless explicitly added)
- Token can be reused indefinitely within validity period

**PIC Model (RESISTANT)**:

**With PCC (Challenge-Response)**:

```
Executor requests PCC_i from CAT
  │
CAT issues fresh challenge (nonce, timestamp)
  │
Executor constructs PoC_i with challenge response
  │
[Attacker captures PoC_i]
  │
Attacker attempts replay
  ▼
CAT validation:
  ✓ Checks challenge response
  ❌ REJECTED: Challenge expired or already used
```

**Without PCC (Temporal Binding)**:

```
PCA_i contains temporal constraints (start_time + duration)
  │
[Attacker captures PCA_i]
  │
Attacker attempts replay (after validity period)
  ▼
CAT validation:
  ✓ Checks temporal constraints
  ❌ REJECTED: PCA expired
```

**Why PIC is Resistant**:
- Challenge-response prevents replay (fresh nonce per transition)
- Temporal constraints limit validity window
- Executor binding prevents use by wrong executor
- **Replay detection**: CAT tracks used challenges

---

### 6.2.7 Credential Forwarding Attack

**Attack Description**:

A service forwards the client's credentials to another service, allowing unauthorized lateral movement.

**Token-Based Systems (VULNERABLE)**:

```
Client → Service A (forwards client token)
           │
           └→ Service B (uses client token)
                │
                └→ Service C (uses same token)
                     │
                     └→ Any service in infrastructure
  ❌ UNRESTRICTED FORWARDING
```

**Why Token-Based is Vulnerable**:
- Single token usable across entire infrastructure
- No restriction on token propagation
- No visibility into execution chain
- "Token sprawl": credentials spread uncontrollably

**PIC Model (CONTROLLED)**:

```
Client (PCA_0)
  │
  ├→ Service A (receives PCA_1, requests PCA_2 from CAT)
      │
      ├→ Service B (receives PCA_2, requests PCA_3 from CAT)
          │
          ├→ Service C (receives PCA_3, requests PCA_4 from CAT)

Every transition validated by CAT:
  ✓ ops_i monotonically decreasing
  ✓ Executor binding validated
  ✓ Complete provenance tracked
```

**Why PIC is Controlled**:
- Each hop requires CAT validation
- Authority monotonically decreases (ops_i ⊆ ops_{i-1})
- Complete audit trail of all transitions
- **Controlled propagation**: no unrestricted forwarding

---

### 6.2.8 Cross-Service Impersonation

**Attack Description**:

Service A impersonates Service B by reusing Service B's token.

**Token-Based Systems (VULNERABLE)**:

```
Service B (token_B: high privileges)
  │ Token leaked/stolen
  │
Service A acquires token_B
  │ Uses token_B to impersonate Service B
  ▼
Backend accepts token_B
  ❌ IMPERSONATION: Service A acts as Service B
```

**Why Token-Based is Vulnerable**:
- Token validity independent of holder identity
- Possession = identity (bearer token)
- No binding between token and service identity
- Anyone with token can impersonate

**PIC Model (RESISTANT)**:

```
Service B (PCA_B with executor_binding for Service B)
  │
Service A attempts to use PCA_B
  │ Submits PoC with Service A's PoI
  ▼
CAT validation:
  ✓ Validates PoI (Service A's identity)
  ✓ Checks executor_binding in PCA_B
  ❌ REJECTED: Service A's PoI doesn't match PCA_B's executor_binding
```

**Why PIC is Resistant**:
- PCA bound to executor characteristics
- PoI must match executor_binding
- Service A cannot provide Service B's PoI
- **Impersonation prevented**: identity verification required

---

### 6.2.9 Man-in-the-Middle Token Modification

**Attack Description**:

An attacker intercepts communication and modifies tokens to escalate privileges.

**Token-Based Systems (VULNERABLE)**:

```
Client → Service
  │ Token: {user: alice, role: user}
  │
[MITM intercepts]
  │ Modifies to: {user: alice, role: admin}
  │ (if token not cryptographically protected)
  ▼
Service accepts modified token
  ❌ PRIVILEGE ESCALATION via MITM
```

**Why Token-Based is Vulnerable** (without signatures):
- Tokens may be transmitted without integrity protection
- JSON Web Tokens (JWT) without signatures (alg: none)
- Modification undetected if no cryptographic binding

**PIC Model (IMMUNE)**:

```
Executor → CAT
  │ PoC bundle signed by executor
  │
[MITM intercepts and modifies]
  │ Changes proposed_pca.ops to higher authority
  │
CAT validation:
  ✓ Verifies executor_signature on bundle
  ❌ REJECTED: Signature invalid (bundle modified)
```

**Why PIC is Immune**:
- All PoC bundles signed by executor
- CAT verifies signature before processing
- Modification breaks signature
- **Tampering detection**: cryptographic integrity guaranteed

---

### 6.2.10 Revocation Delay Exploitation

**Attack Description**:

A compromised service continues operating with valid token despite being revoked, due to long token lifetime or lack of revocation checking.

**Token-Based Systems (VULNERABLE)**:

```
Service compromised at t=0
  │ Token valid until t=3600 (1 hour)
  │
Administrator revokes service at t=10
  │
Service continues using token until t=3600
  │ Performs malicious operations
  ▼
  ❌ REVOCATION INEFFECTIVE (50-minute window)
```

**Why Token-Based is Vulnerable**:
- Long-lived tokens remain valid until expiry
- Revocation requires token blacklist (often not checked)
- No active verification at each operation
- Gap between revocation and expiry

**PIC Model (RESPONSIVE)**:

```
Service compromised at t=0
  │ Has PCA_i
  │
Administrator revokes service at t=10
  │ Updates CAT revocation list
  │
Service requests PCA_{i+1} at t=11
  │ Submits PoC with PoI
  ▼
CAT validation:
  ✓ Validates PoI (service identity)
  ✓ Checks revocation list
  ❌ REJECTED: Service revoked
```

**Why PIC is Responsive**:
- Revocation checked at every CAT validation
- Compromised service blocked immediately at next transition
- No reliance on token expiry
- **Immediate effect**: revocation enforced within one hop

---

## 6.3 Attack Comparison Summary

| Attack Vector | Token-Based | PIC Model | Mitigation Mechanism |
|---------------|-------------|-----------|---------------------|
| **Confused Deputy** | ❌ Vulnerable | ✅ Immune | Monotonicity + CAT validation |
| **Token Theft** | ❌ Vulnerable | ✅ Resistant | Executor binding + PoI/PoP |
| **Privilege Escalation** | ❌ Vulnerable | ✅ Immune | Structural monotonicity |
| **Ambient Authority** | ❌ Vulnerable | ✅ Immune | Scoped authority from ops_0 |
| **Token Substitution** | ❌ Vulnerable | ✅ Immune | Causal chain verification |
| **Replay Attack** | ❌ Vulnerable | ✅ Resistant | Challenge-response + temporal binding |
| **Credential Forwarding** | ❌ Uncontrolled | ✅ Controlled | CAT validation per hop |
| **Cross-Service Impersonation** | ❌ Vulnerable | ✅ Resistant | Executor binding enforcement |
| **MITM Modification** | ⚠️ Depends on JWT sig | ✅ Immune | Bundle signature required |
| **Revocation Delay** | ❌ Vulnerable | ✅ Responsive | Real-time revocation check |

**Legend**:
- ❌ **Vulnerable**: Attack succeeds with standard deployment
- ⚠️ **Depends**: Vulnerable unless additional measures taken
- ✅ **Resistant**: Attack very difficult but theoretically possible
- ✅ **Immune**: Attack structurally impossible

---

## 6.4 Residual Risks and Limitations

While PIC eliminates many attack classes, certain risks remain:

### 6.4.1 CAT Compromise

**Risk**: If the CAT itself is compromised, all security guarantees are void.

**Mitigation Strategies**:
- Deploy CAT in hardened environment (HSM, TEE)
- Use distributed CAT with consensus (no single point of failure)
- Implement CAT auditing and monitoring
- Federated CAT with cross-verification

### 6.4.2 Trust Model Vulnerabilities

**Risk**: Weaknesses in the underlying Trust Model (e.g., broken cryptographic primitives) undermine PIC guarantees.

**Mitigation Strategies**:
- Use battle-tested cryptographic libraries
- Regular security audits
- Crypto-agility (support for algorithm upgrades)
- Post-quantum readiness

### 6.4.3 Side-Channel Attacks

**Risk**: Timing attacks, cache attacks, or other side-channels may leak sensitive information.

**Mitigation**: Implementation-specific hardening (out of scope for this specification).

### 6.4.4 Denial of Service

**Risk**: Attacker floods CAT with validation requests, causing DoS.

**Mitigation Strategies**:
- Rate limiting per executor
- Batch validation
- Distributed CAT with load balancing
- Challenge-response to prevent request amplification

### 6.4.5 Policy Bypass

**Risk**: Misconfigured PDP policies allow unauthorized operations.

**Mitigation**: Policy testing, formal verification, least-privilege defaults (out of scope for PIC specification).

---

## 6.5 Security Design Principles

The PIC Model follows these security design principles:

1. **Least Privilege**: Authority monotonically decreases (ops_i ⊆ ops_{i-1})
2. **Separation of Concerns**: Untrusted execution (Executors) separated from trusted validation (CAT)
3. **Defense in Depth**: Multiple validation layers (PoC + PoI + PoP + PDP)
4. **Fail-Safe Defaults**: Operations rejected unless explicitly authorized
5. **Complete Mediation**: CAT validates every authority transition
6. **Open Design**: Security does not rely on secrecy of PIC mechanisms
7. **Audit Trail**: Complete provenance tracking for forensics
8. **Revocation**: Compromised executors immediately invalidated

---

## 6.6 Formal Security Properties

The PIC Model provides the following formally verifiable properties:

**Property 1 (Origin Immutability)**:
For all hops i in transaction τ: `p_i = p_0`

**Property 2 (Authority Monotonicity)**:
For all hops i in transaction τ: `ops_i ⊆ ops_{i-1}`

**Property 3 (Confused Deputy Impossibility)**:
For all executors E_i: E_i cannot exercise authority ops_j where ops_j ⊄ ops_i

**Property 4 (Causal Provenance)**:
For all PCA_i: There exists a verifiable chain PCA_0 → PCA_1 → ... → PCA_i

**Property 5 (Non-Transferability)**:
For all PCA_i: PCA_i is bound to executor E_i and cannot be used by E_j where j ≠ i

**Formal Proof**: See [[1]](#references) for complete proofs of these properties.

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

The PIC Model and the PIC Spec are canonically defined by this document as published in the official PIC Spec repositories (the “Official PIC Spec”).  
Forks and derivative specifications MAY exist, but MUST NOT represent themselves as the canonical PIC Model, the canonical PIC Spec, or the normative reference for PIC unless explicitly designated by the PIC Spec Contributors.

Any implementation, specification, library, framework, or document that:

- uses the **PIC Model** as defined in this specification, or  
- claims compatibility with, conformance to, or derivation from the **PIC Model** or the **PIC Spec**
  (e.g., “PIC-compliant”, “PIC-based”, “PIC-inspired”, “implements the PIC Spec”),

**MUST** provide clear, visible, and unambiguous attribution to:

1. **Gallo, N.** as the original author of the **PIC Model** and the associated Authority Propagation framework; and  
2. this specification (the **PIC Spec**) and its maintainers, the **PIC Spec Contributors**, as the editors and custodians of the normative specification.

Attribution **MUST NOT** omit the original author in favor of contributors, implementers, or downstream projects.

These attribution requirements DO NOT restrict contribution, experimentation, or the creation of forks and derivative works; they only ensure that conceptual authorship and normative provenance remain explicit as the ecosystem evolves.

An acceptable attribution statement includes, for example:

> “This work is based on the Provenance Identity Continuity (PIC) Model created by 
> Nicola Gallo. The model and its initial specification originate from this work. 
> Maintenance of the PIC Spec and related PIC Protocol documents is performed over 
> time by the PIC Spec Contributors, with authorship of the model remaining with 
> Nicola Gallo.”

---

### B.3 Derivative Works and Implementations

Derivative works, including modified specifications, extensions, profiles, or specialized adaptations:

- **MUST** clearly state that they are *derivative works* of the PIC Spec, and  
- **SHOULD** document any substantive semantic, security, or continuity-relevant changes.

Implementations (software libraries, SDKs, middleware, gateways, or services) **MAY** claim authorship of the implementation itself, **but MUST NOT** claim authorship of the PIC Model, its invariants, or its foundational design.

---

### B.4 Use of PIC Terminology

The terms **“PIC Model”**, **“Provenance Identity Continuity”**, **“PIC Spec”**, **“PIC-compliant”**, and similar designations **MUST NOT** be used in a way that:

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

“PIC Protocol” documents, when published, will define concrete protocol encodings and interoperability profiles that implement the PIC Model as specified in the PIC Spec.  
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

- [1] Gallo, N. (2025). *Authority Propagation Models: PoP vs PoC and the Confused Deputy Problem*. Zenodo. [doi.org/10.5281/zenodo.17833000](https://doi.org/10.5281/zenodo.17833000)
- [2] Gallo, N. (2025). *PIC Model — Provenance Identity Continuity for Distributed Execution Systems (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17777421](https://doi.org/10.5281/zenodo.17777421)
- [3] Gallo, N. (2025). *Authority is a Continuous System. (0.1-draft)*. Zenodo. [doi.org/10.5281/zenodo.17860199](https://doi.org/10.5281/zenodo.17860199)
