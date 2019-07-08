page 6150632 "POS Audit Profiles"
{
    // NPR5.48/MMV /20181026 CASE 318028 Created object
    // NPR5.50/MMV /20190503 CASE 353807 Added "Allow Zero Amount Sales".

    Caption = 'POS Audit Profiles';
    PageType = List;
    SourceTable = "POS Audit Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Sale Fiscal No. Series";"Sale Fiscal No. Series")
                {
                }
                field("Credit Sale Fiscal No. Series";"Credit Sale Fiscal No. Series")
                {
                }
                field("Balancing Fiscal No. Series";"Balancing Fiscal No. Series")
                {
                }
                field("Fill Sale Fiscal No. On";"Fill Sale Fiscal No. On")
                {
                }
                field("Audit Log Enabled";"Audit Log Enabled")
                {
                }
                field("Audit Handler";"Audit Handler")
                {
                }
                field("Allow Zero Amount Sales";"Allow Zero Amount Sales")
                {
                }
            }
        }
    }

    actions
    {
    }
}

