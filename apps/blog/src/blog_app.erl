-module(blog_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    inets:start(),
    start_http(),
    blog_sup:start_link().

stop(_State) ->
    ok.

start_http() ->
    Dispatch =
        cowboy_router:compile(
          [{'_', [
		  %{"/:file", file_handler, []}%,
		  {"/[...]", file_handler, []}
		  %{"/", http_handler, []}
		 ]}]),
    {ok, _} = cowboy:start_clear(http,
				 [{ip, {0,0,0,0}}, {port, 8000}],
				 #{env => #{dispatch => Dispatch}}),
    ok.
    
