class HTMLString.Tag

    # A HTML tag

    constructor: (name, attributes) ->
        @_name = name.toLowerCase()
        @_selfClosing = HTMLString.Tag.SELF_CLOSING[@_name] == true
        @_head = null

        # Copy the attributes
        @_attributes = {}
        for k, v of attributes
            @_attributes[k] = v

    # Constants

    # A list of tags that must self close
    @SELF_CLOSING = {
        'area': true,
        'base': true,
        'br': true,
        'hr': true,
        'img': true,
        'input': true,
        'link meta': true,
        'wbr': true
        }

    # Read only properties

    head: () ->
        # Return the head <tag> of the tag

        # For performance we cache the head part of the tag
        if not @_head
            components = []

            for k, v of @_attributes
                if v
                    components.push("#{ k }=\"#{ v }\"")
                else
                    components.push("#{ k }")
            components.sort()

            components.unshift(@_name)

            @_head = "<#{ components.join(' ') }>"

        return @_head

    name: () ->
        # Return the tag's name
        return @_name

    selfClosing: () ->
        # Return true if the tag is self closing
        return @_selfClosing

    tail: () ->
        # Return the tail </tag> of the tag
        if @_selfClosing
            return ''
        return "</#{ @_name }>"

    # Methods

    attr: (name, value) ->
        # Get/Set the value of an attribute

        if value == undefined
            return @_attributes[name]

        # Set the attribute
        @_attributes[name] = value

        # Clear the head cache
        @_head = null

    removeAttr: (name) ->
        # Remove an attribute from the tag

        if @_attributes[name] == undefined
            return

        delete @_attributes[name]

    copy: () ->
        # Return a copy of the tag
        return new HTMLString.Tag(@_name, @_attributes)