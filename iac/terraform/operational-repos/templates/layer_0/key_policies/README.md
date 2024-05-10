# KMS Key Policies

## Overview

This directory contains the key policies for keys deployed through the provisioner. These policies will be attached to the per-service keys, potentially shared by multiple use-cases. Therefore, __it is important to follow least-privilege, particularly when delegating permissions to IAM policy__. Any key policy here should delegate only _use_ of the key to roles. Administrative use of the key should be limited to the provisioner role.

## Risks and Mitigations

Note that with the removal of per-resource keys and explicit principal references as a result of generalization, the security potential of KMS policy is reduced. However, this is an accepted risk as of January 2024 to be mitigated by effective identity policy and potentially key grants at a later date.

## References

Please refer to the _KMS - Remodelling_ reference below for in-depth documentation of the KMS infrastructure.

  - KMS - Remodelling: https://cpg-gpc.atlassian.net/l/cp/PHB701aB
