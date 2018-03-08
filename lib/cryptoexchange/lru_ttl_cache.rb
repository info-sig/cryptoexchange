module Cryptoexchange
  class LruTtlCache
    class << self
      def ticker_cache(ticker_ttl = 10)
        LruRedux::TTL::ThreadSafeCache.new(100, ticker_ttl)
      end
    end
  end
end
