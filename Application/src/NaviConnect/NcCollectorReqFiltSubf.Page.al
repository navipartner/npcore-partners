page 6151534 "NPR Nc Collector Req.Filt.Subf"
{
    Caption = 'Nc Collector Req. Filter Subf.';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Collector Req. Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Text"; Rec."Filter Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Text field';
                }
            }
        }
    }
}

