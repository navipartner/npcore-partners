page 6151331 "NPR Legal Page"
{
    Caption = 'Legal Page';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NP Retail Setup";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Standard Conditions"; "Standard Conditions")
                {
                    ApplicationArea = All;

                }
                field("License Agreement"; "License Agreement")
                {
                    ApplicationArea = All;

                }
                field(Privacy; Privacy)
                {
                    ApplicationArea = All;

                }
            }
        }

    }
}