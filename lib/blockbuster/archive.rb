class Blockbuster::Archive
  TAR_EXTNAME = '.tar.gz'.freeze
  ZIP_EXTNAME = '.zip'.freeze

  class << self
    def for(archive)
      archivers.fetch(archive.extname).new(archive)
    end

    def archivers
      @archivers ||= {
        TAR_EXTNAME => Blockbuster::TarArchive,
        ZIP_EXTNAME => Blockbuster::ZipArchive,
      }
    end

    def glob
      '{' + archivers.keys.join(',') + '}'
    end
  end
end
