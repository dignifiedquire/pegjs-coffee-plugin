peg-coffee
==========

Plugin for PEG.js to use coffee script in actions.


## Requirements

* [PEG.js](http://pegjs.majda.cz/) (who would have guessed that?)
* [CoffeeScript](http://coffeescript.org/)

## Installation

**Node.js**
```bash
$ npm install peg-coffee
```
Then in your code call
```coffee-script
PEG = require 'pegjs'
PEGCoffee = require '../lib/peg-coffee'
```

**Browser**
Download
[peg-coffee.js](https://raw.github.com/Dignifiedquire/peg-coffee/master/lib/peg-coffee.js).
Now include all needed scripts in your html file like this.
```html
<script src="peg.js"></script>
<script src=coffee-script.js"></script>
<script src="peg-coffee.js"></script>
``

## Usage
After you have loaded all scripts you can do
```coffee-script
PEGCoffee.initialize(PEG)
# From here on out you can use CoffeeScript in your actions
PEG.compile(..)
```



-------------

## Development


### Requirements

* [Node.js](http://nodejs.org/) with npm
* [mocha](http://visionmedia.github.com/mocha/)
* [http-server](https://github.com/nodeapps/http-server)

Everything else gets installed automatically.

### Setup

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
and open your browser on [localhost:3000](http://localhost:3000).



# Todo

* more tests
* add CoffeeScript test suite
* make npm package
