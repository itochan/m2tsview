require 'pp'

Mask = Struct.new('Mask', :description, :bit, :shift)
mask = [
  Mask.new('Sync byte', 0xff, 6 * 4),
  Mask.new('Transport Error Indicator (TEI)', 0x8, 5 * 4),
  Mask.new('Payload Unit Start Indicator (PUSI)', 0x4, 5 * 4),
  Mask.new('Transport Priority', 0x2, 5 * 4),
  Mask.new('PID', 0x1fff, 2 * 4),
  Mask.new('Transport Scrambling Control (TSC)', 0xc, 1 * 4),
  Mask.new('Adaptation field control', 0x3, 1 * 4),
  Mask.new('Continuity counter', 0xf, 0)
]

stats = {
  pid_count: {}
}
File.open(ARGV[0]) do |io|
  until io.eof?
    division = io.read(4).bytes.reverse.map.with_index { |n, i| n << i * 8 }.sum

    mask.each do |m|
      value = ((division & m.bit << m.shift) >> m.shift).to_s(16)
      puts "#{m.description}: 0x#{value}"

      if m.description == 'PID'
        stats[:pid_count][value.to_sym] = 0 unless stats[:pid_count][value.to_sym]
        stats[:pid_count][value.to_sym] += 1
      end
    end
    puts

    io.seek(184, IO::SEEK_CUR)
  end
end

pp stats
