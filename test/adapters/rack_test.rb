require File.expand_path("../integration", __FILE__)
require File.expand_path('../../live_server', __FILE__)

module Adapters
  class RackTest < Faraday::TestCase

    def adapter() :rack end

    def adapter_options
      [FaradayTestServer]
    end

    # no Integration.apply because this doesn't require a server as a separate process
    include Integration::Common
    include Integration::NonParallel

    # not using shared test because error is swallowed by Sinatra
    def test_timeout
      conn = create_connection(:request => {:timeout => 1, :open_timeout => 1})
      err = assert_raise { conn.get '/slow' }

      case err
      when Faraday::Error::ClientError
        # happens on Mac OS
        assert_include err.response[:body], 'execution expired'
      else
        # happens on Travis
        assert_instance_of Timeout::Error, err
      end
    end

  end
end
