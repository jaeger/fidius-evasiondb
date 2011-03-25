module FIDIUS
  module EvasionDB
    def self.fetcher(name,&block)
      FIDIUS::EvasionDB::Fetcher.new(name,&block)
    end

    def self.install_fetchers
      FIDIUS::EvasionDB::Fetcher.all.each do |fetcher|
        fetcher.run_install
      end
    end

    class Fetcher
      @@fetchers = []
      def initialize(name,&block)
        self.instance_eval(&block)
        @@fetchers << self
      end

      def install(&block)
        $logger.debug "setting installblock"
        @install = block
      end

      def run_install
        raise "no install block given" unless @install
        @install.call
      end

      def begin_record
        raise "overwrite this"
      end

      def get_events
        raise "overwrite this"
      end

      def self.all
        @@fetchers
      end
    end
  end
end

Dir[File.join(File.dirname(__FILE__), "*/fetcher.rb")].each{|fetch_require|
  $logger.debug "load #{fetch_require}"
  require fetch_require
} 