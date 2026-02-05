page 6151526 "NPR Nc Endpoint File List"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Nc Endpoint File List';
    CardPageID = "NPR Nc Endpoint File Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR Nc Endpoint File";

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
                field(Path; Rec.Path)
                {

                    ToolTip = 'Specifies the value of the Path field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Client Path"; Rec."Client Path")
                {
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Client Path field is about to be removed because it is not needed anymore.';
                    ToolTip = 'Specifies the value of the Client Path field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Filename; Rec.Filename)
                {

                    ToolTip = 'Specifies the value of the Filename field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

