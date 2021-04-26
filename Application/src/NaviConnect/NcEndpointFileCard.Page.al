page 6151527 "NPR Nc Endpoint File Card"
{
    Caption = 'Nc Endpoint File Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Endpoint File";

    layout
    {
        area(content)
        {
            group(General)
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
            }
            group("File")
            {
                field(Path; Rec.Path)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Path field';
                }
                field("Client Path"; Rec."Client Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Client Path can only be used with Manual Export';
                }
                field(Filename; Rec.Filename)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filename field';
                }
                field("Handle Exiting File"; Rec."Handle Exiting File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handle Exiting File field';
                }
                field("File Encoding"; Rec."File Encoding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Encoding field';
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

