local resolve_test_file = require('neotest-gradle.hooks.resolve_test_file')

describe('resolve_test_file', function()
  local tmp_dir
  before_each(function()
    tmp_dir = os.tmpname() .. '_dir'
    os.execute('mkdir -p ' .. tmp_dir .. '/src/main/kotlin/co/lety')
    os.execute('mkdir -p ' .. tmp_dir .. '/src/test/kotlin/co/lety')
  end)

  after_each(function()
    os.execute('rm -rf ' .. tmp_dir)
  end)

  it('resolves a kotlin source file to its test file', function()
    local test_file = tmp_dir .. '/src/test/kotlin/co/lety/HttpRouteTest.kt'
    local f = io.open(test_file, 'w')
    f:close()

    local source_path = tmp_dir .. '/src/main/kotlin/co/lety/HttpRoute.kt'
    assert.are.equal(test_file, resolve_test_file(source_path))
  end)

  it('resolves a java source file to its test file', function()
    os.execute('mkdir -p ' .. tmp_dir .. '/src/main/java/co/lety')
    os.execute('mkdir -p ' .. tmp_dir .. '/src/test/java/co/lety')

    local test_file = tmp_dir .. '/src/test/java/co/lety/ServiceTest.java'
    local f = io.open(test_file, 'w')
    f:close()

    local source_path = tmp_dir .. '/src/main/java/co/lety/Service.java'
    assert.are.equal(test_file, resolve_test_file(source_path))
  end)

  it('returns nil when test file does not exist', function()
    local source_path = tmp_dir .. '/src/main/kotlin/co/lety/Missing.kt'
    assert.is_nil(resolve_test_file(source_path))
  end)

  it('returns nil for paths not under src/main/', function()
    local source_path = tmp_dir .. '/lib/kotlin/co/lety/HttpRoute.kt'
    assert.is_nil(resolve_test_file(source_path))
  end)

  it('returns nil for non-kotlin/java files', function()
    local source_path = tmp_dir .. '/src/main/resources/config.properties'
    assert.is_nil(resolve_test_file(source_path))
  end)

  it('returns nil for files that are already test files', function()
    local test_file = tmp_dir .. '/src/test/kotlin/co/lety/HttpRouteTest.kt'
    local f = io.open(test_file, 'w')
    f:close()

    -- A test file path has no src/main/ segment, so gsub is a no-op
    assert.is_nil(resolve_test_file(test_file))
  end)

  it('handles filenames with underscores', function()
    local test_file = tmp_dir .. '/src/test/kotlin/co/lety/shopping_sessionTest.kt'
    local f = io.open(test_file, 'w')
    f:close()

    local source_path = tmp_dir .. '/src/main/kotlin/co/lety/shopping_session.kt'
    assert.are.equal(test_file, resolve_test_file(source_path))
  end)
end)
