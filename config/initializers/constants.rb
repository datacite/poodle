class IdentifierError < RuntimeError; end

RESCUABLE_EXCEPTIONS = [CanCan::AccessDenied,
                        CanCan::AuthorizationNotPerformed,
                        JWT::DecodeError,
                        JWT::VerificationError,
                        IdentifierError,
                        NotImplementedError,
                        ActionController::RoutingError,
                        ActionController::ParameterMissing,
                        ActionController::UnpermittedParameters,
                        NoMethodError,
                        Encoding::UndefinedConversionError]