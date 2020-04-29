page 6014610 "Retail Campaigns"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign

    Caption = 'Retail Campaigns';
    CardPageID = "Retail Campaign";
    Editable = false;
    PageType = List;
    SourceTable = "Retail Campaign Header";
    UsageCategory = Lists;

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

