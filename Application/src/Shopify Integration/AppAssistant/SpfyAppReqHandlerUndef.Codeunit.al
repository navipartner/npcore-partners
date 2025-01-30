#if not BC17
codeunit 6248245 "NPR Spfy AppReq.Handler: Undef" implements "NPR Spfy App Request IHndlr"
{
    Access = Internal;

    procedure ProcessAppRequest(var SpfyAppRequest: Record "NPR Spfy App Request")
    begin
        ThrowNoHandlerError(SpfyAppRequest.Type);
    end;

    procedure NavigateToRelatedBCEntity(SpfyAppRequest: Record "NPR Spfy App Request")
    begin
        ThrowNoHandlerError(SpfyAppRequest.Type);
    end;

    local procedure ThrowNoHandlerError(RequestType: Enum "NPR Spfy App Request Type")
    var
        NoHandlerErr: Label 'There is no handler registered in the system for Shopify app requests of type "%1"', Comment = '%1 - Shopify app request type';
    begin
        Error(NoHandlerErr, RequestType);
    end;
}
#endif