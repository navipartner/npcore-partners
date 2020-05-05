page 6151301 "NpEc Store Card"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce
    // NPR5.54/MHA /20200129  CASE 367842 Added fields 160 "Allow Create Customers", 170 "Update Customers from Sales Order"

    Caption = 'Np E-commerce Store Card';
    PageType = Card;
    SourceTable = "NpEc Store";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                    ShowMandatory = true;
                }
                field(Name;Name)
                {
                }
                field("Salesperson/Purchaser Code";"Salesperson/Purchaser Code")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
                field(Control6014408;"Customer Mapping")
                {
                    ShowCaption = false;
                }
                field("Customer Config. Template Code";"Customer Config. Template Code")
                {
                }
                field("Allow Create Customers";"Allow Create Customers")
                {
                }
                field("Update Customers from S. Order";"Update Customers from S. Order")
                {
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
                RunObject = Page "NpEc Customer Mapping";
                RunPageLink = "Store Code"=FIELD(Code);
            }
        }
    }
}

