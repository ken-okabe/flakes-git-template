# home.nix - NixOS module that configures Home Manager
{ config, pkgs, specialArgs, ... }:

{
  home-manager.users.${specialArgs.username} = { config, ... }: {
    home.stateVersion = specialArgs.stateVersion; # Ensure this matches your NixOS version or desired HM version
    xdg.userDirs.enable = true;
    xdg.userDirs.createDirectories = true;

    home.packages = with pkgs; [
      zsh-history-substring-search
      zsh-powerlevel10k
 
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      fira-code
      nerd-fonts.fira-code
    ];

    # Font configuration for Home Manager
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif CJK JP" "serif" ];
        sansSerif = [ "Noto Sans CJK JP" "sans-serif" ];
        monospace = [ "FiraCode Nerd Font Mono"  "monospace" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    # Japanese Input Method Editor (fcitx5 with Mozc)
    # Note: In Home Manager, i18n.inputMethod configuration is simpler

    i18n.inputMethod.enable = true;
    i18n.inputMethod = {
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc-ut      # Mozc engine for Japanese input.
        fcitx5-gtk          # GTK integration modules for Fcitx5.
        fcitx5-nord  
      ];
    };

    # Session variables for applications launched by the user
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      INPUT_METHOD = "fcitx";
    };

    programs.home-manager.enable = true;

    programs.git = {
      enable = true;
      userName = specialArgs.gitUsername; # Access from specialArgs
      userEmail = specialArgs.gitUseremail; # Access from specialArgs
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    programs.gh = {
      enable = true;
    
      settings = {
        git_protocol = "ssh";
      };
    };

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      shellAliases = {
        ll = "ls -la -F --color=auto --group-directories-first";
        update-system = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      };
      initContent = ''
        export EDITOR=nano
        stty intr ^T

        if [ -f "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]; then
          source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
        fi
        if [[ -r "${config.home.homeDirectory}/.p10k.zsh" ]]; then
          source "${config.home.homeDirectory}/.p10k.zsh"
        fi
        local history_substring_search_path="${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
        if [ -f "$history_substring_search_path" ]; then
          source "$history_substring_search_path"
          bindkey "$terminfo[kcuu1]" history-substring-search-up
          bindkey "$terminfo[kcud1]" history-substring-search-down
        else
          echo "Warning: zsh-history-substring-search plugin not found at $history_substring_search_path" >&2
        fi
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
      '';
    };

    programs.ghostty = {
      enable = true;
      package = pkgs.ghostty;
      settings = {
        font-size = 12;
        background-opacity = 0.9;
        split-divider-color = "green";
        gtk-titlebar = false;
        keybind = [
          "ctrl+c=copy_to_clipboard"
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          "ctrl+v=paste_from_clipboard"
          "ctrl+left=goto_split:left"
          "ctrl+down=goto_split:down"
          "ctrl+up=goto_split:up"
          "ctrl+right=goto_split:right"
          "ctrl+enter=new_split:down"
        ];
      };
      clearDefaultKeybinds = false;
      enableZshIntegration = true;
    };

    programs.mpv = {
	    enable = true;
	    config = {
	      "loop-file" = "inf";
	    };
    };
    
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

  };

}
