{
  # Manage ghostty config file through home-manager
  home.file.".config/ghostty/config" = {
    text = ''
      # Ghostty Configuration
      theme = Oceanic Next

      # Terminal type
      term = xterm-256color

      # Font settings
      font-family = "Monaco"
      font-size = 12

      # Cursor
      cursor-style = block
      cursor-opacity = 1
    '';
  };
}
