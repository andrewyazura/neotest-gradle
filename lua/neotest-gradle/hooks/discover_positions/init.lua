local lib = require('neotest.lib')
local filetype = require('plenary.filetype')
local position_queries = require('neotest-gradle.position_queries')
local resolve_test_file = require('neotest-gradle.hooks.resolve_test_file')

--- See Neotest adapter specification.
---
--- It uses the Neotest provided utilities to run Treesitter queries. These
--- queries find (nested) test classes as Neotest namespaces and test functions
--- as Neotest tests. Other positions like "file" and "dir" are not supported
--- and are handled differently during execution.
---
--- For source files with a corresponding test file, the test file is parsed
--- instead and the resulting tree root is re-keyed to the source path. This
--- allows neotest to store test positions under the source file, showing test
--- indicators in the summary and enabling run-from-source.
---
--- Referred context functions help to provide good readable test names for UI
--- and construct test identifiers based on Java paths used during execution.
---
--- @param path string - absolute file path
--- @return nil | table | table[] - see neotest.Tree
return function(path)
  local test_path = resolve_test_file(path)
  local parse_path = test_path or path
  local file_type = filetype.detect(parse_path)
  local position_query = position_queries[file_type]

  local tree = lib.treesitter.parse_positions(parse_path, position_query, {
    build_position = 'require("neotest-gradle.hooks.discover_positions.build_position")',
    position_id = 'require("neotest-gradle.hooks.discover_positions.build_position_identifier")',
  })

  if test_path then
    local root = tree:data()
    root.path = path
    root.id = path
    root.name = path:match('([^/]+)$')
  end

  return tree
end
