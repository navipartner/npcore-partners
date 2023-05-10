page 6150843 "NPR M2 Integration Records"
{
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR M2 Integration Record";
    UsageCategory = None;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(RecordsRepeater)
            {
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies which table no. the record is tracking';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Integration Area"; Rec."Integration Area")
                {
                    ToolTip = 'Specifies which integration area the record is supporting';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the table name of the table selected through Table No.';
                    ApplicationArea = NPRRetail;
                }
                field("Last SystemRowVersionNo"; Rec."Last SystemRowVersionNo")
                {
                    ToolTip = 'Specifies the last SystemRowVersionNo that was read in the synchronization';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}