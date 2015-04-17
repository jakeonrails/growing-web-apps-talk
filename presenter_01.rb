# View-Model for campaign subheaders
class SubheaderDecorator < Draper::Decorator

  def owner_subheader
    case source.status
    when :active             then active_subheader
    when :suspended          then suspended_subheader
    when :success, :redirect then success_subheader
    when :failed, :archive   then failed_subheader
    else
      ''
    end
  end

  def active_subheader
    return pending_subheader if source.enterprise_state == 'MICRO_PENDING'

    return new_campaign_subheader if source.started_at && source.started_at > 6.hours.ago

    return approved_subheader if source.enterprise_state == 'MICRO_APPROVED'

    default_owner_subheader
  end

  def pending_subheader
    render_subheader(h.render('subheaders/pending'))
  end

  def new_campaign_subheader
    render_subheader(h.render('subheaders/new_campaign', url: source.url, current_user: @user))
  end

  def approved_subheader
    default_owner_subheader
  end

  def default_owner_subheader
    render_subheader(h.render('subheaders/organizer_tools', url: source.url, id: source.id))
  end

  ### /Active

  def suspended_subheader
    render_subheader(h.render('subheaders/suspended'))
  end

  def success_subheader
    render_subheader(h.render('subheaders/success', campaign: source))
  end

  def failed_subheader
    render_subheader(h.render('subheaders/failed', campaign: source))
  end

  def render_subheader(content)
    h.render("buyer/campaigns/#{@version}/subheader",  content: content)
  end

end
