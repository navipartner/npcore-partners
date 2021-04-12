page 6151522 "NPR Nc Endpoint FTP List"
{
    // NC2.01/BR /20160818  CASE 248630 NaviConnect

    Caption = 'Nc Endpoint FTP List';
    CardPageID = "NPR Nc Endpoint FTP Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Endpoint FTP";

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
                field(Server; Rec.Server)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Server field';
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

