function output_arg = hlp_serialize_int8(input)
% deserialises data serialised with hlp_serialize_int8
single_serialised   = single(input);
single_serialised   = single_serialised + 128;
uint8_serialised    = uint8(single_serialised);
output_arg          = funcs.hlp_deserialize(uint8_serialised);
end

