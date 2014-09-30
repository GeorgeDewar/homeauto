require 'clockwork'
require 'cron_parser'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job, time|
    Task.all.each do |task|
      cron_parser = CronParser.new task.expression
      last = cron_parser.last(Time.now + 60)
      last_ago = Time.now - last

      if last_ago < 60 && (task.last_run_at == nil || task.last_run_at < last)
        puts "Running task '#{task.name}' at #{Time.now.to_s}"
        task.last_run_at = Time.now
        message = Message.new created_at: Time.now, device: task.device, message: task.message
        message.save
        task.save
      end
    end
  end

  every(1.seconds, 'check')

end
