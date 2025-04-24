module ApplicationHelper
  # Returns the application page name, configurable via PAGE_NAME env var
  def page_name
    ENV.fetch('PAGE_NAME', 'Weather Lookup')
  end
end
