module DiscordBot
  class Logger
    attr_reader :mode
    attr_reader :targets, :file
    def initialize(mode = :console, targets = { :errors => "lib/src/logs/errors.txt", :logs => "lib/src/logs/logs.txt" })
      @mode = mode
      @targets = targets if @mode == :file
    end
    def write(data, mode = :logs)
      return Logger.new(:console).warn("The file logs aren't available on #{@mode} mode") if @mode != :file
      File.open(@targets[mode], "a+") do |f|
        f.write("#{Time.now.strftime("%Y-%m-%d-%H:%M:%S")} - #{mode.upcase} : #{data}\n")
      end
      data
    end
    COLORS = {
      :default => "\e[38m",
      :white => "\e[39m",
      :black => "\e[30m",
      :red => "\e[31m",
      :green => "\e[32m",
      :brown => "\e[33m",
      :blue => "\e[34m",
      :magenta => "\e[35m",
      :cyan => "\e[36m",
      :gray => "\e[37m",
      :yellow => "\e[33m",
    }.freeze
    MODES = {
      :info => :cyan,
      :error => :red,
      :warn => :yellow,
      :check => :green
    }.freeze
    def console_color(color, message)
      "#{COLORS[color]}#{message}\e[0m"
    end

    MODES.each do |key, value|
      define_method(key) do |message|
        return Logger.new(:console).warn("The console logs aren't available on #{@mode} mode") if @mode != :console
        time = Time.now.strftime("%Y-%m-%d-%H:%M:%S")
        puts "[#{console_color(:magenta, time.to_s)}] - [#{console_color(value, key.to_s.upcase)}] : #{message}"
      end
    end
    private :console_color
  end
end