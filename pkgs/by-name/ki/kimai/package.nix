{
  php,
  fetchFromGitHub,
  lib,
  nixosTests,
}:

php.buildComposerProject (finalAttrs: {
  pname = "kimai";
  version = "2.27.0";

  src = fetchFromGitHub {
    owner = "kimai";
    repo = "kimai";
    rev = finalAttrs.version;
    hash = "sha256-CTYmk6QGEd+WKC+Q+odvLF961u61MCaA6VoZlxpo3Gc=";
  };

  php = php.buildEnv {
    extensions = (
      { enabled, all }:
      enabled
      ++ (with all; [
        gd
        intl
        mbstring
        pdo
        tokenizer
        xml
        xsl
        zip
      ])
    );

    # Asset building and (later) cache building process requires a little bit
    # more memory.
    extraConfig = ''
      memory_limit=384M
    '';
  };

  vendorHash = "sha256-DV4yU1PiH2HnAJ2hcVmSkZxTTpjtfqP3dV2d/FL9VHg=";

  composerNoPlugins = false;
  composerNoScripts = false;

  postInstall = ''
    # Make available the console utility, as Kimai doesn't list this in
    # composer.json.
    mkdir -p "$out"/share/php/kimai "$out"/bin
    ln -s "$out"/share/php/kimai/bin/console "$out"/bin/console
  '';

  passthru.tests = {
    kimai = nixosTests.kimai;
  };

  meta = {
    description = "Web-based multi-user time-tracking application";
    homepage = "https://www.kimai.org/";
    license = lib.licenses.agpl3Plus;
    longDescription = "
      Kimai is a web-based multi-user time-tracking application. Works great for
      everyone: freelancers, companies, organizations - everyone can track their
      times, generate reports, create invoices and do so much more.
    ";
    maintainers = with lib.maintainers; [ peat-psuwit ];
    platforms = lib.platforms.all;
  };
})
