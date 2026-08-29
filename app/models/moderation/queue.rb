module Moderation
  class Queue
    Entry = Struct.new(:record, :kind, :title, :excerpt, :author, :created_at, keyword_init: true)

    SOURCES = [
      { type: ForumThread, kind: "Hilo", includes: [ :user, :topic ] },
      { type: Comment, kind: "Comentario", includes: [ :user, :commentable ] },
      { type: News, kind: "Noticia", includes: [ :user ] }
    ].freeze

    def self.pending
      SOURCES.flat_map { |source| entries_for(source) }.sort_by(&:created_at)
    end

    def self.entries_for(source)
      source[:type]
        .where(status: :pending)
        .includes(*source[:includes])
        .map { |record| build_entry(record, source[:kind]) }
    end

    def self.build_entry(record, kind)
      Entry.new(
        record: record,
        kind: kind,
        title: title_for(record),
        excerpt: excerpt_for(record),
        author: record.user,
        created_at: record.created_at
      )
    end

    def self.entry_for(record)
      source = SOURCES.find { |config| config[:type] == record.class }
      build_entry(record, source&.dig(:kind) || record.class.model_name.human)
    end

    def self.title_for(record)
      case record
      when ForumThread then record.title
      when Comment then "Comentario en #{commentable_label(record.commentable)}"
      when News then record.title
      else record.to_s
      end
    end

    def self.excerpt_for(record)
      case record
      when ForumThread then record.body
      when Comment then record.body
      when News then record.summary
      else ""
      end
    end

    def self.commentable_label(commentable)
      case commentable
      when ForumThread then commentable.title
      when Initiative then commentable.title
      else commentable.class.model_name.human
      end
    end
  end
end
