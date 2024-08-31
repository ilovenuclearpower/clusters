local k = import "k.libsonnet";
local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local createHelm = function(file) tanka.helm.new(file);
local helm = createHelm(std.thisFile);
local cluster_secrets = import "../../secrets.libsonnet";
local utils = import "utils.libsonnet";
local secrets = k.core.v1.secret;
{
    new(namespace):: {
        ns: utils.privileged_namespace(namespace),

        "traefik-internal": helm.template("traefik", "../charts/traefik", {
            namespace: namespace,
            deployment: {
                replicas: 3
            },
            values: {
                service: {
                    type: "LoadBalancer"
                },
            deployment: {
                replicas: 3
            },
            ingressRoute: {
                dashboard: {
                    enabled: true,
                    entrypoints: [ "web" ],
                },
            },
            providers: {
                kubernetesIngress: {
                    ingressClass: "traefik-internal",
                    labelSelector: "environment=local"
                },
                kubernetesCRD: {
                    ingressClass: "traefik-internal",
                    labelSelector: "environment=test"
                }
            }
            },
        }),
        whoami_test: {
            container: {
                apiVersion: "apps/v1",
                kind: "Deployment",
                metadata: {
                    name: "whoami-test",
                    namespace: namespace
                },
                spec: {
                    replicas: 1,
                    selector: {
                        matchLabels: {
                            app: "whoami-test"
                        }
                    },
                    template: {
                        metadata: {
                            labels: {
                                app: "whoami-test"
                            }
                        },
                        spec: {
                            containers: [
                                {
                                    name: "whoami-test",
                                    image: "containous/whoami",
                                    ports: [
                                        {
                                            containerPort: 80
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            },
            service: {
                apiVersion: "v1",
                kind: "Service",
                metadata: {
                    name: "whoami-test",
                    namespace: namespace,
                    labels: {
                        app: "whoami-test",
                        environment: "local"
                    }
                },
                spec: {
                    selector: {
                        app: "whoami-test"
                    },
                    ports: [
                        {
                            protocol: "TCP",
                            port: 80,
                            targetPort: 80
                        }
                    ]
                    }
                }

            },
            ingress: {
                apiVersion: "networking.k8s.io/v1",
                kind: "Ingress",
                metadata: {
                    name: "whoami-test",
                    namespace: namespace,
                },
                spec: {
                    ingressClassName: "traefik.traefik",
                    rules: [{
                            host: "whoami-test.local",
                            http: {
                                paths: [
                                    {
                                        path: "/test",
                                        pathType: "Prefix",
                                        backend: {
                                            service:
                                            {
                                                name: "whoami-test",
                                                port: {
                                                    number: 80
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                            }
                    ]
            }
        }
    }
}