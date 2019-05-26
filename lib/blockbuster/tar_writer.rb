class Blockbuster::TarWriter < Gem::Package::TarWriter
  NULL_CHARACTER = "\0".freeze

  def add(file:, path: file)
    check_closed

    file = Pathname.new(file)
    path = Pathname.new(path)

    size = file.stat.size

    header = Gem::Package::TarHeader.new(
      mode: file.stat.mode,
      mtime: file.stat.mtime,
      name: path.basename.to_s,
      prefix: path.dirname.to_s,
      size: size,
    ).to_s
    @io.write header

    min_padding = size
    if block_given?
      BoundedStream.new(@io, size).tap do |os|
        yield os

        min_padding = size - os.written
      end
    end

    @io.write(NULL_CHARACTER * min_padding)

    remainder = (512 - (size % 512)) % 512
    @io.write(NULL_CHARACTER * remainder)

    self
  end
end
