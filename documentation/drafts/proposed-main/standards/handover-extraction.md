# Handover Extraction Standard

Status: CURRENT

## Purpose

This standard governs extraction of durable Project Tendril information from chat handovers and other draft source material.

Extraction converts source material into structured candidate project information.

Extraction does not itself:
- grant authority
- modify accepted Project Tendril documentation
- authorize discovered work
- execute discovered work

## Extraction Categories

- Decisions
- Architectural Invariants
- Behavioral / Operational Standards
- Logging / Reporting Standards
- Data and File Formats
- Naming Conventions
- Security / Permission Rules
- Implementation Requirements
- Plans / Candidate Tasks
- Terminology / Definitions
- Unresolved Questions
- Conflicts / Ambiguities
- Rejected / Superseded Ideas
- Proposed Documentation Changes
- Proposed Schema / Config / Code Changes
- Provenance

## Extracted Item Metadata

Every extracted item must include these fields:

- Source Strength
- Current State
- Source Section where identifiable

### Source Strength

Allowed values:

- EXPLICIT
- INFERRED
- UNCERTAIN

Definitions:

EXPLICIT
The information is directly stated in the source material.

INFERRED
The information is reasonably derived from the source material but is not directly stated.

UNCERTAIN
The information cannot be established reliably from the source material.

### Current State

Allowed values:

- UNKNOWN
- ALREADY REPRESENTED
- PARTIAL
- NEW
- CONFLICTING

Definitions:

UNKNOWN
The item's relationship to current Project Tendril state has not yet been assessed.

ALREADY REPRESENTED
The information is already represented in current Project Tendril state.

PARTIAL
Some, but not all, of the information is represented in current Project Tendril state.

NEW
The information is not currently represented in Project Tendril state.

CONFLICTING
The information conflicts with current Project Tendril state or with another relevant extracted item.

Rules:

- Extraction agents must assign Source Strength from the source material they are currently extracting.
- For the single-source default Current State behavior, see the Current State classification rule in Extraction Rules.
- Do not infer ALREADY REPRESENTED, PARTIAL, NEW, or CONFLICTING without actually inspecting the relevant authorized project state.
- Metadata describes the extraction; it does not grant authority to the extracted information.

### Source Section

The Source Section field records the source section or local source location supporting the extracted item.

This field is required when identifiable.

It must not be invented when no precise source location can be determined.

When unavailable, Source File provenance remains sufficient.

## Provenance

Every extraction artifact must identify its source document.

At minimum record:

Source File:
<path to the source handover or draft>

For each extracted item, record where identifiable:

Source Section:
<section heading or local source location>

Rules:

- Do not invent a source section if one cannot be identified.
- If no precise section can be identified, record only the source file.
- Provenance must remain attached to extracted information so later reconciliation can determine why the item exists.
- Provenance records origin only; it does not grant authority or acceptance.
- For source-document immutability during extraction, see Extraction Rules: The source document must remain unchanged.
- If an extracted item is supported by multiple locations in the same source, record all relevant source sections where practical.

## Extraction Rules

- Extraction does not grant authority.
- Do not silently resolve ambiguity.
- Do not invent decisions.
- Do not promote draft material into accepted documentation during extraction.
- Do not modify documentation/main/ during extraction.
- Do not execute candidate tasks discovered during extraction.
- Preserve conflicting statements for later reconciliation.
- Preserve uncertain information as uncertain.
- The source document must remain unchanged.
- One source handover produces one extraction artifact.
- Extraction output remains draft material until explicitly reviewed and accepted by the human.
- Do not perform cross-document reconciliation during single-source extraction.
- Do not expand beyond information supported by the authorized source.
- Do not classify Current State as ALREADY REPRESENTED, PARTIAL, NEW, or CONFLICTING unless the current task explicitly authorizes comparison against relevant project state.
- Follow-up work discovered during extraction may only be recorded as candidate work; it must not be performed.

## Output Requirements

- Extraction artifacts must be written beneath:

  /home/gabriel/project-tendril/documentation/drafts/extractions/

- See Extraction Rules for the one-source/one-artifact requirement; each extraction artifact is a Markdown file.
- The extraction artifact filename should clearly identify the source handover.
- Every extraction artifact must identify its source file.
- Extracted information must be grouped under the canonical extraction categories defined by this standard.
- Every extracted item must include:
  - Source Strength
  - Current State
  - Source Section where identifiable
- For the single-source default Current State behavior, see the Current State classification rule in Extraction Rules.
- Empty extraction categories must be retained and marked:

  none identified

- Preserve useful technical and architectural specificity.
- Remove conversational repetition only where doing so does not change meaning.
- Do not turn uncertain, inferred, provisional, or conflicting source material into definitive project statements.
- Do not merge multiple distinct extracted items merely to make the output shorter.
- Do not create accepted documentation, implementation changes, or authorized tasks from the extraction.
- Candidate documentation changes, schema/config/code changes, and tasks must remain proposals inside the extraction artifact.
- The extraction artifact remains draft material until human review and acceptance.

Require this minimum extraction artifact structure:

# Handover Extraction

## Source

Source File:
<path>

## Decisions

none identified

## Architectural Invariants

none identified

## Behavioral / Operational Standards

none identified

## Logging / Reporting Standards

none identified

## Data and File Formats

none identified

## Naming Conventions

none identified

## Security / Permission Rules

none identified

## Implementation Requirements

none identified

## Plans / Candidate Tasks

none identified

## Terminology / Definitions

none identified

## Unresolved Questions

none identified

## Conflicts / Ambiguities

none identified

## Rejected / Superseded Ideas

none identified

## Proposed Documentation Changes

none identified

## Proposed Schema / Config / Code Changes

none identified

## Provenance

none identified
