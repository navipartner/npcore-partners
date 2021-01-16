page 6151180 "NPR Retail Cross References"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Retail Cross References';
    PageType = List;
    SourceTable = "NPR Retail Cross Reference";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Retail ID field';
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field';
                }
                field("Record Value"; "Record Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Record Value field';
                }
            }
        }
    }

    actions
    {
    }
}

