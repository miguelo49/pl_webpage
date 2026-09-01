# frozen_string_literal: true

class HomeFeedQuery
  FeedEntry = Struct.new(:record_type, :record_id, :feed_at, :record, keyword_init: true)

  attr_reader :user, :page, :per_page

  def initialize(user:, page: 1, per_page: 10)
    @user = user
    @per_page = per_page
    @page = [ page.to_i, 1 ].max
  end

  def items
    return [] if page > total_pages

    @items ||= hydrate(paginated_rows)
  end

  def total_count
    @total_count ||= count_rows
  end

  def total_pages
    @total_pages ||= [ (total_count / per_page.to_f).ceil, 1 ].max
  end

  def has_more?
    page < total_pages
  end

  private

  def news_scope
    NewsPolicy::Scope.new(user, News).resolve
  end

  def feed_subquery
    news = news_scope.select(
      "id AS record_id, 'News' AS record_type, COALESCE(published_at, created_at) AS feed_at"
    )
    events = Event.upcoming.select(
      "id AS record_id, 'Event' AS record_type, created_at AS feed_at"
    )

    Arel::Nodes::TableAlias.new(
      Arel::Nodes::UnionAll.new(news.arel, events.arel),
      "feed_items"
    )
  end

  def paginated_rows
    offset = (page - 1) * per_page
    sql = News.unscoped
      .select("feed_items.record_id, feed_items.record_type, feed_items.feed_at")
      .from(feed_subquery)
      .order("feed_at DESC")
      .limit(per_page)
      .offset(offset)
      .to_sql

    ActiveRecord::Base.connection.select_all(sql).to_a
  end

  def count_rows
    sql = News.unscoped.select("COUNT(*)").from(feed_subquery).to_sql
    ActiveRecord::Base.connection.select_value(sql).to_i
  end

  def hydrate(rows)
    news_ids = rows.filter_map { |row| row["record_id"] if row["record_type"] == "News" }
    event_ids = rows.filter_map { |row| row["record_id"] if row["record_type"] == "Event" }

    news_by_id = News.where(id: news_ids)
      .includes(:user, featured_image_attachment: :blob)
      .index_by(&:id)
    events_by_id = Event.where(id: event_ids)
      .includes(:organizer, :commune)
      .index_by(&:id)

    rows.filter_map do |row|
      record = case row["record_type"]
      when "News" then news_by_id[row["record_id"]]
      when "Event" then events_by_id[row["record_id"]]
      end
      next unless record

      FeedEntry.new(
        record_type: row["record_type"],
        record_id: row["record_id"],
        feed_at: row["feed_at"],
        record: record
      )
    end
  end
end
