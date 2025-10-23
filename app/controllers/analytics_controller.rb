class AnalyticsController < ApplicationController
  # def scroll_stats
  #   @stats = PageViewEvent
  #     .joins(:page_view)
  #     .where(event_type: "scroll")
  #     .group(Arel.sql("page_views.url"))
  #     .pluck(
  #       Arel.sql("page_views.url"),
  #       Arel.sql("AVG((metadata->>'scroll_percent')::float)")
  #     )
  #     .map { |url, avg_scroll| { url: url, avg_scroll: avg_scroll.to_f.round(1) } }

  #   respond_to do |format|
  #     format.html
  #     format.json { render json: @stats }
  #   end
  # end

  def scroll_stats
    events = PageViewEvent.joins(:page_view).where(event_type: "scroll")

    # --- Psychologist profile pages ---
    psych_stats = events
      .where("page_views.url LIKE ?", "/psychologist_profiles/%")
      .group("page_views.url")
      .pluck(
        Arel.sql("page_views.url"),
        Arel.sql("AVG((metadata->>'scroll_percent')::float)")
      )
      .map do |url, avg_scroll|
        {
          url: url,
          avg_scroll: avg_scroll.to_f.round(1)   # nil becomes 0.0
        }
      end

    # --- Other pages normalized ---
    other_stats = events
      .where.not("page_views.url LIKE ?", "/psychologist_profiles/%")
      .pluck(
        Arel.sql("page_views.url"),
        Arel.sql("(metadata->>'scroll_percent')::float")
      )
      .group_by { |url, _| normalize_route(url) }
      .map do |route, values|
        # Remove nils (missing scroll values)
        scroll_values = values.map { |_, s| s.to_f } # converts nil to 0.0 safely

        next if scroll_values.empty?

        avg_scroll = scroll_values.sum / scroll_values.size
        { url: route, avg_scroll: avg_scroll.round(1) }
      end
      .compact   # remove any nils from 'next if'

    respond_to do |format|
      format.html
      format.json { render json: { psych_stats: psych_stats, other_stats: other_stats } }
    end
  end


  def page_links
    views = PageView.order(:created_at)

    nodes_map = {}
    links_map = Hash.new { |h,k| h[k] = { count: 0, urls: [] } }
    all_pages_count = Hash.new(0)

    views.group_by(&:session_id).each do |session, page_views|
      page_views.each_cons(2) do |from_view, to_view|
        next if from_view.url.blank? || to_view.url.blank?

        # Normalize and parameterize routes
        from_url = parameterize_route(from_view.url)
        to_url   = parameterize_route(to_view.url)

        from_cat = categorize_route(from_url)
        to_cat   = categorize_route(to_url)

        # Count all pages for the initial table
        all_pages_count[from_url] += 1
        all_pages_count[to_url] += 1

        # Initialize nodes
        nodes_map[from_cat] ||= { id: from_cat, label: from_cat, pages: Set.new, pages_count: Hash.new(0) }
        nodes_map[to_cat]   ||= { id: to_cat, label: to_cat, pages: Set.new, pages_count: Hash.new(0) }

        # Store pages and counts inside nodes
        nodes_map[from_cat][:pages] << from_url
        nodes_map[to_cat][:pages] << to_url
        nodes_map[from_cat][:pages_count][from_url] += 1
        nodes_map[to_cat][:pages_count][to_url] += 1

        # Build links between categories
        key = [from_cat, to_cat]
        links_map[key][:count] += 1
        links_map[key][:urls] << { from: from_url, to: to_url }
      end
    end

    # Convert Set to Array for JSON
    nodes_map.each { |k,v| v[:pages] = v[:pages].to_a }

    links = links_map.map do |(src, tgt), info|
      { source: src, target: tgt, count: info[:count], urls: info[:urls] }
    end

    @graph_data = { nodes: nodes_map.values, links: links }

    # Initial table: all pages sorted by total visits
    @all_pages_sorted = all_pages_count.sort_by { |_, count| -count }.map do |url, count|
      { url: url, visits: count }
    end
  end

  private

  # Replace numeric IDs with :id and normalize route
  def parameterize_route(route)
    route = normalize_route(route)
    route.gsub(%r{/(\d+)}) { "/:id" }
  end

  # Remove locale prefix /en, /ru, /kg
  def normalize_route(route)
    return '' if route.blank?

    # Remove optional locale prefix like /en or /ru
    route = route.sub(%r{^/(en|ru|kg)(/|$)}, '/')

    # Remove query string
    route = route.split('?').first

    # Replace numeric IDs with :id
    route = route.gsub(%r{/(\d+)}, '/:id')

    # Remove format extensions like .json, .html
    route = route.gsub(/\.(json|html)$/, '')

    route
  end

  # Categorize routes for nodes
  def categorize_route(route)
    route = normalize_route(route)

    # Landing / search pages
    return 'Landing/Search' if route.blank? || route == '/' || route == '/find-a-psychologist'
    # Treat listing/search of psychologists as landing/search
    return 'Landing/Search' if route.start_with?('/psychologist_profiles') && route !~ %r{/psychologist_profiles/:id}

    case route
    when %r{^/dashboard} then 'Dashboard'
    when %r{^/booking}, %r{^/book} then 'Bookings'
    when %r{^/service} then 'Services'
    when %r{^/event} then 'Events'
    when %r{^/client_info}, %r{^/client_profile} then 'Clients'
    when %r{^/article} then 'Articles'
    when %r{^/calendar} then 'Calendar'
    when %r{^/quiz} then 'Quizzes'
    when %r{^/psychologist_profiles/:id} then 'Profile'
    when %r{^/for-psychologists}, %r{^/contact-us} then 'Marketing/Contact'
    when %r{^/analytics} then 'Analytics'
    when %r{^/users} then 'Authentication'
    when %r{^/p/} then 'Short Links'
    else 'Other'
    end
  end
end
