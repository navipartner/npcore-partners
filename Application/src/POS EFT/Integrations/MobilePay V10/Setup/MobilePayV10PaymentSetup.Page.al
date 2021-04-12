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
                field(Environment; Environment)
                {
                    ApplicationArea = All;

                }
                field("Merchant VAT Number"; "Merchant VAT Number")
                {
                    ApplicationArea = All;
                }
                field("Log Level"; "Log Level")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}