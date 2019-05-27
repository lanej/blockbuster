class Blockbuster::TarArchive
  extend Forwardable

  def_delegators :pathname, :open, :exist?

  attr_reader :pathname

  def initialize(pathname)
    @pathname = pathname
  end

  def read(cassette)
    entry_name = package_path(cassette)
    each do |entry|
      next unless entry_name == entry.full_name
      return yield entry
    end
  end

  def write(cassettes)
    open('w', binmode: true) do |file|
      Zlib::GzipWriter.wrap(file) do |gz|
        Blockbuster::TarWriter.new(gz) do |tar|
          cassettes.each do |cassette|
            cassette.open(File::RDONLY, binmode: true) do |cassette_io|
              tar.add(file: cassette, path: package_path(cassette)) do |package_io|
                IO.copy_stream(cassette_io, package_io)
              end
            end
          end
        end
      end
    end
  end

  def each
    return to_enum unless block_given?
    return unless exist?

    open(File::RDONLY, binmode: true) do |file|
      Zlib::GzipReader.wrap(file) do |gz|
        Gem::Package::TarReader.new(gz) do |tar|
          tar.each_entry do |entry|
            next unless entry.file?

            yield entry
          end
        end
      end
    end
  end

  def package_path(cassette)
    Pathname.new(cassette).relative_path_from(cassette.cassettes_path.parent)
  end
end
