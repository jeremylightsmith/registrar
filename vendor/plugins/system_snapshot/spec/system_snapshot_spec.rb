dir = File.dirname(__FILE__)
require "rubygems"
require "spec"
require 'lib/system_snapshot'
require 'fileutils'


include FileUtils

process_list = \
ProcessList.new( \
%{
COMMAND                       PID %CPU %MEM   RSS
init [3]                        1  0.0  0.0    68
[migration/0]                   2  0.0  0.0     0
[ksoftirqd/0]                   3  0.0  0.0     0
[events/0]                      4  0.0  0.0     0
[khelper]                       5  0.0  0.0     0
[kthread]                       6  0.0  0.0     0
nginx: master process /usr/     7  1.0  5.0    50
nginx: worker process           8  2.0  5.0   50
nginx: worker process           9  2.0  5.0   50
nginx: worker process          10  5.0  5.0   50
nginx: worker process          11  5.0  5.0   50
/usr/sbin/ntpd -p /var/run/    12  0.0  0.1   404
/usr/sbin/rwhod -b             13  0.0  0.0   128
/usr/sbin/rwhod -b             14  0.0  0.0   136
[pdflush]                      15  0.0  0.0     0
/usr/bin/ruby18 /usr/bin/mo    16  10.0 20.0 30000
/usr/bin/ruby18 /usr/bin/mo    17  20.0 30.0 20000
/usr/bin/ruby18 /usr/bin/mo    18  30.0 40.0 10000
/usr/bin/rake                  19  15.0 10.0 3333
ps -eo command,%cpu,%mem,rs    20  0.0  0.1   712
})

describe "capture information about a series of processes" do
  it "gives avg/max memory and processor readings" do

    process_list.process_info("/usr/bin/ruby").should == [
      ["/usr/bin/ruby count",       3],
      ["/usr/bin/ruby avg cpu%",    20],
      ["/usr/bin/ruby avg mem%",    30],
      ["/usr/bin/ruby avg rss",     20000],
      ["/usr/bin/ruby max cpu%",    30],
      ["/usr/bin/ruby max mem%",    40],
      ["/usr/bin/ruby max rss",     30000]
    ]

    process_list.process_info("nginx").should == [
      ["nginx count",       5],
      ["nginx avg cpu%",    3],
      ["nginx avg mem%" ,   5],
      ["nginx avg rss" ,    50],
      ["nginx max cpu%",    5],
      ["nginx max mem%" ,   5],
      ["nginx max rss" ,    50]
    ]
  end

  it "is blank when there aren't any relevant processes" do
    process_list.process_info("zzzzz").should == [
      ["zzzzz count",       0],
      ["zzzzz avg cpu%",    nil],
      ["zzzzz avg mem%" ,   nil],
      ["zzzzz avg rss" ,    nil],
      ["zzzzz max cpu%",    nil],
      ["zzzzz max mem%" ,   nil],
      ["zzzzz max rss" ,    nil]
    ]
  end
end

lsof = Lsof.new( \
%{COMMAND    PID    USER   FD     TYPE    DEVICE  SIZE/OFF     NODE NAME
ATSServer   68 pivotal  cwd      DIR      14,2      1224        2 /
ATSServer   68 pivotal  txt      REG      14,2   6675820  1065275 /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATS.framework/Versions/A/Support/ATSServer
ATSServer   68 pivotal  txt      REG      14,2     81316   674740 /System/Library/CoreServices/CharacterSets/CFUnicodeData-L.mapping
ATSServer   68 pivotal  txt      REG      14,2    352454   674737 /System/Library/CoreServices/CharacterSets/CFCharacterSetBitmaps.bitmap
ATSServer   68 pivotal  txt      REG      14,2   2449048  1073895 /Library/Caches/com.apple.ATS/501/annex_aux
ATSServer   68 pivotal  txt      REG      14,2    156474  1073953 /Library/Caches/com.apple.ATS/501/Local.fcache
ATSServer   68 pivotal  txt      REG      14,2    307743   695645 /System/Library/Fonts/Monaco.dfont
ATSServer   68 pivotal  txt      REG      14,2    385906   695633 /System/Library/Fonts/Courier.dfont
ATSServer   68 pivotal  txt      REG      14,2   1135530   698680 /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATS.framework/Versions/A/Resources/SynthDB.rsrc
ATSServer   68 pivotal  txt      REG      14,2    133076  1073954 /Library/Caches/com.apple.ATS/501/System.fcache
ATSServer   68 pivotal  txt      REG      14,2   1688500  1071869 /usr/lib/dyld
ATSServer   68 pivotal  txt      REG      14,2   8000260   759152 /usr/lib/libSystem.B.dylib
ATSServer   68 pivotal  txt      REG      14,2   2323604  1072550 /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
ATSServer   68 pivotal  txt      REG      14,2   2815144  1072638 /usr/lib/libicucore.A.dylib
ATSServer   68 pivotal  txt      REG      14,2   1580124  1072557 /usr/lib/libobjc.A.dylib
ATSServer   68 pivotal  txt      REG      14,2   3559472  1072925 /usr/lib/libstdc++.6.0.4.dylib
ATSServer   68 pivotal  txt      REG      14,2    251320   916985 /usr/lib/libgcc_s.1.dylib
ATSServer   68 pivotal  txt      REG      14,2    220988  1072644 /usr/lib/libauto.dylib
ATSServer   68 pivotal  txt      REG      14,2   6437928  1073376 /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/CarbonCore
ATSServer   68 pivotal  txt      REG      14,2   1492552  1073377 /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/OSServices.framework/Versions/A/OSServices
ATSServer   68 pivotal  txt      REG      14,2    263296  1072614 /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/WebServicesCore.framework/Versions/A/WebServicesCore
ATSServer   68 pivotal  txt      REG      14,2   1754552  1073427 /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/SearchKit.framework/Versions/A/SearchKit
ATSServer   68 pivotal  txt      REG      14,2    383528  1073476 /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/A/Metadata
})

describe "capture information about open files" do
  it "gives an open file count" do

    lsof.info().should == [
      ["file count",       23]
    ]

  end
end

vmstat = VmStat.new(%{
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0  20764  92780  41832  35208    3    3    19    44   30    33  4  2 91  3
 0  0  20764  92780  41832  35208 4386 3457     0    24  405    77  0  2 98  0
})

describe "capture memory information" do
  it "gives free, si, so" do
    vmstat.info.should == [
      ["free", 92780],
      ["si", 4386],
      ["so", 3457]
    ]
  end
end




closer_to_real_process_list = \
ProcessList.new( \
%{
COMMAND                       PID %CPU %MEM    RSS
init [3]                        1  0.0  0.0     68
[migration/0]                   2  0.0  0.0      0
[ksoftirqd/0]                   3  0.0  0.0      0
[events/0]                      4  0.0  0.0      0
[khelper]                       5  0.0  0.0      0
[kthread]                       6  0.0  0.0      0
sendmail: accepting connect     7  2.0  3.0   1000
sendmail: Queue runner@01:0     8  4.0  5.0   2000
/bin/sh ./solr.sh               9  0.0  0.0    492
java -DSTART=/kenlet_produc    10  2.0 10.3 417408
/bin/sh /usr/bin/mysqld_saf    11  0.0  0.0    824
/usr/libexec/mysqld --defau    12  9.0  0.6  24904
/usr/local/bin/memcached -d    13  0.5  2.7 111036
/usr/sbin/httpd                14  0.0  0.1   4096
/usr/local/bin/ruby /usr/lo    15  2.0  10.0 20000
/usr/local/bin/ruby /usr/lo    16  4.0  10.0 30000
/usr/local/bin/ruby /usr/lo    17  6.0  20.0 40000
/usr/local/bin/ruby /usr/lo    18  8.0  20.0 50000
/usr/sbin/httpd                19  0.0  0.4  20028
/usr/sbin/httpd                20  0.0  0.5  20192
/usr/sbin/httpd                21  0.0  0.4  19528
ps -eo command,pid,%cpu,%me    22  0.0  0.0    828
})


describe "system_snapshot" do
  it "gives a giant 'row' of statistics" do

    time = Time.parse("2007-02-03 13:14:15")

    snapshot_results =
        system_snapshot(
            :current_time => time,
            :process_list => closer_to_real_process_list,
            :vmstat => vmstat)


    snapshot_results.slice(0..3).should == [
      ["time",  "20070203131415"],
      ["free",  92780],
      ["si",    4386],
      ["so",    3457]
    ]

    snapshot_results.select{|r|r[0].include?("max rss")}.sort{|a,b|a[0]<=>b[0]}.should == [
      ["/usr/libexec/mysqld max rss",     24904],
      ["/usr/local/bin/ruby max rss",     50000],
      ["/usr/sbin/httpd max rss", 20192]
    ]
  end
end

describe "as csv row" do
  it "stats as csv header row" do
    [
      ["/usr/bin/ruby count", 3],
      ["/usr/bin/ruby avg cpu%", 20],
      ["nginx count", 5],
      ["nginx avg cpu%", 3]
    ].as_csv_header_row.should == "'/usr/bin/ruby count','/usr/bin/ruby avg cpu%','nginx count','nginx avg cpu%'"
  end

  it "stats as csv data row" do
    [
      ["/usr/bin/ruby count", 3],
      ["/usr/bin/ruby avg cpu%", 20],
      ["nginx count", 5],
      ["nginx avg cpu%", 3]
    ].as_csv_data_row.should == "3,20,5,3"
  end
end


describe "append row to csv file" do
  it "creates file with header and first row if file doesn't exist" do
    rm_rf("/tmp/stats") if File.exists?("/tmp/stats")

    [
      ["/usr/bin/ruby count", 3],
      ["/usr/bin/ruby avg cpu%", 20],
      ["nginx count", 5],
      ["nginx avg cpu%", 3]
    ].append_to_csv_file("/tmp/stats/test_csv")

    file_content = File.new("/tmp/stats/test_csv").read
    file_content.should include("'/usr/bin/ruby count','/usr/bin/ruby avg cpu%','nginx count','nginx avg cpu%'")
    file_content.should include("3,20,5,3")
  end

  it "appends data row only if file exists" do
    rm("/tmp/test_csv") if File.exists?("/tmp/test_csv")

    [
      ["/usr/bin/ruby count", 3],
      ["/usr/bin/ruby avg cpu%", 20],
      ["nginx count", 5],
      ["nginx avg cpu%", 3]
    ].append_to_csv_file("/tmp/test_csv")

    [
      ["/usr/bin/ruby count", 4],
      ["/usr/bin/ruby avg cpu%", 21],
      ["nginx count", 6],
      ["nginx avg cpu%", 4]
    ].append_to_csv_file("/tmp/test_csv")

    file_content = File.new("/tmp/test_csv").read
    file_content.should include("'/usr/bin/ruby count','/usr/bin/ruby avg cpu%','nginx count','nginx avg cpu%'")
    file_content.should include("3,20,5,3")
    file_content.should include("4,21,6,4")

  end

  it "handles nils as nothing" do
    rm("/tmp/test_csv") if File.exists?("/tmp/test_csv")

    [
      ["/usr/bin/ruby count", 3],
      ["/usr/bin/ruby avg cpu%", 20],
      ["nginx count", nil],
      ["nginx avg cpu%", nil]
    ].append_to_csv_file("/tmp/test_csv")

    file_content = File.new("/tmp/test_csv").read
    file_content.should include("'/usr/bin/ruby count','/usr/bin/ruby avg cpu%','nginx count','nginx avg cpu%'")
    file_content.should include("3,20,,")

  end

end