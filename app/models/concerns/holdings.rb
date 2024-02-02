# frozen_string_literal: true

# This module is responsible for getting data
# from the document[:holdings_1display] and
# document[:id]
module Holdings
  private

  [:first, :second].each do |number|
    # Create the first_call_number and second_call_number methods
    define_method "#{number}_call_number" do
      send(:"#{number}_holding")['call_number']
    end

    # Create the first_library and second_library methods
    define_method "#{number}_library" do
      send(:"#{number}_holding")['library']
    end

    # Create the first_status and second_status methods
    define_method "#{number}_status" do
      return unless send(:"#{number}_holding")['library']

      'On-site access' if coin? || senior_thesis?
    end
  end

  def first_holding
    @first_holding ||= if holdings.blank?
                         {}
                       else
                         holdings&.first&.last
                       end
  end

  def second_holding
    @second_holding ||= if holdings.blank?
                          {}
                        else
                          second_holding = holdings[1]
                          second_holding ? second_holding&.last : {}
                        end
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

  def coin?
    document[:id].start_with? 'coin-'
  end

  def senior_thesis?
    document[:id].start_with? 'dsp'
  end
end
