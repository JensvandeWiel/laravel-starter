{
    description = "Clockin dev flake";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs { inherit system; };

                # Define the aliases script
                sail = pkgs.writeShellScriptBin "sail" ''
                    exec ./vendor/bin/sail $@'';
                dev = pkgs.writeShellScriptBin "dev" ''
                    exec composer dev'';
                test = pkgs.writeShellScriptBin "test" ''
                    exec sail artisan test'';
            in {
                # Define devShell with aliases
                devShell = pkgs.mkShell {
                    name = "laravel-dev-shell";
                    buildInputs = [
                        pkgs.docker
                        pkgs.docker-compose
                        pkgs.bun
                        pkgs.php83
                        pkgs.php83Packages.composer
                        pkgs.postgresql
                        sail
                        dev
                        test
                    ];

                    shellHook = ''
                        echo 'Wynq dev environment loaded'
                    '';
                };

                nixosModule = {
                    config = {
                        services.docker.enable = true;
                        virtualisation.docker.enable = true;

                        # Ensure Docker Compose is accessible system-wide
                        environment.systemPackages = with pkgs; [
                            docker-compose
                        ];
                    };
                };
        });
}
