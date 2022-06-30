page 6184628 NPRPowerBIItemApplication
{
    ApplicationArea = All;
    Caption = 'PowerBI Item Application';
    PageType = List;
    SourceTable = "Item Application Entry";
    UsageCategory = Lists;
    editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Cost Application"; Rec."Cost Application")
                {
                    ToolTip = 'Specifies the value of the Cost Application field.';
                    ApplicationArea = All;
                }
                field("Created By User"; Rec."Created By User")
                {
                    ToolTip = 'Specifies the value of the Created By User field.';
                    ApplicationArea = All;
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ToolTip = 'Specifies the value of the Creation Date field.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = All;
                }
                field("Inbound Item Entry No."; Rec."Inbound Item Entry No.")
                {
                    ToolTip = 'Specifies the number of the item ledger entry corresponding to the inventory increase or positive quantity in inventory.';
                    ApplicationArea = All;
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    ToolTip = 'Specifies one or more item application entries for each inventory transaction that is posted.';
                    ApplicationArea = All;
                }
                field("Last Modified By User"; Rec."Last Modified By User")
                {
                    ToolTip = 'Specifies the value of the Last Modified By User field.';
                    ApplicationArea = All;
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ToolTip = 'Specifies the value of the Last Modified Date field.';
                    ApplicationArea = All;
                }
                field("Outbound Entry is Updated"; Rec."Outbound Entry is Updated")
                {
                    ToolTip = 'Specifies the value of the Outbound Entry is Updated field.';
                    ApplicationArea = All;
                }
                field("Outbound Item Entry No."; Rec."Outbound Item Entry No.")
                {
                    ToolTip = 'Specifies the number of the item ledger entry corresponding to the inventory decrease for this entry.';
                    ApplicationArea = All;
                }
                field("Output Completely Invd. Date"; Rec."Output Completely Invd. Date")
                {
                    ToolTip = 'Specifies the value of the Output Completely Invd. Date field.';
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date that corresponds to the posting date of the item ledger entry, for which this item application entry was created.';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity of the item that is being applied from the inventory decrease in the Outbound Item Entry No. field, to the inventory increase in the Inbound Item Entry No. field.';
                    ApplicationArea = All;
                }
                field("Transferred-from Entry No."; Rec."Transferred-from Entry No.")
                {
                    ToolTip = 'Specifies the value of the Transferred-from Entry No. field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}

