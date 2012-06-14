root = exports ? window

root.jtable_response: (data, error) ->
        response = { }
        if error?
                response.Result = 'ERROR'
                response.Message = error
        else
                response.Result = 'OK'
        response.Records = if data? data else [ ]
        return response
