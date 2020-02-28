page 6151301 "NpEc Store Card"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

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

