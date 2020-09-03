page 6184851 "NPR FR Audit No. Series"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // NPR5.51/MMV /20190614 CASE 356076 Added field 6

    Caption = 'FR Audit No. Series';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR FR Audit No. Series";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Reprint No. Series"; "Reprint No. Series")
                {
                    ApplicationArea = All;
                }
                field("JET No. Series"; "JET No. Series")
                {
                    ApplicationArea = All;
                }
                field("Period No. Series"; "Period No. Series")
                {
                    ApplicationArea = All;
                }
                field("Grand Period No. Series"; "Grand Period No. Series")
                {
                    ApplicationArea = All;
                }
                field("Yearly Period No. Series"; "Yearly Period No. Series")
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

