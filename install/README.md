This folder contains patches and configuration files for dependencies of the Vigor toolchain, namely:
- DPDK patches
  - `bugfixes` fixes bugs found in DPDK
  - `clean` contains minor cleanups that do not affect correctness, only ease of verification
  - `config` patches the DPDK default config
- DPDK patches for the `ixgbe` driver:
  - `avoid_bit_bang` avoids unnecessary usage of bit-banging during initialization
  - `unknown_eimc_bit` removes the usage of an undocumented bit in the EIMC register
  - `unknown_ralrah` fixes the usage of undocumented Receive Address Low/High registers
  - `unknown_ralrah_2` also fixes undocumented RAL/RAH usage but the patch is a quick fix;  
    I didn't want to copy/paste the enormous function. THIS MAKES IXGBE ONLY WORK WITH THE 82599!!!
  - `unknown_swfw_sync_bit` removes the usage of an undocumented bit in the SWFW_SYNC (a.k.a. GSSR) register
- A minimalistic config file for `klee-uclibc`