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
--- When the given path is a source file (not a test file), it attempts to
--- resolve the corresponding test file and parse that instead.
---
--- Referred context functions help to provide good readable test names for UI
--- and construct test identifiers based on Java paths used during execution.
---
--- @param path string - absolute file path
--- @return nil | table | table[] - see neotest.Tree
return function(path)
  local test_path = resolve_test_file(path) or path
  local file_type = filetype.detect(test_path)
  local position_query = position_queries[file_type]

  return lib.treesitter.parse_positions(test_path, position_query, {
    build_position = 'require("neotest-gradle.hooks.discover_positions.build_position")',
    position_id = 'require("neotest-gradle.hooks.discover_positions.build_position_identifier")',
  })
end
