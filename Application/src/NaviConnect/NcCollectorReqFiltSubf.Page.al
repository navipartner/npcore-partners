page 6151534 "NPR Nc Collector Req.Filt.Subf"
{
    Extensible = False;
    Caption = 'Nc Collector Req. Filter Subf.';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Collector Req. Filter";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Filter Text"; Rec."Filter Text")
                {

                    ToolTip = 'Specifies the value of the Filter Text field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

