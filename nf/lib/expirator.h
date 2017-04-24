#ifndef _EXPIRATOR_H_INCLUDED_
#define _EXPIRATOR_H_INCLUDED_

#include "containers/double-chain.h"
#include "containers/double-map.h"
#include "containers/map.h"
#include "containers/vector.h"
#include "coherence.h"

/**
  The function takes "coherent" chain allocator and hash map, and current time.
  It removes flows older than time simultaneously from the allocator and the
  map.
  @param chain - DoubleChain index allocator. Items in the allocator are
                 tagged with timestamps.
  @param map - DoubleMap hash table holding flows synchronized with the allocator.
  @param time - Current number of seconds since the Epoch.

  @returns the number of expired flows.
 */
int expire_items/*@<K1,K2,V> @*/(struct DoubleChain* chain,
                                 struct DoubleMap* map,
                                 uint32_t time);
/*@ requires dmappingp<K1,K2,V>(?m, ?kp1, ?kp2, ?hsh1, ?hsh2,
                                ?fvp, ?bvp, ?rof, ?vsz,
                                ?vk1, ?vk2, ?rp1, ?rp2, map) &*&
             double_chainp(?ch, chain) &*&
             dchain_index_range_fp(ch) < INT_MAX &*&
             dmap_dchain_coherent<K1,K2,V>(m, ch); @*/
/*@ ensures dmappingp<K1,K2,V>(?nm,
                               kp1, kp2, hsh1, hsh2, fvp, bvp, rof, vsz,
                               vk1, vk2, rp1, rp2, map) &*&
            nm == dmap_erase_all_fp
                               (m, dchain_get_expired_indexes_fp(ch, time),
                               vk1, vk2) &*&
            double_chainp(?nch, chain) &*&
            nch == dchain_expire_old_indexes_fp(ch, time) &*&
            dmap_dchain_coherent<K1,K2,V>(nm, nch) &*&
            result == length(dchain_get_expired_indexes_fp(ch, time)); @*/

typedef void entry_extract_key/*@ <kt,et> (predicate (void*;kt) kp,
                                           predicate (void*;et) full_ep,
                                           predicate (void*,et) bare_ep,
                                           fixpoint (void*, void*, bool)
                                             right_offsets,
                                           fixpoint (et,kt) ek) @*/
                           (void* entry, void** key);
/*@ requires [?fr]full_ep(entry, ?e) &*& *key |-> _; @*/
/*@ ensures [fr]bare_ep(entry, e) &*& *key |-> ?nk &*&
            [fr]kp(nk, ek(e)) &*&
            true == right_offsets(entry, nk); @*/

typedef void entry_pack_key/*@ <kt,et> (predicate (void*;kt) kp,
                                        predicate (void*;et) full_ep,
                                        predicate (void*,et) bare_ep,
                                        fixpoint (void*, void*, bool)
                                          right_offsets,
                                        fixpoint (et,kt) ek) @*/
                           (void* entry, void* key);
/*@ requires [?fr]bare_ep(entry, ?e) &*&
             [fr]kp(key, ek(e)) &*&
             true == right_offsets(entry, key); @*/
/*@ ensures [fr]full_ep(entry, e); @*/

int expire_items_single_map/*@ <vt,kt> @*/(struct DoubleChain* chain,
                                           struct Vector* vector,
                                           struct Map* map,
                                           entry_extract_key* eek,
                                           entry_pack_key* epk,
                                           uint32_t time);
/*@ requires mapp<kt>(map, ?kp, ?hsh, mapc(?cap, ?m)) &*&
             [_]is_entry_extract_key<kt,vt>(eek, kp, ?fep, ?bep, ?roffs, ?ek) &*&
             [_]is_entry_pack_key<kt,vt>(epk, kp, fep, bep, roffs, ek) &*&
             vectorp<vt>(vector, ?entp, ?v) &*&
             double_chainp(?ch, chain) &*&
             map_vec_chain_coherent<kt,vt>(m, v, ch); @*/
/*@ ensures mapp<kt>(map, kp, hsh, mapc(cap, ?nm)) &*&
            vectorp<vt>(vector, entp, ?nv) &*&
            double_chainp(?nch, chain) &*&
            nch == dchain_expire_old_indexes_fp(ch, time) &*&
            map_vec_chain_coherent<kt,vt>(nm, nv, nch) &*&
            result == length(dchain_get_expired_indexes_fp(ch, time)); @*/
#endif //_EXPIRATOR_H_INCLUDED_
