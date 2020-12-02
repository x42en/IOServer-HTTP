# Add required packages
fs     = require 'fs'
url    = require 'url'
path   = require 'path'

# Add http servers
http   = require 'http'
https  = require 'https'
querystring = require 'querystring'

# Start a simple HTTP server based on http(s) libs
module.exports = class SimpleServer
    constructor: ({share, ssl_ca, ssl_cert, ssl_key}) ->
        # If websocket and server must be secured
        # with certificates
        @share = if share then String(share) else null
        @secure = false
        if not fs.existsSync @share
            throw "Directory #{@share} does not exists"

        if ssl_key? or ssl_cert? or ssl_ca?
            try
                @sec_profile = {
                    key: fs.readFileSync(ssl_key),
                    cert: fs.readFileSync(ssl_cert),
                    ca: fs.readFileSync(ssl_ca)
                }
                @secure = true
            catch err
                throw "Unable to load certificate profile: #{err}"

        if @secure
            try
                @app = https.createServer @sec_profile, @_http_handler
            catch err
                throw "Unable to create secured HTTPS server: #{err}"
        else
            try
                @app = http.createServer @_http_handler
            catch err
                throw "Unable to create HTTP server: #{err}"

    # Allow your small server to share some stuff
    _http_handler: (req, res) =>
        # If nothing is shared
        if not @share
            res.writeHead 200
            res.end 'Nothing shared'
            return
        
        # If param is set
        params = url.parse(req.url).query
        
        # Avoid blank filename
        uri = url.parse(req.url).pathname
        filename = path.join(@share, uri)

        # Sanitize request
        if '..' in uri.split('/')
            res.writeHead 400
            res.end "Bad Request\n"
            return
        
        @method = req.method
        @_parse_request filename, params, res
    
    _parse_request: (filename, params, res) ->
        # Hard defined mime-type based on extension
        contentTypesByExtension = {
            '.html': "text/html; charset=utf-8"
            '.css' : "text/css; charset=utf-8"
            '.js'  : "application/javascript; charset=utf-8"
            '.avi' : "video/x-msvideo"
            '.exe' : "application/octet-stream"
            '.gif' : "image/gif"
            '.htm' : "text/html; charset=utf-8"
            '.ico' : "image/x-icon"
            '.png' : "image/png"
            '.jpeg' : "image/jpeg"
            '.jpg' : "image/jpeg"
            '.mp3' : "audio/mpeg"
            '.mpeg' : "video/mpeg"
            '.pdf' : "application/pdf"
            '.sh' : "application/x-sh"
            '.snd' : "audio/basic"
            '.src' : "application/x-wais-source"
            '.svg' : "image/svg+xml"
            '.tar' : "application/x-tar"
            '.tgz' : "application/x-compressed"
            '.txt' : "text/plain; charset=utf-8"
            '.zip' : "application/zip"
            '.woff' : "application/font-woff"
            '.woff2' : "application/font-woff2"
        }

        # Set default headers
        headers = {
            "Server": "IOServer"
            "Content-Type": "text/plain; charset=utf-8"
            "X-Content-Type-Options": "nosniff"
        }

        # Check file existence
        if not fs.existsSync filename
            res.writeHead 404, headers
            res.write "404 Not Found\n"
            res.end()
            return
            
        # If file is directory search for index.html/php
        if fs.statSync(filename).isDirectory()
            # Remove end slash if necessary
            if filename[-1] is '/'
                filename = filename.slice(0, -1)
            filename = "#{filename}/index.html"
        
        # Prevent directory listing
        if not fs.existsSync filename
            res.writeHead 403, headers
            res.write "403 Forbidden\n"
            res.end()
            return
        
        try
            # Get filename content
            content = fs.readFileSync filename, 'binary'
        catch err
            res.writeHead 500, headers
            res.write "#{err}\n"
            res.end()
            return
            
        contentType = contentTypesByExtension[path.extname(filename)]
        
        if contentType
            headers["Content-Type"] = contentType
        
        res.writeHead 200, headers
        res.write content, 'binary'
        res.end()

        return