class Blockbuster::Archive
  class << self
    def for(archive)
      archivers.fetch(archive.extname).new(archive)
    end

    def archivers
      @archivers ||= {
        '.tar.gz' => Blockbuster::TarArchive,
      }
    end
  end
end
