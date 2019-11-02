page 6150639 "POS Posting Profile Card"
{
    // NPR5.52/ALPO/20190923 CASE 365326 Posting related fields moved here (POS Posting Profiles) from NP Retail Setup

    Caption = 'POS Posting Profile Card';
    PageType = Card;
    SourceTable = "POS Posting Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Automatic Item Posting";"Automatic Item Posting")
                {
                }
                field("Adj. Cost after Item Posting";"Adj. Cost after Item Posting")
                {
                }
                field("Post to G/L after Item Posting";"Post to G/L after Item Posting")
                {
                }
                field("Automatic POS Posting";"Automatic POS Posting")
                {
                }
                field("Automatic Posting Method";"Automatic Posting Method")
                {
                }
                field("Max. POS Posting Diff. (LCY)";"Max. POS Posting Diff. (LCY)")
                {
                }
                field("POS Posting Diff. Account";"POS Posting Diff. Account")
                {
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Default POS Entry No. Series";"Default POS Entry No. Series")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014413;Notes)
            {
            }
            systempart(Control6014414;Links)
            {
            }
        }
    }

    actions
    {
    }
}

