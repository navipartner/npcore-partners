codeunit 85000 "NPR Library - EFT"
{
    trigger OnRun()
    begin
    end;

    procedure CreateMockEFTSetup(var EFTSetup: Record "NPR EFT Setup"; RegisterNo: Text; PaymentType: Text)
    var
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
    begin
        EFTSetup.Init();
        EFTSetup."POS Unit No." := RegisterNo;
        EFTSetup."Payment Type POS" := PaymentType;
        EFTSetup."EFT Integration Type" := EFTTestMockIntegration.IntegrationType();
        EFTSetup.Insert();
    end;


    procedure CreateEFTPaymentTypePOS(var POSPaymentMethod: Record "NPR POS Payment Method"; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store")
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
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
        POSPaymentMethod.Modify();
    end;

    procedure EFTTransactionCleanup(POSUnitNo: Code[10])
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
    begin
        //Delete all previous transactions, so all tests are independent instead of triggering lookup prompts for previous errors when not intended.
        EFTTransactionRequest.SetRange("Register No.", POSUnitNo);
        EFTTransactionRequest.SetRange("Integration Type", EFTTestMockIntegration.IntegrationType());
        EFTTransactionRequest.DeleteAll();
    end;

    procedure CreateBINGroup(var EFTBINGroup: Record "NPR EFT BIN Group"; GroupCode: Code[10]; Description: Text[100]; Priority: Integer)
    begin
        EFTBINGroup.Init();
        EFTBINGroup.Code := GroupCode;
        EFTBINGroup.Description := Description;
        EFTBINGroup.Priority := Priority;
        EFTBINGroup.Insert(true);
    end;

    procedure CreateBINRange(GroupCode: Code[10]; BINFrom: BigInteger; BINTo: BigInteger)
    var
        EFTBINRange: Record "NPR EFT BIN Range";
    begin
        EFTBINRange.Init();
        EFTBINRange."BIN from" := BINFrom;
        EFTBINRange."BIN to" := BINTo;
        EFTBINRange.Validate("BIN Group Code", GroupCode);
        EFTBINRange.Insert(true);
    end;

    procedure CreateBINGroupPaymentLink(GroupCode: Code[10]; PaymentMethodCode: Code[10])
    var
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        EFTBINGroupPaymentLink.Init();
        EFTBINGroupPaymentLink."Group Code" := GroupCode;
        EFTBINGroupPaymentLink."Location Code" := '';
        EFTBINGroupPaymentLink."From Payment Type POS" := '';
        EFTBINGroupPaymentLink."Payment Type POS" := PaymentMethodCode;
        EFTBINGroupPaymentLink.Insert(true);
    end;
}

