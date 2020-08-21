page 6184503 "CleanCash Register List"
{
    // NPR4.21/JHL/20160302 CASE 222417 Page created to show which register that is used to CleanCash
    // NPR5.49/JAVA/20190401 CASE 350661 Added missing object caption.

    Caption = 'CleanCash Cash Register List';
    PageType = List;
    SourceTable = "CleanCash Register";
    UsageCategory = Lists;

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

