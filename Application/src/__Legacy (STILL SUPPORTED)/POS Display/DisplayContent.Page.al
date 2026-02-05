page 6059951 "NPR Display Content"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Display Content';
    PageType = List;
    UsageCategory = Administration;

    RefreshOnActivate = true;
    SourceTable = "NPR Display Content";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Content Lines"; Rec."Content Lines")
                {

                    ToolTip = 'Specifies the value of the Content Lines field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

