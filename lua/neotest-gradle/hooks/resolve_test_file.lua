--- Resolves a source file path to its corresponding test file path using
--- Gradle conventions. Maps src/main/{lang}/path/File.ext to
--- src/test/{lang}/path/FileTest.ext.
---
--- Only considers Kotlin (.kt) and Java (.java) source files.
--- Returns nil if the source file is not under src/main/ or the
--- corresponding test file does not exist on disk.
---
--- @param source_path string - absolute path to a source file
--- @return string | nil - absolute path to corresponding test file, or nil
return function(source_path)
  if not (source_path:match('%.kt$') or source_path:match('%.java$')) then
    return nil
  end

  local test_path = source_path:gsub('/src/main/', '/src/test/')
  if test_path == source_path then
    return nil
  end

  test_path = test_path:gsub('(%.%w+)$', 'Test%1')

  local file = io.open(test_path, 'r')
  if file then
    file:close()
    return test_path
  end

  return nil
end
