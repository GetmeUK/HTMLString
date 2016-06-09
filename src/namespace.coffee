HTMLString = {}


# Export the namespace

# Browser (via window)
if typeof window != 'undefined'
    window.HTMLString = HTMLString

# Node/Browserify
if typeof module != 'undefined' and module.exports
    exports = module.exports = HTMLString