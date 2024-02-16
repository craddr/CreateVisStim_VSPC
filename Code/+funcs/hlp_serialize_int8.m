function output_arg = hlp_serialize_int8(input)
% serialises and converts to int8 without losing precision by converting to
% single, subtracting 128 and then converting to int8.  Should be used with
% hlp_serialize_int8 to deserialise.
% This should be used when sending data structures using UDP commands.
uint8_serialised    = funcs.hlp_serialize(input);
single_serialised   = single(uint8_serialised);
single_serialised   = single_serialised - 128;
output_arg          = int8(single_serialised);
end

