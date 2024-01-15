codeunit 6184727 "NPR MM Loyalty Point Facade"
{
    procedure CalculatePointsForTransactions(MembershipEntryNo: Integer; ReferenceDate: Date; ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Decimal; AmountBase: Decimal; AmountIsDiscounted: Boolean; SalesChannel: Code[20]; var AwardedAmount: Decimal; var AwardedPoints: Integer; var PointsEarned: Integer; RuleReference: Integer): Integer
    var
        LoyaltyPointMgt: Codeunit "NPR MM Loyalty Point Mgt.";
    begin
        exit(LoyaltyPointMgt.CalculatePointsForTransactions(MembershipEntryNo, ReferenceDate, ItemNo, VariantCode, Quantity, AmountBase, AmountIsDiscounted, SalesChannel, AwardedAmount, AwardedPoints, PointsEarned, RuleReference));
    end;
}
