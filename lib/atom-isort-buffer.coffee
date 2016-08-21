fs = require 'fs'
process = require 'child_process'

module.exports =
  config:
    isortPath:
      type: 'string'
      default: 'isort'

  activate: ->
    atom.commands.add 'atom-workspace', 'atom-isort-buffer:sort', ->
      editor = atom.workspace.getActiveTextEditor()
      if not editor?
        return
      if editor.getGrammar().name != 'Python'
        return

      tmpfile = '/tmp/atom-isort-buffer.py'
      unsorted = editor.getText()
      fs.writeFile(tmpfile, unsorted)

      isortpath = atom.config.get "atom-isort-buffer.isortPath"
      process.exec(
        [isortpath, tmpfile].join ' '
        (error, stdout, stderr) ->
          if error
            atom.notifications.addError stderr, dismissable: true
            return
          sorted = fs.readFileSync tmpfile, 'utf-8'
          curpos = editor.getCursorScreenPosition()
          editor.setText sorted
          curpos = editor.setCursorScreenPosition curpos
      )
