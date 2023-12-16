{ lib, buildGoModule, fetchFromGitHub, nixosTests }:

buildGoModule rec {
  pname = "consul";
  version = "1.17.0";
  rev = "v${version}";

  # Note: Currently only release tags are supported, because they have the Consul UI
  # vendored. See
  #   https://github.com/NixOS/nixpkgs/pull/48714#issuecomment-433454834
  # If you want to use a non-release commit as `src`, you probably want to improve
  # this derivation so that it can build the UI's JavaScript from source.
  # See https://github.com/NixOS/nixpkgs/pull/49082 for something like that.
  # Or, if you want to patch something that doesn't touch the UI, you may want
  # to apply your changes as patches on top of a release commit.
  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = pname;
    inherit rev;
    hash = "sha256-fAcgO7r0GrL2GrsX7flezhbQMcg+YBH6Lrn7BW2XMwM=";
  };

  passthru.tests.consul = nixosTests.consul;

  # This corresponds to paths with package main - normally unneeded but consul
  # has a split module structure in one repo
  subPackages = ["." "connect/certgen"];

  vendorHash = "sha256-xxREyw7xgx9Zp7nua1yq39TioWvRQXOhWqYaK6eJaOc=";

  doCheck = false;

  ldflags = [
    "-X github.com/hashicorp/consul/version.GitDescribe=v${version}"
    "-X github.com/hashicorp/consul/version.Version=${version}"
    "-X github.com/hashicorp/consul/version.VersionPrerelease="
  ];

  meta = with lib; {
    description = "Tool for service discovery, monitoring and configuration";
    homepage = "https://www.consul.io/";
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.bsl11;
    maintainers = with maintainers; [ pradeepchhetri vdemeester nh2 techknowlogick];
    mainProgram = "consul";
  };
}
