cert_test
=====

An OTP application for tinkering with TLS certificates using cowboy and gun.

There are two listeners used:

* Basic TLS, e.g. only server certificates are verified by the client (port 8080)
* Client authenticated TLS, e.g. also client certificates are verified by the server (port 8081)

Start
-----

    $ rebar3 shell

    [...]

    1> cert_test_client:req_basic_tls().
    {ok,<<"huhu!">>}

    2> cert_test_client:req_client_auth_tls().
    {ok,<<"huhu!">>}


Certificates
------------

The `priv` folder contains all used certificates and associated private keys. Note that there are also
invalid certificates for the client and server for tinkering.

For the sake of documentation here's described how the content in `priv` was generated.

Generate private keys:

    % openssl ecparam -genkey -name prime256v1 -noout -out example.key

Generate the CA certificate:

    % openssl req -x509 -sha256 -new -nodes -days 3650 -key CA.key -out CA.crt 

You will have to enter several infos here, for the CA certificate all of this doesn't really matter.

Generate signed Certificates with CSRs (Certificate Signing Request) for other keys:

    $ openssl req -new -key example.key -out example.csr
    $ openssl x509 -req -in example.csr -CA CA.crt -CAkey CA.key -CAcreateserial -days 3650 -sha256 -out example.crt

Again, you will have to enter information but this time you need to take care for this line:

    Common Name (eg, fully qualified host name) []: <my_hostname>

For the server certificate you can choose e.g. `localhost`.
The Client will do hostname validation on this attribute.
For the Client this line doesn't matter in terms of TLS authentication.

The `invalid_server.crt` certificate uses `invalid` as hostname and is therefore not accepted by the client.

The `invalid_client.crt` is self-signed and is therefore not accepted by the server.

You can also verify your signed certificates with the CA certificate:

    $ openssl verify -verbose -CAfile CA.crt example.crt


Special case: intermediate CA, the real fun. Don't generate certificates as described here for production.

Put that into your shell:

    CONFIG="
    [req]
    distinguished_name=dn
    [ dn ]
    [ ext ]
    basicConstraints=CA:TRUE,pathlen:0
    "

Then sign the CSR using the following command:

    $ openssl x509 -req -extfile <(echo "$CONFIG") -in ICA.csr -CA CA.crt -CAkey CA.key -CAcreateserial -days 3650 -sha256 -extensions ext -out ICA.crt

This adds the `basicConstraints` extension to the certificate to make it CA capable.
