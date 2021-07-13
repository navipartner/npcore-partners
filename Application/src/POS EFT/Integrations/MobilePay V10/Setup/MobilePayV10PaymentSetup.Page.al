page 6014437 "NPR MobilePayV10 Payment Setup"
{
    PageType = Card;

    UsageCategory = Administration;
    SourceTable = "NPR MobilePayV10 Payment Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Environment; Rec.Environment)
                {

                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;

                }
                field("Merchant VAT Number"; Rec."Merchant VAT Number")
                {

                    ToolTip = 'Specifies the value of the Merchant VAT Number field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Level"; Rec."Log Level")
                {

                    ToolTip = 'Specifies the value of the Log Level field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}