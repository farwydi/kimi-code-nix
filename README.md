# kimi-code-nix

Nix-пакет [Kimi Code](https://code.kimi.com) — агентный coding CLI от Moonshot AI (`kimi`).

Официальный бинарный релиз (Node SEA single-file) с code.kimi.com. Бинарь не патчится:
на Linux запускается через nix-загрузчик `ld-linux` с `--library-path` (паттерн droid-nix).
Встроенный автоапдейт выключен через `KIMI_CODE_NO_AUTO_UPDATE=1`.

- `sources.json` — версия и per-system хэши (SRI из sha256 в manifest.json апстрима, без скачивания).
- `update.sh` — перегенерация sources.json; пин версии аргументом: `./update.sh 0.26.0`.
- `.github/workflows/update.yml` — ежедневная проверка новой версии (9:00 МСК) с проверкой сборки.

## Использование (home-manager, каналы)

```nix
let
  kimiCodeSrc = builtins.fetchTarball {
    url = "https://github.com/farwydi/kimi-code-nix/archive/refs/heads/master.tar.gz";
  };
  kimi-code = (import <nixpkgs> {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  }).callPackage "${kimiCodeSrc}/package.nix" { };
in
{
  home.packages = [ kimi-code ];
}
```
