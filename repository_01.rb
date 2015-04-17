class AudienceCampaignsRepository

  def self.available_campaigns(user)
    user.campaigns
        .available
        .select(audience_attributes)
        .where
        .not(shirt_types_array: nil)
  end

  def select_audience_attributes(campaigns)
    [
      "campaigns.id",
      "campaigns.name",
      "campaigns.url",
      "campaigns.campaign_state_id",
      "campaigns.shirt_types_array",
      "campaigns.images_last_updated",
      "campaigns.last_saved",
      "campaigns.hidden",
    ]
  end

end
