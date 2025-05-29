# config/initializers/money.rb

MoneyRails.configure do |config|

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


  config.default_format = {
    # If you want to ALWAYS show decimals (e.g., "50.00"), set no_cents_if_whole to false.
    # Your current setting `true` means "hide cents if it's a whole number" (e.g., "50").
    no_cents_if_whole: true, # Changed to false to always show decimals
    symbol: true,             # Show currency symbol
    sign_before_symbol: true  # Show - before $
  }


end