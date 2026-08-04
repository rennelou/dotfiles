{
  description = "Dotfiles compartilhados (módulo do Home Manager)";

  # Este repositório NÃO é o ponto de entrada do "home-manager switch".
  # Ele expõe o perfil compartilhado como um MÓDULO reutilizável, que cada
  # máquina importa a partir de um flake pessoal e privado (fora do repo).
  #
  # Exemplo de flake pessoal (ex.: em ~/.config/home-manager/flake.nix):
  #
  #   {
  #     inputs = {
  #       nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  #       home-manager = {
  #         url = "github:nix-community/home-manager";
  #         inputs.nixpkgs.follows = "nixpkgs";
  #       };
  #       dotfiles.url = "path:/home/SEU-USUARIO/dotfiles"; # ou github:user/dotfiles
  #     };
  #     outputs = { nixpkgs, home-manager, dotfiles, ... }:
  #       let system = "x86_64-linux";
  #       in {
  #         homeConfigurations."seu-usuario" = home-manager.lib.homeManagerConfiguration {
  #           modules = [
  #             dotfiles.homeModules.default
  #             ./machine.nix   # dados pessoais, fora do repositório
  #           ];
  #           pkgs = nixpkgs.legacyPackages.${system};
  #         };
  #       };
  #   }
  #
  # Depois:  home-manager switch --flake ~/.config/home-manager#seu-usuario

  outputs = { self }:
    {
      homeModules.default = import ./home.nix;
    };
}