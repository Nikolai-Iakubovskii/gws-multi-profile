# gws-multi-profile

Tiny wrappers for running the official [`gws`](https://github.com/googleworkspace/cli) with multiple isolated accounts on one machine.

Built by [Nikolai Iakubovskii](https://github.com/Nikolai-Iakubovskii), indie developer behind [MistyWay](https://apps.apple.com/us/app/mistyway-walking-quest-game/id6730126556) and [AuroraMe](https://apps.apple.com/us/app/aurora-forecast-map-aurorame/id6749782053). I made this because one `gws` login was never enough in real work.

`gws` is great, but by default it behaves like a single-user CLI. This repo adds one simple trick:

- each profile gets its own config directory
- each command runs with its own `GOOGLE_WORKSPACE_CLI_CONFIG_DIR`
- you can stay logged into multiple Google accounts at the same time

No forks. No patched `gws`. No credential files in this repo.

## What You Get

- `gws-profile.sh`  
  Run any `gws` command inside one named profile.

- `gws-login-all.sh`  
  Start multiple `gws auth login` flows in parallel.

## Why This Is Useful

If you work across multiple Google accounts, you usually hit one of these problems:

- logging into one account breaks another
- you forget which token is active
- Gmail / Drive / Sheets work is mixed across clients or projects

This wrapper fixes that by separating `gws` state per profile:

```text
~/.config/gws-work
~/.config/gws-personal
~/.config/gws-client-a
```

## Requirements

- macOS or Linux shell environment
- [`gws`](https://github.com/googleworkspace/cli) installed
- `bash` or `zsh`

Install `gws`:

```bash
npm install -g @googleworkspace/cli
```

## Quick Start

Clone the repo:

```bash
git clone https://github.com/Nikolai-Iakubovskii/gws-multi-profile.git
cd gws-multi-profile
chmod +x gws-profile.sh gws-login-all.sh
```

Log into two accounts:

```bash
./gws-login-all.sh work personal
```

Check status:

```bash
./gws-profile.sh work auth status
./gws-profile.sh personal auth status
```

Run different commands under different accounts:

```bash
./gws-profile.sh work gmail users messages list \
  --params '{"userId":"me","maxResults":5}' \
  --format json

./gws-profile.sh personal drive files list \
  --params '{"pageSize":10}' \
  --format json
```

## How It Works

The whole idea is this:

```bash
GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws-work gws ...
GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws-personal gws ...
```

That is all.

The wrappers just make it repeatable and less annoying.

## Scripts

### `gws-profile.sh`

Usage:

```bash
./gws-profile.sh <profile> <gws args...>
```

Examples:

```bash
./gws-profile.sh work auth status
./gws-profile.sh client-a gmail users messages list --params '{"userId":"me","maxResults":1}' --format json
./gws-profile.sh finance sheets spreadsheets get --params '{"spreadsheetId":"..."}' --format json
```

Environment:

- `GWS_BIN`  
  Custom path to the `gws` binary.

- `GWS_PROFILES_DIR`  
  Base directory for profile configs. Default: `~/.config`

### `gws-login-all.sh`

Usage:

```bash
./gws-login-all.sh <profile> [profile...]
```

Examples:

```bash
./gws-login-all.sh work personal client-a
GWS_LOGIN_SCOPES="gmail,drive,sheets" ./gws-login-all.sh work personal
GWS_DEFAULT_PROFILES="work personal client-a" ./gws-login-all.sh
```

Environment:

- `GWS_LOGIN_SCOPES`  
  Comma-separated scopes passed to `gws auth login`.

- `GWS_DEFAULT_PROFILES`  
  Space-separated fallback profile list when no args are passed.

- `GWS_LOGIN_LOG_DIR`  
  Where login logs are written. Default: `~/.cache/gws-logins/<timestamp>`

## Security Notes

- This repo does **not** store tokens.
- This repo does **not** ship credentials.
- Tokens stay in local `gws` profile directories created on your machine.
- Login logs may contain OAuth callback info while a login is in progress, so keep them local.

If you share examples publicly, do not paste token contents or local callback URLs after login.

## Troubleshooting

### `localhost refused to connect`

Usually this means the `gws auth login` process is no longer running.

Fix:

1. start login again
2. keep the shell process alive
3. open the new browser URL

### Wrong account in the wrong profile

Check:

```bash
./gws-profile.sh work auth status
./gws-profile.sh personal auth status
```

If a profile drifted, just re-run login for that profile.

### `gws` not found

Install it:

```bash
npm install -g @googleworkspace/cli
```

Or set:

```bash
export GWS_BIN=/full/path/to/gws
```

## Why Open Source This?

Because this is one of those tiny utilities that saves real time and should not stay buried inside a private repo.

If you already use `gws`, this gives you multi-account support with almost no extra complexity.

---

<div align="center">

### Built by <a href="https://github.com/Nikolai-Iakubovskii">Nikolai Iakubovskii</a>

Indie developer shipping
<a href="https://apps.apple.com/us/app/mistyway-walking-quest-game/id6730126556">MistyWay</a> &bull;
<a href="https://apps.apple.com/us/app/aurora-forecast-map-aurorame/id6749782053">AuroraMe</a>

<br>

**Follow / DM / argue with me:**

[![X / Twitter](https://img.shields.io/badge/X-yak__niko-black?style=for-the-badge&logo=x&logoColor=white)](https://x.com/yak_niko)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Nikolai_Iakubovskii-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/nikolai-iakubovskii/)
[![Threads](https://img.shields.io/badge/Threads-@yak.nikolay-000000?style=for-the-badge&logo=threads&logoColor=white)](https://www.threads.com/@yak.nikolay)
[![Telegram](https://img.shields.io/badge/Telegram-sexyllm-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/sexyllm)

<sub>Open an issue or DM me on any of the above if you want improvements, edge-case fixes, or more wrappers around Google tooling.</sub>

</div>

## License

MIT
