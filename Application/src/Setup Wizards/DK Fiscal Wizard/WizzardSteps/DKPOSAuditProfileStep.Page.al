page 6184798 "NPR DK POS Audit Profile Step"
{
    Caption = 'CRO POS Audit Profile Setup';
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
                field("Sale Fiscal No. Series"; Rec."Sale Fiscal No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Sale Fiscal No. Series of the POS Audit Profile.';
                }
                field("Credit Sale Fiscal No. Series"; Rec."Credit Sale Fiscal No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Credit Sale Fiscal No. Series of the POS Audit Profile.';
                }
                field("Balancing Fiscal No. Series"; Rec."Balancing Fiscal No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Balancing Fiscal No. Series of the POS Audit Profile.';
                }
                field("Fill Sale Fiscal No. On"; Rec."Fill Sale Fiscal No. On")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enables the Fill Sale Fiscal No. On for the POS Audit Profile.';
                }
                field("Sales Ticket No. Series"; Rec."Sales Ticket No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Sales Ticket No. Series of the POS Audit Profile.';
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
                field("Allow Zero Amount Sales"; Rec."Allow Zero Amount Sales")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Allow Zero Amount Sales field';
                }
                field("Print Receipt On Sale Cancel"; Rec."Print Receipt On Sale Cancel")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether printing of receipts on POS sale cancel is enabled.';
                }
                field("Do Not Print Receipt on Sale"; Rec."Do Not Print Receipt on Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether printing of receipts on POS sale end is suppressed.';
                }
                field(DoNotPrintEftReceiptOnSale; Rec.DoNotPrintEftReceiptOnSale)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether printing of EFT receipts on POS sale end is suppressed.';
                }
                field("Allow Printing Receipt Copy"; Rec."Allow Printing Receipt Copy")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether printing of receipt copies is enabled.';
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

    internal procedure DKPOSAuditProfileDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePOSAuditProfileData()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if Rec.FindSet() then
            repeat
                POSAuditProfile.TransferFields(Rec);
                if not POSAuditProfile.Insert() then
                    POSAuditProfile.Modify();
            until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    var
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        Rec.SetRange("Audit Handler", DKAuditMgt.HandlerCode());
        Rec.SetRange("Audit Log Enabled", true);

        exit(Rec.FindFirst());
    end;
}