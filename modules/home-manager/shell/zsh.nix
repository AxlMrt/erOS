{...}: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "❯";
        error_symbol = "❯";
      };
      cmd_duration = {
        min_time = 500;
        show_milliseconds = false;
      };
    };
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
      rebuild = "sudo nixos-rebuild switch --flake /home/$USER/eros#default-desktop";
    };
  };
}
