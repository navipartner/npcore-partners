page 6151120 "NPR GDPR Setup"
{
    Extensible = False;
    // MM1.29/TSA /20180509 CASE 313795 Intial Version

    Caption = 'GDPR Setup';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR GDPR Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Agreement Nos."; Rec."Agreement Nos.")
                {

                    ToolTip = 'Specifies the value of the Agreement Nos. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

