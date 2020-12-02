# IOServer-HTTP

[![NPM](https://nodei.co/npm/ioserver-http.png?compact=true)](https://nodei.co/npm/ioserver-http/)

[![Downloads per month](https://img.shields.io/npm/dm/ioserver-http.svg?maxAge=2592000)](https://www.npmjs.org/package/ioserver-http)
[![npm version](https://img.shields.io/npm/v/ioserver-http.svg)](https://www.npmjs.org/package/ioserver-http)
[![Build Status](https://travis-ci.org/x42en/IOServer-http.svg?branch=master)](https://travis-ci.org/x42en/IOServer-http)
[![Known Vulnerabilities](https://snyk.io/test/github/x42en/ioserver-http/badge.svg)](https://snyk.io/test/github/x42en/ioserver-http)


Simple HTTP(S) server for usage with [IOServer](http://github.com/x42en/IOServer).

This will launch a server on port specified (default: 8080) and will listen for all GET requests. This is particulary useful with static content. For dynamic support like PHP and more advanced usage (POST/PUT/etc...) please have a look at [Express](https://expressjs.com/) and/or specific web server like [Nginx](https://www.nginx.com/).

## Install

Install with npm:
  ```bash
    npm install ioserver-http
  ```
  
## Basic Usage

Require the module:
  ```coffeescript
    IOServerHTTP = require 'ioserver-http'
  ```

Instanciate object:
  ```coffeescript
    server = new IOServerHTTP
            share: '/var/www/html'
  ```

Start the server...
  ```coffeescript
    server.app.listen('127.0.0.1', 8000)
  ```