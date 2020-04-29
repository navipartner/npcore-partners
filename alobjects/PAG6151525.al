page 6151525 "Nc Endpoint E-mail Card"
{
    // NC2.01/BR /20160826  CASE 247479 NaviConnect

    Caption = 'Nc Endpoint E-mail Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Nc Endpoint E-mail";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Enabled;Enabled)
                {
                }
            }
            group("E-Mail")
            {
                field("Recipient E-Mail Address";"Recipient E-Mail Address")
                {
                }
                field("CC E-Mail Address";"CC E-Mail Address")
                {
                }
                field("BCC E-Mail Address";"BCC E-Mail Address")
                {
                }
                field("Subject Text";"Subject Text")
                {
                }
                field("Body Text";"Body Text")
                {
                }
                field("Filename Attachment";"Filename Attachment")
                {
                }
                field("Sender Name";"Sender Name")
                {
                }
                field("Sender E-Mail Address";"Sender E-Mail Address")
                {
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

                trigger OnAction()
                begin
                    ShowEndpointTriggerLinks;
                end;
            }
        }
    }
}

