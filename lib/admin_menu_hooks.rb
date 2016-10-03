class AdminMenuHooks < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = {})
    stylesheet_link_tag('vault.css', :plugin => 'vault')
  end
end