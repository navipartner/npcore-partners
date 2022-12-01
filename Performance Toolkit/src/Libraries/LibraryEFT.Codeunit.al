codeunit 88101 "NPR Library - EFT"
{
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
}

