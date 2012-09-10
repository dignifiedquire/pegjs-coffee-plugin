peg-coffee
==========

Plugin for PEG.js to use coffee script in actions.


Usage
-----

# Node.js

First install it via
```shell
$ npm install peg-coffee
```
Then in your code you do

```coffee-script
PEG = require 'pegjs'
PEGCoffee = require '../lib/peg-coffee'

PEGCoffee.initialize(PEG)
# From here on out you can use CoffeeScript in your actions
PEG.compile(..)
```


# Browser
## Script

## Require.js


Development
-----------


# Setup


# Running the tests



# Todo

* add pass
* make browser compatible
* add CoffeeScript test suite
* make npm package
