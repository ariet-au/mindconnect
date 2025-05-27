# config/initializers/money.rb

MoneyRails.configure do |config|
  # To set the default currency (uncomment and modify if needed)
  # config.default_currency = :usd # Example: config.default_currency = :kgs

  # Configure default amount column settings for `add_money` migration helper
  # and for inferring column names when `monetize` is used without explicit options.
  # This section does NOT directly affect how `as_subunit: false` works,
  # but sets the default expectations if you don't use `as_subunit: false` or
  # if you use `add_money` in migrations.
  config.amount_column = {
    # postfix: '_money', # This would mean `monetize :price` looks for `price_money` column.
                        # If you want `monetize :price` to look for a `price` column, use '' or nil.
    postfix: '',        # To use column names like 'price' instead of 'price_cents' or 'price_money'
    type: :decimal,     # Default column type will be decimal
    default: 0.0,       # Use 0.0 for decimal default to prevent integer truncation
    present: true,      # Column will be created (for migrations)
    null: false         # Ensures the column is not nullable by default
    # REMOVED: subunit_to_unit: 1 (This is for currency definition, not amount_column config)
    # REMOVED: value_parser (Not a valid config.amount_column option)
  }

  # Ensure your database migrations properly define decimal columns with precision and scale:
  # Example: add_column :your_table, :your_money_column, :decimal, precision: 10, scale: 2

  # Optional: Register a custom currency or override a standard one.
  # This is where `subunit_to_unit` belongs if you need to define it.
  # KGS (Kyrgyzstani Som) is a standard ISO currency with 100 subunits,
  # so you typically don't need to register it unless you're overriding something.
  # config.register_currency = {
  #   priority:            100,
  #   iso_code:            "KGS",
  #   name:                "Kyrgyzstani Som",
  #   symbol:              "сом",
  #   symbol_first:        false,
  #   subunit:             "Tyiyn",
  #   subunit_to_unit:     100, # This is the CORRECT place for subunit_to_unit for KGS
  #   decimal_mark:        ".",
  #   thousands_separator: ","
  # }

  # Set default money format globally.
  # Default value is nil meaning "ignore this option".
  config.default_format = {
    # If you want to ALWAYS show decimals (e.g., "50.00"), set no_cents_if_whole to false.
    # Your current setting `true` means "hide cents if it's a whole number" (e.g., "50").
    no_cents_if_whole: true, # Changed to false to always show decimals
    symbol: true,             # Show currency symbol
    sign_before_symbol: true  # Show - before $
  }

  # Set default bank object (uncomment and modify if needed)
  # config.default_bank = EuCentralBank.new

  # Add exchange rates to current money bank object.
  # (The conversion rate refers to one direction only)
  # Example:
  # config.add_rate "USD", "CAD", 1.24515
  # config.add_rate "CAD", "USD", 0.803115

  # To handle the inclusion of validations for monetized fields (default is true)
  # config.include_validations = true

  # Specify a rounding mode (BigDecimal::ROUND_HALF_EVEN by default)
  # config.rounding_mode = BigDecimal::ROUND_HALF_UP

  # Set whether an error should be raised when parsing money values (default is false)
  # config.raise_error_on_money_parsing = true
end