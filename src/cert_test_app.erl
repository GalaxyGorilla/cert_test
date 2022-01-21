-module(cert_test_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [{"/", cert_test_handler, []}]}
    ]),
    CertOpts = [
                {cacertfile, "priv/CA.crt"},

                {certfile, "priv/server.crt"},
                {keyfile, "priv/server.key"}

                %{certfile, "priv/SCA_server.crt"},
                %{keyfile, "priv/SCA_server.key"}

                %{certfile, "priv/invalid_server.crt"},
                %{keyfile, "priv/invalid_server.key"}
               ],
    %% Only use server certificates for TLS
    {ok, _} = cowboy:start_tls(basic_tls_listener,
        [{port, 8080}] ++ CertOpts,
        #{env => #{dispatch => Dispatch}}
    ),
    %% Also use client certificates for TLS
    {ok, _} = cowboy:start_tls(client_auth_tls_listener,
        [
         {port, 8081},
         {verify, verify_peer},
         {fail_if_no_peer_cert, true}
        ] ++ CertOpts,
        #{env => #{dispatch => Dispatch}}
    ),
    cert_test_sup:start_link().

stop(_State) ->
    ok.
