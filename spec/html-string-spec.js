(function() {
  var quotes;

  quotes = {
    Gates: '<!-- --><b><!-- Comments are ignored --><q data-example>We all</q></b><q data-example> need people who will give us feedback. That\'s how we improve. <a href="#"><img src="bill-gates.jpg"></a></q>',
    Kernighan: ' <q>\n    Everyone knows that debugging is twice as hard as writing a program in\n    the first place. So if you\'re as clever as you can be when you write\n    it, <span class="question">how will you ever <b>debug</b> it?</span>\n</q> ',
    Ritchie: 'I can\'t recall any difficulty in making the C language definition completely\nopen - any discussion on the matter tended to mention languages whose\ninventors tried to keep tight control, and consequent ill fate.',
    Turing: '<q id="turings-quote">Machines take me by <br> <span class="suprised">surprise</span> with <i>great&nbsp;frequency.</i></q>',
    Wozniak: 'all the best people in life seem to like LINUX.',
    WozniakNamespaced: 'all the best people in life seem to like <ns:tag ns:attr="foo">LINUX</ns:tag>.',
    WozniakWhitespace: 'all    the best people in life seem to like LINUX.',
    AmbiguousAmpersand: '&amp; &<a href="/foo?bar=1&zee=2&amp;omm=3&end">amp</a> &foo && &&amp; &end'
  };

  describe('HTMLString.String()', function() {
    it('should parse and render text (no HTML)', function() {
      var string;
      string = new HTMLString.String(quotes.Wozniak);
      return expect(string.text()).toBe(quotes.Wozniak);
    });
    it('should parse and render text (no HTML with whitespace preserved)', function() {
      var string;
      string = new HTMLString.String(quotes.WozniakWhitespace, true);
      return expect(string.text()).toBe(quotes.WozniakWhitespace);
    });
    it('should parse and render a string (HTML)', function() {
      var string;
      string = new HTMLString.String(quotes.Turing);
      expect(string.html()).toBe(quotes.Turing);
      string = new HTMLString.String(quotes.WozniakNamespaced);
      return expect(string.html()).toBe(quotes.WozniakNamespaced);
    });
    return it('should parse and render a string (HTML with ambiguous ampersands)', function() {
      var string;
      string = new HTMLString.String(quotes.AmbiguousAmpersand);
      expect(string.html()).toBe(quotes.AmbiguousAmpersand);
      return console.log(string.html());
    });
  });

  describe('HTMLString.String.isWhitespace()', function() {
    it('should return true if a string consists entirely of whitespace characters', function() {
      var string;
      string = new HTMLString.String("&nbsp; <br>");
      return expect(string.isWhitespace()).toBe(true);
    });
    return it('should return false if a string contains any non-whitespace character', function() {
      var string;
      string = new HTMLString.String("&nbsp; a <br>");
      return expect(string.isWhitespace()).toBe(false);
    });
  });

  describe('HTMLString.String.length()', function() {
    return it('should return the length of a string', function() {
      var string;
      string = new HTMLString.String(quotes.Turing);
      return expect(string.length()).toBe(52);
    });
  });

  describe('HTMLString.String.preserveWhitespace()', function() {
    return it('should return the true if whitespace is reserved for the string', function() {
      var string;
      string = new HTMLString.String(quotes.Turing);
      expect(string.preserveWhitespace()).toBe(false);
      string = new HTMLString.String(quotes.Turing, true);
      return expect(string.preserveWhitespace()).toBe(true);
    });
  });

  describe('HTMLString.String.capitalize()', function() {
    return it('should capitalize the first character of a string', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Wozniak);
      newString = string.capitalize();
      return expect(newString.charAt(0).c()).toBe('A');
    });
  });

  describe('HTMLString.String.charAt()', function() {
    return it('should return a character from a string at the specified index', function() {
      var string;
      string = new HTMLString.String(quotes.Turing);
      return expect(string.charAt(18).c()).toBe('y');
    });
  });

  describe('HTMLString.String.concat()', function() {
    return it('should combine 2 or more strings and return a new string', function() {
      var newString, stringA, stringB;
      stringA = new HTMLString.String(quotes.Turing);
      stringB = new HTMLString.String(quotes.Wozniak);
      newString = stringA.concat(stringB);
      return expect(newString.html()).toBe('<q id="turings-quote">Machines take me by <br> <span class="suprised">surprise</span> with <i>great&nbsp;frequency.all the best people in life seem to like LINUX.</i></q>');
    });
  });

  describe('HTMLString.String.contain()', function() {
    return it('should return true if a string contains a substring', function() {
      var string, substring;
      string = new HTMLString.String(quotes.Turing);
      substring = new HTMLString.String('<q id="turings-quote">take me</q>');
      expect(string.contains('take me')).toBe(true);
      return expect(string.contains(substring)).toBe(true);
    });
  });

  describe('HTMLString.String.endswith()', function() {
    return it('should return true if a string ends with a substring.`', function() {
      var string, substring;
      string = new HTMLString.String(quotes.Turing);
      substring = new HTMLString.String('<q id="turings-quote"><i>great&nbsp;frequency.</i></q>');
      expect(string.endsWith("great" + (HTMLString.String.decode('&nbsp;')) + "frequency.")).toBe(true);
      return expect(string.endsWith(substring)).toBe(true);
    });
  });

  describe('HTMLString.String.format()', function() {
    return it('should format a selection of characters in a string (add tags)', function() {
      var string;
      string = new HTMLString.String(quotes.Ritchie);
      string = string.format(0, -1, new HTMLString.Tag('q'));
      string = string.format(19, 29, new HTMLString.Tag('a', {
        href: 'http://www.getme.co.uk'
      }), new HTMLString.Tag('b'));
      return expect(string.html()).toBe("<q>I can't recall any <a href=\"http://www.getme.co.uk\"><b>difficulty</b></a> in making the C language definition completely open - any discussion on the matter tended to mention languages whose inventors tried to keep tight control, and consequent ill fate.</q>".trim());
    });
  });

  describe('HTMLString.String.hasTags()', function() {
    return it('should return true if the string has and characters formatted with the specifed tags', function() {
      var string;
      string = new HTMLString.String(quotes.Kernighan).trim();
      expect(string.hasTags(new HTMLString.Tag('q'), 'b')).toBe(true);
      return expect(string.hasTags(new HTMLString.Tag('q')), true).toBe(true);
    });
  });

  describe('HTMLString.String.indexOf()', function() {
    return it('should return the first position of an substring in another string, or -1 if there is no match', function() {
      var string, substring;
      string = new HTMLString.String(quotes.Kernighan).trim();
      substring = new HTMLString.String('<q>debugging</q>');
      expect(string.indexOf('debugging')).toBe(20);
      expect(string.indexOf(substring)).toBe(20);
      return expect(string.indexOf(substring, 30)).toBe(-1);
    });
  });

  describe('HTMLString.String.insert()', function() {
    return it('should insert a string into another string and return a new string', function() {
      var newString, stringA, stringB;
      stringA = new HTMLString.String(quotes.Kernighan).trim();
      stringB = new HTMLString.String(quotes.Turing);
      newString = stringA.insert(9, stringB);
      newString = newString.insert(9 + stringB.length(), ' - new string inserted - ');
      expect(newString.html()).toBe('<q>Everyone <q id="turings-quote">Machines take me by <br> <span class="suprised">surprise</span> with <i>great&nbsp;frequency. - new string inserted - </i></q>knows that debugging is twice as hard as writing a program in the first place. So if you\'re as clever as you can be when you write it, <span class="question">how will you ever <b>debug</b> it?</span></q>');
      newString = stringA.insert(9, ' - insert unformatted string - ', false);
      return expect(newString.html()).toBe('<q>Everyone </q> - insert unformatted string - <q>knows that debugging is twice as hard as writing a program in the first place. So if you\'re as clever as you can be when you write it, <span class="question">how will you ever <b>debug</b> it?</span></q>');
    });
  });

  describe('HTMLString.String.lastIndexOf()', function() {
    return it('should return the last position of an substring in another string, or -1 if there is no match', function() {
      var string, substring;
      string = new HTMLString.String(quotes.Kernighan).trim();
      substring = new HTMLString.String('<q>debugging</q>');
      expect(string.lastIndexOf('debugging')).toBe(142);
      expect(string.lastIndexOf(substring)).toBe(142);
      return expect(string.lastIndexOf(substring, 30)).toBe(-1);
    });
  });

  describe('HTMLString.String.optimize()', function() {
    return it('should optimize the string (in place) so that tags are restacked in order of longest running', function() {
      var string;
      string = new HTMLString.String(quotes.Gates);
      string.optimize();
      return expect(string.html()).toBe('<q data-example><b>We all</b> need people who will give us feedback. That\'s how we improve. <a href="#"><img src="bill-gates.jpg"></a></q>');
    });
  });

  describe('HTMLString.String.slice()', function() {
    return it('should extract a section of a string and return a new string', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Kernighan).trim();
      newString = string.slice(10, 19);
      return expect(newString.html()).toBe('<q>nows that</q>');
    });
  });

  describe('HTMLString.String.split()', function() {
    return it('should split a string by the separator and return a list of sub-strings', function() {
      var string, substrings;
      string = new HTMLString.String(' ', true);
      substrings = string.split(' ');
      expect(substrings.length).toBe(2);
      expect(substrings[0].length()).toBe(0);
      expect(substrings[1].length()).toBe(0);
      string = new HTMLString.String(quotes.Kernighan).trim();
      substrings = string.split('a');
      expect(substrings.length).toBe(11);
      substrings = string.split('@@');
      expect(substrings.length).toBe(1);
      substrings = string.split(new HTMLString.String('<q><span class="question"><b>e</b></span></q>'));
      return expect(substrings.length).toBe(2);
    });
  });

  describe('HTMLString.String.startsWith()', function() {
    return it('should return true if a string starts with a substring.`', function() {
      var string, substring;
      string = new HTMLString.String(quotes.Turing);
      substring = new HTMLString.String('<q id="turings-quote">Machines take</q>');
      expect(string.startsWith("Machines take")).toBe(true);
      return expect(string.startsWith(substring)).toBe(true);
    });
  });

  describe('HTMLString.String.substr()', function() {
    return it('should return a subset of a string from an offset for a specified length`', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Kernighan).trim();
      newString = string.substr(10, 9);
      return expect(newString.html()).toBe('<q>nows that</q>');
    });
  });

  describe('HTMLString.String.substring()', function() {
    return it('should return a subset of a string between 2 indexes`', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Kernighan).trim();
      newString = string.substring(10, 19);
      return expect(newString.html()).toBe('<q>nows that</q>');
    });
  });

  describe('HTMLString.String.toLowerCase()', function() {
    return it('should return a copy of a string converted to lower case.`', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Turing);
      newString = string.toLowerCase();
      return expect(newString.html()).toBe('<q id="turings-quote">machines take me by <br> <span class="suprised">surprise</span> with <i>great&nbsp;frequency.</i></q>');
    });
  });

  describe('HTMLString.String.toUpperCase()', function() {
    return it('should return a copy of a string converted to upper case.`', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Turing);
      newString = string.toUpperCase();
      return expect(newString.html()).toBe('<q id="turings-quote">MACHINES TAKE ME BY <br> <span class="suprised">SURPRISE</span> WITH <i>GREAT&nbsp;FREQUENCY.</i></q>');
    });
  });

  describe('HTMLString.String.trim()', function() {
    return it('should return a copy of a string converted with whitespaces trimmed from both ends.`', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Kernighan);
      newString = string.trim();
      expect(newString.characters[0].isWhitespace()).toBe(false);
      return expect(newString.characters[newString.length() - 1].isWhitespace()).toBe(false);
    });
  });

  describe('HTMLString.String.trimLeft()', function() {
    return it('should return a copy of a string converted with whitespaces trimmed from the left.`', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Kernighan);
      newString = string.trimLeft();
      expect(newString.characters[0].isWhitespace()).toBe(false);
      return expect(newString.characters[newString.length() - 1].isWhitespace()).toBe(true);
    });
  });

  describe('HTMLString.String.trimRight)', function() {
    return it('should return a copy of a string converted with whitespaces trimmed from the left.`', function() {
      var newString, string;
      string = new HTMLString.String(quotes.Kernighan);
      newString = string.trimRight();
      expect(newString.characters[0].isWhitespace()).toBe(true);
      return expect(newString.characters[newString.length() - 1].isWhitespace()).toBe(false);
    });
  });

  describe('HTMLString.String.unformat()', function() {
    return it('should return a sting unformatted (no tags)', function() {
      var clearAllString, clearEachString, string;
      string = new HTMLString.String(quotes.Kernighan).trim();
      clearEachString = string.unformat(0, -1, new HTMLString.Tag('q'), new HTMLString.Tag('span', {
        "class": 'question'
      }), new HTMLString.Tag('b'));
      expect(clearEachString.html()).toBe(string.text());
      clearEachString = string.unformat(0, -1, 'q', 'span', 'b');
      expect(clearEachString.html()).toBe(string.text());
      clearAllString = string.unformat(0, -1);
      return expect(clearAllString.html()).toBe(string.text());
    });
  });

}).call(this);
