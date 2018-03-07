module Cryptoexchange
  module Services
    class Market
      class << self
        def supports_individual_ticker_query?
          fail "Must define supports_individual_ticker_query? as true or false"
        end
      end

      def fetch(endpoint, ticker_ttl = 10)
        if @tickers && @tickers_last_change && @tickers_last_change > Time.now - ticker_ttl
          return @tickers
        end

        @tickers =
          begin
            @tickers_last_change = Time.now
            response = http_get(endpoint)
            if response.code == 200
              response.parse :json
            elsif response.code == 400
              raise Cryptoexchange::HttpBadRequestError, { response: response }
            else
              raise Cryptoexchange::HttpResponseError, { response: response }
            end
          rescue HTTP::ConnectionError => e
            raise Cryptoexchange::HttpConnectionError, { error: e, response: response }
          rescue HTTP::TimeoutError => e
            raise Cryptoexchange::HttpTimeoutError, { error: e, response: response }
          rescue JSON::ParserError => e
            raise Cryptoexchange::JsonParseError, { error: e, response: response }
          rescue TypeError => e
            raise Cryptoexchange::TypeFormatError, { error: e, response: response }
          end
      end

      private

      def http_get(endpoint)
        fetch_response = HTTP.timeout(:write => 2, :connect => 15, :read => 18).get(endpoint)
      end
    end
  end
end
