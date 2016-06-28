class HTMLString.Character

    # A HTML character

    constructor: (c, tags) ->
        @_c = c

        # Entities are stored lower case
        if c.length > 1
            @_c = c.toLowerCase()

        # Add the tags
        @_tags = []
        @addTags.apply(@, tags)

    # Read-only properties

    c: () ->
        # Return the native character string
        return @_c

    isEntity: () ->
        # Return true if the character is an entity
        return @_c.length > 1

    isTag: (tagName) ->
        # Return true if the character is a self-closing tag (e.g br, img),
        # optionally a tagName can be specified to match against.

        if @_tags.length == 0 or not @_tags[0].selfClosing()
            return false

        if tagName and @_tags[0].name() != tagName
            return false

        return true

    isWhitespace: () ->
        # Return true if the character represents a whitespace character
        return @_c in [' ', '\n', '&nbsp;'] or @isTag('br')

    tags: () ->
        # Return the tags for this character
        return (t.copy() for t in @_tags)

    # Methods

    addTags: (tags...) ->
        # Add tag(s) to the character
        for tag in tags

            # HACK: Fix for IE edge (see issue:
            # https://github.com/GetmeUK/ContentTools/issues/258#issuecomment-228931486
            #
            # ~ Anthony Blackshaw <ant@getme.co.uk>, 28th June 2016
            if Array.isArray(tag)
                continue;

            # Any self closing tag has to be inserted as the first tag
            if tag.selfClosing()
                # You can't add a self closing tag to a character that is a tag
                if not @isTag()
                    @_tags.unshift(tag.copy())

                continue

            # Add the tag to the stack
            @_tags.push(tag.copy())

    eq: (c) ->
        # Return true if the specified character is equal to this character

        # Check characters are the same
        if @c() != c.c()
            return false

        # Check the number of tags are the same
        if @_tags.length != c._tags.length
            return false

        # Check tags are the same
        tags = {}
        for tag in @_tags
            tags[tag.head()] = true

        for tag in c._tags
            if not tags[tag.head()]
                return false

        return true

    hasTags: (tags...) ->
        # Return true if the tags specified format this character
        tagNames = {}
        tagHeads = {}
        for tag in @_tags
            tagNames[tag.name()] = true
            tagHeads[tag.head()] = true

        # If a tag is supplied as a string we test if a tag with that name is
        # characters tags, if a tag instance is supplied then we check for
        # exact tag.
        for tag in tags
            if typeof tag == 'string'
                if tagNames[tag] == undefined
                    return false
            else
                if tagHeads[tag.head()] == undefined
                    return false

        return true

    removeTags: (tags...) ->
        # Remove tag(s) from the character

        # If no tags are provide we remove all tags
        if tags.length == 0
            @_tags = []
            return

        names = {}
        heads = {}
        for tag in tags
            if typeof tag == 'string'
                names[tag] = tag
            else
                heads[tag.head()] = tag

        newTags = []
        @_tags = @_tags.filter (tag) ->
            if not heads[tag.head()] and not names[tag.name()]
                return tag

    copy: () ->
        # Return a copy of the character
        return new HTMLString.Character(@_c, (t.copy() for t in @_tags))