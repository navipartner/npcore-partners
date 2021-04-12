page 6151525 "NPR Nc Endpoint E-mail Card"
{
    // NC2.01/BR /20160826  CASE 247479 NaviConnect

    Caption = 'Nc Endpoint E-mail Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Endpoint E-mail";

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
            group("E-Mail")
            {
                field("Recipient E-Mail Address"; Rec."Recipient E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recipient E-Mail Address field';
                }
                field("CC E-Mail Address"; Rec."CC E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CC E-Mail Address field';
                }
                field("BCC E-Mail Address"; Rec."BCC E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BCC E-Mail Address field';
                }
                field("Subject Text"; Rec."Subject Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subject Text field';
                }
                field("Body Text"; Rec."Body Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Body Text field';
                }
                field("Filename Attachment"; Rec."Filename Attachment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filename Attachment field';
                }
                field("Sender Name"; Rec."Sender Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sender Name field';
                }
                field("Sender E-Mail Address"; Rec."Sender E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sender E-Mail Address field';
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

