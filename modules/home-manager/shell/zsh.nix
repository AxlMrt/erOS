{
  pkgs,
  lib,
  config,
  ...
}: {
  home.file.".config/eros/p10k-theme.zsh".text = let
    c = config.eros.theme.active.palette;
  in ''
    typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=${c.surface1}
    typeset -g POWERLEVEL9K_DIR_BACKGROUND=${c.blue}
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=255
    typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=${c.green}
    typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=${c.yellow}
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=${c.peach}
    typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=${c.red}
    typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=${c.green}
    typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=${c.red}
  '';

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern" "regexp" "root" "line"];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    oh-my-zsh = {
      enable = true;
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./p10k-config;
        file = "p10k.zsh";
      }
    ];

    initContent = ''
      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word
      if [ -f "$HOME/.config/eros/p10k-theme.zsh" ]; then
        source "$HOME/.config/eros/p10k-theme.zsh"
      fi
      if [ -f $HOME/.zshrc-personal ]; then
        source $HOME/.zshrc-personal
      fi
    '';

    shellAliases = {
      # c = "clear";
    };
  };
}
