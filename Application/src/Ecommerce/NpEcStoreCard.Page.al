page 6151301 "NPR NpEc Store Card"
{
    Caption = 'E-commerce Store Card';
    PageType = Card;
    SourceTable = "NPR NpEc Store";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code of the record.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the record.';
                }
                field("Salesperson/Purchaser Code"; Rec."Salesperson/Purchaser Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the e-commerce store.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location of the e-commerce store.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the first dimension, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the second dimension, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies way for searching customer while creating or updating sales order.';
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the customer configuration template.';
                }
                field("Allow Create Customers"; Rec."Allow Create Customers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if customer will be created for current e-commerce store. Customer will be created if it''s not found when order is imported.';
                }
                field("Update Customers from S. Order"; Rec."Update Customers from S. Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if customer will be updated for current e-commerce store. Customer will be updated if it''s found when order is imported.';
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
                ApplicationArea = All;
                ToolTip = 'View or edit customer mapping.';
            }
        }
    }
}

