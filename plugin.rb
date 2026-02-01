# name: discourse-x-large-card
# about: Forces X (Twitter) to use summary_large_image card when possible
# version: 0.3
# author: TheFacto.ORG
# url: https://github.com/MHAT-DEV/discourse-x-large-card
# transpile_js: true

after_initialize do
  module ::XLargeCardPatch
    def crawlable_meta_data(opts = nil)
      opts ||= {}

      # เรียก core เดิมก่อนเสมอ
      html = super(opts)

      return html unless respond_to?(:tag)

      x_image =
        opts[:twitter_summary_large_image].presence ||
        opts[:image].presence ||
        SiteSetting.site_twitter_summary_large_image_url.presence ||
        SiteSetting.site_opengraph_image_url.presence

      return html if x_image.blank?

      if respond_to?(:get_absolute_image_url)
        x_image = get_absolute_image_url(x_image)
      end

      # ป้องกัน meta ซ้ำ
      unless html.include?("twitter:card")
        html << "\n" << tag(:meta, name: "twitter:card", content: "summary_large_image")
      end

      unless html.include?("twitter:image")
        html << "\n" << tag(:meta, name: "twitter:image", content: x_image)
      end

      html
    rescue => e
      Rails.logger.warn("[discourse-x-large-card] #{e.class}: #{e.message}")
      super(opts)
    end
  end

  ::ApplicationHelper.prepend(XLargeCardPatch)
end
