require 'minitest/autorun'
require 'acorn_cache'

class AcornCacheTest < Minitest::Test

  def test_call_returns_app_if_request_is_not_a_get
    env = { "REQUEST_METHOD" => "POST" }
    app = mock("app")
    app.stubs(:call).returns([200, { }, ["foo"]])

    acorn_cache = Rack::AcornCache.new(app)

    assert_equal [200, { }, ["foo"]], acorn_cache.call(env)
  end

  def test_call_returns_app_if_error
    env = { "REQUEST_METHOD" => "GET" }
    Rack::AcornCache::CacheController.stubs(:new).raises(StandardError)
    app = mock("app")
    app.stubs(:call).returns([200, { }, ["foo"]])

    acorn_cache = Rack::AcornCache.new(app)

    assert_equal [200, { }, ["foo"]], acorn_cache.call(env)
  end

  def test_call_passes_request_and_app_to_cache_controller_if_ok
    request = mock("request")
    response = mock("response")
    cache_controller = mock("cache controller")
    env = { "REQUEST_METHOD" => "GET" }
    app = mock("app")
    app.stubs(:call).returns([200, { }, ["foo"]])
    Rack::AcornCache::CacheController.stubs(:new).with(request, app)
                                     .returns(cache_controller)
    Rack::AcornCache::Request.stubs(:new).with(env).returns(request)
    cache_controller.expects(:response).returns(response)
    request.stubs(:get?).returns(true)
    response.expects(:to_a).returns([200, { }, ["foo"]])

    acorn_cache = Rack::AcornCache.new(app)

    assert_equal [200, { }, ["foo"]], acorn_cache.call(env)
  end
end