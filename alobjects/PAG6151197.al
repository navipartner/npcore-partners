page 6151197 "NpCs Workflows"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Workflows';
    CardPageID = "NpCs Workflow Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpCs Workflow";
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

