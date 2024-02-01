# frozen_string_literal: true

# This module is responsible for getting data
# from the document[:holdings_1display]
module Holdings
  private

  def first_holding
    return {} if holdings.blank?

    holdings&.first&.last
  end

  def second_holding
    return {} if holdings.blank?

    second_holding = holdings[1]
    second_holding ? second_holding&.last : {}
  end

  def first_call_number
    first_holding['call_number']
  end

  def second_call_number
    second_holding['call_number']
  end

  def first_library
    first_holding['library']
  end

  def second_library
    second_holding['library']
  end

  def holdings
    @holdings ||= begin
      holdings_string = document[:holdings_1display]
      if holdings_string.blank?
        nil
      else
        JSON.parse(holdings_string).to_a
      end
    end
  end
end
