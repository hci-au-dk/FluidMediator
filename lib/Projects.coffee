fs = require 'fs'
uuid = require 'node-uuid'

root = exports ? window
class root.Projects
        projectFile = ''
        projectMap = { }
        projectsHasBeenRetrieved = false

        class Project
                constructor: (defaultParameters={ }) ->
                        @id = defaultParameters.id or uuid.v1()
                        @name = defaultParameters.name or ''
                        @owner = defaultParameters.owner or ''
                        @participants = defaultParameters.participants or [ @owner ]
                        @created = if defaultParameters.created then new Date(defaultParameters.created) else new Date()
                        @modified = if defaultParameters.modified then new Date(defaultParameters.modified) else new Date()

        constructor: (defaultParameters={ }) ->
                projectFile = defaultParameters.projectFile or "./.projects"
                projectMap = { }

        retrieveProjects: (whenDone, req, res) ->
                file_data = ''
                @projectMap = { }
                rs = fs.createReadStream(projectFile, { encoding: 'utf8' })
                rs.on 'data', (data) ->
                        file_data += data
                rs.on 'end', () =>
                        if file_data.length > 0
                                for own _id, _project of JSON.parse file_data
                                        this.addProject _project
                                whenDone(req, res) if whenDone?
                                this.projectsHasBeenRetrieved = true
                                console.log("Projects has totally been retrieved.")

        addProject: (defaultParameters={ }) ->
                _project = new Project defaultParameters
                projectMap[_project.id] = _project

        getProject: (_id) ->
                return projectMap[_id]

        getAllProjects: () ->
                _allProjects = [ ]
                for own _id, _project of projectMap
                        _allProjects.push _project
                return _allProjects


        removeProject: (_id) ->
                delete projectMap[_id]

        writeProjects: (whenDone, req, res) ->
                ws = fs.createWriteStream(projectFile, { encoding: 'utf8' })
                ws.write JSON.stringify projectMap
                ws.on 'drain', (whenDone) ->
                        whendone(req, res) if whenDone?

        dumpProjectsToConsole: () ->
                console.log projectMap

## The following are convenience functions that answers admirably to the requirements of JTable
# 			  listAction: '/api/ListProjects',
#			  createAction: '/api/CreateProject',
#			  updateAction: '/api/UpdateProject',
#			  deleteAction: '/api/DeleteProject'

        listAction: (req, res) =>
                console.log("inside listAction")
                if (this.projectsHasBeenRetrieved)
                        console.log("Projects has been retrieved.")
                        response = { Result: 'OK' }
                        response['Records'] = this.getAllProjects()
                        res.writeHead(200, {'content-type': 'text/json' });
                        res.write(JSON.stringify(response))
                        res.end('\n')
                else
                        console.log("Projects has not been retrieved.")
                        this.retrieveProjects((req, res) =>
                                console.log("Whendone commencing")
                                console.log("res = " + res)
                                response = { Result: 'OK' }
                                response['Records'] = this.getAllProjects()
                                res.writeHead(200, {'content-type': 'text/json'});
                                res.write(JSON.stringify(response))
                                res.end('\n')
                                console.log(JSON.stringify(response))
                        req, res)


        createAction: (req, res) ->
                response = { Result: 'OK' }
                res.writeHead(200, {'content-type': 'text/json' });
                res.write(JSON.stringify(response))
                res.end('\n')


        updateAction: (req, res) ->
                response = { Result: 'OK' }
                res.writeHead(200, {'content-type': 'text/json' });
                res.write(JSON.stringify(response))
                res.end('\n')

        deleteAction: (req, res) ->
                response = { Result: 'OK' }
                res.writeHead(200, {'content-type': 'text/json' });
                res.write(JSON.stringify(response))
                res.end('\n')



