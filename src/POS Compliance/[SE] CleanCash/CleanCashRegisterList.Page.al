page 6184503 "NPR CleanCash Register List"
{

    Caption = 'CleanCash Cash Register List';
    PageType = List;
    SourceTable = "NPR CleanCash Register";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("CleanCash No. Series"; "CleanCash No. Series")
                {
                    ApplicationArea = All;
                }
                field("CleanCash Integration"; "CleanCash Integration")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

