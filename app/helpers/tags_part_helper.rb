module Merb
  module TagsPartHelper

    def tag_cloud(tags, classes)
      return if tags.empty?

      max_count = 0
      tags.each { |key, value| max_count = value.size if value.size > max_count }

      tags.each do |tag_id, tagging|
        index = ((tagging.size / max_count) * (classes.size - 1)).round
        yield Tag.get(tag_id), classes[index]
      end
    end

  end
end # Merb
