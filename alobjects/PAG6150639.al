page 6150639 "POS Posting Profile Card"
{
    // NPR5.52/ALPO/20190923 CASE 365326 Posting related fields moved here (POS Posting Profiles) from NP Retail Setup
    // NPR5.53/ALPO/20191017 CASE 371955 New group 'Rounding' with fields "POS Sales Rounding Account", "POS Sales Amt. Rndng Precision", "Rounding Type"

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
                group("Posting Difference")
                {
                    Caption = 'Posting Difference';
                    field("Max. POS Posting Diff. (LCY)";"Max. POS Posting Diff. (LCY)")
                    {
                    }
                    field("POS Posting Diff. Account";"POS Posting Diff. Account")
                    {
                    }
                }
                group(Rounding)
                {
                    Caption = 'Rounding';
                    field("POS Sales Rounding Account";"POS Sales Rounding Account")
                    {
                    }
                    field("POS Sales Amt. Rndng Precision";"POS Sales Amt. Rndng Precision")
                    {
                    }
                    field("Rounding Type";"Rounding Type")
                    {
                    }
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

