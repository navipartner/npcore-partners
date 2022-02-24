page 6184484 "NPR Pepper Terminal Type Card"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Force Fixed Currency Check.

    Caption = 'Pepper Terminal Type Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Pepper Terminal Type";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ID; Rec.ID)
                {

                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
                field("Force Fixed Currency Check"; Rec."Force Fixed Currency Check")
                {

                    ToolTip = 'Specifies the value of the Force Fixed Currency Check field';
                    ApplicationArea = NPRRetail;
                }
                field(Deprecated; Rec.Deprecated)
                {

                    ToolTip = 'Specifies the value of the Deprecated field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(ATOS)
            {
                field(Overtender; Rec.Overtender)
                {

                    ToolTip = 'Specifies the value of the Overtender field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

