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
                field("Original Company"; "Original Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company of Origin field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location field';
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("Generic Item No."; "Generic Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Generic Item Number field';
                }
                field(Customer; Customer)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer field';
                }
                field("Use Original Item No."; "Use Original Item No.")
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

