require 'pp'

Mask = Struct.new('Mask', :description, :bit, :shift)
mask = [
  Mask.new('Sync byte', 0xff, 6 * 4),
  Mask.new('Transport Error Indicator (TEI)', 0x8, 5 * 4),
  Mask.new('Payload Unit Start Indicator (PUSI)', 0x4, 5 * 4),
  Mask.new('Transport Priority', 0x2, 5 * 4),
  Mask.new('PID', 0x2, 5 * 4),
  Mask.new('Transport Scrambling Control (TSC)', 0xc, 1 * 4),
  Mask.new('Adaptation field control', 0x3, 1 * 4),
  Mask.new('Continuity counter', 0xf, 0)
]

output = {}
File.open(ARGV[0]) do |io|
  # until io.eof?
  # 50.times do
  #   division = io.read(4).bytes
  #
  #   sync_byte = ((division & MASK_SYNC_BYTE) >> SHIFT_SYNC_BYTE).to_s(16)
  #
  #   io.seek(188, IO::SEEK_CUR)
  #   packet_count += 1
  # end
  division = io.read(4).bytes.reverse.map.with_index { |n, i| n << i * 8 }.sum

  mask.each do |m|
    output[m.description] = ((division & m.bit << m.shift) >> m.shift)
  end
  break
end

pp output
# puts "TS packet count: #{packet_count}"
