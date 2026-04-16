; sh script injections == bash
(recipe_body
  (shebang
    (language) @_lang)
  (#match? @_lang "sh")
  (#set! injection.language "bash")
  (#set! injection.include-children)) @injection.content
