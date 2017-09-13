require "cw_ec2_cm/version"
require 'tempfile'
require 'json'
require 'net/http'

module CwEc2Cm
  WHENEVER_ID='cw-ec2-cm-schedule'
  def update_crontab(update_cmd)
    Tempfile.open(WHENEVER_ID) do |f|
      f.write <<-SCHEDULE
        every 1.minute do
          runner "CwEc2Cm.push_metrics"
        end      
      SCHEDULE
      f.close
      system('whenever', '--load-file', f.path, update_cmd, WHENEVER_ID)
    end
  end
  module_function :update_crontab
  
  def push_metrics
    metadata_endpoint = 'http://169.254.169.254/latest/meta-data/'
    instance_id = Net::HTTP.get( URI.parse( metadata_endpoint + 'instance-id' ) )

    metric_data = []

    # disk usage
    df_fields = %w(fstype source size used avail pcent target)
    metric_time = Time.now
    df_data = `df -l -k --output=#{df_fields.join(',')}`.lines.collect do |l|
      line_array = l.split
      while line_array.size > df_fields.size do
        line_array.last << ' ' << line_array.pop
      end
      {}.tap do |line_data|
        df_fields.each_with_index do |fld, idx|
          line_data[fld] = line_array[idx]
        end
        line_data['pcent'].gsub!('%', '')
      end
    end
    df_data.shift #strip header line
    df_data.reject!{|fs| /tmpfs/ =~ fs['fstype']} #strip tmpfs mounts

    if worst_fs = df_data.max_by{ |fs| fs['pcent'].to_f }
      metric_data << {
        "MetricName": "FSUsagePercent",
        "Dimensions": [{ "Name": "InstanceId", "Value": instance_id }],
        "Timestamp": metric_time,
        "Value": worst_fs['pcent'].to_f,
        "Unit": "Percent" # accepts Seconds, Microseconds, Milliseconds, Bytes, Kilobytes, Megabytes, Gigabytes, Terabytes, Bits, Kilobits, Megabits, Gigabits, Terabits, Percent, Count, Bytes/Second, Kilobytes/Second, Megabytes/Second, Gigabytes/Second, Terabytes/Second, Bits/Second, Kilobits/Second, Megabits/Second, Gigabits/Second, Terabits/Second, Count/Second, None
      }
    end

    # mem usage
    meminfo = {}
    metric_time = Time.now
    `cat /proc/meminfo`.each_line do |l|
      line_array = l.split
      line_array[0].gsub!(':', '')
      meminfo[line_array[0]] = line_array[1].to_f * 1024
    end
    mem_total = meminfo['MemTotal']
    mem_free = meminfo['MemFree'] + meminfo['Cached'] + meminfo['Buffers']
    mem_used = mem_total - mem_free
    mem_percent = (mem_used/mem_total*100).ceil
    metric_data << {
      "MetricName": "MemUsagePercent",
      "Dimensions": [{ "Name": "InstanceId", "Value": instance_id }],
      "Timestamp": metric_time,
      "Value": mem_percent,
      "Unit": "Percent" # accepts Seconds, Microseconds, Milliseconds, Bytes, Kilobytes, Megabytes, Gigabytes, Terabytes, Bits, Kilobits, Megabits, Gigabits, Terabits, Percent, Count, Bytes/Second, Kilobytes/Second, Megabytes/Second, Gigabytes/Second, Terabytes/Second, Bits/Second, Kilobits/Second, Megabits/Second, Gigabits/Second, Terabits/Second, Count/Second, None
    }
    metric_data << {
      "MetricName": "MemFree",
      "Dimensions": [{ "Name": "InstanceId", "Value": instance_id }],
      "Timestamp": metric_time,
      "Value": mem_free/1024/1024,
      "Unit": "Megabytes" # accepts Seconds, Microseconds, Milliseconds, Bytes, Kilobytes, Megabytes, Gigabytes, Terabytes, Bits, Kilobits, Megabits, Gigabits, Terabits, Percent, Count, Bytes/Second, Kilobytes/Second, Megabytes/Second, Gigabytes/Second, Terabytes/Second, Bits/Second, Kilobits/Second, Megabits/Second, Gigabits/Second, Terabits/Second, Count/Second, None
    }

    Tempfile.open('cw-ec2-cm-metrics') do |f|
      f.write(JSON.dump(metric_data))
      f.close
      `aws cloudwatch put-metric-data --namespace EC2Custom --metric-data file://#{f.path}`
    end
  end
  module_function :push_metrics
end
