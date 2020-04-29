page 6150732 "POS Sales Workflow Sets"
{
    // NPR5.45/MHA /20180820  CASE 321266 Object created

    Caption = 'POS Sales Workflow Sets';
    CardPageID = "POS Sales Workflow Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Sales Workflow Set";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

