codeunit 85000 "NPR Library - EFT"
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


    procedure CreateEFTPaymentTypePOS(var POSPaymentMethod: Record "NPR POS Payment Method"; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store")
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
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

        POSPaymentMethod."EFT Surcharge Service Item No." := SurchargeItem."No.";
        POSPaymentMethod."EFT Tip Service Item No." := TipItem."No.";
        POSPaymentMethod.Modify;
    end;
}

