
-module(file_handler).

-export([init/2, init/3, handle/2, terminate/3]).
%ejemplo:
%httpc:request(post, {"http://127.0.0.1:3011/", [], "application/octet-stream", "echo"}, [], []).
%curl -i -d '[-6,"test"]' http://localhost:3011
init(Req, Opts) ->
	handle(Req, Opts).
handle(Req, State) ->
    {IP, _} = cowboy_req:peer(Req),
    F0 = cowboy_req:path(Req),
    PrivDir0 = "../../../../web",
    PrivDir = list_to_binary(PrivDir0),
    F = case F0 of
	       <<"/favicon.ico">> -> F0;
	       <<"/principal.html">> -> F0;
	       <<"/escuela.html">> -> F0;
	       <<"/cuerpo.html">> -> F0;
	       <<"/dia.html">> -> F0;
	       <<"/con_lenses.jpg">> -> F0;
	       <<"/mi.jpg">> -> F0;
	       <<"/mi2.jpg">> -> F0;
	       <<"/futuro.html">> -> F0;
               X -> 
                io:fwrite("no tenemos esta fila: "),
                io:fwrite(X),
                io:fwrite("\n"),
                <<"/principal.html">>
           end,
    {{Year, Month, Day},{Hour,Minute,Second}} = 
        calendar:now_to_universal_time(erlang:now()),
    Time = 
        integer_to_list(Year) ++ "," ++
        integer_to_list(Month) ++ "," ++
        integer_to_list(Day) ++ "," ++
        integer_to_list(Hour) ++ "," ++
        integer_to_list(Minute) ++ "," ++
        integer_to_list(Second) ++ " ",
    LogString = 
        case {IP, F0} of
            {_, <<"/favicon.ico">>} -> "";
            {{IP1, IP2, IP3, IP4}, _} ->
                Time ++
                    binary_to_list(F0) ++
                    " [" ++
                    integer_to_list(IP1) ++
                    "," ++
                    integer_to_list(IP2) ++
                    "," ++
                    integer_to_list(IP3) ++
                    "," ++
                    integer_to_list(IP4) ++
                    "]\n";
            _ -> Time ++ binary_to_list(F0)++"\n"
    end,
    file:write_file("views", LogString, [append]),
    File = << PrivDir/binary, F/binary>>,
    {ok, _Data, _} = cowboy_req:read_body(Req),
    Headers = #{<<"content-type">> => <<"text/html">>,
    <<"Access-Control-Allow-Origin">> => <<"*">>},
    Text = read_file(File),
    Req2 = cowboy_req:reply(200, Headers, Text, Req),
    {ok, Req2, State}.
read_file(F) ->
    {ok, File } = file:open(F, [read, binary, raw]),
    {ok, O} =file:pread(File, 0, filelib:file_size(F)),
    file:close(File),
    O.
init(_Type, Req, _Opts) -> {ok, Req, []}.
terminate(_Reason, _Req, _State) -> ok.
