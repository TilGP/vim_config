;; extends
 
[(assignment
  left: (identifier) @_varname
  (#match? @_varname "query$")
  right: (string (string_content) @injection.content)
  (#match? @injection.content "^[\n \t\s]*([sS](elect|ELECT)|[iI](nsert|NSERT)|[uU](pdate|PDATE)|[cC](reate|REATE)|[dD](elete|ELETE)|[aA](lter|LTER)|[dD](rop|ROP))[\n \t\s]+")
)
(call
  function: [
    (attribute attribute: (identifier) @_funcname)
    (identifier) @_funcname]
  (#match? @_funcname "^(runquery|read_sql|execute)$")
  arguments: (argument_list . (string (string_content) @injection.content))
  (#set! injection.language "sql")
)]
