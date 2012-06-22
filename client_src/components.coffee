root = exports ? window

$.fn.pixels = (property) ->
    return parseInt this.css(property).slice(0,-2)

#COMPONENT
class root.Component
    ###
    This class provides the chrome of all of our components
    It takes a div and creates a contentdiv (@content) that the class
    inheriting from Component can use to put stuff in
    ###
    constructor: (@div) ->
        @id = @div.attr 'id'
        #Create the content div
        @content = $('<div/>')
        @content.css 'position', 'absolute'
        @content.css 'left', 2
        @content.css 'top', 20
        @content.css 'width', @div.pixels('width')-4
        @content.css 'height', @div.pixels('height')-20
        @content.css 'background', '#FFFFFF'
#        @content.css 'border-radius', '5px'
#        @content.css '-moz-border-radius', '5px'
#        @content.css '-webkit-border-radius', '5px'
#        @content.css 'padding', '10px'
#        @content.css 'border', '1px solid #800000'
        @content.attr 'id', @id+'_content'
        @should_stack = true

        #Initiate a Raphael canvas to draw some chrome
        @paper = Raphael document.getElementById(@id), @div.pixels('width'), @div.pixels('height')
        @background = @paper.rect 4, 4, @div.pixels('width')-8, 12, 4
        @background.attr "fill", 'rgba(70, 70, 100, .3)'
        @background.attr 'stroke', 'rgba(0, 0, 0, 0)'
        @div.append @content
        @animating = false
        @dragging = false

        #Handle dragging the component around on the screen
        @background.mouseover () =>
            if not @animating and not @dragging
                @background.animate {"fill-opacity": .75}, 500
                @animating = true

        @background.mouseout () =>
            @animating = false
            if not @dragging
                @background.animate {"fill-opacity": .4}, 500

        start = (x, y) =>
            @dragging = true
            parent = @div.parent()
            if @should_stack
                parent.append @div
            @offsetX = x - @div.pixels 'left'
            @offsetY = y - @div.pixels 'top'

        move = (dx, dy, a, b, event) =>
            @div.css 'left', a - @offsetX
            @div.css 'top', b - @offsetY

        up = () =>
            @dragging = false

        @background.drag move, start, up

#PREVIEWER
class root.Previewer extends Component
    constructor: (@div, @docId) ->
        @div.css 'width', 612
        @div.css 'height', 792
        @div.css 'left', 0
        @div.css 'top', 0
        @div.attr 'id', @docId
        super @div

        #Create the buttons to control the pdf
        #This NEEDS to be refactored because in this way we goPrevious and goNext are global, hence we only support one PDF previwer
        top = '''
        <div>
            <button id="prev" onclick="goPrevious()">Previous</button>
            <button id="next" onclick="goNext()">Next</button>
            &nbsp; &nbsp;
            <span>Page: <span id="page_num"></span> / <span id="page_count"></span></span>
        </div>
        '''
        bottom =
        '''
        <div>
            <canvas id="''' + @docId + '''_canvas" style="border:1px solid black"></canvas>
        </div>
        '''

        @content.append top
        @content.append bottom

        url = 'pdf/tracemonkey.pdf'

        #Black magic - doesn't work unless worker is disabled
        PDFJS.disableWorker = true

        pdfDoc = null
        pageNum = 1
        scale = 1
        canvas = document.getElementById(@docId + '_canvas')
        ctx = canvas.getContext('2d')

        renderPage = (num) ->
            pdfDoc.getPage(num).then (page) ->
                viewport = page.getViewport(scale)
                canvas.height = viewport.height
                canvas.width = viewport.width

                renderContext = {
                    canvasContext: ctx,
                    viewport: viewport
                }
                page.render(renderContext)
            document.getElementById('page_num').textContent = pageNum
            document.getElementById('page_count').textContent = pdfDoc.numPages

        root.goPrevious = () ->
            if (pageNum <= 1)
                return
            pageNum--
            renderPage(pageNum)

        root.goNext = () ->
            if (pageNum >= pdfDoc.numPages)
                return
            pageNum++
            renderPage(pageNum)

        PDFJS.getDocument(url).then (_pdfDoc) ->
              pdfDoc = _pdfDoc
              renderPage(pageNum)

#EDITOR
class root.Editor extends Component
    constructor: (@div, @root_dir) ->
        @div.css 'width', 762
        @div.css 'height', 792
        @div.css 'left', 0
        @div.css 'top', 0
        @div.attr 'id', @root_dir
        super @div

        @currentDoc = null
        webfs.ls root.username, @root_dir, (data) =>
            @loadProjectFolder(data)
        
        
    loadProjectFolder: (data) ->
        #console.log data
        menu = $('<div/>')
        
        project_data = []
        for file in data
            filename = file.path[@root_dir.length+1..] #ToDo provide filename in json
            if filename[0] == '.'
                continue
            file_data = {
                "data": filename,
                "metadata": { id: filename, path: file.path}
            }
            project_data.push file_data
        
        menu.jstree {
            "core" : { },
            "themes" : {
                "theme" : "default",
                "dots" : true,
                "icons" : false
            },
            "json_data": {
                "data": project_data,
            }
            "plugins" : [ "themes", "json_data", "ui"]
            }
        
        #menu.jstree "set_theme", "default-rtl"

        compileButton = $('<button type="button">Compile</button>')
        compileButton.on 'click', (event) =>
            surrogate.compileLatex(@root_dir, root.username)

        @content.append menu
        @content.append compileButton

        menu.css 'position', 'absolute'
        menu.css 'width', 150
        menu.css 'height', @content.pixels('height') - 80
        menu.css 'left', 0
        menu.css 'top', 0
        menu.css 'margin-bottom', 8
        menu.css 'border', 'solid 1px'
        menu.css 'margin', '0 auto'

        compileButton.css 'position', 'absolute'
        compileButton.css 'width', 150
        compileButton.css 'height', 50
        compileButton.css 'left', 0
        compileButton.css 'top', @content.pixels('height') - 70
        
        editorDiv = $('<div/>')
        editorDiv.css 'position', 'absolute'
        editorDiv.css 'width', @content.pixels('width')-146
        editorDiv.css 'height', @content.pixels('height')
        editorDiv.css 'left', 154
        editorDiv.css 'top', 0
        editorDiv.attr 'id', @id+'_editor'
        
        loadingIcon = $('<img src="img/ajax-loader.gif"/>')
        loadingIcon.css('position': 'absolute')
        loadingIcon.css('top': '50%')
        loadingIcon.css('left': '50%')

        @content.append editorDiv
        @content.append loadingIcon
        loadingIcon.hide()

        #convert the editorDiv into a CodeMirror thing
        @editor = CodeMirror editorDiv.get(0), {"mode": "stex", "lineWrapping": true}
        
        #Give it some tex
        #editor.setValue tex

        menu.bind "select_node.jstree", (event, data) =>
                if @currentDoc != null
                    @currentDoc.detach_cm()
                filename = data.rslt.obj.data("id")
                path = data.rslt.obj.data("path")
                loadingIcon.show()
                webfs.loadBuffer root.username, path, (error, doc) =>
                    if error?
                        console.log error
                    else
                        @currentDoc = doc
                        doc.attach_cm(@editor, false)
                        loadingIcon.hide()

#PROJECT_LIST
class root.ProjectList extends Component
    constructor: (@div, @docId) ->
        @div.css 'width', 600
        @div.css 'height', 400
        @div.css 'left', 0
        @div.css 'top', 0
        @div.attr 'id', @docId
        super @div

        top = '''
        '''
        middle =
        '''
<!--        <table id="projects_table">
                <thead>
                        <tr>
                                <th>Name</th>
                                <th>Owner</th>
                                <th>Created</th>
                        </tr>
                </thead>
                <tbody>
                        <tr>
                                <td>CHI Paper</td>
                                <td>Clemens</td>
                                <td>2012-05-20</td>
                        </tr>
                        <tr>
                                <td>UIST Paper</td>
                                <td>Niels Olof</td>
                                <td>2012-06-13</td>
                        </tr>
                        <tr>
                                <td>UBICOM Paper</td>
                                <td>Mads</td>
                                <td>2012-04-15</td>
                        </tr>
                </tbody>
        </table>
-->
        <div id="ProjectsTableContainer"></div>
        '''
        bottom =
        '''
        <div>
            <canvas id="''' + @docId + '''_canvas" style="border:1px solid black"></canvas>
        </div>
        '''

        @content.append top
        @content.append middle
#        @content.append bottom
