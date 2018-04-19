%%%-------------------------------------------------------------------
%%% @author marinakr
%%% Created : 18. Apr 2018 5:00 PM
%%%-------------------------------------------------------------------
-module(utils).
-author("marinakr").

%% API
-export([
  trim_first_last_whitespaces/1
]).


-spec trim_first_last_whitespaces(Name) -> NoWhitespaceName when
  Name :: list(),
  NoWhitespaceName :: list().

trim_first_last_whitespaces(Name) ->
  LName = trim_leading_whitespaces(Name),
  RName = trim_leading_whitespaces(lists:reverse(LName)),
  lists:reverse(RName).

-spec trim_leading_whitespaces(list()) -> list().

% Be accurate here with tabulation,
% Whitespace after $ is matter, it is whitespace symbol, 32
trim_leading_whitespaces([$ | Name]) ->
  trim_leading_whitespaces(Name);

trim_leading_whitespaces([$\t | Name]) ->
  trim_leading_whitespaces(Name);

trim_leading_whitespaces([$\n | Name]) ->
  trim_leading_whitespaces(Name);

trim_leading_whitespaces(Name) ->
  Name.
