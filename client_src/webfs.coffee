root = exports ? window
root.webfs = {}

webfs.loadBuffer = (user, file_path, cb) ->
    file_path = file_path.replace new RegExp('/', 'g'), '+'
    sharejs.open user+file_path, 'text', webfs.url+'/channel', (error, doc) =>
            if error?
                cb error, null
            else
                cb null, doc
                
webfs.ls = (user, path, cb) ->
    $.get webfs.url+'/store/'+user+path, (data) ->
        cb data
     

jQuery.ajaxSetup {async:false}
$.get 'webfs', (data) ->
    webfs.info = data
    webfs.url = "http://"+webfs.info.hostname+":"+ webfs.info.port
jQuery.ajaxSetup {async:true}


