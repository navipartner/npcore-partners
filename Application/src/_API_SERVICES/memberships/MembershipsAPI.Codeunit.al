#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185113 "NPR MembershipsAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    var
        SubscriptionPmtMethods: Codeunit "NPR API SubscriptionPmtMethods";
    begin
        if Request.Paths().Contains('paymentmethods') then
            exit(SubscriptionPmtMethods.Handle(Request));
    end;
}
#endif