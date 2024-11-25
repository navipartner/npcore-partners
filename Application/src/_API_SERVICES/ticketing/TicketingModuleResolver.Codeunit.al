#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185039 "NPR TicketingModuleResolver" implements "NPR API Module Resolver"
{
    Access = Internal;
    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        Ticketing: Codeunit "NPR TicketingApi";
    begin
        exit(Ticketing);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR Ticketing API');
    end;
}
#endif
