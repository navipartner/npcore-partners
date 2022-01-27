page 6151507 "NPR Nc Task Proces. Card"
{
    Extensible = False;
    Caption = 'NaviConnect Task Processor';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Nc Task Processor";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
            part(Control6150618; "NPR Nc Task Proces. Lines")
            {
                ApplicationArea = NPRNaviConnect;

            }
        }
    }
}
