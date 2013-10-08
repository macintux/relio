-type input_type() :: 'string'|'float'|'integer'|'float_as_integer'|'custom'.
-type validation_fun() :: fun((string()) -> 'true'|'false').
-type conversion_fun() :: fun((term()) -> term()).
-type input_options() :: {'validation', list(validation_fun())} |
                         {'conversion', list(conversion_fun())} |
                         {'prompt', string()}.
-type input_results() :: {term(), string()}.

