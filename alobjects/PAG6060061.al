page 6060061 "Catalog Suppliers"
{
    // NPR5.39/BR  /20171212 CASE 295322 Object Created
    // NPR5.42/RA/20180522  CASE 313503 Added field "Send Sales Statistics" and "Trade Number"

    Caption = 'Catalog Suppliers';
    PageType = List;
    SourceTable = "Catalog Supplier";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Send Sales Statistics"; "Send Sales Statistics")
                {
                    ApplicationArea = All;
                }
                field("Trade Number"; "Trade Number")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

