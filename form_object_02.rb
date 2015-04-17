require 'sanitize'
require_relative 'base_form'
require_relative 'shipping_form'

class CampaignEditForm < BaseForm
  def self.fields
    %i(
      name
      description
      allow_pickup
      pickup_instructions
      firstname
      lastname
      shipping_attributes
      tags
      default_side
    )
  end

  attr_accessor(*fields)

  def shipping
    @shipping ||= ShippingForm.new(self, country: "United States")
  end

  def allow_pickup=(allow_pickup)
    @allow_pickup = allow_pickup.to_i
  end

  def allow_pickup?
    @allow_pickup.to_i != 0
  end

  def name=(name)
    @name = Sanitize.clean(name)
  end

  def description=(description)
    @description = Sanitize.clean(description, Campaign::SANITIZE_DESCRIPTION)
  end

  def shipping_attributes=(attrs)
    if attrs
      @shipping = ShippingForm.new(self, attrs)
    end
  end

  def completed_orders=(completed_orders)
    @completed_orders = completed_orders
  end

  def completed_orders?
    @completed_orders
  end

  def tags=(tags)
    @tags = tags.to_s.split(',').reject(&:blank?).uniq.join(',')
  end

  validates :name, :description, presence: true

  validates :name, length: {
    maximum: 40,
    too_long: I18n.t('seller.dashboard.campaign_edit_form.too_long'),
  }

  validates :description, length: {
    maximum: 2500,
    too_long: I18n.t('seller.dashboard.campaign_edit_form.too_long'),
  }

  validates :pickup_instructions, length: {
    maximum: 500,
    too_long: I18n.t('seller.dashboard.campaign_edit_form.too_long'),
  }

  validate :too_many_tags

  validate :proper_pickup_info, if: :allow_pickup?

  private

  def too_many_tags
    if tags.present? && tags.split(",").count > 5
      errors[:tags] = I18n.t('seller.dashboard.campaign_edit_form.no_more_than_five')
    end
  end

  def proper_pickup_info
    if pickup_instructions.empty?
      errors[:pickup_instructions] = I18n.t('seller.dashboard.campaign_edit_form.must_include_pickup')
    end

    if shipping.invalid?
      shipping.errors.each do |key, values|
        errors[:"shipping_#{key}"] = values
      end
    end

    if firstname.blank?
      errors[:firstname] = I18n.t('seller.dashboard.campaign_edit_form.if_picking_up')
    end

    if lastname.blank?
      errors[:lastname] = I18n.t('seller.dashboard.campaign_edit_form.if_picking_up')
    end
  end

end
