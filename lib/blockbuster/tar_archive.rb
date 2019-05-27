class Blockbuster::TarArchive
  include Blockbuster::CassetteArchive

  def read(cassette)
    entry_name = package_path(cassette)
    each_entry do |entry|
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

  def each_cassette(cassettes_path)
    return to_enum(:each_cassette, cassettes_path) unless block_given?

    each_entry { |entry| yield cassette_for(cassettes_path, entry) }
  end

  def each_cassette_with_stat(cassettes_path)
    return to_enum(:each_cassette_with_stat, cassettes_path) unless block_given?

    each_entry do |entry|
      yield cassette_for(cassettes_path, entry),
        Stat.new(entry.header.mode, entry.header.mtime)
    end
  end

  protected

  def each_entry
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

  def cassette_for(cassettes_path, entry)
    Blockbuster::Cassette.for(cassettes_path.parent.join(entry.full_name),
                              directory: cassettes_path)
  end

  def package_path(cassette)
    Pathname.new(cassette).relative_path_from(cassette.cassettes_path.parent)
  end
end
