page 6184829 "NPR DK SAFT Setup Step"
{
    Caption = 'DK SAF-T Setup';
    PageType = CardPart;
    SourceTable = "NPR DK Fiscalization Setup";
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
        if not DKFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(DKFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateSAFTData()
    begin
        if not Rec.Get() then
            exit;
        if not DKFiscalizationSetup.Get() then
            DKFiscalizationSetup.Init();
        if Rec."SAF-T Audit File Sender" <> xRec."SAF-T Audit File Sender" then
            DKFiscalizationSetup."SAF-T Audit File Sender" := Rec."SAF-T Audit File Sender";
        if Rec."SAF-T Contact No." <> xRec."SAF-T Contact No." then
            DKFiscalizationSetup."SAF-T Contact No." := Rec."SAF-T Contact No.";
        if not DKFiscalizationSetup.Insert() then
            DKFiscalizationSetup.Modify();
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if Rec.Get() then
            exit(false);
        exit((Format(Rec."SAF-T Audit File Sender") <> '') and (Format(Rec."SAF-T Contact No.") <> ''))
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
}
