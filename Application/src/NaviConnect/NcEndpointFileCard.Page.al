page 6151527 "NPR Nc Endpoint File Card"
{
    Extensible = False;
    Caption = 'Nc Endpoint File Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint File";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
            }
            group("File")
            {
                Caption = 'File';
                field(Path; Rec.Path)
                {

                    ToolTip = 'Specifies the value of the Path field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Client Path"; Rec."Client Path")
                {

                    ToolTip = 'Client Path can only be used with Manual Export';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Filename; Rec.Filename)
                {

                    ToolTip = 'Specifies the value of the Filename field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Handle Exiting File"; Rec."Handle Exiting File")
                {

                    ToolTip = 'Specifies the value of the Handle Exiting File field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("File Encoding"; Rec."File Encoding")
                {

                    ToolTip = 'Specifies the value of the File Encoding field';
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

                trigger OnAction()
                begin
                    Rec.ShowEndpointTriggerLinks();
                end;
            }
        }
    }
}

