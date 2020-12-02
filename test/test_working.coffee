# During the test the env variable is set to test
process.env.NODE_ENV = 'test'

# Import required packages
chai         = require 'chai'
chaiHttp     = require 'chai-http'
expect       = chai.expect
IOServer     = require 'ioserver'
IOServerHTTP = require "#{__dirname}/../build/server.js"

# Setup global vars
HOST = '127.0.0.1'
PORT = 9000
chai.use(chaiHttp)

ioserver = new IOServer
            host: HOST
            port: PORT
server = new IOServerHTTP
            share: "#{__dirname}/public"
ioserver.start(server.app)

###################### UNIT TESTS ##########################
describe "Simple HTTP server working tests", ->

    # Set global timeout
    @timeout 4000
    
    it 'Check public index.html implicit page access', (done) ->
        chai.request(server.app)
        .get('/')
        .end((err, res) =>
                expect(err).to.be.null
                expect(res).to.have.status(200)
                expect(res).to.have.header('content-type', 'text/html; charset=utf-8');
                done()
            )
        return
    
    it 'Check public index.html explicit page access', (done) ->
        chai.request(server.app)
        .get('/index.html')
        .end((err, res) =>
                expect(err).to.be.null
                expect(res).to.have.status(200)
                expect(res).to.have.header('content-type', 'text/html; charset=utf-8');
                done()
            )
        return
    
    it 'Check forbidden directory listing', (done) ->
        chai.request(server.app)
        .get('/noindex')
        .end((err, res) =>
                expect(err).to.be.null
                expect(res).to.have.status(403)
                done()
            )
        return
    
    it 'Check invalid page access', (done) ->
        chai.request(server.app)
        .get('/does_not_exists')
        .end((err, res) =>
                expect(err).to.be.null
                expect(res).to.have.status(404)
                done()
            )
        return
    
    it 'Check directory traversal forbidden', (done) ->
        chai.request(server.app)
        .get('/../../../../index.html')
        .end((err, res) =>
                expect(err).to.be.null
                expect(res).to.have.status(400)
                done()
            )
        return
    
    it 'Check public/page.txt page access', (done) ->
        chai.request(server.app)
        .get('/page.txt')
        .end((err, res) =>
                expect(err).to.be.null
                expect(res).to.have.status(200)
                expect(res).to.have.header('content-type', 'text/plain; charset=utf-8');
                expect(res.text).to.deep.equal('Hello World!')
                done()
            )
        return