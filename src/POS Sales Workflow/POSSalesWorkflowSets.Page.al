page 6150732 "NPR POS Sales Workflow Sets"
{
    // NPR5.45/MHA /20180820  CASE 321266 Object created

    Caption = 'POS Sales Workflow Sets';
    CardPageID = "NPR POS Sales WF Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Sales Workflow Set";
    UsageCategory = Administration;

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
                field(Description; Description)
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

