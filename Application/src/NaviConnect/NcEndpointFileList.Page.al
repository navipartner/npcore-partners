page 6151526 "NPR Nc Endpoint File List"
{
    Extensible = False;
    Caption = 'Nc Endpoint File List';
    CardPageID = "NPR Nc Endpoint File Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint File";
    ApplicationArea = NPRNaviConnect;

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

    actions
    {
        area(navigation)
        {
            action("Trigger Links")
            {
                Caption = 'Trigger Links';
                Image = Link;

                ToolTip = 'Executes the Trigger Links action';
                ApplicationArea = NPRNaviConnect;
                ObsoleteState = Pending;
                ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Trigger is also going to be removed.';
                ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

                trigger OnAction()
                begin
                    Rec.ShowEndpointTriggerLinks();
                end;
            }
        }
    }
}

