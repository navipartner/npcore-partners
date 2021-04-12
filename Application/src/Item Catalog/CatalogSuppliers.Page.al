page 6060061 "NPR Catalog Suppliers"
{
    // NPR5.39/BR  /20171212 CASE 295322 Object Created
    // NPR5.42/RA/20180522  CASE 313503 Added field "Send Sales Statistics" and "Trade Number"

    Caption = 'Catalog Suppliers';
    PageType = List;
    SourceTable = "NPR Catalog Supplier";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Send Sales Statistics"; Rec."Send Sales Statistics")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Sales Statistics field';
                }
                field("Trade Number"; Rec."Trade Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trade Number field';
                }
            }
        }
    }

    actions
    {
    }
}

