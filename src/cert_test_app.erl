-module(cert_test_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [{"/", cert_test_handler, []}]}
    ]),
    {ok, _} = cowboy:start_clear(cert_test_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    cert_test_sup:start_link().

stop(_State) ->
    ok.
