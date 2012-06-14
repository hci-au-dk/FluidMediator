root = exports ? window

loadPage = () ->
    $('#login').hide()
    $('#main').show()
    
    
    root.username = $('#username').val()
    #webfs.ls 'madsdk', '/mypaper', (data) ->
    #    console.log data
    
    #webfs.loadBuffer 'madsdk', 'test', (error, buffer) ->
    #    console.log buffer.snapshot
    
    testEditor = $('<div class="component"/>')
    $('#main').append testEditor
    editor = new Editor testEditor, '/mypaper'

    #testPreviewer = $('<div class="component"/>')
    #$('#main').append testPreviewer
    #editor = new Previewer testPreviewer, 'bar'

    #testProjectList = $('<div class="component"/>')
    #$('#main').append testProjectList
    #project = new ProjectList testProjectList, 'baz'

    #Layout content
    $('#main').layout({
            type: 'flow',
            resize: false,
            items: $('#main').children()
    })
    #The layouter messes with the css sizing, we'll fix that!
    $('#main').css('width', '100%')
    $('#main').css('height', '100%')
    $('#main').css('position', 'absolute')

$(document).ready () ->
        $('#main').hide()
        
        $.ajaxSetup {
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            xhrFields: {withCredentials: true},
            crossDomain: true
        }
        
        $('#input').click () ->
            send = $("#form").formToJSON()
            $.ajax {
                url: webfs.url + "/authenticate",
                type: "POST",
                data: send,
                error: ((xhr, error) ->
                    alert('Error!  Status = ' + xhr.status + ' Message = ' + error)),
                success: ((data) ->
                    loadPage()),
                }
            return false
        
