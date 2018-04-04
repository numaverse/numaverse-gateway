class Message < ApplicationRecord
  Gutentag::ActiveRecord.call self
  include ActivityStreamable
  include Uuidable

  validates_presence_of :body, :json_schema
  validates_length_of :body, maximum: 280, if: :micro?

  belongs_to :account
  belongs_to :user, optional: true
  has_many :favorites
  has_many :reposts, class_name: 'Message', foreign_key: 'repost_id'
  belongs_to :repost, class_name: 'Message', foreign_key: 'repost_id', optional: true
  has_many :replies, class_name: 'Message', foreign_key: 'reply_to_id'
  belongs_to :reply_to, class_name: 'Message', foreign_key: 'reply_to_id', optional: true
  has_one :federated_message, class_name: 'Federated::Message', foreign_key: 'local_message_id'

  has_many :tips, foreign_key: 'to_message_id', class_name: 'Tip'
  has_one :tip, foreign_key: 'message_id', class_name: 'Tip'

  before_validation :sanitize_html, if: :body_changed?
  after_create :update_repost_count
  after_create :update_reply_count
  after_create :send_notifications
  before_save :fetch_onebox

  enum json_schema: {
    other: 0,
    article: 1,
    micro: 2,
  }

  def sanitize_html
    config = Sanitize::Config::RESTRICTED
    elements = ['a']
    if article?
      elements = Sanitize::Config::BASIC[:elements] + ['div', 'table','h1','h2','h3','h4','h5','h6']
      config = Sanitize::Config.merge(Sanitize::Config::RELAXED, {
        add_attributes: {
          'a' => {'rel' => 'nofollow', 'target' => '_blank'}
        },
        elements: elements,
      })
      html = make_markdown
      html = Sanitize.fragment(html, config)
    elsif micro?
      html = linkify_body
      html = Sanitize.fragment(html, Sanitize::Config.merge(config,
        :elements        => elements,
        :attributes => {
          'a'    => ['href', 'rel', 'class', 'target'],
        },
      ))
    else
      html = body
    end
    

    self.sanitized_body = html
  end

  def generate_foreign_data
    self.foreign_data = {
      web_id: self.id,
      title: title || ''
    }.to_json
  end

  def update_tx_data(save: true)
    return true unless tx_hash

    data = Networker.get_client.eth_get_transaction_by_hash(tx_hash)['result']
    self.tx_data = data
    # ap data
    self.save if save
    if data['blockNumber'].blank? && (DateTime.now < created_at + 2.hours)
      FetchMessageDataJob.set(wait_until: (DateTime.now - created_at).seconds.from_now).perform_later(self)
    end
    data
  end

  def ipfs_json
    activity_stream.data
  end

  def activity_stream
    ActivityPub::Message.new(self)
  end

  def update_repost_count
    return true if repost_id.blank?
    repost.update(repost_count: repost.reposts.reload.count)
  end

  def update_reply_count
    return true if reply_to_id.blank?
    reply_to.update(reply_count: reply_to.replies.reload.count)
  end

  def linkify_body
    WebText.format(body)
  end

  def send_mentions
    usernames = WebText.mentions(body)
    usernames.each do |username|
      account = Account.find_by(username: username)
      next if account.blank? || account&.email.blank?
      NotificationMailer.mention(account, self).deliver_later
    end
  end

  def confirmations
    number = tx.try(:confirmations) || nil
  end

  def make_markdown
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true, 
      no_styles: true, 
      with_toc_data: true, 
      link_attributes: { target: '_blank' }
    )
    markdown = Redcarpet::Markdown.new(renderer, { 
      no_intra_emphasis: true, 
      strikethrough: true, 
      autolink: true, 
      fenced_code_blocks: true,
      highlight: true,
      superscript: true
    })

    html = markdown.render(body)
  end

  def tips_sum
    tips.inject(0) {|sum, tip| sum + tip.value}
  end

  def sender_account
    account
  end

  def update_federated_model
    model = federated_message || Federated::Message.new(local_message: self)
    model.update(
      object_data: activity_stream.object_data, 
      local_account: account,
      federated_account: account.federated_account,
      local_message: self,
      hidden_at: hidden_at,
    )
    model
  end

  def fetch_onebox
    return true unless micro?

    matches = WebText.uri_regex.match(body)
    return true if matches.to_s.blank?

    preview = Onebox.preview(matches.to_s)
    return true if preview.to_s.blank?
    self.onebox = preview.to_s
  end

  def send_notifications
    send_mentions
    if reply_to_id.present? && reply_to.account.email.present?
      NotificationMailer.reply(self).deliver_later
    end
    if repost_id.present? && repost.account.email.present?
      NotificationMailer.repost(self).deliver_later
    end
  end
end
