require 'stringio'

class JobManager
  @job = nil
  @output = {}

  class << self
    def run(payload)
      @output = {}

      @job = Thread.new {
        b = binding

        begin
          code = %{
            begin $stdout = StringIO.new;
            #{payload["code"]}
            $stdout.string;
            ensure $stdout = STDOUT end
          }

          puts "<<< BEGIN CODE >>>"
          puts code
          puts "<<< END CODE >>>"

          @output[:stdout] = eval(code, b)

          puts "<<< BEGIN OUTPUT >>>"
          puts @output[:stdout]
          puts "<<< END OUTPUT >>>"
        rescue Exception => e
          puts e
          @output[:error] = e.to_s
        end

        Thread.exit
      }
    end

    def running?
      if @job.nil? || @job.status == false
        false
      else
        true
      end
    end

    def stop
      if @job != nil
        @job.exit
      end
    end

    def output
      @output
    end
  end
end
