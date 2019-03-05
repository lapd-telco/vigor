open Str
open Core
open Fspec_api
open Ir
open Common_fspec

let lb_flow_struct = Ir.Str ( "LoadBalancedFlow", ["src_ip", Uint32;
                                                   "dst_ip", Uint32;
                                                   "src_port", Uint16;
                                                   "dst_port", Uint16;
                                                   "protocol", Uint8;])
let lb_backend_struct = Ir.Str ( "LoadBalancedBackend", ["nic", Uint16;
                                                         "mac", ether_addr_struct;
                                                         "ip", Uint32])

let ip_addr_struct = Ir.Str("ip_addr", ["addr", Uint32])

(* FIXME: borrowed from ../nf/vigbalancer/lb_data_spec.ml*)
let containers = ["flow_to_flow_id", Map ("LoadBalancedFlow", "flow_capacity", "lb_flow_id_condition");
                  "flow_heap", Vector ("LoadBalancedFlow", "flow_capacity", "");
                  "flow_chain", DChain "flow_capacity";
                  "flow_id_to_backend_id", Vector ("uint32_t", "flow_capacity", "lb_flow_id2backend_id_cond");
                  "ip_to_backend_id", Map ("ip_addr", "backend_capacity", "lb_backend_id_condition");
                  "backend_ips", Vector ("ip_addr", "backend_capacity", "");
                  "backends", Vector ("LoadBalancedBackend", "backend_capacity", "lb_backend_condition");
                  "active_backends", DChain "backend_capacity";
                  "cht", CHT ("backend_capacity", "cht_height");
                  "backend_capacity", UInt32;
                  "flow_capacity", UInt32;
                  "cht_height", UInt32;
                  "", EMap ("LoadBalancedFlow", "flow_to_flow_id", "flow_heap", "flow_chain");
                  "", EMap ("ip_addr", "ip_to_backend_id", "backend_ips", "active_backends");
                 ]

let fun_types =
  String.Map.of_alist_exn
    (common_fun_types @
     [hash_spec lb_flow_struct;
     "loop_invariant_consume", (loop_invariant_consume_spec containers);
     "loop_invariant_produce", (loop_invariant_produce_spec containers);
      "dchain_allocate", (dchain_alloc_spec [("65536", Some "LoadBalancedFlowi");
                                             ("20", Some "ip_addri")]);
      "dchain_allocate_new_index", (dchain_allocate_new_index_spec (gen_dchain_map_related_specs containers));
      "dchain_rejuvenate_index", (dchain_rejuvenate_index_spec (gen_dchain_map_related_specs containers));

     "dchain_is_index_allocated", dchain_is_index_allocated_spec;
     "dchain_free_index", (dchain_free_index_spec ["LoadBalancedFlowi", lma_literal_name "LoadBalancedFlow", "last_flow_searched_in_the_map";
                                                   "ip_addri", lma_literal_name "ip_addr", "last_ip_addr_searched_in_the_map"]) ;
     "expire_items_single_map", (expire_items_single_map_spec ["LoadBalancedFlowi";"ip_addri"]);
      "map_allocate", (map_alloc_spec
                         [{typ="LoadBalancedFlow";coherent=true;entry_type=lb_flow_struct;open_callback=(fun name ->
                              "//@ open [_]LoadBalancedFlowp(" ^ name ^ ", _);\n")};
                          {typ="ip_addr";coherent=true;entry_type=ip_addr_struct;open_callback=(fun name ->
                               "//@ open ip_addrp(" ^ name ^ ", _);\n")}]);
      "map_get", (map_get_spec
                    [{typ="LoadBalancedFlow";coherent=true;entry_type=lb_flow_struct;open_callback=(fun name ->
                         "//@ open [_]LoadBalancedFlowp(" ^ name ^ ", _);\n")};
                     {typ="ip_addr";coherent=true;entry_type=ip_addr_struct;open_callback=(fun name ->
                          "//@ open ip_addrp(" ^ name ^ ", _);\n")}]);
     "map_put", (map_put_spec [{typ="LoadBalancedFlow";coherent=true;entry_type=lb_flow_struct;open_callback=(fun name ->
                         "//@ open [_]LoadBalancedFlowp(" ^ name ^ ", _);\n")};
                     {typ="ip_addr";coherent=true;entry_type=ip_addr_struct;open_callback=(fun name ->
                          "//@ open ip_addrp(" ^ name ^ ", _);\n")}]);
      "map_erase", (map_erase_spec [{typ="LoadBalancedFlow";coherent=true;entry_type=lb_flow_struct;open_callback=(fun name ->
                         "//@ open [_]LoadBalancedFlowp(" ^ name ^ ", _);\n")};
                     {typ="ip_addr";coherent=true;entry_type=ip_addr_struct;open_callback=(fun name ->
                          "//@ open ip_addrp(" ^ name ^ ", _);\n")}]);
     "map_size", map_size_spec;
     "cht_find_preferred_available_backend", cht_find_preferred_available_backend_spec;
      "vector_allocate", (vector_alloc_spec [
          {typ="LoadBalancedFlow";has_keeper=true;entry_type=lb_flow_struct;open_callback=(fun name ->
               "//@ open [_]LoadBalancedFlowp(*" ^ name ^ ", _);\n")};
          {typ="uint32_t";has_keeper=false;entry_type=Uint32;open_callback=noop};
          {typ="ip_addr";has_keeper=true;entry_type=ip_addr_struct;open_callback=noop};
          {typ="LoadBalancedBackend";has_keeper=false;entry_type=lb_backend_struct;open_callback=(fun name ->
               "//@ open [_]LoadBalancedBackendp(*" ^ name ^ ", _);\n" ^
               "//@ open [_]ether_addrp(" ^ name ^ "->mac, _);\n")};
          {typ="uint32_t";has_keeper=false;entry_type=Uint32;open_callback=noop};]);
      "cht_fill_cht", cht_fill_cht_spec;
      "vector_borrow", (vector_borrow_spec [
          {typ="LoadBalancedFlow";has_keeper=true;entry_type=lb_flow_struct;open_callback=(fun name ->
               "//@ open [_]LoadBalancedFlowp(*" ^ name ^ ", _);\n")};
          {typ="uint32_t";has_keeper=false;entry_type=Uint32;open_callback=noop};
          {typ="ip_addr";has_keeper=true;entry_type=ip_addr_struct;open_callback=noop};
          {typ="LoadBalancedBackend";has_keeper=false;entry_type=lb_backend_struct;open_callback=(fun name ->
               "//@ open [_]LoadBalancedBackendp(*" ^ name ^ ", _);\n" ^
               "//@ open [_]ether_addrp(" ^ name ^ "->mac, _);\n")};
          {typ="uint32_t";has_keeper=false;entry_type=Uint32;open_callback=noop};]);
     "vector_return", (vector_return_spec [
          {typ="LoadBalancedFlow";has_keeper=true;entry_type=lb_flow_struct;open_callback=(fun name ->
               "//@ open [_]LoadBalancedFlowp(*" ^ name ^ ", _);\n")};
          {typ="uint32_t";has_keeper=false;entry_type=Uint32;open_callback=noop};
          {typ="ip_addr";has_keeper=true;entry_type=ip_addr_struct;open_callback=noop};
          {typ="LoadBalancedBackend";has_keeper=false;entry_type=lb_backend_struct;open_callback=(fun name ->
               "//@ open [_]LoadBalancedBackendp(*" ^ name ^ ", _);\n" ^
               "//@ open [_]ether_addrp(" ^ name ^ "->mac, _);\n")};
          {typ="uint32_t";has_keeper=false;entry_type=Uint32;open_callback=noop};]);])

module Iface : Fspec_api.Spec =
struct
  let preamble = gen_preamble "vigbalancer/lb_loop.h" containers
  let fun_types = fun_types
  let boundary_fun = "loop_invariant_produce"
  let finishing_fun = "loop_invariant_consume"
  let eventproc_iteration_begin = "loop_invariant_produce"
  let eventproc_iteration_end = "loop_invariant_consume"
  let user_check_for_complete_iteration = In_channel.read_all "balancer_forwarding_property.tmpl"
end

(* Register the module *)
let () =
  Fspec_api.spec := Some (module Iface) ;

