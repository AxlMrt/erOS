{...}: {
  programs.starship = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      share = true;
      save = 10000;
      size = 10000;
      extended = true;
    };

    initContent = ''
      bindkey -e
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      export STARSHIP_CONFIG="$HOME/.config/eros/active/theme/starship.toml"

      if [ -f "$HOME/.config/eros/active/theme/colors.env" ]; then
        # shellcheck disable=SC1090
        . "$HOME/.config/eros/active/theme/colors.env"
      fi

      if [ -f "$HOME/.config/eros/active/theme/settings.env" ]; then
        # shellcheck disable=SC1090
        . "$HOME/.config/eros/active/theme/settings.env"
      fi

      if [ -f "$HOME/.zshrc-personal" ]; then
        source "$HOME/.zshrc-personal"
      fi
    '';

    shellAliases = {
      ll = "ls -lah";
      la = "ls -A";
      gs = "git status -sb";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -n 20";
      rebuild = "nix run /home/$USER/eros#secrets-guard && sudo nixos-rebuild switch --flake /home/$USER/eros#default-sec-desktop";
    };
  };
}
