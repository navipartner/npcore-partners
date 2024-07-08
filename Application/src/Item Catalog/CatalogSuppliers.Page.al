page 6060061 "NPR Catalog Suppliers"
{
    Extensible = False;
    // NPR5.39/BR  /20171212 CASE 295322 Object Created
    // NPR5.42/RA/20180522  CASE 313503 Added field "Send Sales Statistics" and "Trade Number"

    Caption = 'Catalog Suppliers';
    PageType = List;
    SourceTable = "NPR Catalog Supplier";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Sales Statistics"; Rec."Send Sales Statistics")
                {

                    ToolTip = 'Specifies the value of the Send Sales Statistics field';
                    ApplicationArea = NPRRetail;
                }
                field("Trade Number"; Rec."Trade Number")
                {

                    ToolTip = 'Specifies the value of the Trade Number field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

