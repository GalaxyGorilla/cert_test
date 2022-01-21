-module(cert_test_client).

-export([req_basic_tls/0, req_client_auth_tls/0]).

req_basic_tls() ->
    TransportOpts = [
                     {verify, verify_peer},
                     {cacertfile, "priv/CA.crt"}
                    ],
    {ok, ConnPid} = gun:open("localhost", 8080,
                             #{transport => tls,
                               transport_opts => TransportOpts}),
    request(ConnPid).

req_client_auth_tls() ->
    TransportOpts = [
                     {verify, verify_peer},
                     {cacertfile, "priv/CA.crt"},
                     %{cacertfile, "priv/CA_ICA_SCA_batch.crt"},

                     {certfile, "priv/client.crt"},
                     {keyfile, "priv/client.key"}

                     %{certfile, "priv/ICA_client.crt"},
                     %{keyfile, "priv/ICA_client.key"}
                     
                     %{certfile, "priv/invalid_client.crt"},
                     %{keyfile, "priv/invalid_client.key"}
                    ],
    {ok, ConnPid} = gun:open("localhost", 8081,
                             #{transport => tls,
                               transport_opts => TransportOpts}),
    request(ConnPid).

request(ConnPid) ->
    {ok, _Protocol} = gun:await_up(ConnPid),
    StreamRef = gun:get(ConnPid, "/"),
    case gun:await(ConnPid, StreamRef) of
        {response, fin, _Status, _Headers} ->
            no_data;
        {response, nofin, _Status, _Headers} ->
            gun:await_body(ConnPid, StreamRef)
    end.
