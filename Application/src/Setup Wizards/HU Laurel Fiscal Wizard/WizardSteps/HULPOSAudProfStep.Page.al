page 6185012 "NPR HU L POS Aud. Prof. Step"
{
    Caption = 'HU Laurel POS Audit Profile Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR POS Audit Profile";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Code of the POS Audit Profile.';
                }
                field("Audit Log Enabled"; Rec."Audit Log Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enables the Audit Log of the POS Audit Profile.';
                }
                field("Audit Handler"; Rec."Audit Handler")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the audit handler to be used with this POS audit profile.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    begin
                        exit(POSAuditLogMgt.LookupAuditHandler(Text));
                    end;
                }
                field("Require Item Return Reason"; Rec."Require Item Return Reason")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Prompts for return reason when returning items in POS';
                }
            }
        }
    }
    internal procedure CopyRealToTemp()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if POSAuditProfile.FindSet() then
            repeat
                Rec.TransferFields(POSAuditProfile);
                if not Rec.Insert() then
                    Rec.Modify();
            until POSAuditProfile.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
    begin
        Rec.SetRange("Audit Log Enabled", true);
        Rec.SetRange("Audit Handler", HULAuditMgt.HandlerCode());
        Rec.SetRange("Require Item Return Reason", true);
        exit(not Rec.IsEmpty());
    end;

    internal procedure CreatePOSAuditProfileData()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            POSAuditProfile.TransferFields(Rec);
            if not POSAuditProfile.Insert() then
                POSAuditProfile.Modify();
        until Rec.Next() = 0;
    end;
}