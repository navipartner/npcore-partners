page 6059811 "NPR POS Cross References"
{
    Extensible = False;
    Caption = 'POS Cross References';
    PageType = List;
    SourceTable = "NPR POS Cross Reference";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the table name for the POS cross reference';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ToolTip = 'Specifies the reference number';
                    ApplicationArea = NPRRetail;
                }
                field("Record Value"; Rec."Record Value")
                {
                    ToolTip = 'Specifies the record value';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

