page 6151301 "NPR NpEc Store Card"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce
    // NPR5.54/MHA /20200129  CASE 367842 Added fields 160 "Allow Create Customers", 170 "Update Customers from Sales Order"

    Caption = 'Np E-commerce Store Card';
    PageType = Card;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Salesperson/Purchaser Code"; "Salesperson/Purchaser Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson/Purchaser Code field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field(Control6014408; "Customer Mapping")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Customer Mapping field';
                }
                field("Customer Config. Template Code"; "Customer Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                }
                field("Allow Create Customers"; "Allow Create Customers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Create Customers field';
                }
                field("Update Customers from S. Order"; "Update Customers from S. Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Update Customers from Sales Order field';
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
                ToolTip = 'Executes the Customer Mapping action';
            }
        }
    }
}

