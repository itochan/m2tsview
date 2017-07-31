packet_count = 0

File.open(ARGV[0]) do |io|
  until io.eof?
    io.seek(188, IO::SEEK_CUR)
    packet_count += 1
  end
end

puts "TS packet count: #{packet_count}"
