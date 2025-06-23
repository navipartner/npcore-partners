#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248429 "NPR LoyaltyModuleResolver" implements "NPR API Module Resolver"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'This API is being phased out';

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        LoyaltyAPI: Codeunit "NPR LoyaltyAPI";
    begin
        exit(LoyaltyAPI);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Loyalty');
    end;
}
#endif