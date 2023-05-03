---
breadcrumb: CVEs and FIPS
---
# CVEs and the FIPS provider

After the release of OpenSSL 3.0.0, several CVEs have been identified
and resolved.  While the majority of these vulnerabilities are unrelated
to the validated FIPS provider, a few of them are applicable.  This table
lists all of the CVEs issued since the FIPS provider's release and their
relevance to it:


CVE ID | Fixed | FIPS? | Notes
----- | :-: | :-: | :---------------
CVE-2023-1255 | 3.0.9 | **yes** | Possible denial of service on Arm 64 (aarch64) using AES XTS mode
CVE-2023-0466 | 3.0.9 | no |
CVE-2023-0465 | 3.0.9 | no |
CVE-2023-0464 | 3.0.9 | no |
CVE-2023-0401 | 3.0.8 | no |
CVE-2023-0286 | 3.0.8 | no |
CVE-2023-0217 | 3.0.8 | **yes** | DSA public key checks (but not from TLS)
CVE-2023-0216 | 3.0.8 | no |
CVE-2023-0215 | 3.0.8 | no |
CVE-2022-4450 | 3.0.8 | no |
CVE-2022-4304 | 3.0.8 | **yes** | Timing side channel in RSA
CVE-2022-4203 | 3.0.8 | no |
CVE-2022-3996 | 3.0.8 | no |
CVE-2022-3786 | 3.0.7 | no |
CVE-2022-3602 | 3.0.7 | no |
CVE-2022-3358 | 3.0.6 | no |
CVE-2022-2274 | 3.0.5 | no | Bug introduced in 3.0.4 which isn't validated
CVE-2022-2097 | 3.0.5 | no | Architecture (x86) is not part of validation
CVE-2022-2068 | 3.0.4 | no |
CVE-2022-1473 | 3.0.3 | no |
CVE-2022-1434 | 3.0.3 | no |
CVE-2022-1343 | 3.0.3 | no |
CVE-2022-1292 | 3.0.3 | no |
CVE-2022-0778 | 3.0.2 | _maybe_ | Difficult to encounter inside FIPS boundary
CVE-2021-4160 | 3.0.1 | no | Architecture (MIPS) is not part of validation
CVE-2021-4044 | 3.0.1 | no |

