page 6151534 "NPR Nc Collector Req.Filt.Subf"
{
    Extensible = False;
    Caption = 'Nc Collector Req. Filter Subf.';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Nc Collector Req. Filter";
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

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

