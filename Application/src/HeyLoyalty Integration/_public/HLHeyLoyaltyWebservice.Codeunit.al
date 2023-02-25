codeunit 6059991 "NPR HL HeyLoyalty Webservice"
{
    Access = Public;

    var
        HLWSMgt: Codeunit "NPR HL HeyLoyalty WS Mgt.";

    procedure UnsubscribeMember(HeyLoyaltyId: Text)
    begin
        HLWSMgt.UnsubscribeMember(HeyLoyaltyId);
    end;

    procedure UpsertMember(HeyLoyaltyId: Text)
    begin
        HLWSMgt.UpsertMember(HeyLoyaltyId);
    end;
}