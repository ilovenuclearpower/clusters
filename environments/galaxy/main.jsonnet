
local grafana = import 'grafana.libsonnet';
local prom = import 'prometheus.libsonnet';
local k = "github.com/jsonnet-libs/k8s-libsonnet/1.30/main.libsonnet";
local names = import 'namespaces.libsonnet';
local metallb = import 'metallb.libsonnet';

{

  namespaces: names.new(),
  lb: metallb.new("network")
  
}