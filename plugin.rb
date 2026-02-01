# name: discourse-x-large-card
# about: Override only twitter:card to summary_large_image when image exists
# version: 1.1
# author: TheFacto.ORG
# url: https://github.com/MHAT-DEV/discourse-x-large-card
# transpile_js: true

after_initialize do
  module ::XLargeCardPatch
    OG_OR_TW_IMAGE_REGEX = /
      <meta\s+
      (?:property=["']og:image(?:[:\w]+)?["']|
       name=["']twitter:image(?:[:\w]+)?["'])
      \s+content=["']([^"']+)["']
      [^>]*>
    /ix

    TWITTER_CARD_REGEX = /
      <meta\s+
      name=["']twitter:card["']
      \s+content=["'][^"']+["']
      [^>]*>
    /ix

    def crawlable_meta_data(opts = nil)
      html = super(opts || {})

      return html unless respond_to?(:tag)

      # ตรวจว่ามี image สำหรับ preview หรือไม่
      has_preview_image = html.match?(OG_OR_TW_IMAGE_REGEX)
      return html unless has_preview_image

      # ถ้ามี twitter:card อยู่แล้ว → แทนที่เฉพาะ content
      if html.match?(TWITTER_CARD_REGEX)
        html = html.gsub(
          TWITTER_CARD_REGEX,
          tag(:meta, name: "twitter:card", content: "summary_large_image")
        )
      else
        # ถ้า core ไม่ใส่มา → ใส่เพิ่ม
        html << "\n" << tag(
          :meta,
          name: "twitter:card",
          content: "summary_large_image"
        )
      end

      html
    rescue => e
      Rails.logger.warn(
        "[discourse-x-large-card] PARTIAL OVERRIDE FAILED: #{e.class} #{e.message}"
      )
      html
    end
  end

  ::ApplicationHelper.prepend(::XLargeCardPatch)
end
