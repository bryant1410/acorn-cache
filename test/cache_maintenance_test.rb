require 'acorn_cache/cache_maintenance'
require 'minitest/autorun'

class CacheMaintenanceTest < MiniTest::Test
  def test_new
    cache_key = "/foo"
    server_response = [200, {}, ["bar"]]
    cached_response = [200, {}, ["foobar"]]

    cache_maintenance =
      Rack::AcornCache::CacheMaintenance.new(cache_key, server_response, cached_response)

    assert_equal "/foo", cache_maintenance.cache_key
    assert_equal [200, {}, ["bar"]], cache_maintenance.server_response
    assert_equal [200, {}, ["foobar"]], cache_maintenance.cached_response
  end

  def test_update_cache_with_server_response_nil
    cache_key = "/foo"
    server_response = nil
    cached_response = mock('cached_response')

    cached_response.expects(:add_acorn_cache_header!).returns(cached_response)
    cache_maintenance =
      Rack::AcornCache::CacheMaintenance.new(cache_key, server_response, cached_response)
    cache_maintenance.update_cache

    assert_equal cached_response, cache_maintenance.response
  end

  def test_update_cache_with_server_response_not_cacheable_or_304
    cache_key = "/foo"
    server_response = mock('server_response')
    cached_response = mock('cached_response')

    server_response.stubs(:cacheable?).returns(false)
    server_response.stubs(:status_304?).returns(false)

    cache_maintenance =
      Rack::AcornCache::CacheMaintenance.new(cache_key, server_response, cached_response)
    cache_maintenance.update_cache

    assert_equal server_response, cache_maintenance.response
  end

  def test_update_cache_with_server_response_cacheable
    cache_key = "/foo"
    server_response = stub(cacheable?: true, status_304?: false)
    cached_response = mock('cached_response')

    server_response.expects(:cache!).with(cache_key).returns(server_response)

    cache_maintenance =
      Rack::AcornCache::CacheMaintenance.new(cache_key, server_response, cached_response)
    cache_maintenance.update_cache

    assert_equal server_response, cache_maintenance.response
  end

  def test_update_cache_with_server_response_304_and_matches_cached_response
    cache_key = "/foo"
    server_response = mock('server_response')
    cached_response = mock('cached_response')

    server_response.stubs(:cacheable?).returns(false)
    server_response.stubs(:status_304?).returns(true)

    cached_response.expects(:matches?).with(server_response).returns(true)
    cached_response.expects(:update_date_and_recache!).with(cache_key).returns(cached_response)

    cache_maintenance =
      Rack::AcornCache::CacheMaintenance.new(cache_key, server_response, cached_response)
    cache_maintenance.update_cache

    assert_equal cached_response, cache_maintenance.response
  end

  def test_update_cache_with_server_response_304_and_doest_matche_cached_response
    cache_key = "/foo"
    server_response = mock('server_response')
    cached_response = mock('cached_response')

    server_response.stubs(:cacheable?).returns(false)
    server_response.stubs(:status_304?).returns(true)

    cached_response.expects(:matches?).with(server_response).returns(false)

    cache_maintenance =
      Rack::AcornCache::CacheMaintenance.new(cache_key, server_response, cached_response)
    cache_maintenance.update_cache

    assert_equal server_response, cache_maintenance.response
  end

  def test_update_cache_not_cacheable_or_304
    cache_key = "/foo"
    server_response = mock('server_response')
    cached_response = mock('cached_response')

    server_response.stubs(:cacheable?).returns(false)
    server_response.stubs(:status_304?).returns(false)

    cache_maintenance =
      Rack::AcornCache::CacheMaintenance.new(cache_key, server_response, cached_response)
    cache_maintenance.update_cache

    assert_equal server_response, cache_maintenance.response
  end
end
