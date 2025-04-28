#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6184952 "NPR SendGrid Sender Identities"
{
    Extensible = false;
    Caption = 'SendGrid Sender Identities';
    ApplicationArea = NPRNPEmail;
    UsageCategory = None;
    PageType = List;
    DataCaptionFields = Nickname;
    SourceTable = "NPR SendGrid Sender Identity";

    layout
    {
        area(Content)
        {
            repeater(IdentityRepeater)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the id';
                }
                field(Nickname; Rec.Nickname)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the nickname';
                }
                field("From E-mail Address"; Rec.FromEmailAddress)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the from e-mail address';
                }
                field(Verified; Rec.Verified)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the verified';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateSenderIdentities)
            {
                Caption = 'Update Identities';
                ToolTip = 'Running this action will update the identities from the central server.';
                ApplicationArea = NPRNPEmail;
                Image = UpdateXML;

                trigger OnAction()
                var
                    Client: Codeunit "NPR SendGrid Client";
                begin
                    Client.UpdateLocalSenderIdentities();
                    CurrPage.Update(false);
                end;
            }
        }

        area(Promoted)
        {
            actionref(Promoted_UpdateSenderIdentities; UpdateSenderIdentities) { }
        }
    }
}
#endif