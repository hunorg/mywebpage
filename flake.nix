{
  description = "Hunor Geréd — personal site";

  nixConfig.extra-experimental-features = [ "pipe-operators" ];

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    htnl = {
      url = "github:molybdenumsoftware/htnl";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, htnl, ... }:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      perSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import "${htnl}/overlay.nix") ];
          };
          site = pkgs.callPackage ./site.nix { };
          updateDocs = pkgs.writeShellApplication {
            name = "update-docs";
            runtimeInputs = [ pkgs.coreutils ];
            text = ''
              install -Dm644 ${site}/index.html docs/index.html                                                                                                                           
            '';
          };
        in
        {
          packages = {
            default = site;
            inherit site;
          };
          apps.update-docs = {
            type = "app";
            program = "${updateDocs}/bin/update-docs";
          };
        };
    in
    {
      packages = forAllSystems (system: (perSystem system).packages);
      apps = forAllSystems (system: (perSystem system).apps);
    };
}
