page 6151175 "NPR NpGp Cross Companies Setup"
{
    Extensible = False;
    Caption = 'Cross Companies Setup';
    PageType = List;
    SourceTable = "NPR NpGp Cross Company Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Original Company"; Rec."Original Company")
                {

                    ToolTip = 'Specifies the value of the Company of Origin field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {

                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Generic Item No."; Rec."Generic Item No.")
                {

                    ToolTip = 'Specifies the value of the Generic Item Number field';
                    ApplicationArea = NPRRetail;
                }
                field(Customer; Rec.Customer)
                {

                    ToolTip = 'Specifies the value of the Customer field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Original Item No."; Rec."Use Original Item No.")
                {

                    ToolTip = 'Specifies the value of the Use Original Item No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

