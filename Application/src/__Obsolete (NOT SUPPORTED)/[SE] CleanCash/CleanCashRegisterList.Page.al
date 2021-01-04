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
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("CleanCash No. Series"; "CleanCash No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CleanCash No. Series field';
                }
                field("CleanCash Integration"; "CleanCash Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CleanCash Integration field';
                }
            }
        }
    }

    actions
    {
    }
}

