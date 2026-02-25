local filetype = require('plenary.filetype')
local resolve_test_file = require('neotest-gradle.hooks.resolve_test_file')

local detection_queries = {
  kotlin = [[
    (function_declaration
      (modifiers (annotation (user_type (type_identifier) @marker)))
      (#eq? @marker "Test")
    )
  ]],
  java = [[
    (method_declaration
      (modifiers (marker_annotation name: (identifier) @marker))
      (#eq? @marker "Test")
    )
  ]],
}

--- Checks whether the file itself contains @Test annotations by parsing its
--- content with Treesitter and running a lightweight detection query.
---
--- @param path string - absolute file path
--- @param lang string - treesitter language name ("kotlin" or "java")
--- @return boolean
local function has_test_annotations(path, lang)
  local query_text = detection_queries[lang]
  if not query_text then
    return false
  end

  local file = io.open(path, 'r')
  if not file then
    return false
  end
  local content = file:read('*a')
  file:close()

  local ok, parser = pcall(vim.treesitter.get_string_parser, content, lang)
  if not ok then
    return false
  end

  local tree = parser:parse()[1]
  local root = tree:root()

  local query_ok, query = pcall(vim.treesitter.query.parse, lang, query_text)
  if not query_ok then
    return false
  end

  local iter = query:iter_matches(root, content)
  return iter() ~= nil
end

--- Predicate function to determine if a file is a test file or has a
--- corresponding test file. First checks whether a resolved test file exists
--- via path conventions, then falls back to Treesitter-based @Test annotation
--- detection.
---
--- @param file_path string
--- @return boolean
return function(file_path)
  if resolve_test_file(file_path) ~= nil then
    return true
  end

  local ft = filetype.detect(file_path)
  return has_test_annotations(file_path, ft)
end
