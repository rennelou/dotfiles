# Dotfiles (Home Manager)

Configuração compartilhada de dotfiles usando [Home Manager] e Nix flakes.
O repositório é **público**, mas não contém dados pessoais: ele expõe um
**módulo** que cada máquina importa a partir de um flake privado.

## Arquitetura

```
╭───────────── repositório público ─────────────╮
│  flake.nix  →  homeModules.default  = home.nix │  ← perfil compartilhado
│                                                   (sem dados pessoais)
╰────────────────────────────────────────────────╯
            ▲ importa
            │
╭───────────── ~/.config/home-manager/ ──────────╮
│  flake.nix  →  homeConfigurations."<user>"      │  ← flake pessoal (fora do repo)
│  machine.nix                                   │  ← seus dados (nunca versionado)
╰────────────────────────────────────────────────╯
```

Vantagens deste modelo:
- **Sem `git add -N`**: o Nix não precisa rastrear `machine.nix`, pois ele vive
  fora do repositório.
- **Sem dados pessoais no repo**: repositório público liberado como exemplo.
- **Per-machine**: cada máquina tem o seu próprio `machine.nix` e pode aplicar
  overrides.

## Como usar

### 1. Clone o repositório

```bash
git clone https://github.com/SEU-USER/dotfiles.git ~/dotfiles
```

### 2. Crie o flake pessoal (fora do repositório)

Em `~/.config/home-manager/flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Use "path:" enquanto o repo não estiver publicado,
    # ou "github:user/dotfiles" depois de publicar.
    dotfiles.url = "path:/home/SEU-USER/dotfiles";
  };

  outputs = { nixpkgs, home-manager, dotfiles, ... }:
    let system = "x86_64-linux";
    in {
      homeConfigurations."SEU-USER" = home-manager.lib.homeManagerConfiguration {
        modules = [
          dotfiles.homeModules.default   # perfil compartilhado
          ./machine.nix                  # seus dados
        ];
        pkgs = nixpkgs.legacyPackages.${system};
      };
    };
}
```

### 3. Crie o arquivo pessoal

Em `~/.config/home-manager/machine.nix`:

```nix
{ config, pkgs, ... }:
{
  home.username = "SEU-USER";
  home.homeDirectory = "/home/SEU-USER";

  programs.git.settings.user = {
    name = "Seu Nome";
    email = "seu-email@exemplo.com";
  };
}
```

### 4. Aplique

```bash
home-manager switch --flake ~/.config/home-manager#SEU-USER
```

## Personalizar por máquina

Como `machine.nix` é o último módulo, ele pode **sobrescrever** opções do perfil
compartilhado (`home.nix`). Ex.: forçar mais pacotes, aliases diferentes, um
tema distinto — basta setar a mesma opção em `machine.nix`.

No `home.nix` (público) fiquem apenas as coisas comuns a todas as máquinas.

## Proteção de segredos

- `home.machine.nix` (o equivalente real, `~/.config/home-manager/machine.nix`)
  fica **fora** do repositório — nunca é versionado.
- Chaves SSH, `.env`, tokens, etc. estão cobertos pelo `.gitignore`.
- Um hook do Git (via [`pre-commit`] + [gitleaks]) bloqueia commits com segredos.

Ative-o uma vez após clonar:

```bash
pre-commit install
```

## Estrutura

```
├── flake.nix          → expõe homeModules.default
├── home.nix           → perfil compartilhado (público)
├── .gitignore         → ignore segredos
├── .pre-commit-config.yaml → gitleaks
└── dotfiles/          → configurações por app (hypr, kitty, ...)
```

[Home Manager]: https://nix-community.github.io/home-manager/
[pre-commit]: https://pre-commit.com/
[gitleaks]: https://github.com/gitleaks/gitleaks