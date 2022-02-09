page 6151300 "NPR NpEc Stores"
{
    Extensible = False;
    Caption = 'E-commerce Stores';
    CardPageID = "NPR NpEc Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpEc Store";
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

                    ToolTip = 'Specifies the code of the record.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the name of the record.';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson/Purchaser Code"; Rec."Salesperson/Purchaser Code")
                {

                    ToolTip = 'Specifies the name of the salesperson who is assigned to the e-commerce store.';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the location of the e-commerce store.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the code for the first dimension, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the code for the second dimension, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {

                    ShowCaption = false;
                    ToolTip = 'Specifies way for searching customer while creating or updating sales order.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {

                    ToolTip = 'Specifies the code of the customer configuration template.';
                    ApplicationArea = NPRRetail;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ToolTip = 'Specifies the code of the responsibility center, such as a distribution hub, that is associated with the involved user, company, customer, or vendor. When webshop order is created and imported to Business Central, if Code of this Store is named, then value from this field will be passed to the Sales Header.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(CustomerMapping)
            {
                Caption = 'Customer Mapping';
                Image = List;
                RunObject = Page "NPR NpEc Customer Mapping";
                RunPageLink = "Store Code" = FIELD(Code);

                ToolTip = 'View or edit customer mapping.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

