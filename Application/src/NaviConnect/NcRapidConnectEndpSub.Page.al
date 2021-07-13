page 6151093 "NPR Nc RapidConnect Endp. Sub."
{
    Caption = 'Endpoints';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Nc RapidConn. Endpoint";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint Code"; Rec."Endpoint Code")
                {

                    ToolTip = 'Specifies the value of the Endpoint Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Endpoint Type"; Rec."Endpoint Type")
                {

                    ToolTip = 'Specifies the value of the Endpoint Type field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Setup Summary"; Rec."Setup Summary")
                {

                    ToolTip = 'Specifies the value of the Setup Summary field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

