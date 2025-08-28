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
    SourceTableTemporary = true;

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
            action(AddDomain)
            {
                Caption = 'Add Domain';
                ToolTip = 'Running this action will create a new domain to be authenticated.';
                ApplicationArea = NPRNPEmail;
                Image = New;

                trigger OnAction()
                var
                    AddDomainWizard: Page "NPR NPEmailAddDomainWiz";
                begin
                    AddDomainWizard.Initialize(_NPEmailAccount);
                    AddDomainWizard.RunModal();
                    GetDomains();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Promoted_CheckVerification; CheckVerification) { }
            actionref(Promoted_AddDomain; AddDomain) { }
        }
    }

    var
        _Initialized: Boolean;
        _NPEmailAccount: Record "NPR NP Email Account";

    trigger OnOpenPage()
    begin
        if (not _Initialized) then
            Error('The page was not properly initialized. This is a programming bug. Contact system vendor!');

        GetDomains();
    end;

    internal procedure Initialize(AccountId: BigInteger)
    begin
        _NPEmailAccount.Get(AccountId);
        Rec.SetRange(AccountId, _NPEmailAccount.AccountId);
        _Initialized := true;
    end;

    local procedure GetDomains()
    var
        Client: Codeunit "NPR SendGrid Client";
    begin
        Client.GetDomains(_NPEmailAccount.AccountId, Rec);
    end;
}
#endif