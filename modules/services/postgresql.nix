{
  pkgs,
  osConfig,
  config,
}:
{
  services.postgresql = {
    enable = true;
    authentication = pkgs.lib.mkOverride 10 ''
      # TYPE  DATABASE  USER  ADDRESS       METHOD
      local   all       all                 trust
      host    all       all   127.0.0.1/32  trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      ALTER USER postgres WITH PASSWORD 'postgres';
    '';
  };

  environment.persistence."${osConfig.persistDir}" = {
    directories = [ config.services.postgresql.dataDir ];
  };
}
