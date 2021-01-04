page 6151526 "NPR Nc Endpoint File List"
{
    // NC2.01/BR  /20160826  CASE 247479 NaviConnect
    // NC2.12/MHA /20180502  CASE 313362 Added field 105 "Client Path"

    Caption = 'Nc Endpoint File List';
    CardPageID = "NPR Nc Endpoint File Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint File";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field(Path; Path)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Path field';
                }
                field("Client Path"; "Client Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Path field';
                }
                field(Filename; Filename)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filename field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Trigger Links action';

                trigger OnAction()
                begin
                    ShowEndpointTriggerLinks;
                end;
            }
        }
    }
}

