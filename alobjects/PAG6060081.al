page 6060081 "MCS Recommendations Model List"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created

    Caption = 'MCS Recommendations Model List';
    CardPageID = "MCS Recommendations Model Card";
    PageType = List;
    SourceTable = "MCS Recommendations Model";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
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

