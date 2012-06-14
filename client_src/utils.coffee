$.fn.formToJSON = () ->
    objectGraph = {}

    add = (objectGraph, name, value) ->
        if (name.length == 1)
            #if the array is now one element long, we're done
            objectGraph[name[0]] = value
        else
            #else we've still got more than a single element of depth
            if (objectGraph[name[0]] == null)
                #create the node if it doesn't yet exist
                objectGraph[name[0]] = {}
                
                #recurse, chopping off the first array element
            add(objectGraph[name[0]], name.slice(1), value)
        #loop through all of the input/textarea elements of the form
        #this.find('input, textarea').each(function() {
    $(this).children('input, textarea').each () ->
                    #ignore the submit button
                    if($(this).attr('name') != 'submit')
                        #split the dot notated names into arrays and pass along with the value
                        add(objectGraph, $(this).attr('name').split('.'), $(this).val())
    return JSON.stringify(objectGraph)