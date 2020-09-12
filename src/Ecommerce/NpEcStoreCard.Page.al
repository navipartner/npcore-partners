page 6151301 "NPR NpEc Store Card"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce
    // NPR5.54/MHA /20200129  CASE 367842 Added fields 160 "Allow Create Customers", 170 "Update Customers from Sales Order"

    Caption = 'Np E-commerce Store Card';
    PageType = Card;
    SourceTable = "NPR NpEc Store";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Salesperson/Purchaser Code"; "Salesperson/Purchaser Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field(Control6014408; "Customer Mapping")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("Customer Config. Template Code"; "Customer Config. Template Code")
                {
                    ApplicationArea = All;
                }
                field("Allow Create Customers"; "Allow Create Customers")
                {
                    ApplicationArea = All;
                }
                field("Update Customers from S. Order"; "Update Customers from S. Order")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Customer Mapping")
            {
                Caption = 'Customer Mapping';
                Image = List;
                RunObject = Page "NPR NpEc Customer Mapping";
                RunPageLink = "Store Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }
}

