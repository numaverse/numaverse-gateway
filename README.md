# Numaverse Gateway

This project hosts the web server that acts as a gateway to the Numa network. Documentation is currently sparse, but will improve soon.

To setup a development environment locally, first run a few basic setup steps:

Clone the repository:

~~~bash
git clone git@github.com:numaverse/numaverse-gateway.git
cd numaverse-gateway
~~~

Install ruby and node dependencies:

~~~bash
bundle -j4
yarn
~~~

Setup the database:

~~~bash
bundle exec rails db:setup
~~~

You'll also need to setup a local Ethereum chain for testing. This will setup a single account that, when you run the dev chain, will have a very large amount of funds. You can then import the [private key](./dev-chain/account.txt) into MetaMask and use that account to setup and fund other testing accounts. Obviously, that private key should never be used on the Ethereum main net, or you might get your funds stolen.

~~~bash
geth account import --password ./dev-chain/password.txt --keystore ./dev-chain/geth-keys --datadir ./dev-chain/geth-data dev-chain/account.txt 
~~~

I recommend using [overmind](https://github.com/DarthSim/overmind) to run all the processes needed for development (there area lot).

Then, run:

~~~
overmind s -f Procfile.dev
~~~

And you'll have the following processes:

1. An IPFS daemon
2. A local ethereum chain in development mode (no mining)
3. A rails server
4. A webpack server for hot reloading
5. Livereload for regular page reloading
6. A sidekiq worker process

If you made it this far, you should have a server running at http://localhost:9000
