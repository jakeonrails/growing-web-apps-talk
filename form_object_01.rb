require_relative 'base_form'
require 'locatable'
require 'buyer/shipping_address_changer'

class ShippingForm < BaseForm
  include Locatable
  include Shippable
  include AddressCorrector

  def self.fields
    %i(country address address2 city province state zip firstname lastname phone)
  end

  attr_accessor(*fields)

  def initialize(parent, attrs)
    super(attrs)
    @parent = parent
  end

  validates :country, :address, :city, presence: true

  validates :address,
    format: { with: /(?:\d|^p\.?o\.?\s)/i },
    if: proc { |shipping| shipping.country.to_s.downcase == 'united states' },
    allow_blank: true

  validates :address,
    length: {maximum: 40},
    allow_blank: true

  validates :address2,
    length: {maximum: 40},
    allow_blank: true

  validates :state, presence: true, allow_blank: false,
            if: :uses_state?,
            unless: proc { |shipping| shipping.province.present? }

  validates :zip, presence: true,
                  unless: proc { |shipping| shipping.country.to_s.downcase == 'ireland' }

  validates :zip, format: { with: /\A\d{5}(?:-\d{4})?\z/ },
                  if: proc { |shipping| shipping.country.to_s.downcase == 'united states' },
                  allow_blank: true

  validates :phone,
            format: { with: /\A\d{7,20}\z/ },
            if: proc { |shipping| shipping.country.to_s.downcase != 'united states' }

  def ship_to_other
    false
  end

  def stripe_token
    @parent.stripe_token
  end

  def phone
    @phone.to_s.gsub(/\D/, '')
  end

  def state_or_province
    uses_state? ? @state : @province
  end

  alias_method :ship_address, :address
  alias_method :ship_address2, :address2
  alias_method :ship_city, :city
  alias_method :ship_zip, :zip
  alias_method :ship_country, :country
  alias_method :ship_state, :state_or_province
end
