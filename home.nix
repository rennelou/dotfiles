{ config, pkgs, ... }:

{
  # ============================================================
  # PERFIL COMUM DE DOTFILES (TEMPLATE PÚBLICO)
  # 
  # Este arquivo contém as configurações compartilhadas entre
  # todas as suas máquinas. NÃO COLOQUE DADOS PESSOAIS AQUI
  # (como nome de usuário, e-mail, senhas ou tokens).
  #
  # As configurações pessoais/específicas de máquina devem ficar
  # em `home.machine.nix` (arquivo ignorado pelo git).
  # Veja `home.machine.example.nix` como referência.
  # ============================================================

  # Estado de compatibilidade do Home Manager
  home.stateVersion = "24.05";

  # Pacotes a serem instalados apenas para o seu usuário
  home.packages = with pkgs; [
    # Ferramentas CLI enxutas
    ripgrep
    fd
    eza
    htop
    zoxide
    fzf
    bat

    opencode

    # Proteção de segredos e qualidade no Git
    gitleaks
    pre-commit
  ];

  xdg.configFile = {
    "kitty".source = ./dotfiles/kitty;
    "hypr".source = ./dotfiles/hypr;
    "gamemode.ini".source = ./dotfiles/gamemode.ini;
  };

  # Permitir instalação de pacotes unfree caso necessário
  nixpkgs.config.allowUnfree = true;

  # Deixe o Home Manager gerenciar a si mesmo
  programs.home-manager.enable = true;

  # Configuração genérica do Git (sem identidade pessoal)
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
    };
  };

  # ==========================================
  # CONFIGURAÇÃO DO ZSH E FERRAMENTAS AUXILIARES
  # ==========================================

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # Recursos nativos ultrarrápidos em C/Zsh puro
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Histórico otimizado
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    # Aliases práticos aproveitando as ferramentas modernas
    shellAliases = {
      # Substitutos modernos do coreutils
      ls = "eza --icons=auto";
      ll = "eza -l --icons=auto --git";
      la = "eza -la --icons=auto --git";
      lt = "eza --tree --level=2 --icons=auto";
      cat = "bat";

      # Atalhos do Git
      g = "git";
      gs = "git status";
      gp = "git push";
      gl = "git pull";

      # Atalhos do Nix
      hms = "home-manager switch";
    };

    # Opções extras de performance do próprio Zsh
    initContent = ''
      # Navegação rápida sem precisar digitar 'cd'
      setopt AUTO_CD

      # Corrige erros de digitação simples em caminhos
      setopt CORRECT

      # Busca no histórico usando as setas para cima/baixo
      bindkey '^[[A' history-beginning-search-backward
      bindkey '^[[B' history-beginning-search-forward
    '';
  };

  # Prompt Starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      package.disabled = true;
    };
  };

  # Integração do Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Integração do FZF
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
