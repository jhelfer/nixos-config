username:
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  home-manager.users.${username} = {
    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      fzf.enable = true;
      zoxide.enable = true;

      zsh = {
        enable = true;
        plugins = [
          {
            name = "fzf-tab";
            src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
          }
        ];
        initContent = lib.mkAfter ''
          # Query cursor position, print newline only if not on first row
          precmd() {
            local row col
            stty -echo
            print -n '\e[6n' >/dev/tty
            IFS='[;' read -sd R _ row col </dev/tty
            stty echo
            (( row > 1 )) && print
          }

          prompt_git() {
            local git_ref color
            git_ref="$(
              git symbolic-ref --short HEAD 2>/dev/null ||
              git rev-parse --short HEAD 2>/dev/null
            )" || return

            if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
              color=yellow
            else
              color=green
            fi

            print -n " on %F{$color}$git_ref%f"
          }

          setopt prompt_subst
          PROMPT='%F{blue}%~%f$(prompt_git)
          %F{magenta}%#%f '

          eval "$(${inputs.zsh-patina.packages.${system}.default}/bin/zsh-patina activate)"
        '';
      };
    };
  };

  ephemeral = {
    directories = [
      "/home/${username}/.local/share/direnv"
      "/home/${username}/.local/share/zoxide"
    ];
    files = [ "/home/${username}/.zsh_history" ];
  };
}
