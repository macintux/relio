%%% @author John Daily <jd@epep.us>
%%% @copyright (C) 2013, John Daily
%%% @doc
%%%   Simple functions for handling terminal input.
%%% @end
%%% Created : 28 Sep 2013 by John Daily <jd@epep.us>

-module(relio).
-vsn("1.0.0").
-include("relio.hrl").
-compile(export_all).
-export([get_input/2]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-spec promptify(string(), string()) -> string().
promptify(String, Marker) ->
    String ++ Marker.

%% get_input(type, Prompt, [list of additional validation funs])
%% Returns {Converted, String}
%% If (and only if) the requested type is "string" then the second
%% value returned will include all preceding and trailing
%% whitespace. Otherwise any such whitespace is removed
%%
%% Will force any input that doesn't match our expectations to be
%% re-entered. Should, but does not, provide the developer with the
%% option to allow blank lines to be entered and returned.

%% Example of specifying a custom input type:
%% 16> relio:get_input(standard_io, custom, "?", [{conversion, [fun erlang:hd/1]}]).
%% ? > a
%% {97,"a\n"}

%% Example of specifying a custom conversion:
%% 17> relio:get_input(standard_io, integer, "?", [{conversion, [fun(X) -> X * 2 end]}]).
%% ? > 4
%% {8,"4\n"}

%% Example of specifying an extra validator:
%% 24> ExtraValidFun = fun(X) -> case re:run(X, "\\.", [{capture, none}]) of match -> true; nomatch -> false end end.
%% #Fun<erl_eval.6.80484245>
%%
%% 25> relio:get_input(standard_io, float, "?", [{validation, [ExtraValidFun]}]).
%% ? > 34
%% ? > 42.0
%% {42.0,"42.0\n"}

-spec get_input(input_type(), string()) -> input_results().

get_input(What, Prompt) ->
    get_input(standard_io, What, Prompt, []).

-spec get_input(io:device(), input_type(), string()) -> input_results().
get_input(FH, What, Prompt) ->
    get_input(FH, What, Prompt, []).


-spec get_input(io:device(), input_type(), string(), list(input_options())) ->
                       input_results().
get_input(FH, Type, Prompt, Options) ->
    get_input(FH, Type,
              promptify(Prompt, proplists:get_value(prompt, Options, " > ")),
              proplists:get_value(Type, [
                                         {custom, []},
                                         {string, [fun relio_funs:not_blank/1]},
                                         {float, [fun relio_funs:not_blank/1,
                                                  fun relio_funs:is_float/1]},
                                         {integer, [fun relio_funs:is_integer/1]}
                                        ], []) ++
                  proplists:get_value(validation, Options, []),
              proplists:get_value(Type, [
                                         {custom, []},
                                         {string, [fun relio_funs:chomp/1]},
                                         {float, [fun relio_funs:convert_float/1]},
                                         {integer,
                                          [fun relio_funs:convert_integer/1]}
                                        ], []) ++
                  proplists:get_value(conversion, Options, [])
             ).


-spec get_input(io:device(), input_type(), string(),
                list(validation_fun()),
                list(conversion_fun())) ->
                       input_results().
get_input(FH, Type, FullPrompt, ValidationFuns, ConversionFuns) ->
    Raw = io:get_line(FH, FullPrompt),
    repeat_if_error(validate(Raw, ValidationFuns),
                    FH, Type, FullPrompt, Raw, ValidationFuns, ConversionFuns).

-spec repeat_if_error('true'|'false',
                      io:device(),
                      input_type(), string(), string(),
                      list(validation_fun()), list(conversion_fun())) ->
                             input_results().
repeat_if_error(true, _FH, _Type, _Prompt, Raw, _VF, ConversionFuns) ->
    {apply_conversions(relio_funs:trim(Raw), ConversionFuns), Raw};
repeat_if_error(false, FH, Type, Prompt, _Raw, VF, CF) ->
    get_input(FH, Type, Prompt, VF, CF).

-spec apply_conversions(string(), list(conversion_fun())) -> term().
apply_conversions(Input, ConversionFuns) ->
    lists:foldl(fun(X, Accum) -> X(Accum) end, Input, ConversionFuns).

-spec validate(string(), list(validation_fun())) ->
                      'true' | 'false'.
validate(Input, Funs) ->
    lists:foldl(fun(_X, false) -> false;
                   (X, true) -> X(Input) end,
                true, Funs).
                         


