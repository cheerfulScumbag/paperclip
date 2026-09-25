{
  lib,
  buildNpmPackage,
  nodejs,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "paperclipai";
  version = "2026.916.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/paperclipai/-/paperclipai-${version}.tgz";
    hash = "sha256-57FNarsXzbmUq1h65yeIwpeJ2Vx63YEeXVgQYXDJqbk=";
  };

  # npm tarballs extract to a "package" directory
  sourceRoot = "package";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-J+f8vgZdSX3qFB4XUIhk5wFxe+rMH8P4f8xgJTG4+Dw=";

  dontNpmBuild = true;

  # The CLI entrypoint is already bundled by esbuild upstream.
  # We only need npm to install runtime dependencies.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/paperclipai $out/bin
    cp -r node_modules $out/lib/paperclipai/
    cp -r dist $out/lib/paperclipai/
    cp package.json $out/lib/paperclipai/

    cat > $out/bin/paperclipai <<WRAPPER
#!/usr/bin/env bash
exec ${nodejs}/bin/node "${placeholder "out"}/lib/paperclipai/dist/index.js" "\$@"
WRAPPER
    chmod +x $out/bin/paperclipai

    runHook postInstall
  '';

  meta = {
    description = "Paperclip CLI - orchestrate AI agent teams";
    homepage = "https://github.com/paperclipai/paperclip";
    license = lib.licenses.mit;
    mainProgram = "paperclipai";
  };
}
