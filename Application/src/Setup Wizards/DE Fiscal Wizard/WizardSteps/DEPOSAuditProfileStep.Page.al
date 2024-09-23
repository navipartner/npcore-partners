page 6184751 "NPR DE POS Audit Profile Step"
{
    Caption = 'DE POS Audit Profile Setup';
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
                    ToolTip = 'Specifies the unique code for the POS Audit Profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the short description of profile.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No. Series"; Rec."Sales Ticket No. Series")
                {
                    ToolTip = 'Specifies the number series used for creating the document number.';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Fiscal No. Series"; Rec."Sale Fiscal No. Series")
                {
                    ToolTip = 'Specifies the number series used for creating the fiscal number.';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Sale Fiscal No. Series"; Rec."Credit Sale Fiscal No. Series")
                {
                    ToolTip = 'Specifies whether the items will be searched by their cross reference numbers.';
                    ApplicationArea = NPRRetail;
                }
                field("Balancing Fiscal No. Series"; Rec."Balancing Fiscal No. Series")
                {
                    ToolTip = 'Specifies the number series used for creating the fiscal number for balancing.';
                    ApplicationArea = NPRRetail;
                }
                field("Fill Sale Fiscal No. On"; Rec."Fill Sale Fiscal No. On")
                {
                    ToolTip = 'Specifes at which point the sale fiscal number will be filled. You can choose between All Sale and Successful Sale.';
                    ApplicationArea = NPRRetail;
                }
                field("Audit Log Enabled"; Rec."Audit Log Enabled")
                {
                    ToolTip = 'Create additional logs, usually for VAT.';
                    ApplicationArea = NPRRetail;
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
                    ToolTip = 'Allow the sale to be finalized with the amount zero.';
                    ApplicationArea = NPRRetail;
                }
                field("Print Receipt On Sale Cancel"; Rec."Print Receipt On Sale Cancel")
                {
                    ToolTip = 'Allow receipts to be printed even when the sale is canceled.';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Printing Receipt Copy"; Rec."Allow Printing Receipt Copy")
                {
                    ToolTip = 'Set up whether a copy is printed or not. Available options are: Always, Once, Never.';
                    ApplicationArea = NPRRetail;
                }
                field("Do Not Print Receipt on Sale"; Rec."Do Not Print Receipt on Sale")
                {
                    ToolTip = 'Specifies whether printing of receipts on POS sale end is suppressed.';
                    ApplicationArea = NPRRetail;
                }
                field(DoNotPrintEftReceiptOnSale; Rec.DoNotPrintEftReceiptOnSale)
                {
                    ToolTip = 'Specifies the value of the Do Not Print EFT Receipt on Sale field.';
                    ApplicationArea = NPRRetail;
                }
                field("Require Item Return Reason"; Rec."Require Item Return Reason")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Prompts for return reason when returning items in POS';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.FindSet() then
            exit;

        repeat
            Rec.TransferFields(POSAuditProfile);
            if not Rec.Insert() then
                Rec.Modify();
        until POSAuditProfile.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
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

    local procedure CheckIsDataPopulated(): Boolean
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."Audit Handler" = DEAuditMgt.HandlerCode()) and Rec."Audit Log Enabled" then
                exit(true);
        until Rec.Next() = 0;

        exit(false);
    end;
}