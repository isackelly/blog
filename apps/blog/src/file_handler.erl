
-module(file_handler).

-export([init/2, init/3, handle/2, terminate/3]).
%ejemplo:
%httpc:request(post, {"http://127.0.0.1:3011/", [], "application/octet-stream", "echo"}, [], []).
%curl -i -d '[-6,"test"]' http://localhost:3011
init(Req, Opts) ->
	handle(Req, Opts).
handle(Req, State) ->
    F0 = cowboy_req:path(Req),
    PrivDir0 = "../../../../web",
    PrivDir = list_to_binary(PrivDir0),
    F = case F0 of
	       <<"/principal.html">> -> F0;
	       <<"/escuela.html">> -> F0;
	       <<"/cuerpo.html">> -> F0;
	       <<"/dia.html">> -> F0;
               X -> 
                io:fwrite("no tenemos esta fila: "),
                io:fwrite(X),
                io:fwrite("\n"),
                <<"/principal.html">>
           end,
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