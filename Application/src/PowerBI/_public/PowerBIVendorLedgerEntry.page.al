page 6184627 NPRPowerBIVendorLedgerEntry
{
    PageType = List;
    Caption = 'PowerBI Vendor Ledger Entry';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Vendor Ledger Entry";
    Editable = false;
    ObsoleteState = pending;
    ObsoleteReason = 'Page type changed to API';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Buy-from Vendor No. field.';
                    ApplicationArea = All;
                }
                field("Closed by Amount (LCY)"; Rec."Closed by Amount (LCY)")
                {
                    ToolTip = 'Specifies the value of the Closed by Amount (LCY) field.';
                    ApplicationArea = All;
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {
                    ToolTip = 'Specifies the value of the Closed by Entry No. field.';
                    ApplicationArea = All;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ToolTip = 'Specifies a reference to a combination of dimension values. The actual values are stored in the Dimension Set Entry table.';
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the vendor entry''s posting date.';
                    ApplicationArea = All;
                }
                field("Purchase (LCY)"; Rec."Purchase (LCY)")
                {
                    ToolTip = 'Specifies the value of the Purchase (LCY) field.';
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ToolTip = 'Specifies the name of the vendor account that the entry is linked to.';
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the number of the vendor account that the entry is linked to.';
                    ApplicationArea = All;
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ToolTip = 'Specifies the value of the Vendor Posting Group field.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = All;
                }
            }
        }
    }
}