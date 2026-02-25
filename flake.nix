{
  description = "neotest-gradle development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lua = pkgs.lua5_4;
          luaEnv = lua.withPackages (ps: with ps; [
            busted
            luacheck
          ]);
        in
        {
          default = pkgs.mkShell {
            packages = [
              luaEnv
              pkgs.stylua
            ];
          };
        });
    };
}
