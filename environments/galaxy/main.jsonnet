
local grafana = import 'grafana.libsonnet';
local monitoring = import 'monitoring.libsonnet';
local k = "github.com/jsonnet-libs/k8s-libsonnet/1.30/main.libsonnet";
local names = import 'namespaces.libsonnet';
local metallb = import 'metallb.libsonnet';
local nfs = import 'nfs.libsonnet';
local cert_manager = import "cert_manager.libsonnet";
local traefik = import "traefik.jsonnet";

{

  namespaces: names.new(),
  lb: metallb.new("network", [ "192.168.88.70-192.168.88.100"], 64512, 64513),
  storage_driver: nfs.new("storage"),
  storage_class: nfs.create_storageclass("apps", "/mnt/apps", "192.168.88.51"),
  cert_manager: cert_manager.new("cert-manager"),
  traefik: traefik.new("traefik"),

}
  