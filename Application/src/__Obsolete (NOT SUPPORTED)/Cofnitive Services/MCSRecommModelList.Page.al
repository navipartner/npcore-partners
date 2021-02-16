page 6060081 "NPR MCS Recomm. Model List"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';
    Caption = 'MCS Recommendations Model List';
    CardPageID = "NPR MCS Recomm. Model Card";
    PageType = List;
    SourceTable = "NPR MCS Recomm. Model";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
            }
        }
    }

    actions
    {
    }
}

