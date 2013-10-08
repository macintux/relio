%%% @author John Daily <jd@epep.us>
%%% @copyright (C) 2013, John Daily
%%% @doc
%%%   
%%% @end
%%% Created : 28 Sep 2013 by John Daily <jd@epep.us>

-module(relio_funs).
-include("relio.hrl").
-compile(export_all).

-spec get_line(string()) -> string().
get_line(Prompt) ->
    chomp(io:get_line(Prompt)).

    
-spec is_integer(string()) -> 'true'|'false'.
is_integer(String) ->
    case re:run(String, "^\\s*[+-]?\\d+\\s*$", [{capture, none}]) of
        match ->
            true;
        nomatch ->
            false
    end.

-spec convert_integer(string()) -> integer().
convert_integer(String) ->
    list_to_integer(string:strip(String)).

-spec not_blank(string()) -> 'true'|'false'.
not_blank(String) ->
    case re:run(String, "\\S", [{capture, none}]) of
        match ->
            true;
        nomatch ->
            false
    end.

convert_float({Value, []}, _Int) ->
    Value;
convert_float(_Float, {Value, []}) ->
    Value * 1.0; %% floatify that int
convert_float(_, _) ->
    throw(cannot_convert_float).


-spec convert_float(string()) -> float().
convert_float(String) ->
    convert_float(string:to_float(String),
                  string:to_integer(String)).

-spec is_float(string()) -> 'true'|'error'.
is_float(String) ->
    case {string:to_float(String), string:to_integer(String)} of
        {{error, _}, {error, _}} ->
            error;
        _ ->
            true
    end.

-spec chomp(string()) -> string().
%% chomp: remove end of line
chomp(String) ->
    re:replace(String, "(\\n|\\r)+", "", [{return, list}]).

-spec trim(string()) -> string().
%% trim: remove all leading or trailing whitespace, including end of line
trim(String) ->
    re:replace(String, "(^\\s+)|(\\s+$)", "", [{return, list}, global]).
