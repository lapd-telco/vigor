# This file should be automatically generated by codegen script
# from the dataspec.ml, but currently has to be written by hand.
# it contains extracts from it translated from OCaml speak to Python.
# Here you define three dictionaries: 
# - objConstructors maps method calls into
#      a dictionary with meta information about the return type of the method
#      if the method has a nontrivial return type.
#      the metainformation dictionary must define the 
#       - name of the constructor for the type: 'constructor'
#       - typename: 'type'
#       - properties of the compound object: 'fields', an array of strings
# - typeConstructors maps constructors to the names of the types they produce
# - stateObjects for the NF state objects (global), which are persisted
#      across packet processing maps object name to the object type.
#      here the object type is one of predefined types: emap, vector or None

# An example of an objConstructors entry:
#
# 'dyn_vals.get' : {'constructor' : 'DynamicValuec',
#                   'type' : 'DynamicValuei',
#                   'fields' : ['bucket_size', 'bucket_time']}},
#
# This translates into: invocation of a method get on the
# global object dyn_vals returns a DynamicValuei instance,
# that can be constructed (or destructed) by the DynamicValuec constructor
# and has at least two fields: bucket_size and bucket_time
# the symbols mentioned in the type meta information are defined
# in the autogenerated file dynamic_value.h.gen.h
objConstructors = {}

# An example of a typeConstructors entry:
#
# 'ip_addrc' : 'ip_addri',
#
# note the different suffixes. These symbols are generated by the
# codegenertor script and are defined in the ip_addr.h.gen.h
typeConstructors = {}

# An example of a stateObjects entry:
#
# 'backends' : vector
#
# describing the backends object to be of type vector.
# The backends objects, as all the other objects mentioned 
# in this file is declared in the dataspec.ml file.
stateObjects = {}
