class Blockbuster::ZipArchive
  include Blockbuster::CassetteArchive

  def read(cassette)
    yield Zip::File.open(pathname.to_path).
      find_entry(cassette.relative_path.to_path).
      get_input_stream
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
            Stat.new(entry.unix_perms, entry.time)
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

  def package_path(cassette)
    Pathname.new(cassette).relative_path_from(cassette.cassettes_path)
  end
end
