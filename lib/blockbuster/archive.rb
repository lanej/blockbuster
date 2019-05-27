class Blockbuster::Archive
  TAR_EXTNAME = '.tar.gz'.freeze

  class << self
    def for(archive)
      archivers.fetch(archive.extname).new(archive)
    end

    def archivers
      @archivers ||= {
        TAR_EXTNAME => Blockbuster::TarArchive,
      }
    end

    def glob
      '*{' + archivers.keys.join(',') + '}'
    end
  end
end
