page 6151180 "NPR Retail Cross References"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Retail Cross References';
    PageType = List;
    SourceTable = "NPR Retail Cross Reference";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                }
                field("Record Value"; "Record Value")
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

