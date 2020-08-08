# go-github-apps

`go-github-apps` is a command-line tool to retrieve a github access token for your Github Apps.

When you want to call Github APIs from machines, you would want an access token which independs of a real account.
Github provides several ways to issue tokens, for example:
- Issue Personal Access Token via machine-user: Before Github Apps exists, this is typical method to issue a token but it consumes one user seats.
- Create Github Apps and issue a token for the app: This is a new way and recommended way. The problem is [it's not that easy to issue a token](https://docs.github.com/en/developers/apps/authenticating-with-github-apps#authenticating-as-a-github-app) just to automate small stuff.

This command-line tool allows you to get a token with just providing `App ID`, `Installation ID` and the private key.

## Usage

```sh
Usage of go-github-apps:
  -app-id int
    	App ID
  -export
    	show token as 'export GITHUB_TOKEN=...'
  -inst-id int
    	Installation ID
```

**Example**:
```sh
export GITHUB_PRIV_KEY=$(cat your-apps-2020-08-07.private-key.pem)
eval $(go-github-apps -export -app-id 12345 -inst-id 123456)

# github token is now exported to GITHUB_TOKEN environment variable
```

## AppID and Installation ID

You can find how to get those ID at https://github.com/bradleyfalzon/ghinstallation#what-is-app-id-and-installation-id
