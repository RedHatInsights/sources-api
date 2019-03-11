module OpenApi
  class Docs
    def initialize(glob)
      @cache = {}
      glob.each { |f| load_file(f) }
    end

    def load_file(file)
      yaml = YAML.load_file(file)
      doc  = DocV2.new(yaml) if yaml["swagger"] == "2.0"
      store_doc(doc)
    end

    def store_doc(doc)
      update_doc_for_version(doc, doc.version.segments[0..1].join("."))
      update_doc_for_version(doc, doc.version.segments.first.to_s)
    end

    def update_doc_for_version(doc, version)
      if @cache[version].nil?
        @cache[version] = doc
      else
        existing_version = @cache[version].version
        @cache[version] = doc if doc.version > existing_version
      end
    end

    def [](version)
      @cache[version]
    end

    def routes
      @routes ||= begin
        @cache.each_with_object([]) do |(version, doc), routes|
          next unless /\d+\.\d+/ =~ version # Skip unless major.minor
          routes.concat(doc.routes)
        end
      end
    end
  end
end
