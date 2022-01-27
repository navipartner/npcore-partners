page 6151522 "NPR Nc Endpoint FTP List"
{
    Extensible = False;
    Caption = 'Nc Endpoint FTP List';
    CardPageID = "NPR Nc Endpoint FTP Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint FTP";
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
                field(Server; Rec.Server)
                {
                    ToolTip = 'Specifies the value of the FTP Server field';
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

