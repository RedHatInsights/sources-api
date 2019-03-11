module OptionRedirectEnhancements
  def serve(req)
    uri = URI.parse(path(req.path_parameters, req))

    req.commit_flash

    body = %(<html><body>You are being <a href="#{ERB::Util.unwrapped_html_escape(uri.to_s)}">redirected</a>.</body></html>)

    headers = {
      "Location" => uri.to_s,
      "Content-Type" => "text/html",
      "Content-Length" => body.length.to_s
    }

    [ status, headers, [body] ]
  end
end

require 'action_dispatch/routing/redirection'
ActionDispatch::Routing::OptionRedirect.prepend(OptionRedirectEnhancements)
