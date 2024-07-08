codeunit 6059991 "NPR HL HeyLoyalty Webservice"
{
    Access = Public;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Use API page 6150800 "NPR API - HL Webhook Requests" to handle HeyLoyalty webhook requests instead. It accepts json as payload and does not require proxy Azure functions to run.';

    var
        HLWSMgt: Codeunit "NPR HL Member Webhook Handler";

    procedure UnsubscribeMember(HeyLoyaltyId: Text)
    begin
        HLWSMgt.UnsubscribeMember(HeyLoyaltyId);
    end;

    procedure UpsertMember(HeyLoyaltyId: Text)
    begin
        HLWSMgt.UpsertMember(HeyLoyaltyId);
    end;
}
