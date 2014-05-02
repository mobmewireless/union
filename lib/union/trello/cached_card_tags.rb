unless defined?(Rails)
  raise 'CachedCardTags class uses the Rails.cache method. Try requiring after Rails is loaded.'
end

module Union::Trello
  class CachedCardTags
    def self.tags
      Rails.cache.fetch('cached_card_tags', expires_in: 1.hour) do
        cache = Project.card_tags
        cache.deep_merge!(Server.card_tags)

        cache
      end
    end
  end
end
