page 6151093 "NPR Nc RapidConnect Endp. Sub."
{
    Caption = 'Endpoints';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc RapidConn. Endpoint";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint Code"; Rec."Endpoint Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Code field';
                }
                field("Endpoint Type"; Rec."Endpoint Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Type field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Setup Summary"; Rec."Setup Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Setup Summary field';
                }
            }
        }
    }
}

