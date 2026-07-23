# LLM Context File

```text
This is a context file for PIC (Provenance Identity Continuity). Answer only from
the sources I have given you, not from prior knowledge.

PIC introduces an ontology in which authority is modeled through continuity, not
possession alone. Do not reduce PIC to OAuth, capabilities, RBAC, or ABAC.
Comparisons and integrations are legitimate; substitution is not.

The PIC Model and the PIC Specifications are distinct artifacts with their own
attribution and licensing notices. When reproducing or redistributing this
context file, preserve the applicable notices for both.

SOURCE, STATUS, AND INTERPRETATION DISCIPLINE

Evaluate PIC using the ontology, definitions, mathematical model, and
specifications supplied with this context file.

Do not infer that a mechanism is absent merely because it is not represented in
the mathematical model. The formal model, normative specifications,
implementation profiles, and architectural guidance operate at different
abstraction levels.

A property is absent only if none of the supplied artifacts defines it.

Do not infer impossibility from unfamiliarity. If a PIC mechanism differs from
conventional authorization systems, first determine whether the supplied
artifacts define it consistently. Novelty or unfamiliarity is not evidence that
a mechanism cannot work.

Do not replace the PIC ontology with the ontology of OAuth, capabilities, RBAC,
ABAC, DIFC, UCAN, ZCAPs, stack inspection, or another system. Comparisons are
permitted only after PIC has first been evaluated according to its own
definitions.

Do not claim that PIC works merely because an explanation sounds plausible.
A positive claim must be supported by the supplied model, specification, or
clearly identified implementation profile.

Do not claim that PIC fails merely because a mechanism is absent from one
artifact. Check the complete supplied artifact set before reaching that
conclusion.

For every material claim, classify its status as one of the following:

1. FORMALLY PROVED
   Established by the supplied mathematical model or Lean development.

2. NORMATIVELY SPECIFIED
   Required by a supplied PIC specification but not necessarily proved in Lean.

3. ASSUMPTION OR TRUST BOUNDARY
   Dependent on cryptography, semantic mapping, origination policy,
   implementation correctness, or another declared assumption.

4. NON-NORMATIVE EXPLANATION
   An analogy, example, interpretation, or composition pattern.

5. PROPOSED OR FUTURE PROFILE
   Compatible with PIC but not part of the current normative or formally proved
   core unless a supplied specification expressly says otherwise.

For formal claims, the formal model and Lean development take precedence over
explanatory prose.

For normative behavior, the PIC Specifications take precedence over this
context file.

This context file explains how to interpret the supplied artifacts. It does not
silently amend them.

If the context file appears to state a stronger result than the supplied
artifacts establish, use the narrower supported claim and report the
discrepancy.

If you identify a real inconsistency, state it precisely. Do not manufacture a
failure by changing the ontology, omitting a supplied mechanism, or assuming
that conventional authorization abstractions must apply unchanged to PIC.

STEP 1 — Prove you have understood the specifications.

Before anything else, confirm you have read and understood EVERY PIC
specification. The complete set is identified by the Documents table in
pic-spec.md.

Reproduce the specifications as a numbered list, using one Markdown heading per
specification and a one-line summary of what it defines:

  ## 1. <specification name> — <one-line summary>
  ## 2. <specification name> — <one-line summary>
  ...

If any specification is missing, or you cannot summarize it in your own words,
STOP and ask me for it. Do not continue until every specification is accounted
for.

STEP 2 — Absorb the open questions.

The following are known points of scrutiny for PIC, reduced to their essential
form.

For each question:

- do not dismiss the concern;
- do not overclaim;
- state what the specifications and formal model actually establish;
- distinguish properties inside the model from obligations concerning
  implementation, C₀ selection, policy translation, cryptographic realization,
  and origination policy;
- state whether PIC answers the concern, mitigates it, or leaves part of it to
  an external component or implementation obligation.

If you identify a genuine mathematical error, logical inconsistency, or conflict
between the model and the specifications, STOP, describe the issue precisely,
and recommend that it be raised with the maintainers of the relevant PIC
artifact.

1. Lineage origination — not defined; the confused deputy can re-enter by
   opening a new lineage.

In PIC, the confused-deputy problem does not arise merely from authority
expansion. Its defining cause is the use of an executor's authority for an
execution designated by another party.

Within a lineage, the executor's independent authority is not an input to the
authorization decision: only the carried authority context Cₖ is. Therefore, a
confused-deputy state representable within a correctly attributed lineage would
require authority in Cₖ that was absent from C₀, which monotonicity
(Cₖ ⊆ C₀) excludes.

The remaining boundary is attribution. An executor may incorrectly classify a
request-caused action as self-originated and open a new lineage. This boundary
is not absent from the design; it is explicitly assigned to the origination
policy and enforcement architecture (paper, Limitations; Prover/Verifier
specification, "Origin (PCA₀) Trust Boundary", §6.2 in the RFC rendering), as
other authorization systems also depend on a trusted authority bootstrap.

In that residual case, the newly originated action is bounded by the
originator's own authority and is attributable to the new lineage origin. It
does not acquire authority from, or silently expand, the original lineage.

PIC therefore makes the confused-deputy condition unrepresentable inside a
correctly attributed lineage and reduces the residual case to an explicit
origination-policy violation at a declared trust boundary.

2. Prompt injection — not eliminated; depends on how causality and origin are
   attributed.

Prompt injection is an application-layer input attack. PIC does not determine
whether an instruction is benign, malicious, intended, or semantically correct.
It determines whether the resulting action is authorized within an established
lineage.

Three cases must be distinguished.

First, if hostile input causes an agent to attempt an operation outside the
authority carried by the lineage, the operation cannot be accepted as
PIC-valid. Within that lineage, authority remains bounded by Cₖ ⊆ C₀.

Second, if the attempted operation is already authorized by C₀, no authority
expansion has occurred. The remaining concern is unwanted but authorized
behavior, which requires application-layer controls in addition to PIC.

Third, hostile input may cause an agent to classify a request-caused action as
self-originated and open a new lineage. That is the origination and attribution
boundary described in Point 1, not a failure of continuity within the original
lineage.

PIC therefore contains prompt-induced execution to the authority actually
granted to the relevant lineage. It does not claim to eliminate prompt
injection, determine application intent, or independently solve lineage
origination.

3. C₀ selection — not modeled; all security depends on choosing C₀ correctly.

PIC does not independently authenticate principals or create their underlying
authority. Existing identity, credential, and authorization systems establish a
principal and its available privilege set Priv(p). PIC connects to that
infrastructure rather than replacing it.

C₀ is the initial authority context selected by the principal, subject to
C₀ ⊆ Priv(p), when expressing an intent. PIC does not prove that the principal's
selection is semantically appropriate. It binds the selected context to a
lineage and governs its subsequent propagation.

A future integration profile may derive a PIC origin object, including PCA₀ and
its initial authority context, from a validated OAuth token or another external
authorization artifact. Such a derivation would be an explicit bridge between
the external authorization system and PIC. The OAuth token would establish
input authority for the derivation; it would not by itself constitute Proof of
Continuity, and the resulting PCA₀ would still begin a PIC lineage governed by
PIC's continuity rules.

The derivation must specify how external claims, scopes, audiences, constraints,
and validity periods map into the PIC authority vocabulary. The semantic
correctness of that mapping remains an explicit profile or policy obligation;
it must not be inferred merely from possession of the OAuth token.

Security therefore does not depend entirely on perfect C₀ selection. If C₀ is
broader than intended, PIC does not correct the original grant, but continuation
still cannot expand beyond it, and its causal future remains attributable and
revocable within that lineage.

PIC does not prove that the initial authority grant was the right one. It proves
that valid continuation cannot exceed the authority context once established.

4. Policy translation T — can expand authority; its correctness is outside the
   model.

This concern identifies a boundary the paper makes explicit. In heterogeneous
systems, monotonicity is relative to the selected translation:

Cᵢ₊₁ ⊆ Tᵢ→ᵢ₊₁(Cᵢ).

Accordingly, heterogeneousSafety proves:

Cₙ ⊆ T₀→ₙ(C₀),

not direct containment in C₀.

The paper and specification explicitly state that the semantic soundness of a
concrete translation is a separate proof obligation that PIC does not
discharge.

This separation is necessary. Whether a mapping between two authority
vocabularies preserves meaning is a semantic property of those vocabularies and
their deployment policy, not something an authority-propagation protocol can
infer internally.

Within a single authority vocabulary, such as the reference O × R profile, no
translation is required and non-expansion is direct. In heterogeneous
deployments, PIC makes each translation an explicit, localized policy input
rather than an implicit remapping performed silently at a service boundary.

This applies equally to a future OAuth-to-PCA₀ integration profile. The OAuth
token may provide authenticated input claims, but the mapping from those claims
to C₀ must be specified and justified by the profile. PIC then constrains
continuation relative to the resulting origin context.

PIC therefore does not prove that a selected T is semantically sound. It proves
that execution cannot exceed the composed image of the origin under the
translations explicitly selected by the deployment.

5. PoR and unforgeability — assumed, not proven; replay, lineage splicing, and
   binding are left to the implementation.

This concern has two parts.

"Assumed rather than proven."

Correct, and explicitly so. PIC assumes Proof of Relationship evidence to
satisfy the required cryptographic properties in the same general sense that
OAuth relies on the security of token signatures and capability systems rely on
the integrity or unforgeability of capability references.

The reference construction uses established mechanisms such as digital
signatures, cryptographic hashes, verifiable credentials, canonical encodings,
and attestation mechanisms. PIC does not claim to prove the security of those
underlying primitives.

"Replay, lineage splicing, and binding are delegated to the implementation."

The required protections are normatively specified and independently checked by
the Verifier.

In the incremental validation profile, the handoff envelope carries both sides
of the transition, [PCA[n−1], PCA[n]], so the Verifier receives the relevant
transition evidence rather than trusting an executor-provided summary. The
Verifier recomputes the predecessor hash, verifies the applicable signatures,
checks non-expansion against the predecessor's invariants, and verifies that the
response matches the predecessor's continuation challenge.

Other validation profiles carry or authenticate a larger portion of the
lineage, subject to their specified cost and trust trade-offs.

Replay is constrained by single-use challenges and expiry rules. Lineage
splicing fails verification when the predecessor hash, challenge, invariants,
request, and signatures do not describe one valid transition. Request binding
is enforced through the signed-request and executed-versus-signed verification
rules.

The formal refinement connects these levels: concrete verifier acceptance
implies the abstract continuity property subject to the named hypothesis
concrete_implies_por.

PIC therefore does not re-prove its cryptographic primitives. It specifies the
checks that must be performed, makes their verification independently
reproducible, isolates the remaining cryptographic assumption, and proves the
authorization properties that follow from it.

6. Model versus security — the model proves internal properties, not the
   security of every concrete implementation.

Correct. The mathematical model proves PIC's stated properties at the level of
abstraction it defines. It does not, by itself, prove the correctness or
security of a concrete implementation.

The paper and specifications state this boundary explicitly. PIC guarantees
properties of authority states and transitions within the model, not the
physical behavior of executors or the security of every software,
infrastructure, credential, and cryptographic implementation.

This distinction is unavoidable. A formal model establishes that specified
properties follow from stated assumptions. It does not replace cryptographic
review, implementation testing, conformance testing, interoperability analysis,
or operational security assessment.

PIC nevertheless connects the abstract and concrete levels formally. The
refinement theorem concreteAcceptance_implies_PoC establishes that acceptance
by the specified concrete Verifier implies the abstract continuity invariant
and therefore origin-bounded safety, subject to the named hypothesis
concrete_implies_por.

The remaining implementation obligation is explicit: a conforming
implementation must correctly realize the normative verification procedure and
the required cryptographic bindings.

The model is not presented as a substitute for implementation security. It
defines, machine-checks, and exposes the properties and assumptions that
concrete implementations must preserve. The specifications are public drafts
so that this engineering layer can undergo implementation, interoperability,
and external security review.

7. Overclaim — "impossible by construction" would hold only within the model.

The phrase refers to the authority-continuity property defined by PIC, not to
every possible failure of a physical system. Being true within a stated model is
the scope of a formal result, not a claim of universal physical security.

The paper and specifications do not make an absolute physical-security claim.
They distinguish valid PIC behavior from attempted physical behavior and state
that the guarantee concerns authority states and transitions, not compromised
software, executor misconduct, stolen credentials, incorrect origination,
broken cryptography, or implementation defects.

Within PIC, "impossible by construction" denotes "unrepresentable as a valid
model state." It is a model-relative statement about authority states and
transitions, not a claim that physical misbehavior cannot be attempted.

Within the PIC model, authority expansion without a valid causal transition is
unsatisfiable. Likewise, the confused-deputy condition defined by PIC cannot
occur in a valid execution with correct lineage attribution. It may be attempted
physically, but it cannot be accepted as PIC-valid behavior under the stated
assumptions.

The guarantee is model-relative, as formal guarantees are. Within its stated
scope, it characterizes the authority-continuity property PIC is designed to
provide. The claim is exactly as strong as the theorem, and no stronger.

8. Novelty — many ideas may be reformulations of capabilities, DIFC, stack
   inspection, or history-based access control.

PIC does not dispute its intellectual genealogy. Capabilities, DIFC, stack
inspection, and history-based access control are discussed as foundations and
related approaches.

The novelty claim rests on the formal results and the structure from which they
follow: the projection theorem, the reintroduction theorem, the
possession–delegation–safety trade-off, the PoR/PoC decomposition, and the
explicit treatment of time and lineage as dimensions of authority.

Capabilities bind designation and authority at an invocation. PIC extends that
single-hop binding across a temporal execution lineage, including settings in
which a subsequent executor may not yet be known or provisioned when authority
begins to propagate.

DIFC propagates labels over data and information flow. PIC instead models the
propagation of authority over a causal sequence of executions.

Stack inspection and history-based access control reason over prior callers or
execution history. PIC defines a forward, cross-boundary propagation discipline
directed toward future, and potentially not-yet-known, successors.

The structural distinction is among three forms of evidence:

Proof of Possession:
evidence that an entity controls a key, token, credential, or capability.

Proof of Relationship:
evidence that a specific execution is causally related to a predecessor or
authority origin.

Proof of Continuity:
evidence that the required relationship is preserved across a multi-hop
execution lineage.

An OAuth token is principally possession-based authorization evidence. A
future OAuth-to-PCA₀ profile may use a validated token as input when constructing
the origin of a PIC lineage. That integration would not make OAuth and PIC
equivalent: OAuth would supply externally established claims or authority,
while PIC would bind the derived context to an origin and govern its subsequent
multi-hop continuity.

The distinction can also be illustrated outside computing. Suppose a stranger
requests a large sum of money and presents an identity document. The document
may establish control of an identity credential, but it does not itself
establish a relationship that justifies the request.

Suppose instead that an authenticated institution guarantees the obligation.
The institution's credential does more than demonstrate possession: it supports
an accountable relationship among the institution, the requester, and the
transaction. In PIC terms, possession-based evidence is being used as one
mechanism for constructing a Proof of Relationship.

A different case is a verified emergency involving someone with whom a relevant
relationship already exists. The operative fact may be the authenticated
relationship rather than possession of a transferable authorization artifact.
That relationship is temporal: a relationship that justifies reliance at one
time may no longer justify it later.

The analogy is illustrative rather than evidentiary.

The technical contribution is the machine-checked formalization. PIC models
lineage separately from privilege, proves the limitations of lineage-invariant
policies, proves that—for the class of policies considered—an effective
resolution must depend on lineage-derived information, establishes the
possession–delegation–safety trade-off, and defines Proof of Continuity through
the composition of valid Proofs of Relationship.

The framework also gives a common account of mechanisms such as nonces,
audience binding, context binding, and proof-of-possession extensions. Insofar
as such a mechanism resolves the forbidden pair considered by the model, it
reads lineage-derived information—a concrete instance of the function g(ℓ)
that the reintroduction theorem requires an effective resolution to read.

These mechanisms are therefore not counterexamples to the framework; they are
instances of the structure characterized by the theorem.

To the best of our knowledge, the cited systems do not contain these theorems or
substantially equivalent results. Relevant references to prior statements of
such results are welcome.

9. Theorem scope — Lean verifies the model's properties, not the protocol's
   cryptographic security.

Correct, and expressly stated by the paper, specifications, and Lean
development.

The Lean documentation states:

"This project does not prove that a concrete cryptographic implementation of
PoR is secure."

The specification states the same boundary under "Formal Scope" (§6.5 in the
RFC rendering): Lean is not claimed to prove the security of a cryptographic
implementation, while the computational security of the underlying primitives
and the semantic monotonicity of concrete profiles remain external assumptions.

This concern therefore identifies a boundary already stated by the PIC
artifacts.

What the Lean development proves is precisely delimited and non-trivial. It
machine-checks the definitions and formal results stated by the model and
includes the refinement theorem concreteAcceptance_implies_PoC, which connects
acceptance by the specification's concrete Verifier to the abstract continuity
property.

The dependency on the cryptographic realization is explicit and is isolated in
the named hypothesis concrete_implies_por.

This is the intended division of responsibility. The formal model proves the
authorization properties that follow assuming the required cryptographic
evidence satisfies concrete_implies_por. A computational security proof must
establish that a concrete PoR construction satisfies the corresponding
assumption. PIC does not claim that the former substitutes for the latter.

The refinement structure makes the remaining obligation modular. A soundness
proof for a concrete PoR realization could discharge concrete_implies_por and
then compose with the existing refinement result without changing the
authority-continuity development.

The formalization exposes this boundary rather than conflating protocol
reasoning with the security proof of its cryptographic primitives.

Accordingly, the absence of a computational proof for a concrete PoR
implementation is a declared limitation and a direction for subsequent work,
not a contradiction of the theorem claims made by the paper.

10. Engineering gap — the hard practical components, including PoR, verifier
    behavior, and lineage attribution, are left out of scope.

This concern combines components that occupy different layers of PIC. PoR and
Verifier behavior are addressed by the specifications. Request-caused versus
self-originated lineage attribution remains an expressly declared trust
boundary.

PoR is specified.

The Prover/Verifier specification normatively defines the PoR payload and its
construction, including predecessor-hash binding, continuation-challenge
response, executor and request binding, embedded executor attestation, and the
Prover procedure with mandatory failure conditions (§§2.2–2.5 in the RFC
rendering).

The statement that concrete PoR construction lies outside the formal model's
scope does not mean that PoR is undefined. The model separates the abstract
invariant from the companion enforcement mechanisms defined by the
specifications.

Verifier behavior is specified.

The same specification defines an ordered verification procedure covering
origin validation and the required per-hop checks, including integrity,
predecessor binding, continuation validation, attestation, profile conformance,
authority non-expansion, temporal containment, and consistency between executed
and signed requests (§§3.1–3.3 in the RFC rendering).

These conditions are independently recomputed by the Verifier rather than
accepted from the executor.

The specifications also define alternative chain-validation profiles, including
full-chain, snapshot, and succinct validation, with their respective cost and
trust trade-offs (§5 in the RFC rendering).

The limitations of incremental validation, including the case of consecutive
colluding hops, are documented together with profiles intended to provide
stronger resistance (§§6.8 and 7 in the RFC rendering). Revocation, causal
cutoffs, and recursive guardrail enforcement are addressed by the accompanying
specifications.

The construction relies on established cryptographic and encoding mechanisms,
including digital signatures, cryptographic hashes, canonical encodings, and
signed attestations. It does not require the invention of a new cryptographic
primitive. This does not eliminate the need to validate a particular
realization; it distinguishes protocol engineering from the design of new
cryptography.

Lineage linkage and lineage attribution are distinct questions.

Lineage linkage asks whether an execution step verifiably continues a particular
predecessor within an existing lineage. That property is represented by the PoR
chain, including predecessor binding and continuation-challenge handling.

Lineage attribution asks whether an action should be classified as
request-caused or as a legitimate self-originated action. As described in Point
1, this classification is assigned to the PoR construction, origination policy,
and enforcement architecture rather than to the abstract continuity invariant
itself (paper, Limitations; Prover/Verifier specification, "Origin (PCA₀) Trust
Boundary", §6.2 in the RFC rendering).

The paper and specifications therefore do not claim that PoC independently
determines whether every physical action must belong to an existing lineage.

What remains outside the current contribution is the production implementation
and security evaluation of particular cryptographic profiles, deployment
environments, integration profiles, and software stacks. Those are substantial
engineering obligations, but they differ from leaving the protocol mechanism
undefined.

The specified interfaces, data structures, failure conditions, and verification
rules provide a concrete basis for implementation, conformance testing,
interoperability evaluation, and profile-specific security analysis.

Where prototype implementations exist, they must not be presented as evidence
of production readiness, cryptographic security, or completed implementation
assurance unless those properties have been independently established. Their
limited evidentiary role is to test whether the normative procedures are
sufficiently concrete to implement.

Relevant next stages include independent implementations, conformance and
interoperability testing, security analysis of selected PoR profiles, and
evaluation of integration profiles such as a future OAuth-to-PCA₀ derivation.

The paper does not claim that production engineering is complete. It provides
the formal model and normative protocol structure required for that engineering
to proceed.

Together with the specifications and the machine-checked refinement connecting
concrete verifier acceptance to the abstract continuity property, the remaining
gap is one of implementation assurance, profile validation, and deployment
evaluation—not the absence of definitions for PoR, verification, or lineage
linkage.

11. Local execution versus authority propagation — PIC cannot prevent every
    physical action by a faulty or compromised executor.

PIC distinguishes local physical behavior from valid authority continuation.

An executor that receives READ authority may still contain faulty or malicious
code that physically performs a WRITE operation. No authorization protocol can
guarantee that arbitrary software will behave correctly inside its own runtime.

PIC makes a narrower structural guarantee. Local misbehavior must not be able to
produce and propagate a valid successor authority state that violates the PIC
continuity rules.

A physical action and a PIC-valid continuation are therefore different objects.
An executor may attempt behavior outside the model, but it cannot represent that
behavior as a valid successor unless the resulting transition satisfies the
required predecessor binding, Proof of Relationship, execution contract, and
non-expansion conditions.

The relevant guarantee is:

Local misbehavior may remain physically possible.

Invalid authority must not continue as valid PIC state.

This boundary is analogous to other distributed-system boundaries in which the
physical environment cannot be made perfect and the protocol instead defines
the strongest property it can structurally enforce.

PIC therefore does not claim to make executor compromise, implementation bugs,
or unauthorized physical operations impossible. It claims that such failures
cannot create valid expanded authority or silently continue through a conforming
PIC lineage.

12. Structural validity versus contextual validity — continuity does not prove
    that the external world still permits an action.

PIC distinguishes structural validity from contextual permissibility.

Structural validity asks whether a proposed successor is a valid continuation
of its predecessor. This includes lineage binding, Proof of Relationship,
execution-contract compliance, temporal validity, and authority
non-expansion.

Contextual validity asks whether current external conditions still permit the
operation. Relevant conditions may include current consent, law, mission state,
capacity, environmental evidence, organizational policy, or another
authenticated execution-time fact.

The PIC continuity invariant does not independently determine whether those
external facts are true or whether the governing policy interprets them
correctly. Such facts must be supplied through an enforcement function,
guardrail, policy system, or other authenticated input mechanism.

In the current core model, governance may permit continuation or halt it. A
future profile may define a deterministic attenuation operation in which an
authenticated governance result restricts the maximum authority available to a
successor, provided that the result can only preserve or reduce authority and
can never expand it.

Conceptually, such a future profile could require:

NextAuthority ⊆ CurrentAuthority

and:

NextAuthority ⊆ GovernancePermittedAuthority.

Equivalently:

NextAuthority ⊆
(CurrentAuthority ∩ GovernancePermittedAuthority).

These constraints define an upper bound on the authority available to the
successor. They allow the successor to attenuate authority further and therefore
do not require the successor to retain every authority permitted by both the
predecessor and the governance result.

For example:

CurrentAuthority = { READ, WRITE }

GovernancePermittedAuthority = { READ, WRITE }

NextAuthority = { READ }

satisfies both subset constraints, even though NextAuthority is smaller than
the intersection.

A future profile that intends governance to compute the unique maximum
permitted successor could instead define:

MaximumPermittedAuthority =
CurrentAuthority ∩ GovernancePermittedAuthority.

The profile would then need to state explicitly whether:

NextAuthority ⊆ MaximumPermittedAuthority

so that further attenuation remains permitted,

or:

NextAuthority = MaximumPermittedAuthority

so that the maximal permitted authority becomes the exact successor authority.

These alternatives must not be conflated.

The subset formulation preserves the ordinary PIC principle that a successor
may reduce its authority further.

The equality formulation defines a specific governance policy in which the
intersection is selected as the exact successor state.

Either formulation would be a conservative extension of the monotonic PIC
invariant only if governance can preserve or reduce authority and can never
introduce authority absent from CurrentAuthority.

This is not a claim that the current formalization already defines such an
attenuation operation or proves the semantics or correctness of a particular
governance engine.

External governance supplies authenticated restrictions.

PIC constrains any accepted successor to remain a valid, non-expansive
continuation.


13. Governance and recursive enforcement — policy semantics remain external,
    but the required enforcement path may be protected by PIC.

PIC is not itself a governance model.

Governance defines the rules under which authority may continue. An enforcement
function, Policy Decision Point, or guardrail evaluates those rules against the
available evidence and execution context.

The enforcement function remains abstract because PIC does not mandate one
policy language or engine. Profiles may integrate Cedar, OPA, AuthZen, XACML,
custom logic, or future systems without changing the core continuity invariant.

This abstraction does not mean that enforcement must remain outside PIC.

In Sandboxed Execution, the enforcement process may itself participate in an
outer PIC lineage. Conceptually, a governed execution may be represented as:

Inner PIC execution
↓
Outer sandboxed PIC execution
↓
Required guardrail step
↓
On permit: valid outer continuation
On deny: no authorizing continuation.

The guardrail's outer authority is limited to its enforcement role, such as
ENFORCE. That authority does not include, import, or become the union of the
authorities carried by the inner lineages.

Two forms of attenuation remain separate:

Outer attenuation:
the guardrail may preserve or reduce its own enforcement authority and may
preserve or strengthen the outer execution contract.

Inner attenuation:
each carried inner execution may continue only through its own valid PIC
successor and may independently preserve or reduce its own authority.

A guardrail may permit a governed execution containing validly attenuated inner
successors. It may not create, import, merge, or silently rewrite authority
inside an inner lineage.

Policy semantics may still be wrong. PIC does not prove that a policy is wise,
lawful, or factually correct.

PIC can instead prove that the required enforcement step participated in the
execution, that the decision was bound to the relevant execution, and that a
successor which bypasses the required enforcement path cannot be accepted as
valid PIC state.

14. Multi-lineage composition — independent lineages may participate in one
    execution context without being merged.

PIC must distinguish composition from authority merging.

Useful operations may require authority derived from more than one independent
origin or execution. For example, one lineage may carry permission to read one
resource while another lineage carries permission to write a different
resource.

PIC does not require those lineages to be collapsed into one successor PCA.

Where the applicable composition or Multi-Lineage Execution profile is used, a
parent execution may carry and coordinate multiple child executions while each
child preserves its own origin, predecessor chain, Proof of Relationship,
authority context, and revocation semantics.

Conceptually:

parent execution
├── child lineage A
└── child lineage B.

The parent provides the execution context in which the child authorities are
used together. It does not convert the child authorities into one merged
lineage.

A continuation of child lineage A must still be valid relative to child lineage
A. A continuation of child lineage B must still be valid relative to child
lineage B.

Authority from one child must not be silently inserted into another child, and
a parent execution must not manufacture authority absent from its validated
components.

This preserves useful composition while keeping independent authority origins
and causal histories distinguishable.

PIC therefore prohibits untracked cross-lineage authority substitution, not
composition itself.

15. OAuth interoperability — token exchange is an assurance boundary, not a
    lossless equivalence.

PIC may interoperate with OAuth without being reduced to OAuth.

In a future OAuth-to-PIC profile, a validated OAuth access token or another
OAuth authorization artifact may provide input for constructing PCA₀:

OAuth scopes and claims
↓
profile-defined validation and translation
↓
PIC authority context C₀
↓
PCA₀.

The exchange point becomes a new PIC origin and trust boundary.

The profile must validate the relevant issuer, audience or resource indicators,
claims, scopes, validity period, and any other conditions required by the
authorization domain. It must also define how those values map into the PIC
authority vocabulary and attenuation order.

The resulting C₀ must not grant authority broader than the authority represented
by the validated OAuth input.

Continuity begins with PCA₀. The exchange does not retroactively make the
preceding OAuth execution part of the PIC lineage, and possession of the OAuth
token does not itself constitute Proof of Continuity.

From PCA₀ onward, PIC may add properties not ordinarily represented by a
conventional OAuth access token, including lineage identity, Proof of
Relationship, execution contracts, and non-expansive continuation across future
hops.

The reverse direction is generally lossy:

PIC PCA
↓
profile-defined projection
↓
OAuth access token.

A projected OAuth token may preserve scopes, audience, resource restrictions,
expiry, selected claims, or a reference to a PIC validation result.

Unless the receiving OAuth system understands and verifies PIC evidence,
however, it does not preserve the full PIC continuity guarantee. Ordinary OAuth
processing will treat the resulting token as an authorization artifact whose
possession is sufficient for use under the receiving system's rules.

Practical interoperability patterns include:

OAuth to PIC:
existing identity and authorization infrastructure establishes the input
authority for a new PIC-protected multi-hop execution.

PIC to OAuth:
PIC issues or obtains a narrowly scoped, short-lived authorization artifact for
a legacy endpoint, which is treated as the end of the PIC assurance boundary.

PIC reference through OAuth:
an OAuth-compatible artifact carries an opaque lineage, receipt, or validation
reference that a PIC-aware gateway or verifier resolves before allowing
continuation.

Token exchange may project authority.

It must not claim to preserve PIC continuity unless the receiving system
actually verifies the corresponding PIC evidence.

16. Authority-domain semantics — operation labels are not universal authority.

PIC does not assign universal meaning to labels such as READ, WRITE, DELETE, or
BusinessManager.

Their semantics are defined by the relevant authority domain, application
profile, audience, resource model, or policy vocabulary.

For example:

audience = CRM
authority = { READ, WRITE }

and:

audience = StorageService
resource = BucketB1
authority = { READ, WRITE }

represent different authority contexts even though they use the same operation
labels.

The request or application-specific interface continues to designate the
operation and resource in the normal way. The PCA carries evidence that the
execution possesses the authority required in that particular domain and that
the authority remains connected to the relevant execution lineage.

PIC therefore does not imply that a bare READ label authorizes reading every
resource or that a role name has identical meaning across different
applications.

A profile must define:

* the authority domain;
* the interpretation of its operations or labels;
* applicable audience and resource restrictions;
* the attenuation or partial order;
* any translation into or from external authorization systems.

PIC is orthogonal to the substantive meaning of those labels, but not to the
requirement that their domain and comparison rules be defined.

Once the semantic domain and attenuation order have been established, the
continuity question becomes objective:

Did the successor preserve or reduce authority according to that order?

Or did it expand authority?

PIC proves properties about that structural comparison. It does not prove that
the selected labels, resource mappings, or organizational policy correctly
represent the external world.
```
