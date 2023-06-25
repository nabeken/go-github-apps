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

You can automate issuing a token with Github Actions.

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

- Just tag a new release as usual
- To update the default version in the action, you need to update `v0` tag.
    - Create a branch that update "version" in the Github Actions (not the default version)
    - Create a PR to confirm that the new release works
    - Update the branch to update *the default version* in the `action.yml`
    - Merge the PR
- Tag `v0`
    - `git tag -f v0`
    - `git push -f origin refs/tags/v0`
