-module(cert_test_client).

-export([request/0]).

request() ->
    {ok, ConnPid} = gun:open("localhost", 8080,
                             #{transport => tls,
                               transport_opts => [{verify, verify_peer},
                                                  {cacertfile, "priv/CA.crt"},
                                                  {certfile, "priv/client.crt"},
                                                  {keyfile, "priv/client.key"}]}),
    {ok, _Protocol} = gun:await_up(ConnPid),
    StreamRef = gun:get(ConnPid, "/"),
    case gun:await(ConnPid, StreamRef) of
        {response, fin, _Status, _Headers} ->
            no_data;
        {response, nofin, _Status, _Headers} ->
            gun:await_body(ConnPid, StreamRef)
    end.
