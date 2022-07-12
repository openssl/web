# Platform Policy

Platforms are classified as "primary", "secondary", "community"
and "unadopted". Support for a new platform should only be added if it
is being adopted as a primary, secondary or community platform.

Primary
:   *Definition:* A platform that is regularly tested through project CI
    on a project owned and managed system
    
    New Pull Requests (PRs) should not be merged unless the primary
    platforms are showing as "green" in CI. If the CI breaks for a
    branch (such as for a stable version or master) then it should be
    fixed as a priority.
    

Secondary
:   *Definition:* A platform that is regularly tested through project CI
    on a system that is not owned or managed by the project. At least
    one project committer must have access to the system and be able and
    willing to support it.
    
    New Pull Requests (PRs) should avoid introducing new breaks to CI in
    secondary platforms where possible but may still be merged where a
    resolution is not easily achievable without access to the platform.
    If the CI for a branch (such as for a stable version or master) on a
    secondary platform breaks, then a resolution should be sought as
    soon as is practically possible and before a release is made from
    the branch.
    

Community
:   *Definition:* Platforms that one or more members of the OpenSSL
    community have volunteered to support. May or may not be in
    project CI. Members of the community providing support do not have
    to be committers.
    
    Where a community platform is in project CI then new Pull Requests
    (PRs) should avoid introducing new breaks to CI on such platforms
    where possible but may still be merged where a resolution is not
    easily achievable without access to the platform. If the CI for a
    branch (such as for a stable version or master) on a community
    platform breaks, then an attempt should be made to contact the
    community maintainer to request a fix. In the event that a community
    platform is broken in CI for a protracted period then it may be
    dropped from CI.\
    If defects are raised that are specific to a community platform then
    the community maintainer may be contacted to help find a resolution.
    If a community maintainer is unresponsive, or unable to provide
    fixes then the platform may be moved to "unadopted".

Unadopted
:   *Definition:* Platforms that no one has volunteered to support.
    
    Support may still be provided for such platforms where possible
    without access to the platform itself. Platform specific issues may
    be left unresolved where it is not feasible to find a suitable fix.
    Support for such platforms may be removed entirely from the OpenSSL
    code base in future releases.

The current primary platforms are:

  Target                  O/S                          Architecture        Toolchain
  ------------------ ---- ----------------------- ---- -------------- ---- --------------------------------------
  linux-x86\_64           Ubuntu Server 20.04.3        x86\_64             gcc 9.3.0
  linux-generic64         Ubuntu Server 20.04.3        x86\_64             gcc 9.3.0
  linux-x86               Debian 11.2                  x86                 gcc 11.2.0
  linux-generic32         Debian 11.2                  x86                 gcc 11.2.0
  BSD-x86\_64             FreeBSD 13.0                 x86\_64             Clang 11
  VC-WIN64A               Windows 10                   x86\_64             Visual Studio 2019 Community Edition
  mingw64                 Windows 10                   x86\_64             MinGW (64 bit) and MSYS2
  darwin64-x86\_64        Mac OS Big Sur (11)          x86\_64             clang 12.?
  darwin64-arm64          Mac OS Big Sur (11)          AArch64 (M1)        clang 12.?

The current secondary platforms are:

  Target        O/S        Architecture        Toolchain        Nominated Committer(s)
  -------- ---- ----- ---- -------------- ---- ----------- ---- ------------------------
  ??            ??         ??                  ??               ??

The current community platforms are:

  -------------------------------------------------------------------------------------------------------------------
  Target                            O/S               Architecture           Toolchain           Nominated Community
                                                                                                 Member(s)
  ------------------------- ------- --------- ------- -------------- ------- ----------- ------- --------------------
  vms-alpha                         OpenVMS           alpha                  VSI C 7.4           \@levitte
                                    8.4                                                          

  vms-alpha-p32                     OpenVMS           alpha                  VSI C 7.4\          \@levitte
                                    8.4                                      (32 bit             
                                                                             pointer             
                                                                             build)              

  vms-alpha-p64                     OpenVMS           alpha                  VSI C 7.4\          \@levitte
                                    8.4                                      (64 bit             
                                                                             pointer             
                                                                             build)              

  vms-ia64                          OpenVMS           ia64                   VSI C 7.4           \@levitte
                                    8.4 8.4                                                      

  vms-ia64-p32                      OpenVMS           ia64                   VSI C 7.4\          \@levitte
                                    8.4                                      (32 bit             
                                                                             pointer             
                                                                             build)              

  vms-ia64-p64                      OpenVMS           ia64                   VSI C 7.4\          \@levitte
                                    8.4                                      (64 bit             
                                                                             pointer             
                                                                             build)              

  vms-x86\_64                       OpenVMS           x86\_64                VSI C X7.4\         \@levitte
                                    8.4                                      (cross              
                                                                             compile on          
                                                                             ia64,\              
                                                                             currently           
                                                                             build only)         

  nonstop-nsx                       NonStop           x86\_64 ilp32          c99                 \@rsbeckerca
                                    OSS                                                          
                                    L21.06                                                       

  nonstop-nsx\_put                  NonStop           x86\_64 ilp32          c99                 \@rsbeckerca
                                    OSS                                                          
                                    L21.06                                                       

  nonstop-nsx\_64                   NonStop           x86\_64 lp64           c99                 \@rsbeckerca
                                    OSS                                                          
                                    L21.06                                                       

  nonstop-nsx\_64\_put              NonStop           x86\_64 lp64           c99                 \@rsbeckerca
                                    OSS               PUT                                        
                                    L21.06                                                       

  nonstop-nsx\_spt                  NonStop           x86\_64 ilp32          c99                 \@rsbeckerca
                                    OSS               SPT                                        
                                    L21.06                                                       

  nonstop-nsx\_spt\_floss           NonStop           x86\_64 ilp32          c99                 \@rsbeckerca
                                    OSS               SPT FLOSS                                  
                                    L21.06                                                       

  nonstop-nsv                       NonStop           x86\_64 ilp32          c99                 \@rsbeckerca
                                    OSS                                                          
                                    L21.06                                                       

  nonstop-nse                       NonStop           ia64 ilp32             c99                 \@rsbeckerca
                                    OSS                                                          
                                    J06.22                                                       

  nonstop-nse\_put                  NonStop           ia64 ilp32 PUT         c99                 \@rsbeckerca
                                    OSS                                                          
                                    J06.22                                                       

  nonstop-nse\_64                   NonStop           ia64 lp64              c99                 \@rsbeckerca
                                    OSS                                                          
                                    J06.22                                                       

  nonstop-nse\_64\_put              NonStop           ia64 lp64 PUT          c99                 \@rsbeckerca
                                    OSS                                                          
                                    J06.22                                                       

  nonstop-nse\_spt                  NonStop           ia64 ipl32 SPT         c99                 \@rsbeckerca
                                    OSS                                                          
                                    J06.22                                                       

  nonstop-nse\_spt\_floss           NonStop           ia64 ipl32 SPT         c99                 \@rsbeckerca
                                    OSS               FLOSS                                      
                                    J06.22                                                       

  linux64-loongarch64               Linux             loongarch64            gcc                 \@shipujin

  BSD-ppc                           FreeBSD           ppc                    LLVM                \@pkubaj

  BSD-ppc64                         FreeBSD           ppc64                  LLVM                \@pkubaj

  BSD-ppc64le                       FreeBSD           ppc64le                LLVM                \@pkubaj

  BSD-riscv64                       FreeBSD           riscv64                LLVM                \@pkubaj

  solaris64-x86\_64-gcc             Solaris           x86\_64                gcc                 \@orcl-jlana
                                                                                                 \@cernoseka

  solaris64-x86\_64-cc              Solaris           x86\_64                Sun C               \@orcl-jlana
                                                                                                 \@cernoseka

  solaris64-sparcv9-gcc             Solaris           Sparc V9 64            gcc                 \@orcl-jlana
                                                      bit                                        \@cernoseka

  solaris64-sparcv9-cc              Solaris           Sparc V9 64            Sun C               \@orcl-jlana
                                                      bit                                        \@cernoseka

  linux64-s390x                     Linux             s390x                  gcc                 \@juergenchrist
                                                                                                 \@ifranzki

  linux-aarch64                     Linux             aarch64                gcc                 \@zorrorffm
                                                                                                 \@daniel-hu-arm
                                                                                                 \@xkqian
                                                                                                 \@tom-cosgrove-arm
  -------------------------------------------------------------------------------------------------------------------

The current unadopted platforms are:

  Target                        O/S                                      Architecture               Toolchain
  ------------------------ ---- ----------------------------------- ---- --------------------- ---- -------------------------
  vos-gcc                       VOS                                      ??                         gcc
  solaris-x86-gcc               Solaris                                  x86                        gcc
  solaris-sparcv7-gcc           Solaris                                  Sparc V7                   gcc
  solaris-sparcv8-gcc           Solaris                                  Sparc V8                   gcc
  solaris-sparcv9-gcc           Solaris                                  Sparc V9 32 bit            gcc
  solaris-sparcv7-cc            Solaris                                  Sparc V7                   Sun C
  solaris-sparcv8-cc            Solaris                                  Sparc V8                   Sun C
  solaris-sparcv9-cc            Solaris                                  Sparc V9 32 bit            Sun C
  irix-mips3-gcc                Irix 6.x                                 mips64 n32                 gcc
  irix-mips3-cc                 Irix 6.x                                 mips64 n32                 ??
  irix64-mips4-gcc              Irix 6.x                                 mips64 n64                 gcc
  irix64-mips4-cc               Irix 6.x                                 mips64 n64                 ??
  hpux-parisc-gcc               HP-UX                                    parisc                     gcc
  hpux-parisc1\_1-gcc           HP-UX                                    parisc 1.1 32 bit          gcc
  hpux64-parisc2-gcc            HP-UX                                    parisc 2.0 64 bit          gcc
  hpux-parisc-cc                HP-UX                                    parisc                     ??
  hpux-parisc1\_1-cc            HP-UX                                    parisc 1.0 32 bit          ??
  hpux64-parisc2-cc             HP-UX                                    parisc 2.0 64 bit          ??
  hpux-ia64-cc                  HP-UX                                    IA64 32 bit                ??
  hpux64-ia64-cc                HP-UX                                    IA64 64 bit                ??
  hpux-ia64-gcc                 HP-UX                                    IA64 32 bit                gcc
  hpux64-ia64-gcc               HP-UX                                    IA64 64 bit                gcc
  MPE/iX-gcc                    MPE/iX                                   parisc?                    gcc
  tru64-alpha-gcc               Tru64                                    alpha                      gcc
  tru64-alpha-cc                Tru64                                    alpha                      ??
  linux-ppc                     Linux                                    ppc32                      gcc
  linux-ppc64                   Linux                                    ppc64 big endian           gcc
  linux-ppc64le                 Linux                                    ppc64 little endian        gcc
  linux-armv4                   Linux                                    armv4                      gcc
  linux-arm64ilp32              Linux                                    aarch64-ilp32              gcc
  linux-mips32                  Linux                                    mips32 o32                 gcc
  linux-mips64                  Linux                                    mips64 n32                 gcc
  linux64-mips64                Linux                                    mips64 64 bit              gcc
  linux64-riscv64               Linux                                    riscv64                    gcc
  linux-x86-clang               Linux                                    x86                        clang
  linux-x86\_64-clang           Linux                                    x86\_64                    clang
  linux-x32                     Linux                                    x86\_64 x32                gcc
  linux-ia64                    Linux                                    ia64                       gcc
  linux32-s390x                 Linux                                    s390x 31 bit               gcc
  linux-sparcv8                 Linux                                    sparc v8                   gcc
  linux-sparcv9                 Linux                                    sparc v9 32 bit            gcc
  linux64-sparcv9               Linux                                    sparc v9 64 bit            gcc
  linux-alpha-gcc               Linux                                    alpha                      gcc
  linux-c64xplus                Linux                                    c64xplus                   gcc
  linux-c64xplus                Linux                                    c64xplus                   gcc
  BSD-x86                       FreeBSD / OpenBSD / NetBSD / ?           x86 a.out                  ??
  BSD-x86-elf                   FreeBSD / OpenBSD / NetBSD / ?           x86 elf                    ??
  BSD-sparcv8                   ?                                        Sparc v8                   ??
  BSD-sparcv9                   ?                                        Sparc v9 32 bit            ??
  BSD-ia64                      ?                                        IA64                       ??
  BSD-x86\_64                   OpenBSD / NetBSD / ?                     x86\_64                    ??
  bsdi-elf-gcc                  BSDi                                     ??                         ??
  unixware-2.0                  unixware 2.0                             ??                         ??
  unixware-2.1                  unixware 2.1                             ??                         ??
  unixware-7                    unixware 7                               x86                        ??
  unixware-7-gcc                unixware 7                               x86                        gcc
  sco5-cc                       Open Server 5?                           x86                        ??
  sco5-gcc                      Open Server 5?                           x86                        gcc
  aix-gcc                       AIX                                      ppc32                      gcc
  aix64-gcc                     AIX                                      ppc64                      gcc
  aix64-gcc-as                  AIX                                      ppc64                      gcc with as?
  aix-cc                        AIX                                      ppc32                      ??
  aix64-cc                      AIX                                      ppc64                      ??
  BS2000-OSD                    BS2000/OSD                               ??                         ??
  VC-WIN64I                     Windows XP / Windows Server 2008?        ia64                       Visual C
  VC-WIN32                      Windows 10                               x86                        Visual C
  VC-CE                         Windows CE                               x86 / armv4?               Visual C
  VC-WIN64A-masm                Windows 10                               x86                        Visual C with masm
  mingw                         Windows 10?                              x86                        gcc
  UEFI-x86                      UEFI                                     x86                        ??
  UEFI-x86\_64                  UEFI                                     x86\_64                    ??
  UWIN                          UWIN                                     x86                        ?
  Cygwin-x86                    Windows 10                               x86                        gcc
  Cygwin-x86\_64                Windows 10                               x86\_64                    gcc
  darwin-ppc                    MacOS?                                   ppc32                      ?
  darwin64-ppc                  MacOS?                                   ppc64                      ?
  darwin-i386                   MacOS?                                   x86                        ?
  darwin-i386                   MacOS?                                   x86                        ?
  hurd-x86                      Hurd                                     x86                        gcc
  vxworks-ppc60x                vxworks                                  ppc32                      ?
  vxworks-ppcgen                vxworks                                  ppc32                      ?
  vxworks-ppc405                vxworks                                  ppc32 405                  ?
  vxworks-ppc750                vxworks                                  ppc32 750                  ?
  vxworks-ppc860                vxworks                                  ppc32 860                  ?
  vxworks-simlinux              vxworks                                  x86?                       ?
  vxworks-mips                  vxworks                                  mips32 o32                 ?
  uClinux-dist                  uClinux                                  ?                          gcc
  uClinux-dist64                uClinux                                  ?                          gcc
  android-arm                   android                                  armv4                      ?
  android-arm64                 android                                  aarch64                    ?
  android-mips                  android                                  mips32 o32                 ?
  android-mips64                android                                  mips64                     ?
  android-x86                   android                                  x86                        ?
  android-x86\_64               android                                  x86\_64                    ?
  ios-xcrun                     iOS                                      armv7                      ?
  ios64-xcrun                   iOS                                      aarch64                    ?
  iossimulator-xcrun            iOS                                      ?                          ?
  iphoneos-cross                iphoneos?                                ?                          ?
  ios-cross                     iOS                                      armv7                      ?
  ios64-cross                   iOS                                      aarch64                    ?
  BC-32                         Windows 10?                              x86                        Borland C, C++ Builder?
  DJGPP                         DOS?                                     x86?                       djgpp
  haiku-x86                     Haiku                                    x86                        gcc?
  haiku-x86\_64                 Haiku                                    x86\_64                    gcc?
  nonstop-nsx\_g                NonStop Guardian                         x86\_64 ilp32              ?
  nonstop-nsx\_g\_tandem        NonStop Guardian                         x86\_64 ilp32              ?
  nonstop-nse\_g                NonStop Guardian                         ia64 ipl32                 ?
  nonstop-nse\_g\_tandem        NonStop Guardian                         ia64 ipl32                 ?
  OS390-Unix                    zOS                                      s390                       ?
  VC-WIN32-ONECORE              Windows OneCore                          x86                        Visual C
  VC-WIN64A-ONECORE             Windows OneCore                          x86\_64                    Visual C
  VC-WIN32-ARM                  Windows OneCore                          arm                        Visual C
  VC-WIN64-ARM                  Windows OneCore                          aarch64                    Visual C
  VC-WIN32-UWP                  Windows UWP                              x86                        Visual C
  VC-WIN64A-UWP                 Windows UWP                              x86\_64                    Visual C
  VC-ARM-UWP                    Windows UWP                              arm                        Visual C
  VC-ARM64-UWP                  Windows UWP                              aarch64                    Visual C
