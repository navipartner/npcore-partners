page 6151331 "NPR Legal Page"
{
    Caption = 'Legal Page';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Standard Conditions field';

                }
                field("License Agreement"; "License Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License Agreement field';

                }
                field(Privacy; Privacy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Privacy field';

                }
            }
        }

    }
}
