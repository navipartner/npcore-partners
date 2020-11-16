page 6151525 "NPR Nc Endpoint E-mail Card"
{
    // NC2.01/BR /20160826  CASE 247479 NaviConnect

    Caption = 'Nc Endpoint E-mail Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint E-mail";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
            }
            group("E-Mail")
            {
                field("Recipient E-Mail Address"; "Recipient E-Mail Address")
                {
                    ApplicationArea = All;
                }
                field("CC E-Mail Address"; "CC E-Mail Address")
                {
                    ApplicationArea = All;
                }
                field("BCC E-Mail Address"; "BCC E-Mail Address")
                {
                    ApplicationArea = All;
                }
                field("Subject Text"; "Subject Text")
                {
                    ApplicationArea = All;
                }
                field("Body Text"; "Body Text")
                {
                    ApplicationArea = All;
                }
                field("Filename Attachment"; "Filename Attachment")
                {
                    ApplicationArea = All;
                }
                field("Sender Name"; "Sender Name")
                {
                    ApplicationArea = All;
                }
                field("Sender E-Mail Address"; "Sender E-Mail Address")
                {
                    ApplicationArea = All;
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

                trigger OnAction()
                begin
                    ShowEndpointTriggerLinks;
                end;
            }
        }
    }
}

