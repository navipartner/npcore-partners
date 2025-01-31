page 6150626 "NPR POS Audit Profile"
{
    Extensible = False;
    Caption = 'POS Audit Profile';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/reference/audit_prof/audit_prof/';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Audit Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                    ToolTip = 'If the Audit Log Enabled is checked, use this field to choose which log will be created.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    begin
                        exit(POSAuditLogMgt.LookupAuditHandler(Text));
                    end;

                    trigger OnValidate()
                    begin
                        if xRec."Audit Handler" = Rec."Audit Handler" then
                            exit;
                        SetAllowSalesAndReturnInSameTransEnabled();
                    end;
                }
                field("Allow Zero Amount Sales"; Rec."Allow Zero Amount Sales")
                {
                    ToolTip = 'Allow the sale to be finalized with the amount zero.';
                    ApplicationArea = NPRRetail;
                }

                field("Require Item Return Reason"; Rec."Require Item Return Reason")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Prompts for return reason when returning items in POS';
                }
                field(AllowSalesAndReturnInSameTrans; Rec.AllowSalesAndReturnInSameTrans)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether sales and returns lines are allowed in the same sale transaction.';
                    Enabled = AllowSalesAndReturnInSameTransEnabled;
                }
            }
            group(Printing)
            {
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
            }
            group(Bin)
            {
                field("Bin Eject After Credit Sale"; Rec."Bin Eject After Credit Sale")
                {
                    ToolTip = 'Specifies if the bin is going to be ejected after a credit pos sale.';
                    ApplicationArea = NPRRetail;
                }
                field("Bin Eject After Sale"; Rec."Bin Eject After Sale")
                {
                    ToolTip = 'Specifies if the bin is going to be ejected after a pos sale.';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Setup)
            {
                Caption = 'Additional Audit Setup';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Additional setup related to selected Audit Handler.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PosAuditProfiles: Page "NPR POS Audit Profiles";
                begin
                    PosAuditProfiles.OnHandlePOSAuditProfileAdditionalSetup(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetAllowSalesAndReturnInSameTransEnabled();
    end;

    local procedure SetAllowSalesAndReturnInSameTransEnabled()
    var
        ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
        BGSISAuditMgt: Codeunit "NPR BG SIS Audit Mgt.";
        ITAuditMgt: Codeunit "NPR IT Audit Mgt.";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        KSAAuditMgt: Codeunit "NPR KSA Audit Mgt.";
    begin
        AllowSalesAndReturnInSameTransEnabled := (Rec."Audit Handler" = ATAuditMgt.HandlerCode())
                                            or (Rec."Audit Handler" = BGSISAuditMgt.HandlerCode())
                                            or (Rec."Audit Handler" = ITAuditMgt.HandlerCode())
                                            or (Rec."Audit Handler" = RSAuditMgt.HandlerCode())
                                            or (Rec."Audit Handler" = KSAAuditMgt.HandlerCode());
    end;

    var
        AllowSalesAndReturnInSameTransEnabled: Boolean;
}
