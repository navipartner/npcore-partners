page 6184851 "FR Audit No. Series"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // NPR5.51/MMV /20190614 CASE 356076 Added field 6

    Caption = 'FR Audit No. Series';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "FR Audit No. Series";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Reprint No. Series";"Reprint No. Series")
                {
                }
                field("JET No. Series";"JET No. Series")
                {
                }
                field("Period No. Series";"Period No. Series")
                {
                }
                field("Grand Period No. Series";"Grand Period No. Series")
                {
                }
                field("Yearly Period No. Series";"Yearly Period No. Series")
                {
                }
            }
        }
    }

    actions
    {
    }
}

