class AudienceEmailsController < ApplicationController

  def create
    user = User.find(params[:user_id])
    @campaigns = user.campaigns
                     .available
                     .select(audience_attributes)
                     .where
                     .not(shirt_types_array: nil)
    # Email campaign customers
  end
end

describe AudienceEmailsController do

  let(:campaigns) { FactoryGirl.build_list(:campaign, 5) }

  it 'creates an Audience Email' do
    allow_any_instance_of(User).to receive_message_chain("campaigns.available.select.where.not") { campaigns }
  end

  it "emails campaign's customers" do
    ...
  end
end
