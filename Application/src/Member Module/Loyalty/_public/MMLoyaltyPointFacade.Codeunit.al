codeunit 6184727 "NPR MM Loyalty Point Facade"
{
    procedure CalculatePointsForTransactions(MembershipEntryNo: Integer; ReferenceDate: Date; ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Decimal; AmountBase: Decimal; AmountIsDiscounted: Boolean; SalesChannel: Code[20]; var AwardedAmount: Decimal; var AwardedPoints: Integer; var PointsEarned: Integer; RuleReference: Integer): Integer
    var
        LoyaltyPointMgt: Codeunit "NPR MM Loyalty Point Mgt.";
    begin
        exit(LoyaltyPointMgt.CalculatePointsForTransactions(MembershipEntryNo, ReferenceDate, ItemNo, VariantCode, Quantity, AmountBase, AmountIsDiscounted, SalesChannel, AwardedAmount, AwardedPoints, PointsEarned, RuleReference));
    end;

    procedure GetLoyaltyEndpointCode(PosUnitNo: Code[10]): Code[10]
    var
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        LoyaltyClientMgr: Codeunit "NPR MM Loy. Point Mgr (Client)";
        ResponseMessage: Text;
    begin
        if LoyaltyClientMgr.GetStoreSetup(PosUnitNo, ResponseMessage, LoyaltyStoreSetup) then
            exit(LoyaltyStoreSetup."Store Endpoint Code")
    end;

    procedure GetLoyaltyEFTIntegrationType(): Code[20]
    var
        MMLoyPointPSPClient: Codeunit "NPR MM Loy. Point PSP (Client)";
    begin
        exit(MMLoyPointPSPClient.IntegrationName());
    end;
}
