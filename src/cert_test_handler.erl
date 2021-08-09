-module(cert_test_handler).

-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	Req = reply(Method, Req0),
	{ok, Req, Opts}.

reply(<<"GET">>, Req) ->
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain; charset=utf-8">>
	}, <<"huhu!">>, Req);
reply(_, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).
