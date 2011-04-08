module FIDIUS
  module EvasionDB
    module PreludeEventFetcher
      def config(conf)
        $logger.debug "INIT PRELUDE EVENT FETCHER"
 	      ids_db = conf['ids_db']
        #FIDIUS::EvasionDB.load_db_adapter(ids_db['adapter'])
        raise "no ids_db part found" unless ids_db
        FIDIUS::PreludeDB::Connection.establish_connection ids_db
        connection = FIDIUS::PreludeDB::Connection.connection
        $logger.debug "connection is: #{connection}"
        require (File.join File.dirname(__FILE__), 'patches', 'postgres_patch.rb')
      end

      def begin_record
        a = FIDIUS::PreludeDB::Alert.find(:first,:joins => [:detect_time],:order=>"time DESC")
        last_event = FIDIUS::PreludeDB::PreludeEvent.new(a)
        @start_time = last_event.detect_time
      end

      def get_events
        #raise "no local ip given" if @local_ip == nil
        raise "please begin_record before fetching" if @start_time == nil
        res = Array.new
        sleep 3
        $logger.debug "alert.find(:all,:joins=>[:detect_time],time > #{@start_time})"
        events = FIDIUS::PreludeDB::Alert.find(:all,:joins => [:detect_time],:order=>"time DESC",:conditions=>["time > :d",{:d => @start_time}])
        $logger.debug "found #{events.size} events"
        events.each do |event|
          ev = FIDIUS::PreludeDB::PreludeEvent.new(event)
          $logger.debug "Event #{ev.source_ip} -> #{ev.dest_ip}  local_ip:#{@local_ip}"
          if @local_ip
            if (ev.source_ip == @local_ip || ev.dest_ip == @local_ip)
              $logger.debug "adding #{ev.inspect} to events "
              res << ev  
            end
          else
            $logger.debug "adding #{ev.inspect} to events "
            res << ev
          end
        end
        return res
      end

      def fetch_events(module_instance=nil)
        result = []
        events = get_events
        events.each do |event|
          idmef_event = FIDIUS::EvasionDB::Knowledge::IdmefEvent.create(:payload=>event.payload,:detect_time=>event.detect_time,
                            :dest_ip=>event.dest_ip,:src_ip=>event.source_ip,
                            :dest_port=>event.dest_port,:src_port=>event.source_port,
                            :text=>event.text,:severity=>event.severity,
                            :analyzer_model=>event.analyzer_model,:ident=>event.id)
          result << idmef_event
        end
        return result
      end

    end
  end
end

require (File.join File.dirname(__FILE__), 'models', 'connection.rb')

Dir.glob(File.join File.dirname(__FILE__), 'models', '*.rb') do |rb|
  $logger.debug "loading #{rb}"
  require rb
end

