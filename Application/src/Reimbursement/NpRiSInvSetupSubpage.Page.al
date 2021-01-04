page 6151111 "NPR NpRi S. Inv. SetupSubpage"
{
    // NPR5.53/MHA /20191104  CASE 364131 Object Created - NaviPartner Reimbursement - Sales Invoice

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NpRi Sales Inv. Setup Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Invoice %"; "Invoice %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice % field';
                }
            }
        }
    }

    actions
    {
    }
}

