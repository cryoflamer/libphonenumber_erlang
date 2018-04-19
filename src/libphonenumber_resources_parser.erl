%%%-------------------------------------------------------------------
%%% @author marinakr
%%% Created : 18. Apr 2018 4:07 PM
%%%-------------------------------------------------------------------
-module(libphonenumber_resources_parser).
-author("marinakr").

-include("../include/phonenumbers.hrl").

%% API
-export([
  carriers2memory/0
]).

carriers2memory() ->
  FullFilePath = code:priv_dir(libphonenumber_erlang) ++ ?CARRIRER_DIR,
  FileNames = filelib:fold_files(FullFilePath, ?CARRIRER_REGEXP, true, fun(X, Acc) -> [X|Acc] end, []),
  [proccess_carrier_file(File) || File <-FileNames].

proccess_carrier_file(FileName) ->
  {_Lang, _Code} = get_lang_code(filename:split(FileName)),
  {ok, Device} = file:open(FileName, [read]),
  CarriersInfo = read(Device),
  file:close(Device),
  lists:map(fun(Carrier) ->
    write_crarrier(Carrier)
    end,  CarriersInfo).

read(Device) ->
  readlines(io:get_line(Device), Device, #{}).

readlines(eof, _Device, State) ->
  State;

readlines("$\n",  Device, State) ->
  readlines(io:get_line(Device), Device, State);

readlines([$# | _], Device, State) ->
  readlines(io:get_line(Device), Device, State);

readlines(Line, Device, State) ->
  case re:run(Line, "[0-9]{1,}\\|", [{capture, none}]) of
    match ->
      [CCode, Name] = string:tokens(Line, "|"),
      CarrierName = utils:trim_first_last_whitespaces(Name),
      CarrierCode = list_to_binary(CCode),
      NewState = maps:put(CarrierCode, CarrierName, State),
      readlines(io:get_line(Device), Device, NewState);
    _ ->
      readlines(io:get_line(Device), Device, State)
  end.

write_crarrier(#{carrirer := Carrier, code := Code}) ->
  case mnesia:read({?CARRIER, Carrier}) of
    [#?CARRIER{names = _Names}] ->
      ok;
    _ ->
      mnesia:dirty_write(#?CARRIER{carrier = Carrier, code = Code, names = [{}]})
  end.

get_lang_code([Lang, FileName]) ->
  Code = filename:basename(FileName, ".txt"),
  {list_to_binary(Lang), list_to_binary(Code)};

get_lang_code([_I | Rest]) ->
  get_lang_code(Rest).