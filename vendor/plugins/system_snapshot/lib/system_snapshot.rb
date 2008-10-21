require 'fileutils'
include FileUtils

def system_snapshot(params={})

  defaults = {
    :current_time => Time.now,
    :process_list=>ProcessList.new,
    :vmstat=>VmStat.new,
    :lsof=> Lsof.new(nil),
    :processes=> ["/usr/local/bin/ruby", "/usr/libexec/mysqld", "/usr/sbin/httpd"]
  }

  params = defaults.merge(params)

  row = [["time", params[:current_time].strftime("%Y%m%d%H%M%S")]]
  row += params[:vmstat].info
  row += params[:lsof].info
  params[:processes].each do |command|
    row += params[:process_list].process_info(command)
  end
  row
end


class Array
  def average
    total = 0.0
    each {|e| total += e}
    total/length
  end

  def float_max
    max = 0.0
    each {|e| max = e > max ? e : max}
    max
  end

  def as_csv_header_row
    csv_row_for_index(0)
  end

  def as_csv_data_row
    csv_row_for_index(1)
  end

  def append_to_csv_file(path)
    if ( ! File.exists?(path) )
      mkdir_p(File.dirname(path))
      File.open(path, "w+") {|f| f << self.as_csv_header_row + "\n"}
    end

    File.open(path, "a") {|f| f << self.as_csv_data_row + "\n"}
  end

  private
  def csv_row_for_index(index)
    collect{|e| e[index].is_a?(String) ? "'#{e[index]}'" : e[index].to_s}.join(",")
  end
end

class ProcessList
  @@ps_command = `uname`.strip=="Darwin" ?
                  "ps axo command,pid,%cpu,%mem,rss" :
                  "ps -eo command,pid,%cpu,%mem,rss"


  def initialize(process_list_output=`#{@@ps_command}`)
    @lines = process_list_output.strip.split("\n")
  end

  def process_info(process_name)
    process_lines = @lines.select{|line| line =~ /^#{process_name}/}

    if (process_lines.length>0)

      cpu_percents = []
      mem_percents = []
      rsses = []
      pids = []

      process_lines.each do |line|
        elements = line.squeeze(" ").split(" ").reverse

        rss = elements.shift
        mem_percent = elements.shift
        cpu_percent = elements.shift
        pid = elements.shift

        command = elements.last
        
        cpu_percents << cpu_percent.to_f
        mem_percents << mem_percent.to_f
        rsses << rss.to_i
        pids << pid.to_i
      end

      process_count = process_lines.length

      [
        ["#{process_name} count", process_count],
        ["#{process_name} avg cpu%", cpu_percents.average.to_i],
        ["#{process_name} avg mem%", mem_percents.average.to_i],
        ["#{process_name} avg rss", rsses.average.to_i],
        ["#{process_name} max cpu%", cpu_percents.float_max.to_i],
        ["#{process_name} max mem%", mem_percents.float_max.to_i],
        ["#{process_name} max rss", rsses.max]
      ]
    else
      [
        ["#{process_name} count", 0],
        ["#{process_name} avg cpu%", nil],
        ["#{process_name} avg mem%", nil],
        ["#{process_name} avg rss", nil],
        ["#{process_name} max cpu%", nil],
        ["#{process_name} max mem%", nil],
        ["#{process_name} max rss", nil]
      ]
    end
  end
end


class VmStat
  @@canned_darwin_vmstat_response = %{
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0  20764  92780  41832  35208    3    3    19    44   30    33  4  2 91  3
 0  0  20764  92780  41832  35208 4386 3457     0    24  405    77  0  2 98  0
}


  def initialize(vmstat_output=`uname`.strip=="Darwin" ?
                                  @@canned_darwin_vmstat_response :
                                  `vmstat 1 2`)
    @line = vmstat_output.strip.split("\n").last
  end

  def info
    elements = @line.squeeze(" ").split(" ")
    free = elements[3].to_i
    si = elements[6].to_i
    so = elements[7].to_i

    [
      ["free", free],
      ["si", si],
      ["so", so]
    ]
  end
end

class Lsof

  def initialize(username)
    @open_files = username.nil? ? `lsof` : `lsof | grep #{username}`.split("\n")
  end

  def info
    [
      ["open file count", @open_files.size]
    ]
  end
end