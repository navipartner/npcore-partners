page 6151175 "NpGp Cross Companies Setup"
{
    // NPR5.51/ALST/20190422 CASE 337539 New object

    Caption = 'Cross Companies Setup';
    PageType = List;
    SourceTable = "NpGp Cross Company Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Original Company"; "Original Company")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Generic Item No."; "Generic Item No.")
                {
                    ApplicationArea = All;
                }
                field(Customer; Customer)
                {
                    ApplicationArea = All;
                }
                field("Use Original Item No."; "Use Original Item No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

