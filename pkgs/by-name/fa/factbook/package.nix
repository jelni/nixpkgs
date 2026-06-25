{
  at-spi2-core,
  cairo,
  cargo-tauri,
  dbus,
  dpkg,
  fetchFromGitHub,
  fetchPnpmDeps,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  libsoup_3,
  nix-update-script,
  nodejs,
  pango,
  pkg-config,
  pnpm,
  pnpmConfigHook,
  rustPlatform,
  swi-prolog,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "factbook";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "michalwa";
    repo = "factbook";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w9/WVHLSmOE0decMQn/Q1XFn28p6SMqdQIwyxmY8aiw=";
  };

  cargoHash = "sha256-MmpOboURbZEU1d+hSMlRTRnxvj6qp0nGb+mjXOppU+I=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname src;
    hash = "sha256-ipjGEKniWlFPfpwC0wBYnYFXZr3rHkY/b2CuQ29ALxU=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    cargo-tauri
    dpkg
    nodejs
    pkg-config
    pnpm
    pnpmConfigHook
    rustPlatform.bindgenHook
    swi-prolog
    wrapGAppsHook3
  ];

  buildInputs = [
    at-spi2-core
    gtk3
    libsoup_3
    pango
    swi-prolog
    webkitgtk_4_1
  ];

  preBuild = ''
    pnpm tauri build --bundles deb
  '';

  postInstall = ''
    find . -name "*.deb" -exec dpkg-deb -x {} $out \;
    cp -a $out/usr/* $out/
    rm -rf $out/usr
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "${
      lib.makeLibraryPath [
        cairo
        dbus
        gdk-pixbuf
        glib
        gtk3
        libsoup_3
        swi-prolog
        webkitgtk_4_1
      ]
    }")
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Programmer-friendly personal knowledge base in the vein of Zettelkasten based on logic programming";
    homepage = "https://github.com/michalwa/factbook";
    license = lib.licenses.gpl3Plus;
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ jelni ];
  };
})
