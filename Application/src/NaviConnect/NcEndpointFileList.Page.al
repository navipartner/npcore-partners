page 6151526 "NPR Nc Endpoint File List"
{
    Caption = 'Nc Endpoint File List';
    CardPageID = "NPR Nc Endpoint File Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Endpoint File";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field(Path; Rec.Path)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Path field';
                }
                field("Client Path"; Rec."Client Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Path field';
                }
                field(Filename; Rec.Filename)
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
                    Rec.ShowEndpointTriggerLinks;
                end;
            }
        }
    }
}

