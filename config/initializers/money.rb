MoneyRails.configure do |config|
  config.default_currency = :brl

  # O banco armazena o valor real em decimal (não centavos),
  # então desativamos a coluna de currency gerada automaticamente.
  config.amount_column = {
    postfix: "",
    type: :decimal,
    present: true,
    null: false,
    default: 0
  }

  config.currency_column = { present: false }

  config.rounding_mode = BigDecimal::ROUND_HALF_UP
  config.locale_backend = nil
end
