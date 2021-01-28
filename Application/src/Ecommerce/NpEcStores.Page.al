page 6151300 "NPR NpEc Stores"
{
    Caption = 'E-commerce Stores';
    CardPageID = "NPR NpEc Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpEc Store";
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

