# go-github-apps

[![Go](https://github.com/nabeken/go-github-apps/actions/workflows/go.yml/badge.svg)](https://github.com/nabeken/go-github-apps/actions/workflows/go.yml)
[![Test Action](https://github.com/nabeken/go-github-apps/actions/workflows/test-action.yml/badge.svg)](https://github.com/nabeken/go-github-apps/actions/workflows/test-action.yml)

`go-github-apps` is a command-line tool to retrieve a Github Apps Installation Token.

When you want to call Github APIs from machines, you would want an access token which independs of a real account.
Github provides several ways to issue tokens, for example:
- **Personal Access Token via machine-user**: Before Github Apps exists, this is a typical method to issue a token but it consumes one user seats.
- **Github Apps**: This is a new and recommended way. The problem is [it's not that easy to issue a token](https://docs.github.com/en/developers/apps/authenticating-with-github-apps#authenticating-as-a-github-app) just to automate small stuff.

This command-line tool allows you to get a token with just providing `App ID`, `Installation ID` and the private key.

## Usage

```sh
Usage of ./go-github-apps:
  -app-id int
    	App ID
  -export
    	show token as 'export GITHUB_TOKEN=...'
  -inst-id int
    	Installation ID
  -show-insts
    	show all of the installations for the app
  -url string
        Full URL for a Github Enterprise installation, example 'https://github.example.com/api/v3'
  -version
    	show version info
```

**Example**:
```sh
export GITHUB_PRIV_KEY=$(cat your-apps-2020-08-07.private-key.pem)
eval $(go-github-apps -export -app-id 12345 -inst-id 123456)

# github token is now exported to GITHUB_TOKEN environment variable
```

## AppID and Installation ID

As for the App ID, you can get it via the Github Apps page.

As for the Installation ID, you can now find it with the `-show-insts` option:
```sh
export GITHUB_PRIV_KEY=$(cat your-apps-2020-08-07.private-key.pem)

./go-github-apps -app-id 12345 -show-insts
[]*github.Installation{
  &github.Installation{
    ID:       &123456789,
    NodeID:   (*string)(nil),
    AppID:    &12345,
    AppSlug:  &"go-github-apps-test",
    TargetID: &1234,
...
  },
}
```

It shows the response from [`https://api.github.com/app/installations`](https://docs.github.com/en/rest/apps/apps?apiVersion=2022-11-28#list-installations-for-the-authenticated-app).
If you install the app for multiple organizations and/or users, you may see multiple responses. You need to select one of the installations to use with this CLI.

## Installation

https://github.com/nabeken/go-github-apps/releases

## Installation for continuous integration

`install-via-release.sh` allows you to grab the binary into the current working directory so that you can easy integrate it into your pipiline.

**Example**:
```sh
curl -sSLf https://raw.githubusercontent.com/nabeken/go-github-apps/master/install-via-release.sh | bash -s -- -v v0.0.3
sudo cp go-github-apps /usr/local/bin
```

## Github Actions

As of Aug, 2024, Github provides [the official actions](https://github.com/actions/create-github-app-token) to create a GitHub App installation access token. Please consider migrating to the official one.

At certain point, I'll obsolete the github action in this repository.

### Different from `actions/create-github-app-token`

`go-github-apps` always receives an installation token for the installation under an installed owner (organization) where the official action only requires for a current repository.

If you want to have an installation that works for the installation under installed owner (organization), you need to specify `owner` in the workflow:

```yaml
steps:
- uses: actions/create-github-app-token@v1
  id: app-token
  with:
    app-id: ${{ vars.APP_ID }}
    private-key: ${{ secrets.PRIVATE_KEY }}
    owner: ${{ github.repository_owner }}
```

### `go-github-apps`'s Github Actions

You can automate issuing a token for Github Actions with `go-github-apps` but it will be obsoleted in the future as described above.

Example:
```yml
- name: Get GITHUB_TOKEN for Github Apps
  uses: nabeken/go-github-apps@v0
  id: go-github-apps
  with:
    installation_id: ${{ secrets.installation_id }}
    app_id: ${{ secrets.app_id }}
    private_key: ${{ secrets.private_key }}

- name: Test Github API call
  run: |
    curl --fail -H 'Authorization: token ${{ steps.go-github-apps.outputs.app_github_token }}' https://api.github.com/
```

## Release

- Merge a release PR, created by release-please action
- Renovate will update "version" in several places once it detects a new version of `go-github-apps` so you can merge it if you're happy with the result
  - "version" in the github actions for testing
  - default "version" in `action.yml`
- Tag `v0`
  - Run [`Bump the actions version`](https://github.com/nabeken/go-github-apps/actions/workflows/update_actions_tag.yml) to update `v0` tag with the latest main branch
