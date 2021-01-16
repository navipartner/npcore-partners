page 6151120 "NPR GDPR Setup"
{
    // MM1.29/TSA /20180509 CASE 313795 Intial Version

    Caption = 'GDPR Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR GDPR Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Agreement Nos."; "Agreement Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Agreement Nos. field';
                }
            }
        }
    }

    actions
    {
    }
}

