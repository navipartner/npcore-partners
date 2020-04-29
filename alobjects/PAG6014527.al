page 6014527 "Touch Screen - G/L Accounts"
{
    // NPR4.14/BHR/20150818 CASE 220158 Set Property ModifyAllowed to "No"
    // NPR4.14/RMT/20150819 CASE 220157 Set ENU page from ENU=Touch Screen - Lookup vendor to ENU=Touch Screen - Lookup G/L Account
    // NPR5.49/BHR /20190204 CASE 343525  Removed  Fields from Page Income/Balance,Account Type,Net Change,Balance at Date,Balance

    Caption = 'Touch Screen - Lookup G/L Account';
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "G/L Account";
    SourceTableView = SORTING("Search Name")
                      ORDER(Ascending)
                      WHERE("No."=FILTER(<>''),
                            Blocked=CONST(false),
                            "Retail Payment"=CONST(true));

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                }
                field("No.";"No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

