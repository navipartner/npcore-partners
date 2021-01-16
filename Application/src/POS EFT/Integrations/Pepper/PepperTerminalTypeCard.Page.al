page 6184484 "NPR Pepper Terminal Type Card"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Force Fixed Currency Check.

    Caption = 'Pepper Terminal Type Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Pepper Terminal Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ID; ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field("Force Fixed Currency Check"; "Force Fixed Currency Check")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Fixed Currency Check field';
                }
                field(Deprecated; Deprecated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deprecated field';
                }
            }
            group(ATOS)
            {
                field(Overtender; Overtender)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Overtender field';
                }
            }
        }
    }

    actions
    {
    }
}

