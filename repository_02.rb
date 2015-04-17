class AudienceEmailsController < ApplicationController

  def create
    user = User.find(params[:user_id])
    @campaigns =  AudienceCampaignsRepository.available_campaigns(user)

    # do stuff w/ campaigns
  end
end


describe AudienceEmailsController

  let(:campaigns) { FactoryGirl.build_list(:campaign, 20) }

  before do
    allow(AudienceCampaignsRepository).to_receive(:available_campaigns)
                                      .and_return { campaigns }
  end

  it "emails campaign's customers" do
    ...
  end

end
