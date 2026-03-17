class AnalyticsController < ApplicationController
  
  # app/controllers/analytics_controller.rb
  # def experiment_stats_hero_button_color_test
  #   @target_experiment = "hero_button_color_test" 

  #   @hero_test_stats = PageViewEvent.where("metadata->>'experiment_name' = ?", @target_experiment)
  #     .select(
  #       "metadata->>'variant' AS variant",
  #       "metadata->>'event_name' AS btn_name",
  #       "COUNT(DISTINCT page_view_id) FILTER (WHERE event_type = 'experiment_impression') AS impressions",
  #       "COUNT(CASE WHEN event_type = 'click' THEN 1 END) AS clicks"
  #     )
  #     .group("metadata->>'variant'", "metadata->>'event_name'")
  #     .group_by(&:variant)

  #    @bayesian_results = calculate_bayesian(@hero_test_stats) 
  # end
  def experiment_stats_hero_button_color_test
    @target_experiment = "hero_button_color_test" 

    # We use a subquery or a direct join to ensure we get the visitor_id 
    # even if the record was created anonymously
    @hero_test_stats = PageViewEvent
      .joins(:page_view)
      .where("page_view_events.metadata->>'experiment_name' = ?", @target_experiment)
      .select(
        "page_view_events.metadata->>'variant' AS variant",
        "page_view_events.metadata->>'event_name' AS btn_name",
        # Count the unique visitor IDs associated with the impressions
        "COUNT(DISTINCT page_views.visitor_id) FILTER (WHERE event_type = 'experiment_impression') AS impressions",
        # Count the unique visitor IDs associated with the clicks
        "COUNT(DISTINCT page_views.visitor_id) FILTER (WHERE event_type = 'click') AS clicks"
      )
      .group("page_view_events.metadata->>'variant'", "page_view_events.metadata->>'event_name'")
      .to_a

    @bayesian_results = calculate_bayesian(@hero_test_stats) 
  end

  def scroll_stats
    events = PageViewEvent.joins(:page_view).where(event_type: "scroll")

    # --- Psychologist profile pages ---
psych_stats = events
  .where("page_views.url ~ ?", %r{^/(?:en|ru|kg)?/psychologist_profiles/\d+$}.source)
  .select(
    Arel.sql("substring(page_views.url from '/psychologist_profiles/([0-9]+)$')::int AS profile_id"),
    Arel.sql("regexp_replace(page_views.url, '^/(en|ru|kg)/', '/', 'g') AS normalized_url"),
    Arel.sql("AVG((metadata->>'scroll_percent')::float) AS avg_scroll"),
    Arel.sql("psychologist_profiles.first_name"),
    Arel.sql("psychologist_profiles.last_name")
  )
  .joins("LEFT JOIN psychologist_profiles ON psychologist_profiles.id = 
          substring(page_views.url from '/psychologist_profiles/([0-9]+)$')::int")
  .group("normalized_url, profile_id, psychologist_profiles.first_name, psychologist_profiles.last_name")
  .map do |record|
    {
      url: record.normalized_url,
      label: "##{record.profile_id} #{record.first_name} #{record.last_name}",
      avg_scroll: record.avg_scroll.to_f.round(1)
    }
  end





    # --- Other pages normalized ---
    other_stats = events
      .where.not("page_views.url ~ ?", %r{^/psychologist_profiles/\d+$}.source)
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

  # def calculate_bayesian(stats)
  #   # 1. Aggregate totals for Variant A and B
  #   data = {}
  #   ["A", "B"].each do |v|
  #     results = stats[v] || []
  #     clicks = results.sum { |r| r.clicks.to_i }
  #     imps = results.sum { |r| r.impressions.to_i }
  #     # Alpha = Clicks + 1 | Beta = (Impressions - Clicks) + 1
  #     data[v] = { a: clicks + 1.0, b: (imps - clicks) + 1.0 }
  #   end

  #   # 2. Run Simulation
  #   b_wins = 0
  #   simulations = 10_000

  #   simulations.times do
  #     sample_a = beta_sample(data["A"][:a], data["A"][:b])
  #     sample_b = beta_sample(data["B"][:a], data["B"][:b])
  #     b_wins += 1 if sample_b > sample_a
  #   end

  #   { prob_b_better: (b_wins.to_f / simulations * 100).round(2) }
  # end
  

  def calculate_bayesian(stats)
    data = {}
    
    # 1. Convert the array from the query into a Hash grouped by "A" and "B"
    grouped_stats = stats.group_by(&:variant)

    ["A", "B"].each do |v|
      results = grouped_stats[v] || []
      
      # 2. Sum the 'clicks' and 'impressions' using the new names from your SQL
      clicks_count = results.sum { |r| r.clicks.to_i }
      imps_count   = results.sum { |r| r.impressions.to_i }

      # 3. Alpha = Success + 1 | Beta = (Total - Success) + 1
      # We use .abs to prevent negative numbers if tracking is slightly off
      data[v] = { 
        a: clicks_count + 1.0, 
        b: (imps_count - clicks_count).abs + 1.0 
      }
    end

    # --- Simulation Logic (This part stays the same) ---
    b_wins = 0
    simulations = 10_000

    simulations.times do
      sample_a = beta_sample(data["A"][:a], data["A"][:b])
      sample_b = beta_sample(data["B"][:a], data["B"][:b])
      b_wins += 1 if sample_b > sample_a
    end

    { prob_b_better: (b_wins.to_f / simulations * 100).round(2) }
  end

  # 3. The Math: Sampling from Beta(a, b)
  # A Beta(a, b) random variable can be generated by:
  # X = Gamma(a) / (Gamma(a) + Gamma(b))
  def beta_sample(a, b)
    ga = gamma_sample(a)
    gb = gamma_sample(b)
    ga / (ga + gb)
  end

  # Simple Marsaglia-Tsang Gamma sampler
  def gamma_sample(shape)
    if shape < 1.0
      return gamma_sample(shape + 1.0) * (rand**(1.0 / shape))
    end

    d = shape - 1.0 / 3.0
    c = 1.0 / Math.sqrt(9.0 * d)
    
    loop do
      x = 0
      v = 0
      
      # Generate a valid v
      loop do
        x = normal_sample
        v = (1.0 + c * x)**3
        break if v > 0
      end

      u = rand
      x2 = x * x
      x4 = x2 * x2

      # 1. The Fast "Squeeze" Step (Using x here)
      return d * v if u < 1.0 - 0.0331 * x4

      # 2. The Full Log Likelihood Check (Using x here)
      if Math.log(u) < 0.5 * x2 + d * (1.0 - v + Math.log(v))
        return d * v
      end
    end
  end

  # Box-Muller transform for Normal Distribution
  def normal_sample
    # Use Math::PI (constant) instead of Math.PI (method)
    Math.sqrt(-2.0 * Math.log(rand)) * Math.cos(2.0 * Math::PI * rand)
  end

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
