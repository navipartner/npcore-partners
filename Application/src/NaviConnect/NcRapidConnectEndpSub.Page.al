page 6151093 "NPR Nc RapidConnect Endp. Sub."
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect

    Caption = 'Endpoints';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Nc RapidConn. Endpoint";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint Code"; "Endpoint Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Code field';
                }
                field("Endpoint Type"; "Endpoint Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Setup Summary"; "Setup Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Setup Summary field';
                }
            }
        }
    }

    actions
    {
    }
}

