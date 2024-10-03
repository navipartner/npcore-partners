page 6184827 "NPR NO Cert Upload Step"
{
    Caption = 'NO Certificate Upload';
    PageType = CardPart;
    SourceTable = "NPR NO Fiscalization Setup";
    SourceTableTemporary = true;
    Extensible = false;
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            group(SignCertificate)
            {
                Caption = 'Sign Certificate';
                field("Signing Certificate Password"; Rec."Signing Certificate Password")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Provide the password for the signing certificate.';
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'The thumbprint of the signing certificate.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    internal procedure CopyRealToTemp()
    begin
        if not NOFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(NOFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateCertificateData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not NOFiscalizationSetup.Get() then
            NOFiscalizationSetup.Init();
        if Rec."Signing Certificate Password" <> xRec."Signing Certificate Password" then
            NOFiscalizationSetup."Signing Certificate Password" := Rec."Signing Certificate Password";
        if Rec."Signing Certificate Thumbprint" <> xRec."Signing Certificate Thumbprint" then
            NOFiscalizationSetup."Signing Certificate Thumbprint" := Rec."Signing Certificate Thumbprint";
        if not NOFiscalizationSetup.Insert() then
            NOFiscalizationSetup.Modify();
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Format(Rec."Signing Certificate Password") <> '') or
               (Format(Rec."Signing Certificate Thumbprint") <> '') then
                exit(true);
        until Rec.Next() = 0;

        exit(false);
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    var
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
}
