page 6150638 "POS Posting Profiles"
{
    // NPR5.52/ALPO/20190923 CASE 365326 Posting related fields moved here (POS Posting Profiles) from NP Retail Setup
    // NPR5.52/SARA/20191003 CASE 371385 Removed note section

    Caption = 'POS Posting Profiles';
    CardPageID = "POS Posting Profile Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Posting Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Automatic Item Posting";"Automatic Item Posting")
                {
                    Visible = false;
                }
                field("Adj. Cost after Item Posting";"Adj. Cost after Item Posting")
                {
                    Visible = false;
                }
                field("Post to G/L after Item Posting";"Post to G/L after Item Posting")
                {
                    Visible = false;
                }
                field("Automatic POS Posting";"Automatic POS Posting")
                {
                    Visible = false;
                }
                field("Automatic Posting Method";"Automatic Posting Method")
                {
                    Visible = false;
                }
                field("Default POS Entry No. Series";"Default POS Entry No. Series")
                {
                    Visible = false;
                }
                field("Max. POS Posting Diff. (LCY)";"Max. POS Posting Diff. (LCY)")
                {
                    Visible = false;
                }
                field("POS Posting Diff. Account";"POS Posting Diff. Account")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

