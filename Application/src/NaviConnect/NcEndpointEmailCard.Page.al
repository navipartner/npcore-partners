page 6151525 "NPR Nc Endpoint E-mail Card"
{
    Caption = 'Nc Endpoint E-mail Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint E-mail";
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
            group("E-Mail")
            {
                Caption = 'E-Mail';
                field("Recipient E-Mail Address"; Rec."Recipient E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the Recipient E-Mail Address field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("CC E-Mail Address"; Rec."CC E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the CC E-Mail Address field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("BCC E-Mail Address"; Rec."BCC E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the BCC E-Mail Address field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Subject Text"; Rec."Subject Text")
                {

                    ToolTip = 'Specifies the value of the Subject Text field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Body Text"; Rec."Body Text")
                {

                    ToolTip = 'Specifies the value of the Body Text field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Filename Attachment"; Rec."Filename Attachment")
                {

                    ToolTip = 'Specifies the value of the Filename Attachment field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Sender Name"; Rec."Sender Name")
                {

                    ToolTip = 'Specifies the value of the Sender Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Sender E-Mail Address"; Rec."Sender E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the Sender E-Mail Address field';
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

