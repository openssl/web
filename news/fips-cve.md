---
breadcrumb: CVEs and FIPS
---
# CVEs and the FIPS provider

After the release of OpenSSL 3.0.0, several CVEs have been identified
and resolved.  While the majority of these vulnerabilities are unrelated
to the validated FIPS providers, a few of them are applicable.  This table
lists all of the CVEs issued since the FIPS providers' releases and their
relevance to it:

**CVE ID** | **Fixed** | **FIPS?** | **Notes**
----- | --: | :-: | :---------------
[CVE-2023-6237] | 3.0.13<br>3.1.5<br>3.2.1 | **yes** | EVP_PKEY_public_check() can take a long time
[CVE-2023-6129] | 3.0.13<br>3.1.5<br>3.2.1 | no | 3.0.13, 3.1.5 and 3.2.1 are not released yet
[CVE-2023-5678] | 3.0.13<br>3.1.5 | no | 3.0.13 and 3.1.5 are not released yet
[CVE-2023-5363] | 3.0.12<br>3.1.4 | no |
[CVE-2023-4807] | 3.0.11<br>3.1.3 | no |
[CVE-2023-3817] | 3.0.10<br>3.1.2 | no |
[CVE-2023-3446] | 3.0.10<br>3.1.2 | no |
[CVE-2023-2975] | 3.0.10<br>3.1.2 | no |
[CVE-2023-2650] | 3.0.9<br>3.1.1 | no |
[CVE-2023-1255] | 3.0.9<br>3.1.1 | **yes** | Possible denial of service on Arm 64 (aarch64) using AES XTS mode
[CVE-2023-0466] | 3.0.9<br>3.1.1 | no |
[CVE-2023-0465] | 3.0.9<br>3.1.1 | no |
[CVE-2023-0464] | 3.0.9<br>3.1.1 | no |
| | | | **Release of 3.0.8 FIPS provider**
[CVE-2023-0401] | 3.0.8 | no |
[CVE-2023-0286] | 3.0.8 | no |
[CVE-2023-0217] | 3.0.8 | **yes** | DSA public key checks (but not from TLS)
[CVE-2023-0216] | 3.0.8 | no |
[CVE-2023-0215] | 3.0.8 | no |
[CVE-2022-4450] | 3.0.8 | no |
[CVE-2022-4304] | 3.0.8 | **yes** | Timing side channel in RSA
[CVE-2022-4203] | 3.0.8 | no |
[CVE-2022-3996] | 3.0.8 | no |
[CVE-2022-3786] | 3.0.7 | no |
[CVE-2022-3602] | 3.0.7 | no |
[CVE-2022-3358] | 3.0.6 | no |
[CVE-2022-2274] | 3.0.5 | no | Bug introduced in 3.0.4 which isn't validated
[CVE-2022-2097] | 3.0.5 | no | Architecture (x86) is not part of validation
[CVE-2022-2068] | 3.0.4 | no |
[CVE-2022-1473] | 3.0.3 | no |
[CVE-2022-1434] | 3.0.3 | no |
[CVE-2022-1343] | 3.0.3 | no |
[CVE-2022-1292] | 3.0.3 | no |
[CVE-2022-0778] | 3.0.2 | _maybe_ | Difficult to encounter inside FIPS boundary
[CVE-2021-4160] | 3.0.1 | no | Architecture (MIPS) is not part of validation
[CVE-2021-4044] | 3.0.1 | no |
| | | | **Release of 3.0.0 FIPS provider**

[CVE-2023-6237]: /news/vulnerabilities.html#CVE-2023-6237
[CVE-2023-6129]: /news/vulnerabilities.html#CVE-2023-6129
[CVE-2023-5678]: /news/vulnerabilities.html#CVE-2023-5678
[CVE-2023-5363]: /news/vulnerabilities.html#CVE-2023-5363
[CVE-2023-4807]: /news/vulnerabilities.html#CVE-2023-4807
[CVE-2023-3817]: /news/vulnerabilities.html#CVE-2023-3817
[CVE-2023-3446]: /news/vulnerabilities.html#CVE-2023-3446
[CVE-2023-2975]: /news/vulnerabilities.html#CVE-2023-2975
[CVE-2023-2650]: /news/vulnerabilities.html#CVE-2023-2650
[CVE-2023-1255]: /news/vulnerabilities.html#CVE-2023-1255
[CVE-2023-0466]: /news/vulnerabilities.html#CVE-2023-0466
[CVE-2023-0465]: /news/vulnerabilities.html#CVE-2023-0465
[CVE-2023-0464]: /news/vulnerabilities.html#CVE-2023-0464
[CVE-2023-0401]: /news/vulnerabilities.html#CVE-2023-0401
[CVE-2023-0286]: /news/vulnerabilities.html#CVE-2023-0286
[CVE-2023-0217]: /news/vulnerabilities.html#CVE-2023-0217
[CVE-2023-0216]: /news/vulnerabilities.html#CVE-2023-0216
[CVE-2023-0215]: /news/vulnerabilities.html#CVE-2023-0215
[CVE-2022-4450]: /news/vulnerabilities.html#CVE-2022-4450
[CVE-2022-4304]: /news/vulnerabilities.html#CVE-2022-4304
[CVE-2022-4203]: /news/vulnerabilities.html#CVE-2022-4203
[CVE-2022-3996]: /news/vulnerabilities.html#CVE-2022-3996
[CVE-2022-3786]: /news/vulnerabilities.html#CVE-2022-3786
[CVE-2022-3602]: /news/vulnerabilities.html#CVE-2022-3602
[CVE-2022-3358]: /news/vulnerabilities.html#CVE-2022-3358
[CVE-2022-2274]: /news/vulnerabilities.html#CVE-2022-2274
[CVE-2022-2097]: /news/vulnerabilities.html#CVE-2022-2097
[CVE-2022-2068]: /news/vulnerabilities.html#CVE-2022-2068
[CVE-2022-1473]: /news/vulnerabilities.html#CVE-2022-1473
[CVE-2022-1434]: /news/vulnerabilities.html#CVE-2022-1434
[CVE-2022-1343]: /news/vulnerabilities.html#CVE-2022-1343
[CVE-2022-1292]: /news/vulnerabilities.html#CVE-2022-1292
[CVE-2022-0778]: /news/vulnerabilities.html#CVE-2022-0778
[CVE-2021-4160]: /news/vulnerabilities.html#CVE-2021-4160
[CVE-2021-4044]: /news/vulnerabilities.html#CVE-2021-4044
