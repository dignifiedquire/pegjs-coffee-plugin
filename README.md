peg-coffee
==========

Plugin for PEG.js to use coffee script in actions.


Usage
-----

# Node.js

First install it via
```bash
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
Load the following scripts

```html
<script src="peg.js"></script>
<script src=coffee-script.js"></script>
<script src="peg-coffee.js"></script>
```



Development
-----------

# Requirements

* Node.js with npm

Everything else gets installed automatically.

# Setup

Clone the repo and run the install
```bash
$ git clone https://github.com/Dignifiedquire/peg-coffee.git
$ make install
```

# Running the tests

For the node.js test run
```bash
$ make test
```
and for the browser
```bash
$ make test-browser
```



# Todo

* more tests
* add CoffeeScript test suite
* make npm package
