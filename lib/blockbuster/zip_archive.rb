class Blockbuster::ZipArchive
  include Blockbuster::CassetteArchive

  def read(cassette)
    entry_name = package_path(cassette)
    each do |entry|
      next unless entry_name == entry.full_name
      return yield entry
    end
  end

  def write(cassettes)
    Zip::File.open(pathname.to_path, Zip::File::CREATE) do |file|
      cassettes.each do |cassette|
        file.add(cassette.relative_path.to_s, cassette)
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
            Stat.new(entry.mode, entry.mtime)
    end
  end

  protected

  def cassette_for(cassettes_path, entry)
    Blockbuster::Cassette.for(
      cassettes_path.join(entry.name),
      directory: cassettes_path,
    )
  end

  def each_entry
    return to_enum unless block_given?
    return unless exist?

    Zip::File.open(pathname) do |file|
      file.each do |entry|
        next unless entry.file?

        yield entry
      end
    end
  end
end
