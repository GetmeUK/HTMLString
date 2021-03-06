# HTMLString

[![Build Status](https://travis-ci.org/GetmeUK/HTMLString.svg?branch=master)](https://travis-ci.org/GetmeUK/HTMLString)

> An HTML parser written in JavaScript that's probably not what you're looking for.

## Install

**Using bower**

```
bower install --save HTMLString
```

**Using npm**

```
npm install --save HTMLString
```

## Building
To build the library you'll need to use Grunt. First install the required node modules ([grunt-cli](http://gruntjs.com/getting-started) must be installed):
```
git clone https://github.com/GetmeUK/HTMLString.git
cd HTMLString
npm install
```

Then run `grunt build` to build the project.

## Testing
To test the library you'll need to use Jasmine. First install Jasmine:
```
git clone https://github.com/pivotal/jasmine.git
mkdir HTMLString/jasmine
mv jasmine/dist/jasmine-standalone-2.0.3.zip HTMLString/jasmine
cd HTMLString/jasmine
unzip jasmine-standalone-2.0.3.zip
```

Then open `HTMLString/SpecRunner.html` in a browser to run the tests.

Alternatively you can use `grunt jasmine` to run the tests from the command line.

## Documentation
Full documentation is available at http://getcontenttools.com/api/html-string

## Browser support
- Chrome
- Firefox
- IE9+
