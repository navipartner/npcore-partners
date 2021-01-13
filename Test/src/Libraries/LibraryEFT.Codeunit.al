codeunit 50001 "NPR Library - EFT"
{
    trigger OnRun()
    begin
    end;

    procedure CreateMockEFTSetup(var EFTSetup: Record "NPR EFT Setup"; RegisterNo: Text; PaymentType: Text)
    var
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
    begin
        EFTSetup.Init;
        EFTSetup."POS Unit No." := RegisterNo;
        EFTSetup."Payment Type POS" := PaymentType;
        EFTSetup."EFT Integration Type" := EFTTestMockIntegration.IntegrationType();
        EFTSetup.Insert;
    end;

    procedure CreateEFTPaymentTypePOS(var PaymentTypePOS: Record "NPR Payment Type POS"; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store")
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSPaymentMethod: Record "NPR POS Payment Method";
        LibraryERM: Codeunit "Library - ERM";
        SurchargeItem: Record Item;
        TipItem: Record Item;
    begin
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::EFT, '', false);

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(TipItem, POSUnit, POSStore);
        TipItem.Validate(Type, TipItem.Type::Service);
        TipItem.Modify(true);

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(SurchargeItem, POSUnit, POSStore);
        SurchargeItem.Validate(Type, SurchargeItem.Type::Service);
        SurchargeItem.Modify(true);

        PaymentTypePOS.Get(POSPaymentMethod.Code);
        PaymentTypePOS."EFT Surcharge Service Item No." := SurchargeItem."No.";
        PaymentTypePOS."EFT Tip Service Item No." := TipItem."No.";
        PaymentTypePOS."Auto End Sale" := true;
        PaymentTypePOS.Modify;
    end;
}

