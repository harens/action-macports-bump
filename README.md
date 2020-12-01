# MacPorts Bump Action

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/harens/action-macports-bump/Bump%20Test?logo=github&style=flat-square)](https://github.com/harens/action-macports-bump/actions?query=workflow%3A%22Bump+Test%22)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/harens/action-macports-bump/ShellCheck?label=ShellCheck&logo=github%20actions&logoColor=white&style=flat-square)](https://github.com/harens/action-macports-bump/actions?query=workflow%3AShellCheck)

<img src="https://avatars2.githubusercontent.com/u/4225322?s=280&v=4" align="right"
     alt="MacPorts Logo" width="150">

*A GitHub Action to assist in updating MacPorts Portfiles!*

*⚠️ This Action is very early on in development, and is still currently being built. Watch this space! ⚠️*

This action automatically sends a PR to update a project's Portfile following a new release. 

* For __port maintainers__, this means less time has to be spent manually checking and updating ports.
* For __users__, this makes it easier to get updates for your software as soon as they come out.
* For __software authors__, this helps to make sure the latest version of your software is always being packaged 📦 .

## 💻 Usage

```yaml
name: MacPorts Bump Version

on:
  push:
    tags:
      - '*'

jobs:
  macports:
    runs-on: macos-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Bump Version
        uses: harens/action-macports-bump@v1
        with:
          token: ${{secrets.TOKEN}}
          # Name of the port on MacPorts
          name: example
```

## 🎟️ Personal Access Token

### Why this is required

The action runs `gh auth login --with-token` in order to create the PR through the user's account.

### How to Generate

Click [here](https://github.com/settings/tokens/new?scopes=read:org,repo) to generate a Personal Access token with the minimum required scopes for *GitHub cli* to function (`repo` and `read:org`). See the [`gh auth login` docs](https://cli.github.com/manual/gh_auth_login) for more info about the scopes.

After generating the token, in the project repo page, go to `Settings ➤ Secrets ➤ New secret`. Paste the value in and give it a name (e.g. TOKEN). Add this token to the workflow file, such as above `${{secrets.TOKEN}}`, where `TOKEN` is the name of the token generated.

## 📨 How it works

1) Sets up MacPorts using the [GiovanniBussi/macports-ci](https://github.com/GiovanniBussi/macports-ci) shell script
2) Clones the [macports-ports](https://github.com/macports/macports-ports) repo
3) Installs and authenticates GitHub CLI
4) Creates a [local portfile repo](https://guide.macports.org/chunked/development.local-repositories.html), where the version number and checksums are updated
5) Copies the changes to the main repo, and opens a PR

## 🔨 Contributing

Any change, big or small, that you think can help improve this action is more than welcome 🎉.

As well as this, feel free to open an issue with any new suggestions or bug reports. Every contribution is appreciated.

## 📜 Examples

* This project's [tests.yml](https://github.com/harens/action-macports-bump/blob/master/.github/workflows/tests.yml)

## 🏗️ TODO

* Add __support for generating binary packages__ that do not require MacPorts on the target system via `sudo port mpkg/mdmg`. Although this is feasible and [well documented](https://guide.macports.org/chunked/using.binaries.html), the issue with this is that it might be hard to generalise this process for many ports and it would make the action much slower.
* Include an __updating dependencies__ feature that could be useful for Go and Cargo packages in particular. This could make use of tools such as [go2port](https://github.com/amake/go2port).
* Add an option to manually set the commit email address so as to __reduce the number of scopes__ required.

## ✨ Acknowledgements

This project was inspired by [dawidd6/action-homebrew-bump-formula](https://github.com/dawidd6/action-homebrew-bump-formula), a similar GitHub Action for Homebrew.

[GiovanniBussi/macports-ci](https://github.com/GiovanniBussi/macports-ci) also made setting up MacPorts on the fly much simpler. It worked flawlessly and had many advanced flags that were very useful.

## 📒 Notice of Non-Affiliation and Disclaimer

This project is not affiliated, associated, authorized, endorsed by, or in any way officially connected with the MacPorts Project, or any of its subsidiaries or its affiliates. The official MacPorts Project website can be found at <https://www.macports.org>.

The name MacPorts as well as related names, marks, emblems and images are registered trademarks of their respective owners.
