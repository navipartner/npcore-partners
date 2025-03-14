#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6184997 "NPR NP Email Domains"
{
    Extensible = false;
    Caption = 'NP Email Domains';
    Editable = false;
    PageType = List;
    ApplicationArea = NPRNPEmail;
    UsageCategory = None;
    SourceTable = "NPR NP Email Domain";

    layout
    {
        area(Content)
        {
            repeater(DomainRepeater)
            {
                field(Domain; Rec.Domain)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the domain.';
                }
                field(Verified; Rec.Valid)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies if the domain has completed verification.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CheckVerification)
            {
                Caption = 'Check Verification';
                ToolTip = 'Running this action will check the verification of the selected domain.';
                ApplicationArea = NPRNPEmail;
                Image = Approvals;
                Enabled = (not Rec.Valid);

                trigger OnAction()
                var
                    Client: Codeunit "NPR SendGrid Client";
                begin
                    Client.VerifyDomain(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Promoted_CheckVerification; CheckVerification) { }
        }
    }
}
#endif