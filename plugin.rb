# name: discourse-x-large-card
# about: Force summary_large_image when any preview image exists (core-style override)
# version: 0.4
# author: TheFacto.ORG
# url: https://github.com/MHAT-DEV/discourse-x-large-card
# transpile_js: true

after_initialize do
  reloadable_patch do |plugin|
    ApplicationHelper.module_eval do

      def crawlable_meta_data(opts = nil)
        opts ||= {}
        opts[:url] ||= "#{Discourse.base_url_no_prefix}#{request.fullpath}"

        # === core logic เดิม: เตรียม image ===
        if opts[:image].blank?
          opts[:image] = SiteSetting.site_opengraph_image_url
        end

        opts[:image] = get_absolute_image_url(opts[:image]) if opts[:image].present?

        # === render meta ===
        result = []
        result << tag(:meta, property: 'og:site_name', content: SiteSetting.title)

        # === 🔥 จุดเปลี่ยนสำคัญ ===
        # ถ้ามี image ไม่ว่ามาจากไหน → large เสมอ
        if opts[:image].present?
          result << tag(:meta, name: 'twitter:card', content: "summary_large_image")
          result << tag(:meta, name: 'twitter:image', content: opts[:image])
          result << tag(:meta, property: "og:image", content: opts[:image])
        else
          result << tag(:meta, name: 'twitter:card', content: "summary")
        end

        # === ส่วนอื่นคงเดิมทั้งหมด ===
        [:url, :title, :description].each do |property|
          if opts[property].present?
            content =
              property == :url ? opts[property] : gsub_emoji_to_unicode(opts[property])

            result << tag(:meta, { property: "og:#{property}", content: content }, nil, true)
            result << tag(:meta, { name: "twitter:#{property}", content: content }, nil, true)
          end
        end

        if opts[:read_time] && opts[:read_time] > 0 &&
           opts[:like_count] && opts[:like_count] > 0
          result << tag(:meta, name: 'twitter:label1', value: I18n.t("reading_time"))
          result << tag(:meta, name: 'twitter:data1', value: "#{opts[:read_time]} mins 🕑")
          result << tag(:meta, name: 'twitter:label2', value: I18n.t("likes"))
          result << tag(:meta, name: 'twitter:data2', value: "#{opts[:like_count]} ❤")
        end

        if opts[:published_time]
          result << tag(:meta, property: 'article:published_time', content: opts[:published_time])
        end

        if opts[:ignore_canonical]
          result << tag(:meta, property: 'og:ignore_canonical', content: true)
        end

        result.join("\n")
      rescue => e
        Rails.logger.warn("[discourse-x-large-card] #{e.class}: #{e.message}")
        super(opts)
      end

    end
  end
end
