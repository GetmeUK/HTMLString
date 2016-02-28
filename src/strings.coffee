class HTMLString.String

    # A string of HTML

    @_parser = null

    constructor: (html, preserveWhitespace=false) ->
        @_preserveWhitespace = preserveWhitespace

        if html
            # For performance we only initialize the parser once and only the
            # first time a HTMLString instances is initialized with html.
            if HTMLString.String._parser is null
                HTMLString.String._parser = new _Parser()

            @characters = HTMLString.String._parser.parse(
                html,
                @_preserveWhitespace
                ).characters
        else
            @characters = []

    # Read-only properties

    isWhitespace: () ->
        # Return true if the string consists entirely of whitespace characters
        for c in @characters
            if not c.isWhitespace()
                return false
        return true

    length: () ->
        # Return the length of the string
        return @characters.length

    preserveWhitespace: () ->
        # Return true if the string is flagged to preserve whitespace
        return @_preserveWhitespace

    # Methods

    capitalize: () ->
        # Return a copy of the string with the first letter capitalized
        newString = @copy()
        if newString.length()
            c = newString.characters[0]._c.toUpperCase()
            newString.characters[0]._c = c
        return newString

    charAt: (index) ->
        # Return a single character from the string at the specified index
        return @characters[index].copy()

    concat: (strings..., inheritFormat) ->
        # Combine 2 or more strings and returns a new string. Optionally you
        # can specify whether the strings each inherit the previous strings
        # format (default true).

        # Check if the last argument was a string or the `inheritFormat` flag
        if not (typeof inheritFormat == 'undefined' or
                typeof inheritFormat == 'boolean')

            strings.push(inheritFormat)
            inheritFormat = true

        # Concat the strings
        newString = @copy()
        for string in strings

            # Skip empty strings
            if string.length == 0
                continue

            # If the string is supplied as text then convert it to an unformatted
            # string.
            tail = string
            if typeof string == 'string'
                tail = new HTMLString.String(string, @_preserveWhitespace)

            # Inherit the format of the existing string
            if inheritFormat and newString.length()
                indexChar = newString.charAt(newString.length() - 1)
                inheritedTags = indexChar.tags()

                # Don't inherit self-closing tags
                if indexChar.isTag()
                    inheritedTags.shift()

                if typeof string != 'string'
                    tail = tail.copy()

                for c in tail.characters
                    c.addTags.apply(c, inheritedTags)

            # Build the new string
            for c in tail.characters
                newString.characters.push(c)

        return newString

    contains: (substring) ->
        # Return true if the string contains the specified sub-string

        # Compare to text
        if typeof substring == 'string'
            return @text().indexOf(substring) > -1

        # Compare to html string
        from = 0
        while from <= (@length() - substring.length())
            found = true
            for c, i in substring.characters
                if not c.eq(@characters[i + from])
                    found = false
                    break
            if found
                return true
            from++

        return false

    endsWith: (substring) ->
        # Return true if the string ends with the specified sub-string

        # Compare to text
        if typeof substring == 'string'
            return (substring == '' or
                    @text().slice(-substring.length) == substring)

        # Compare to html string
        characters = @characters.slice().reverse()
        for c, i in substring.characters.slice().reverse()
            if not c.eq(characters[i])
                return false

        return true

    format: (from, to, tags...) ->
        # Apply the specified tags to a range (from, to) of characters in the
        # string.

        # Support for negative indexes on from/to
        if to < 0
            to = @length() + to + 1

        if from < 0
            from = @length() + from

        newString = @copy()
        for i in [from...to]
            c = newString.characters[i]
            c.addTags.apply(c, tags)

        return newString

    hasTags: (tags..., strict) ->
        # Return true if the specified tags are applied to some or all
        # (strict=true) characters within the string (default false).

        # Check if the last argument was a tag or the `strict` flag
        if not (typeof strict == 'undefined' or
                typeof strict == 'boolean')
            tags.push(strict)
            strict = false

        found = false
        for c in @characters
            if c.hasTags.apply(c, tags)
                found = true
            else
                if strict
                    return false

        return found

    html: () ->
        # Return a HTML version of the string

        html = ''
        openTags = []
        openHeads = []
        closingTags = []

        for c in @characters

            # Close tags
            closingTags = []
            for openTag in openTags.slice().reverse()
                closingTags.push(openTag)
                if not c.hasTags(openTag)
                    for closingTag in closingTags
                        html += closingTag.tail()
                        openTags.pop()
                        openHeads.pop()
                    closingTags = []

            # Open tags
            for tag in c._tags
                if openHeads.indexOf(tag.head()) == -1
                    if not tag.selfClosing()
                        head = tag.head()
                        html += head
                        openTags.push(tag)
                        openHeads.push(head)

            # If the character is a self-closing tag add it to the HTML after
            # all other tags.
            if c._tags.length > 0 and c._tags[0].selfClosing()
                html += c._tags[0].head()

            html += c.c()

        for tag in openTags.reverse()
            html += tag.tail()

        return html

    indexOf: (substring, from=0) ->
        # Return the index of the first occurrence of the specified sub-string,
        # -1 is returned if no match is found.

        if from < 0
            from = 0

        # Find text
        if typeof substring == 'string'
            return @text().indexOf(substring, from)

        # Find html string
        while from <= (@length() - substring.length())
            found = true
            for c, i in substring.characters
                if not c.eq(@characters[i + from])
                    found = false
                    break
            if found
                return from
            from++

        return -1

    insert: (index, substring, inheritFormat=true) ->
        # Insert the specified sub-string at the specified index

        head = @slice(0, index)
        tail = @slice(index)

        if index < 0
            index = @length() + index

        # If the string is supplied as text then convert it to an unformatted
        # string.
        middle = substring
        if typeof substring == 'string'
            middle = new HTMLString.String(substring, @_preserveWhitespace)

        # Inherit the format of the existing string
        if inheritFormat and index > 0
            indexChar = @charAt(index - 1)
            inheritedTags = indexChar.tags()

            # Don't inherit self-closing tags
            if indexChar.isTag()
                inheritedTags.shift()

            if typeof substring != 'string'
                middle = middle.copy()

            for c in middle.characters
                c.addTags.apply(c, inheritedTags)

        # Build the new string
        newString = head
        for c in middle.characters
            newString.characters.push(c)
        for c in tail.characters
            newString.characters.push(c)
        return newString

    lastIndexOf: (substring, from=0) ->
        # Return the index of the last occurrence of the specified sub-string,
        # -1 is returned if no match is found.

        if from < 0
            from = 0

        characters = @characters.slice(from).reverse()

        # The from offset is applied by the slice so we reset it to 0
        from = 0

        # Find text
        if typeof substring == 'string'

            # Check the this string contains the specified string before
            # perform a full search.
            if not @contains(substring)
                return -1

            # Find text
            substring = substring.split('').reverse()
            while from <= (characters.length - substring.length)
                found = true
                skip = 0
                for c, i in substring
                    if characters[i + from].isTag()
                        skip += 1
                    if c != characters[skip + i + from].c()
                        found = false
                        break
                if found
                    return from
                from++

            return -1

        # Find html string
        substring = substring.characters.slice().reverse()
        while from <= (characters.length - substring.length)
            found = true
            for c, i in substring
                if not c.eq(characters[i + from])
                    found = false
                    break
            if found
                return from
            from++

        return -1

    optimize: () ->
        # Optimize the string so that tags are stacked in order of run length
        openTags = []
        openHeads = []
        lastC = null # Last character

        for c in @characters.slice().reverse()
            c._runLengthMap = {}
            c._runLengthMapSize = 0

            # Close tags
            closingTags = []
            for openTag in openTags.slice().reverse()
                closingTags.push(openTag)
                if not c.hasTags(openTag)
                    for closingTag in closingTags
                        openTags.pop()
                        openHeads.pop()
                    closingTags = []

            # Open tags
            for tag in c._tags
                if openHeads.indexOf(tag.head()) == -1
                    unless tag.selfClosing()
                        openTags.push(tag)
                        openHeads.push(tag.head())

            # Calculate the run length of each tag
            for tag in openTags
                head = tag.head()

                # If this is the first character set the run length to 1 and
                # continue.
                if not lastC
                    c._runLengthMap[head] = [tag, 1]
                    continue

                # If there isn't one already add an entry for the tag against
                # the character.
                if not c._runLengthMap[head]
                    c._runLengthMap[head] = [tag, 0]

                # Check to see if the last character also had this tag applied
                # and if so use the run length as a basis.
                run_length = 0
                if lastC._runLengthMap[head]
                    run_length = lastC._runLengthMap[head][1]

                # Increment the run length for this character and tag
                c._runLengthMap[head][1] = run_length + 1

            lastC = c

        # Order the tags for each character based on their run length
        runLengthSort = (a, b) ->
            return b[1] - a[1]

        for c in @characters
            # Check for characters where there's only a single tag applied in
            # which case there's no need to apply a re-order.
            len = c._tags.length
            if (len > 0 and c._tags[0].selfClosing() and len < 3) or len < 2
                continue

            # Build a list of tags and sort them in order or run length
            runLengths = []
            for tag, runLength of c._runLengthMap
                runLengths.push(runLength)
            runLengths.sort(runLengthSort)

            # Re-add the characters tags in run length order
            for tag in c._tags.slice()
                unless tag.selfClosing()
                    c.removeTags(tag)
            c.addTags.apply(c, (t[0] for t in runLengths))

    slice: (from, to) ->
        # Extract a section of the string and return a new string
        newString = new HTMLString.String('', @_preserveWhitespace)
        newString.characters = (c.copy() for c in @characters.slice(from, to))
        return newString

    split: (separator='', limit=0) ->
        # Split the string by the separator and return a list of sub-strings

        # Build a list of indexes for the separator in the string
        lastIndex = 0
        count = 0
        indexes = [0]
        loop
            if limit > 0 and count > limit
                break
            index = @indexOf(separator, lastIndex)
            if index == -1 or index == (@length() - 1)
                break
            indexes.push(index)
            lastIndex = index + 1

        indexes.push(@length())

        # Build a list of sub-strings based on the split indexes
        substrings = []
        for i in [0..(indexes.length - 2)]
            substrings.push(@slice(indexes[i], indexes[i + 1]))

        return substrings

    startsWith: (substring) ->
        # Return true if the sub=string starts with the specified string

        # Compare to text
        if typeof substring == 'string'
            return @text().slice(0, substring.length) == substring

        # Compare to html string
        for c, i in substring.characters
            if not c.eq(@characters[i])
                return false

        return true

    substr: (from, length) ->
        # Return a subset of a string between from and length, if length isn't
        # specified it will default to the end of the string.

        # Check for zero or negative length selections
        if length <= 0
            return new HTMLString.String('', @_preserveWhitespace)

        if from < 0
            from = @length() + from

        if length == undefined
            length = @length() - from

        return @slice(from, from + length)

    substring: (from, to) ->
        # Return a subset of a string between from and to, if to isn't
        # specified it will default to the end of the string.
        if to == undefined
            to = @length()

        return @slice(from, to)

    text: () ->
        # Return a text version of the string
        text = ''
        for c in @characters

            # Handle tag characters
            if c.isTag()

                # Handle line breaks
                if c.isTag('br')
                    text += '\n'
                continue

            # Prevent multiple spaces (other than &nbsp;)
            if c.c() == '&nbsp;'
                text += c.c()
                continue

            text += c.c()

        return @constructor.decode(text)

    toLowerCase: () ->
        # Return a copy of the string converted to lower case
        newString = @copy()
        for c in newString.characters
            if c._c.length == 1
                c._c = c._c.toLowerCase()
        return newString

    toUpperCase: () ->
        # Return a copy of the string converted to upper case
        newString = @copy()
        for c in newString.characters
            if c._c.length == 1
                c._c = c._c.toUpperCase()
        return newString

    trim: () ->
        # Return a copy of the string with whitespace trimmed from either end

        # Find the first non-whitespace character
        for c, from in @characters
            if not c.isWhitespace()
                break

        # Find the last non-whitespace character
        for c, to in @characters.slice().reverse()
            if not c.isWhitespace()
                break

        to = @length() - to - 1

        newString = new HTMLString.String('', @_preserveWhitespace)
        newString.characters = (c.copy() for c in @characters[from..to])

        return newString

    trimLeft: () ->
        # Return a copy of the string with whitespaces trimmed from the left
        to = @length() - 1

        # Find the first non-whitespace character
        for c, from in @characters
            if not c.isWhitespace()
                break

        newString = new HTMLString.String('', @_preserveWhitespace)
        newString.characters = (c.copy() for c in @characters[from..to])

        return newString

    trimRight: () ->
        # Return a copy of the string with whitespaces trimmed from the right
        from = 0

        # Find the last non-whitespace character
        for c, to in @characters.slice().reverse()
            if not c.isWhitespace()
                break

        to = @length() - to - 1

        newString = new HTMLString.String('', @_preserveWhitespace)
        newString.characters = (c.copy() for c in @characters[from..to])

        return newString

    unformat: (from, to, tags...) ->
        # Remove the specified tags from a range (from, to) of characters in
        # the string. Specifying no tags will clear all formatting form the
        # selection.

        # Support for negative indexes on from/to
        if to < 0
            to = @length() + to + 1

        if from < 0
            from = @length() + from

        newString = @copy()
        for i in [from...to]
            c = newString.characters[i]
            c.removeTags.apply(c, tags)

        return newString

    copy: () ->
        # Return a copy of the string
        stringCopy = new HTMLString.String('', @_preserveWhitespace)
        stringCopy.characters = (c.copy() for c in @characters)
        return stringCopy

    # Class methods

    @encode: (string) ->
        # Encode entities within the specified string
        textarea = document.createElement('textarea')
        textarea.textContent = string
        return textarea.innerHTML

    @decode: (string) ->
        # Decode entities within the specified string
        textarea = document.createElement('textarea')
        textarea.innerHTML = string
        return textarea.textContent


# Constants

# Define character sets
ALPHA_CHARS = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz-_$'.split('')
ALPHA_NUMERIC_CHARS = ALPHA_CHARS.concat('1234567890'.split(''))
ATTR_NAME_CHARS = ALPHA_NUMERIC_CHARS.concat([':'])
ENTITY_CHARS = ALPHA_NUMERIC_CHARS.concat(['#'])
TAG_NAME_CHARS = ALPHA_NUMERIC_CHARS.concat([':'])

# Define the parser states
CHAR_OR_ENTITY_OR_TAG = 1
ENTITY = 2
OPENNING_OR_CLOSING_TAG = 3
OPENING_TAG = 4
CLOSING_TAG = 5
TAG_NAME_OPENING = 6
TAG_NAME_CLOSING = 7
TAG_OPENING_SELF_CLOSING = 8
TAG_NAME_MUST_CLOSE = 9
ATTR_OR_TAG_END = 10
ATTR_NAME = 11
ATTR_NAME_FIND_VALUE = 12
ATTR_DELIM = 13
ATTR_VALUE_SINGLE_DELIM = 14
ATTR_VALUE_DOUBLE_DELIM = 15
ATTR_VALUE_NO_DELIM = 16
ATTR_ENTITY_NO_DELIM = 17
ATTR_ENTITY_SINGLE_DELIM = 18
ATTR_ENTITY_DOUBLE_DELIM = 19


class _Parser

    # A HTML parser for creating HTML strings

    constructor: () ->

        # Build the parser FSM
        @fsm = new FSM.Machine(@)
        @fsm.setInitialState(CHAR_OR_ENTITY_OR_TAG)

        # Character or tag
        @fsm.addTransitionAny CHAR_OR_ENTITY_OR_TAG, null, (c) ->
            @_pushChar(c)

        @fsm.addTransition '<', CHAR_OR_ENTITY_OR_TAG, OPENNING_OR_CLOSING_TAG
        @fsm.addTransition '&', CHAR_OR_ENTITY_OR_TAG, ENTITY

        # Entity
        @fsm.addTransitions ENTITY_CHARS, ENTITY, null, (c) ->
            @entity += c

        @fsm.addTransition ';', ENTITY, CHAR_OR_ENTITY_OR_TAG, () ->
            @_pushChar("&#{ @entity };")
            @entity = ''

        # Opening or closing Tag
        @fsm.addTransitions [' ', '\n'], OPENNING_OR_CLOSING_TAG
        @fsm.addTransitions ALPHA_CHARS, OPENNING_OR_CLOSING_TAG, OPENING_TAG, () ->
            @_back()

        @fsm.addTransition '/', OPENNING_OR_CLOSING_TAG, CLOSING_TAG

        # Opening tag
        @fsm.addTransitions [' ', '\n'], OPENING_TAG
        @fsm.addTransitions ALPHA_CHARS, OPENING_TAG, TAG_NAME_OPENING, () ->
            @_back()

        # Closing tag
        @fsm.addTransitions [' ', '\n'], CLOSING_TAG
        @fsm.addTransitions ALPHA_CHARS, CLOSING_TAG, TAG_NAME_CLOSING, () ->
            @_back()

        # Tag name opening
        @fsm.addTransitions TAG_NAME_CHARS, TAG_NAME_OPENING, null, (c) ->
            @tagName += c

        @fsm.addTransitions [' ', '\n'], TAG_NAME_OPENING, ATTR_OR_TAG_END
        @fsm.addTransition '/', TAG_NAME_OPENING, TAG_OPENING_SELF_CLOSING, () ->
            @selfClosing = true

        @fsm.addTransition '>', TAG_NAME_OPENING, CHAR_OR_ENTITY_OR_TAG, () ->
            @_pushTag()

        @fsm.addTransitions [' ', '\n'], TAG_OPENING_SELF_CLOSING
        @fsm.addTransition '>', TAG_OPENING_SELF_CLOSING, CHAR_OR_ENTITY_OR_TAG, () ->
            @_pushTag()

        @fsm.addTransitions [' ', '\n'], ATTR_OR_TAG_END
        @fsm.addTransition '/', ATTR_OR_TAG_END, TAG_OPENING_SELF_CLOSING, () ->
            @selfClosing = true

        @fsm.addTransition '>', ATTR_OR_TAG_END, CHAR_OR_ENTITY_OR_TAG, () ->
            @_pushTag()

        @fsm.addTransitions ALPHA_CHARS, ATTR_OR_TAG_END, ATTR_NAME, () ->
            @_back()

        # Tag name closing
        @fsm.addTransitions TAG_NAME_CHARS, TAG_NAME_CLOSING, null, (c) ->
            @tagName += c

        @fsm.addTransitions [' ', '\n'], TAG_NAME_CLOSING, TAG_NAME_MUST_CLOSE
        @fsm.addTransition '>', TAG_NAME_CLOSING, CHAR_OR_ENTITY_OR_TAG, () ->
            @_popTag()

        @fsm.addTransitions [' ', '\n'], TAG_NAME_MUST_CLOSE
        @fsm.addTransition '>', TAG_NAME_MUST_CLOSE, CHAR_OR_ENTITY_OR_TAG, () ->
            @_popTag()

        # Attribute name
        @fsm.addTransitions ATTR_NAME_CHARS, ATTR_NAME, null, (c) ->
            @attributeName += c

        @fsm.addTransitions [' ', '\n'], ATTR_NAME, ATTR_NAME_FIND_VALUE
        @fsm.addTransition '=', ATTR_NAME, ATTR_DELIM
        @fsm.addTransitions [' ', '\n'], ATTR_NAME_FIND_VALUE
        @fsm.addTransition '=', ATTR_NAME_FIND_VALUE, ATTR_DELIM

        @fsm.addTransitions '>', ATTR_NAME, ATTR_OR_TAG_END, () ->
            @_pushAttribute()
            @_back()

        @fsm.addTransitionAny ATTR_NAME_FIND_VALUE, ATTR_OR_TAG_END, () ->
            @_pushAttribute()
            @_back()

        # Attribute delimiter
        @fsm.addTransitions [' ', '\n'], ATTR_DELIM
        @fsm.addTransition '\'', ATTR_DELIM, ATTR_VALUE_SINGLE_DELIM
        @fsm.addTransition '"', ATTR_DELIM, ATTR_VALUE_DOUBLE_DELIM

        # Fix for browsers (including IE) that output quoted attributes
        @fsm.addTransitions ALPHA_NUMERIC_CHARS.concat ['&'], ATTR_DELIM, ATTR_VALUE_NO_DELIM, () ->
            @_back()

        @fsm.addTransition ' ', ATTR_VALUE_NO_DELIM, ATTR_OR_TAG_END, () ->
            @_pushAttribute()

        @fsm.addTransitions ['/', '>'], ATTR_VALUE_NO_DELIM, ATTR_OR_TAG_END, () ->
            @_back()
            @_pushAttribute()

        @fsm.addTransition '&', ATTR_VALUE_NO_DELIM, ATTR_ENTITY_NO_DELIM
        @fsm.addTransitionAny ATTR_VALUE_NO_DELIM, null, (c) ->
            @attributeValue += c

        # Attribute value single delimiter
        @fsm.addTransition '\'', ATTR_VALUE_SINGLE_DELIM, ATTR_OR_TAG_END, () ->
            @_pushAttribute()

        @fsm.addTransition '&', ATTR_VALUE_SINGLE_DELIM, ATTR_ENTITY_SINGLE_DELIM
        @fsm.addTransitionAny ATTR_VALUE_SINGLE_DELIM, null, (c) ->
            @attributeValue += c

        # Attribte value double delimiter
        @fsm.addTransition '"', ATTR_VALUE_DOUBLE_DELIM, ATTR_OR_TAG_END, () ->
            @_pushAttribute()

        @fsm.addTransition '&', ATTR_VALUE_DOUBLE_DELIM, ATTR_ENTITY_DOUBLE_DELIM
        @fsm.addTransitionAny ATTR_VALUE_DOUBLE_DELIM, null, (c) ->
            @attributeValue += c

        # Entity in attribute value
        @fsm.addTransitions ENTITY_CHARS, ATTR_ENTITY_NO_DELIM, null, (c) ->
            @entity += c

        @fsm.addTransitions ENTITY_CHARS, ATTR_ENTITY_SINGLE_DELIM, (c) ->
            @entity += c

        @fsm.addTransitions ENTITY_CHARS, ATTR_ENTITY_DOUBLE_DELIM, null, (c) ->
            @entity += c

        @fsm.addTransition ';', ATTR_ENTITY_NO_DELIM, ATTR_VALUE_NO_DELIM, () ->
            @attributeValue += "&#{ @entity };"
            @entity = ''

        @fsm.addTransition ';', ATTR_ENTITY_SINGLE_DELIM, ATTR_VALUE_SINGLE_DELIM, () ->
            @attributeValue += "&#{ @entity };"
            @entity = ''

        @fsm.addTransition ';', ATTR_ENTITY_DOUBLE_DELIM, ATTR_VALUE_DOUBLE_DELIM, () ->
            @attributeValue += "&#{ @entity };"
            @entity = ''

    # Parsing methods

    _back: () ->
        # Move the parsing head back one characters
        @head--

    _pushAttribute: () ->
        # Remember an attribute for the current tag

        @attributes[@attributeName] = @attributeValue

        # Reset the attribute
        @attributeName = ''
        @attributeValue = ''

    _pushChar: (c) ->
        # Push a character on to the string
        character = new HTMLString.Character(c, @tags)

        # Do we need to preserve whitespace?
        if @_preserveWhitespace
            @string.characters.push(character)
            return

        # If the character is whitespace only add it if the last character
        # isn't (e.g don't build strings containing extra unused spaces).
        if @string.length() and not character.isTag() and
                not character.isEntity() and character.isWhitespace()

            lastCharacter = @string.characters[@string.length() - 1]
            if lastCharacter.isWhitespace() and not lastCharacter.isTag() and
                    not lastCharacter.isEntity()
                return

        @string.characters.push(character)

    _pushTag: () ->
        # Push a tag on to the stack applied to characters

        # Push the Tag on to the stack
        tag = new HTMLString.Tag(@tagName, @attributes)
        @tags.push(tag)

        # Adding an empty character for self closing tags
        if tag.selfClosing()
            @._pushChar('')
            @tags.pop()

            # Check if the tag was self closed and if not update the FSM to
            # close it.
            if not @selfClosed and @tagName in HTMLString.Tag.SELF_CLOSING
                @fsm.reset()

        # Reset the tag buffers
        @tagName = ''
        @selfClosed = false
        @attributes = {}

    _popTag: () ->
        # Pop a tag from the stack applied to characters

        # Balanced the tags
        loop
            tag = @tags.pop()

            # Push whitespace at the end of a tag out
            if @string.length()
                character = @string.characters[@string.length() - 1]
                if not character.isTag() and
                        not character.isEntity() and
                        character.isWhitespace()
                    character.removeTags(tag)

            break if tag.name() == @tagName.toLowerCase()

        # Reset the tag buffers
        @tagName = ''

    # Methods

    parse: (html, preserveWhitespace) ->
        # Parse a HTML string
        @_preserveWhitespace = preserveWhitespace

        # Prepare for parsing
        @reset()
        html = @preprocess(html)
        @fsm.parser = @

        # Parse the HTML
        while @head < html.length
            character = html[@head]
            try
                @fsm.process(character)
            catch error
                throw new Error("Error at char #{@head} >> #{error}")

            @head++

        return @string

    preprocess: (html) ->
        # Preprocess a HTML string to prepare it for parsing

        # Normalize line endings
        html = html.replace(/\r\n/g, '\n').replace(/\r/g, '\n')

        # Remove any comments
        html = html.replace(/<!--[\s\S]*?-->/g, '')

        # Replace multiple spaces with a single space
        if not @_preserveWhitespace
            html = html.replace(/\s+/g, ' ')

        return html

    reset: () ->
        # Reset the parser ready to parse a HTML string
        @fsm.reset()

        # The index of the character we're currently parsing
        @head = 0

        # Temporary properties to store the current parser state
        @string = new HTMLString.String()
        @entity = ''
        @tags = []
        @tagName = ''
        @selfClosing = false
        @attributes = {}
        @attributeName = ''
        @attributeValue = ''