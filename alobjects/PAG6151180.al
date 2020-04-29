page 6151180 "Retail Cross References"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Retail Cross References';
    PageType = List;
    SourceTable = "Retail Cross Reference";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Retail ID";"Retail ID")
                {
                }
                field("Reference No.";"Reference No.")
                {
                }
                field("Table ID";"Table ID")
                {
                }
                field("Record Value";"Record Value")
                {
                }
            }
        }
    }

    actions
    {
    }
}

