ActionDispatch::ExceptionWrapper.rescue_responses.merge!(
  "Pundit::NotAuthorizedError"              => :forbidden,
  "Insights::API::Common::EntitlementError" => :forbidden,
  "KeyError"                                => :unauthorized,
  "Insights::API::Common::IdentityError"    => :unauthorized
)
