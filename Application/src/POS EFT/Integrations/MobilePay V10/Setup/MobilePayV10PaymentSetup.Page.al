page 6014437 "NPR MobilePayV10 Payment Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NPR MobilePayV10 Payment Setup";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Environment; Rec.Environment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Environment field';

                }
                field("Merchant VAT Number"; Rec."Merchant VAT Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant VAT Number field';
                }
                field("Log Level"; Rec."Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Level field';
                }
            }
        }
    }
}