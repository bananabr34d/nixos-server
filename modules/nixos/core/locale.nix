{
  flake.modules.nixos.core =
    let
      me = import ../../../lib/me.nix;
    in
    {
      time.timeZone = me.timeZone;
      i18n.defaultLocale = me.locale;
      i18n.extraLocaleSettings = {
        LC_ADDRESS = me.locale;
        LC_IDENTIFICATION = me.locale;
        LC_MEASUREMENT = me.locale;
        LC_MONETARY = me.locale;
        LC_NAME = me.locale;
        LC_NUMERIC = me.locale;
        LC_PAPER = me.locale;
        LC_TELEPHONE = me.locale;
        LC_TIME = me.locale;
      };
    };
}
