codeunit 6185112 "NPR EFT Card Detection"
{
    Access = public;

    procedure DetectBIN(CardNumber: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    begin
        DetectBIN(CardNumber, POSPaymentMethod, '');
    end;

    procedure DetectBIN(CardNumber: Text; var POSPaymentMethod: Record "NPR POS Payment Method"; LocationCode: Text): Boolean
    var
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        Exit(EFTPaymentMapping.MatchBIN(CardNumber, LocationCode, POSPaymentMethod));
    end;

    procedure DetectApplicationID(CardApplicationID: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    begin
        DetectApplicationID(CardApplicationID, POSPaymentMethod, '');
    end;

    procedure DetectApplicationID(CardApplicationID: Text; var POSPaymentMethod: Record "NPR POS Payment Method"; LocationCode: Text): Boolean
    var
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        Exit(EFTPaymentMapping.MatchApplicationID(CardApplicationID, LocationCode, POSPaymentMethod));
    end;
}