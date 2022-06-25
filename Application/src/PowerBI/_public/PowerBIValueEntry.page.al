page 6184625 NPRPowerBIValueEntry
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Value Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Cost Amount (Actual)"; Rec."Cost Amount (Actual)")
                {
                    ToolTip = 'Specifies the cost of invoiced items.';
                    ApplicationArea = All;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the total discount amount of this value entry.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the type of value described in this entry.';
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
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    ToolTip = 'Specifies the number of the item ledger entry that this value entry is linked to.';
                    ApplicationArea = All;
                }
                field("Item Ledger Entry Type"; Rec."Item Ledger Entry Type")
                {
                    ToolTip = 'Specifies the type of item ledger entry that caused this value entry.';
                    ApplicationArea = All;
                }
                field("Item Ledger Entry Quantity"; Rec."Item Ledger Entry Quantity")
                {
                    ToolTip = 'Specifies the average cost calculation.';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the item that this value entry is linked to.';
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date of this entry.';
                    ApplicationArea = All;
                }
                field("Purchase Amount (Actual)"; Rec."Purchase Amount (Actual)")
                {
                    ToolTip = 'Specifies the value of the Purchase Amount (Actual) field.';
                    ApplicationArea = All;
                }
                field("Sales Amount (Actual)"; Rec."Sales Amount (Actual)")
                {
                    ToolTip = 'Specifies the price of the item for a sales entry.';
                    ApplicationArea = All;
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ToolTip = 'Specifies which salesperson or purchaser is linked to the entry.';
                    ApplicationArea = All;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the source code that specifies where the entry was created.';
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                    ApplicationArea = All;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the source type that applies to the source number that is shown in the Source No. field.';
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the type of value entry when it relates to a capacity entry.';
                    ApplicationArea = All;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = All;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}