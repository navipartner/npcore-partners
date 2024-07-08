codeunit 88101 "NPR BCPT Library - EFT"
{
    procedure CreateMockEFTSetup(var EFTSetup: Record "NPR EFT Setup"; RegisterNo: Text; PaymentType: Text)
    var
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
    begin
        EFTSetup.Init();
        EFTSetup."POS Unit No." := CopyStr(RegisterNo, 1, MaxStrLen(EFTSetup."POS Unit No."));
        EFTSetup."Payment Type POS" := CopyStr(PaymentType, 1, MaxStrLen(EFTSetup."Payment Type POS"));
        EFTSetup."EFT Integration Type" := EFTTestMockIntegration.IntegrationType();
        EFTSetup.Insert();
    end;
}

