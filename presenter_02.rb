class ProductSizeDecorator < Draper::Decorator

  def show_human_model_image_link?
    %w[
      hanes-womens-fitted-tee
      bella-womens-tee
      hanes-tagless-tee
      premium-ringspun-tee
      canvas-ringspun-tee
      american-apparel-crew
      canvas-ringspun-vneck
      american-apparel-triblend
      gildan-unisex-tank
      canvas-ringspun-tank
      american-apparel-tank
      hanes-heavy-blend-full-zip-hoodie
      gildan-kids-tee
    ].include?(anchor_for_human_model_image)
  end

  def anchor_for_human_model_image
    @anchor_for_human_model_image ||= source.
      name.
      gsub(/[^a-zA-Z0-9 ]/, '').
      gsub(/\s+/, '-').
      downcase
  end

  def locale_for_answers
    # English or unknown locales will not change the Answers url
    {
      de: '/de', es: '/es', fr: '/fr', it: '/it', nl: '/nl', :"pt-BR" => '/pt_br'
    }[I18n.locale]
  end

  def url_for_human_model_image
    "http://answers.teespring.com"\
    "/customer#{locale_for_answers}/portal/articles/1774777-sizing-guide-v2"\
    "##{anchor_for_human_model_image}"
  end

  def name_for_select
    "#{source.name} - #{Currency::Formatter.format_currency source.price}"
  end

  def size_names
    source.sizes.map(&:size)
  end

  def dimension_names
    @dimension_names ||= begin
      names = []
      source.sizes.each do |size|
        names << dimensions_hash(size).keys
      end
      names.flatten.uniq
    end
  end

  def dimension_for(size, name)
    dimensions[size][name]
  end

  def dimensions_in_centimeters_for(size, name)
    length = inches_to_centimeters(dimension_as_float(size, name)).round
    "#{length} cm"
  end

  def fit_and_suggestion
    [source.product_fit, source.suggestion].compact.join(". ")
  end

  def fit_details
    details_for(:product_fit, fit_and_suggestion)
  end

  def fabric_details
    details_for(:product_material, source.materials)
  end

  def generic_details
    details_for(:product_details, source.details)
  end

  private

  def dimensions
    @dimensions ||= begin
      dimensions = Hash.new { |h, k| h[k] = {} }
      source.sizes.each do |size|
        dimension_names.each do |name|
          dimensions[size.size][name] = dimensions_hash(size)[name]
        end
      end
      dimensions
    end
  end

  def dimensions_hash(size)
    if size.respond_to?(:dimensions_hash)
      size.dimensions_hash
    else
      { 'Width' => size.dimensions }
    end
  end

  def i18n(key)
    "buyer.campaigns.v2.campaign.#{key}"
  end

  def details_for(key, value)
    h.content_tag(:p) do
      name = h.t(i18n(key))
      h.content_tag(:b, name) << ': ' << value
    end if value.present?
  end

  def dimension_as_float(size, name)
    dimension_for(size, name).to_f
  end

end
