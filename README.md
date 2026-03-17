# FinSafe Auth Flow

Hey, this is the repo for the AWS Cognito + Flutter auth flow I've been working on.

I got tired of messy authentication setups, so I decided to build a clean, production-ready starting point that actually uses solid architecture.

### How it works under the hood
I split the codebase up into proper layers so it doesn't become a nightmare to maintain later. Everything lives inside `lib/core`, `lib/presentation`, and `lib/data`.

For the heavy lifting, I'm using `Provider` to keep track of whether the user is logged in or not. `GoRouter` handles pushing screens around (because the default navigator is kinda awful for deep linking). AWS Amplify is wired up in the data layer to handle the actual Cognito calls—sign up, login, OTP codes, all of it.




