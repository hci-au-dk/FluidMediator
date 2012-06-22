root = exports ? window
root.surrogate = {}

surrogateUrl = 'http://10.11.108.249:8002'

surrogate.compileLatex = (path, owner) -> 
    data = {}
    data = {
        'host': webfs.info.hostname
        'port': webfs.info.port,
        'path': path,
        'owner': owner
    }
    
    $.ajax {
      type: 'POST',
      url: surrogateUrl+'/checkout',
      data: JSON.stringify(data),
      contentTypeString: 'application/json'
      success: (data) ->
          console.log data
    }