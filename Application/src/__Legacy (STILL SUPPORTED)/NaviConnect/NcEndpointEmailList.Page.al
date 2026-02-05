page 6151524 "NPR Nc Endpoint E-mail List"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Nc Endpoint E-mail List';
    CardPageID = "NPR Nc Endpoint E-mail Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR Nc Endpoint E-mail";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Recipient E-Mail Address"; Rec."Recipient E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the Recipient E-Mail Address field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

