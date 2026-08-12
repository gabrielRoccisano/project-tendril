# Up Next

Instruction: INST-0002

## Task

Test scoped filesystem read access through a Tendril-owned tool.

## Objective

Prove that a custom Tendril tool can:

1. read a file explicitly inside its permitted scope;
2. reject a read outside that scope.

## Scope

bootstrap/experiments/harness-probe/

## Constraints

Do not modify the Tendril product.

Do not expose generic filesystem read access to the agent.

Do not test write access in this instruction.

Do not expand the experiment beyond the two read cases.

## Done When

One permitted read and one denied read have been attempted and independently checked.

Record the result as PASS, PARTIAL, or FAIL.
