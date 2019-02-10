module RedminePluginWithAssets
  module Hooks
    class AdminMenuVaultHooks < Redmine::Hook::ViewListener
      include ActionView::Helpers::TagHelper

      def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('vault', :plugin => 'vault')
      end
    end
  end
end