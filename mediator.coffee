express = require 'express'
fs = require 'fs'
pr = require './lib/Projects'





#project: name, owner, created, modified
projects =
        Result: 'OK'
        Records: [
                {
                        id: 1
                        name: 'Mit projekt'
                        owner: 'Niels Olof'
                        created: '2012-04-20'
                        modified: '2012-04-21'
                }
                {
                        id: 2
                        name: 'Dit projekt'
                        owner: 'Clemens'
                        created: '2012-04-22'
                        modified: '2012-04-23'
                }
        ]

class Mediator
    constructor: () ->
        @setupExpress()

    setupExpress: () ->
        @app = express.createServer()
        @app.use (req, res, next) ->
            res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
            res.header 'Access-Control-Allow-Origin', '*'
            next()

        @app.use(express.bodyParser())
        @app.use(express.methodOverride())
        @app.use(@app.router)
        @app.use(express.static(__dirname+'/html'))

        @app.get '/webfs', (req, res) ->
            res.send({hostname: 'localhost', port: 8001})
        
        @app.get('/user/:id', (req, res) -> res.send('user ' + req.params.id))
        
        
        @app.post('/api/ListProjects', (req, res) ->
                console.log("responded to POST /api/ListProjects")
                res.writeHead(200, {'content-type': 'text/json' });
                res.write(JSON.stringify(projects))
                res.end('\n')
        )
        @app.post('/api/CreateProject', (req, res) ->
                console.log("responded to POST /api/CreateProject")
                console.log(req.body.name);
                console.log(req.body.owner);
                newrecord =
                        id: projects.length+1
                        name: req.body.name
                        owner: req.body.owner
                        created: req.body.created
                        modified: req.body.modified
                projects.records += newrecord
                okresult =
                        Result: "OK"
                        Record: newrecord
                res.writeHead(200, {'content-type': 'text/json'})
                res.write(JSON.stringify(okresult))
                res.end()
        )
#                req.addListener('data', (chunk) -> data += chunk)
#                req.addListener('end', () ->
#                        console.log(JSON.parse(data))
#
#                        res.end()
#                )


        @app.listen(8000)

mediator = new Mediator()
