page 6151175 "NPR NpGp Cross Companies Setup"
{
    Caption = 'Cross Companies Setup';
    PageType = List;
    SourceTable = "NPR NpGp Cross Company Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Original Company"; Rec."Original Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company of Origin field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location field';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("Generic Item No."; Rec."Generic Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Generic Item Number field';
                }
                field(Customer; Rec.Customer)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer field';
                }
                field("Use Original Item No."; Rec."Use Original Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Original Item No. field';
                }
            }
        }
    }

    actions
    {
    }
}

