page 6151506 "NPR Nc Task Proces. Lines"
{
    AutoSplitKey = true;
    Caption = 'Nc Task Proces. Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Nc Task Proces. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}
