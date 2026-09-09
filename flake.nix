{
  description = "Matan's Fully Reproducible Mac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      system.primaryUser = "matan";
      nixpkgs.config.allowUnfree = true;

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      environment.systemPackages = [
        pkgs.codex
        pkgs.vim pkgs.git pkgs.jq pkgs.neovim pkgs.tmux pkgs.htop pkgs.claude-code pkgs.gh pkgs.zoxide pkgs.starship
        pkgs.zsh-autosuggestions pkgs.zsh-syntax-highlighting pkgs.zsh-completions
        pkgs.temurin-bin-26
        pkgs.kubernetes-helm
        pkgs.cargo pkgs.rustc pkgs.rustfmt pkgs.rust-analyzer
      ];

      # Temurin 26 is OpenJDK 26; jdk26 is not in nixpkgs yet (Zulu tops out at 25).
      environment.variables = {
        JAVA_HOME = "${pkgs.temurin-bin-26.home}";
        RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
      };

      # So Dock/Cursor-launched apps see RUST_SRC_PATH (shells get it via set-environment).
      launchd.user.envVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

      # Fixed: Global aliases in nix-darwin live here
      environment.shellAliases = {
        cc = "claude --dangerously-skip-permissions";
      };

      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall"; 
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;

        taps = [
          "manaflow-ai/cmux"
          "nikitabobko/tap"
        ];
        brews = [ "herdr" "mas" ];
        casks = [
          "nikitabobko/tap/aerospace"
          "cmux"
          "docker-desktop"
          "gitkraken"
          "slack"
          "discord"
          "spotify"
          "rectangle"
          "wispr-flow"
          "zed"
        ];
      };

      nix.enable = false; 
      programs.zsh.enable = true;
      programs.zsh.promptInit = "";
      programs.zsh.interactiveShellInit = ''
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        fpath+=${pkgs.zsh-completions}/share/zsh/site-functions
        autoload -Uz compinit && compinit
        eval "$(zoxide init zsh)"
        eval "$(starship init zsh)"
      '';
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
      security.pam.services.sudo_local.touchIdAuth = true;

      system.activationScripts.postActivation.text = ''
        sudo -u matan mkdir -p /Users/matan/Projects/matabar
      '';

      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
        
        CustomUserPreferences = {
          "com.apple.launchservices.secure" = {
            LSHandlers = [
              { LSHandlerURLScheme = "http"; LSHandlerRoleAll = "tools.dia.desktop"; }
              { LSHandlerURLScheme = "https"; LSHandlerRoleAll = "tools.dia.desktop"; }
            ];
          };
        };
      };
    };
  in {
    darwinConfigurations."Matans-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
