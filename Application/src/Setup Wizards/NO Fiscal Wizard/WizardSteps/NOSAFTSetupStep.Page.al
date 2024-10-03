page 6184792 "NPR NO SAFT Setup Step"
{
    Caption = 'NO SAF-T Setup';
    PageType = CardPart;
    SourceTable = "NPR NO Fiscalization Setup";
    SourceTableTemporary = true;
    Extensible = false;
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            group(SAFTCash)
            {
                Caption = 'SAF-T Setup';
                field("SAF-T Audit File Sender"; Rec."SAF-T Audit File Sender")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the SAF-T Audit File Sender.';
                }
                field("SAF-T Contact No."; Rec."SAF-T Contact No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the SAF-T Contact No.';
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

    internal procedure CreateSAFTData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not NOFiscalizationSetup.Get() then
            NOFiscalizationSetup.Init();
        if Rec."SAF-T Audit File Sender" <> xRec."SAF-T Audit File Sender" then
            NOFiscalizationSetup."SAF-T Audit File Sender" := Rec."SAF-T Audit File Sender";
        if Rec."SAF-T Contact No." <> xRec."SAF-T Contact No." then
            NOFiscalizationSetup."SAF-T Contact No." := Rec."SAF-T Contact No.";
        if not NOFiscalizationSetup.Insert() then
            NOFiscalizationSetup.Modify();
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.Get() then
            exit(false);
        exit((Format(Rec."SAF-T Audit File Sender") <> '') and (Format(Rec."SAF-T Contact No.") <> ''))
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    var
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
}