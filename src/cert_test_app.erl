-module(cert_test_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [{"/", cert_test_handler, []}]}
    ]),
    {ok, _} = cowboy:start_tls(cert_test_listener,
        [
         {port, 8080},
         {verify, verify_peer},
         {fail_if_no_peer_cert, true},
         {cacertfile, "priv/ca.crt"},
         {certfile, "priv/localhost.crt"},
         {keyfile, "priv/localhost.key"}
        ],
        #{env => #{dispatch => Dispatch}}
    ),
    cert_test_sup:start_link().

stop(_State) ->
    ok.
