quotes = {
    Gates: '''<!-- --><b><!-- Comments are ignored --><q data-example>We all</q></b><q data-example> need people who will give us feedback. That's how we improve. <a href="#"><img src="bill-gates.jpg"></a></q>'''
    Kernighan: ''' <q>
        Everyone knows that debugging is twice as hard as writing a program in
        the first place. So if you're as clever as you can be when you write
        it, <span class="question">how will you ever <b>debug</b> it?</span>
    </q> '''
    Ritchie: '''
I can't recall any difficulty in making the C language definition completely
open - any discussion on the matter tended to mention languages whose
inventors tried to keep tight control, and consequent ill fate.'''
    Turing: '''
<q id="turings-quote">Machines take me by <br> <span class="suprised">surprise</span> with <i>great&nbsp;frequency.</i></q>
    '''
    Wozniak: '''
all the best people in life seem to like LINUX.
    '''
    WozniakNamespaced: '''
all the best people in life seem to like <ns:tag ns:attr="foo">LINUX</ns:tag>.
    '''
    WozniakWhitespace: '''
all    the best people in life seem to like LINUX.
    '''
}

describe 'HTMLString.String()', () ->

    it 'should parse and render text (no HTML)', () ->
        string = new HTMLString.String(quotes.Wozniak)
        expect(string.text()).toBe quotes.Wozniak

    it 'should parse and render text (no HTML with whitespace preserved)', () ->
        string = new HTMLString.String(quotes.WozniakWhitespace, true)
        expect(string.text()).toBe quotes.WozniakWhitespace

    it 'should parse and render a string (HTML)', () ->
        string = new HTMLString.String(quotes.Turing)
        expect(string.html()).toBe quotes.Turing

        # Check names spaced tags are supported
        string = new HTMLString.String(quotes.WozniakNamespaced)
        expect(string.html()).toBe quotes.WozniakNamespaced

        console.log string.html()


describe 'HTMLString.String.isWhitespace()', () ->

    it 'should return true if a string consists entirely of whitespace \
        characters', () ->

        string = new HTMLString.String("&nbsp; <br>")
        expect(string.isWhitespace()).toBe true

    it 'should return false if a string contains any non-whitespace \
        character', () ->

        string = new HTMLString.String("&nbsp; a <br>")
        expect(string.isWhitespace()).toBe false


describe 'HTMLString.String.length()', () ->

    it 'should return the length of a string', () ->
        string = new HTMLString.String(quotes.Turing)
        expect(string.length()).toBe 52

describe 'HTMLString.String.preserveWhitespace()', () ->

    it 'should return the true if whitespace is reserved for the string', () ->

        # Not preserved
        string = new HTMLString.String(quotes.Turing)
        expect(string.preserveWhitespace()).toBe false

        # Preserved
        string = new HTMLString.String(quotes.Turing, true)
        expect(string.preserveWhitespace()).toBe true


describe 'HTMLString.String.capitalize()', () ->

    it 'should capitalize the first character of a string', () ->
        string = new HTMLString.String(quotes.Wozniak)
        newString = string.capitalize()
        expect(newString.charAt(0).c()).toBe 'A'


describe 'HTMLString.String.charAt()', () ->

    it 'should return a character from a string at the specified index', () ->
        string = new HTMLString.String(quotes.Turing)
        expect(string.charAt(18).c()).toBe 'y'


describe 'HTMLString.String.concat()', () ->

    it 'should combine 2 or more strings and return a new string', () ->
        stringA = new HTMLString.String(quotes.Turing)
        stringB = new HTMLString.String(quotes.Wozniak)
        newString = stringA.concat(stringB)

        expect(newString.html()).toBe '''<q id="turings-quote">Machines take me by <br> <span class="suprised">surprise</span> with <i>great&nbsp;frequency.all the best people in life seem to like LINUX.</i></q>'''

describe 'HTMLString.String.contain()', () ->

    it 'should return true if a string contains a substring', () ->
        string = new HTMLString.String(quotes.Turing)
        substring = new HTMLString.String('<q id="turings-quote">take me</q>')

        expect(string.contains('take me')).toBe true
        expect(string.contains(substring)).toBe true


describe 'HTMLString.String.endswith()', () ->

    it 'should return true if a string ends with a substring.`', () ->
        string = new HTMLString.String(quotes.Turing)
        substring = new HTMLString.String(
            '<q id="turings-quote"><i>great&nbsp;frequency.</i></q>'
            )

        expect(
            string.endsWith(
                "great#{ HTMLString.String.decode('&nbsp;') }frequency."
                )
            ).toBe true
        expect(string.endsWith(substring)).toBe true


describe 'HTMLString.String.format()', () ->

    it 'should format a selection of characters in a string (add tags)', () ->
        string = new HTMLString.String(quotes.Ritchie)
        string = string.format(0, -1, new HTMLString.Tag('q'))
        string = string.format(
            19,
            29,
            new HTMLString.Tag('a', {href: 'http://www.getme.co.uk'}),
            new HTMLString.Tag('b')
            )

        expect(string.html()).toBe """
<q>I can't recall any <a href="http://www.getme.co.uk"><b>difficulty</b></a> in making the C language definition completely open - any discussion on the matter tended to mention languages whose inventors tried to keep tight control, and consequent ill fate.</q>
""".trim()


describe 'HTMLString.String.hasTags()', () ->

    it 'should return true if the string has and characters formatted with the \
        specifed tags', () ->

        string = new HTMLString.String(quotes.Kernighan).trim()

        expect(
            string.hasTags(
                new HTMLString.Tag('q'),
                'b'
                )
        ).toBe true
        expect(string.hasTags(new HTMLString.Tag('q')), true).toBe true


describe 'HTMLString.String.indexOf()', () ->

    it 'should return the first position of an substring in another string, \
        or -1 if there is no match', () ->

        string = new HTMLString.String(quotes.Kernighan).trim()
        substring = new HTMLString.String('<q>debugging</q>')

        expect(string.indexOf('debugging')).toBe 20
        expect(string.indexOf(substring)).toBe 20
        expect(string.indexOf(substring, 30)).toBe -1


describe 'HTMLString.String.insert()', () ->

    it 'should insert a string into another string and return a new \
        string', () ->

        stringA = new HTMLString.String(quotes.Kernighan).trim()
        stringB = new HTMLString.String(quotes.Turing)

        # Inherit formatting
        newString = stringA.insert(9, stringB)
        newString = newString.insert(9 + stringB.length(), ' - new string inserted - ')
        expect(newString.html()).toBe '''<q>Everyone <q id="turings-quote">Machines take me by <br> <span class="suprised">surprise</span> with <i>great&nbsp;frequency. - new string inserted - </i></q>knows that debugging is twice as hard as writing a program in the first place. So if you're as clever as you can be when you write it, <span class="question">how will you ever <b>debug</b> it?</span></q>'''

        # Do not inherit formatting
        newString = stringA.insert(9, ' - insert unformatted string - ', false)
        expect(newString.html()).toBe '''<q>Everyone </q> - insert unformatted string - <q>knows that debugging is twice as hard as writing a program in the first place. So if you're as clever as you can be when you write it, <span class="question">how will you ever <b>debug</b> it?</span></q>'''


describe 'HTMLString.String.lastIndexOf()', () ->

    it 'should return the last position of an substring in another string, \
        or -1 if there is no match', () ->

        string = new HTMLString.String(quotes.Kernighan).trim()
        substring = new HTMLString.String('<q>debugging</q>')

        expect(string.lastIndexOf('debugging')).toBe 142
        expect(string.lastIndexOf(substring)).toBe 142
        expect(string.lastIndexOf(substring, 30)).toBe -1


describe 'HTMLString.String.optimize()', () ->

    it 'should optimize the string (in place) so that tags are restacked in \
        order of longest running', () ->

        string = new HTMLString.String(quotes.Gates)
        string.optimize()

        expect(string.html()).toBe '''<q data-example><b>We all</b> need people who will give us feedback. That's how we improve. <a href="#"><img src="bill-gates.jpg"></a></q>'''


describe 'HTMLString.String.slice()', () ->

    it 'should extract a section of a string and return a new string', () ->
        string = new HTMLString.String(quotes.Kernighan).trim()
        newString = string.slice(10, 19)

        expect(newString.html()).toBe '''<q>nows that</q>'''


describe 'HTMLString.String.split()', () ->

    it 'should split a string by the separator and return a list of \
        sub-strings', () ->
        string = new HTMLString.String(' ', true)
        substrings = string.split(' ')
        expect(substrings.length).toBe 2
        expect(substrings[0].length()).toBe 0
        expect(substrings[1].length()).toBe 0

        string = new HTMLString.String(quotes.Kernighan).trim()

        substrings = string.split('a')
        expect(substrings.length).toBe 11

        substrings = string.split('@@')
        expect(substrings.length).toBe 1

        substrings = string.split(
                new HTMLString.String(
                    '<q><span class="question"><b>e</b></span></q>'
                    )
                )
        expect(substrings.length).toBe 2


describe 'HTMLString.String.startsWith()', () ->

    it 'should return true if a string starts with a substring.`', () ->
        string = new HTMLString.String(quotes.Turing)
        substring = new HTMLString.String(
            '<q id="turings-quote">Machines take</q>'
            )

        expect(string.startsWith("Machines take")).toBe true
        expect(string.startsWith(substring)).toBe true


describe 'HTMLString.String.substr()', () ->

    it 'should return a subset of a string from an offset for a specified \
        length`', () ->

        string = new HTMLString.String(quotes.Kernighan).trim()
        newString = string.substr(10, 9)

        expect(newString.html()).toBe '''<q>nows that</q>'''


describe 'HTMLString.String.substring()', () ->

    it 'should return a subset of a string between 2 indexes`', () ->
        string = new HTMLString.String(quotes.Kernighan).trim()
        newString = string.substring(10, 19)

        expect(newString.html()).toBe '''<q>nows that</q>'''


describe 'HTMLString.String.toLowerCase()', () ->

    it 'should return a copy of a string converted to lower case.`', () ->
        string = new HTMLString.String(quotes.Turing)
        newString = string.toLowerCase()

        expect(newString.html()).toBe '''<q id="turings-quote">machines take me by <br> <span class="suprised">surprise</span> with <i>great&nbsp;frequency.</i></q>'''


describe 'HTMLString.String.toUpperCase()', () ->

    it 'should return a copy of a string converted to upper case.`', () ->
        string = new HTMLString.String(quotes.Turing)
        newString = string.toUpperCase()

        expect(newString.html()).toBe '''<q id="turings-quote">MACHINES TAKE ME BY <br> <span class="suprised">SURPRISE</span> WITH <i>GREAT&nbsp;FREQUENCY.</i></q>'''


describe 'HTMLString.String.trim()', () ->

    it 'should return a copy of a string converted with whitespaces trimmed \
        from both ends.`', () ->

        string = new HTMLString.String(quotes.Kernighan)
        newString = string.trim()

        expect(newString.characters[0].isWhitespace()).toBe false
        expect(
            newString.characters[newString.length() - 1].isWhitespace()
            ).toBe false


describe 'HTMLString.String.trimLeft()', () ->

    it 'should return a copy of a string converted with whitespaces trimmed \
        from the left.`', () ->

        string = new HTMLString.String(quotes.Kernighan)
        newString = string.trimLeft()

        expect(newString.characters[0].isWhitespace()).toBe false
        expect(
            newString.characters[newString.length() - 1].isWhitespace()
            ).toBe true


describe 'HTMLString.String.trimRight)', () ->

    it 'should return a copy of a string converted with whitespaces trimmed \
        from the left.`', () ->

        string = new HTMLString.String(quotes.Kernighan)
        newString = string.trimRight()

        expect(newString.characters[0].isWhitespace()).toBe true
        expect(
            newString.characters[newString.length() - 1].isWhitespace()
            ).toBe false


describe 'HTMLString.String.unformat()', () ->

    it 'should return a sting unformatted (no tags)', () ->
        string = new HTMLString.String(quotes.Kernighan).trim()

        # Test clearing tags individually
        clearEachString = string.unformat(
            0,
            -1,
            new HTMLString.Tag('q'),
            new HTMLString.Tag('span', {class: 'question'}),
            new HTMLString.Tag('b')
            )
        expect(clearEachString.html()).toBe string.text()

        # Test clearing tags by name
        clearEachString = string.unformat(0, -1, 'q', 'span', 'b')
        expect(clearEachString.html()).toBe string.text()

        # Test clearing all tags in one go
        clearAllString = string.unformat(0, -1)
        expect(clearAllString.html()).toBe string.text()