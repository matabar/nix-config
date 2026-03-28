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
        pkgs.vim pkgs.git pkgs.jq pkgs.neovim pkgs.tmux pkgs.htop pkgs.claude-code pkgs.gh pkgs.zoxide pkgs.starship
      ];

      # Fixed: Global aliases in nix-darwin live here
      environment.shellAliases = {
        cc = "claude --dangerously-skip-permissions";
      };

      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall"; 
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;

        taps = [ "manaflow-ai/cmux" ];
        brews = [ "mas" ];
        casks = [
          "cmux"
          "docker-desktop"
          "gitkraken"
          "slack"
          "discord"
          "spotify"
          "rectangle"
          "wispr-flow"
        ];
      };

      nix.enable = false; 
      programs.zsh.enable = true;
      programs.zsh.promptInit = "";
      programs.zsh.interactiveShellInit = ''
        eval "$(zoxide init zsh)"
        eval "$(starship init zsh)"
      '';
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
      security.pam.services.sudo_local.touchIdAuth = true;

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
