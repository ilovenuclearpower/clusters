local k = import "k.libsonnet";
local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local createHelm = function(file) tanka.helm.new(file);
local helm = createHelm(std.thisFile);
local cluster_secrets = import "../../secrets.libsonnet";
local secrets = k.core.v1.secret;
{
    new(namespace):: {

        local ns = k.core.v1.namespace.new(namespace) + {
            metadata: {
                name: namespace,
                labels: {
                    "pod-security.kubernetes.io/enforce": "privileged",
                    "pod-security.kubernetes.io/audit": "privileged",
                    "pod-security.kubernetes.io/warn": "privileged"
                },
            },
        },
        ns: ns,
        certmanager: helm.template("cert-manager", "../charts/cert-manager", {
            namespace: namespace,
            values: {
                installCRDs: true,
                replicaCount: 3
        }}),

        r53_secret: secrets.new("route53", {
            "r53_key_id": cluster_secrets.ROUTE53_ACCESS_KEY_ID,
            "r53_secret_key": cluster_secrets.ROUTE53_SECRET_ACCESS_KEY
        }, type='Opaque') + {
            metadata+: {
                namespace: namespace
            }
        },

        acme_secret_cert: secrets.new("acme-cert", {
            "tls.key": cluster_secrets.TLS_SECRET
        }, type='Opaque') + {
            metadata+: {
                namespace: namespace
            }
        },

        cluster_issuer: {
            apiVersion: "cert-manager.io/v1",
            kind: "ClusterIssuer",
            metadata: {
                name: "letsencrypt-prod",
                namespace: namespace,
            },
            spec: {
                acme: {
                    email: "burrito@aboveaverage.space",
                    server: "https://acme-v02.api.letsencrypt.org/directory",
                    privateKeySecretRef: {
                        name: "acme-cert",
                        key: "tls.key"
                    },
                    solvers: [
                        {
                            dns01: {
                                route53: {
                                    region: "us-east-1",
                                    accessKeyID: "AKIAQ5EK73TTHDLRUMWS",
                                    secretAccessKeySecretRef: {
                                        key: "r53_secret_key",
                                        name: "route53"
                                    }
                                }
                            }
                        }
                    ]
                }
            }
        }

    }
}