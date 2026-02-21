{config, ...}: {
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      timeout = 6;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = true;
      layer = "overlay";
      control-center-width = 380;
      control-center-height = 680;
      notification-window-width = 340;
      keyboard-shortcuts = true;
      image-visibility = "never";
    };

    style = ''
      @import url("file://${config.home.homeDirectory}/.config/eros/active/theme/swaync.css");
    '';
  };
}
