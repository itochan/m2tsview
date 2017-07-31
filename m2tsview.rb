require 'pp'
require 'optparse'
require 'ruby-progressbar'

option = {}
opts = OptionParser.new
opts.on('-v') { option[:verbose] = true }
opts.parse!(ARGV)

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

pid_count = {}

File.open(ARGV[0]) do |f|
  size = f.size
  progressbar = ProgressBar.create(
    title: 'Analyze',
    total: size / 188,
    format: '%t: |%B| %P% %E'
  )

  until f.eof?
    division = f.read(4).bytes.reverse.map.with_index { |n, i| n << i * 8 }.sum

    mask.each do |m|
      value = "0x#{((division & m.bit << m.shift) >> m.shift).to_s(16)}"
      puts "#{m.description}: #{value}" if option[:verbose]

      if m.description == 'PID'
        pid_count[value] = 0 unless pid_count[value]
        pid_count[value] += 1
      end
    end
    puts if option[:verbose]

    f.seek(184, IO::SEEK_CUR)

    progressbar.increment
  end
end

puts 'PID Count'
pid_count.sort.each { |p| puts "#{p[0]}: #{p[1]}" }
