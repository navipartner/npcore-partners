#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6185093 "NPR NPEmailAddDomainWiz"
{
    Extensible = false;
    Caption = 'NP Email Add Domain Wizard';
    PageType = NavigatePage;
    UsageCategory = None;
    Editable = true;

    layout
    {
        area(Content)
        {
            group(IntroStep)
            {
                Visible = (_CurrentStep = _CurrentStep::Intro);
                Caption = 'Add a new domain';
                InstructionalText = 'This guide will help you add a domain to your NP Email account. When the domain is added and authenticated, you will be able to use it to send e-mails.';
            }
            group(DomainStep)
            {
                Visible = (_CurrentStep = _CurrentStep::Domain);
                InstructionalText = 'Please enter the domain that you wish to send e-mails from. The setup will require you to have access to modify DNS records for the domain.';

                field(_Domain; _Domain)
                {
                    Caption = 'Domain';
                    ToolTip = 'Specifies the domain to be used when sending e-mails.';
                    ApplicationArea = NPRNPEmail;
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        Client: Codeunit "NPR SendGrid Client";
                    begin
#pragma warning disable AA0139
                        _Domain := _Domain.Trim().ToLower();
#pragma warning restore AA0139
                        Client.ValidateDomain(_Domain);
                    end;
                }
            }
            group(DNSStep)
            {
                Visible = (_CurrentStep = _CurrentStep::DNSSetup);
                InstructionalText = 'To set up your domain for sending e-mail, you need to set up the attached DNS records. If you need the help of somebody else to do it, you can download them as Excel.';

                part(DNSRecords; "NPR NPEmailDomainDNSRecords")
                {
                    ApplicationArea = NPRNPEmail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Cancel)
            {
                ApplicationArea = NPRNPEmail;
                Caption = 'Cancel';
                ToolTip = 'Cancel';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action("Next")
            {
                ApplicationArea = NPRNPEmail;
                Caption = 'Next';
                ToolTip = 'Next';
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep();
                end;
            }
            action(DownloadAsTxt)
            {
                ApplicationArea = NPRNPEmail;
                Visible = (_CurrentStep = _CurrentStep::DNSSetup);
                Caption = 'Download as TXT';
                ToolTip = 'Download as TXT';
                Image = Download;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.DNSRecords.Page.DownloadAsTxt();
                end;
            }
        }
    }

    var
        _CurrentStep: Option Intro,Domain,DNSSetup;
        _Domain: Text[300];
        _DomainDNSRecord: Record "NPR NPEmailDomainDNSRecord";
        _NPEmailAccount: Record "NPR NP Email Account";
        _Initialized: Boolean;

    trigger OnOpenPage()
    begin
        if (not _Initialized) then
            Error('The wizard was not properly initialized. This is a programming bug. Contact system vendor!');
    end;

    internal procedure Initialize(NPEmailAccount: Record "NPR NP Email Account")
    begin
        _NPEmailAccount := NPEmailAccount;
        _Initialized := true;
    end;

    local procedure NextStep()
    var
        SendGridClient: Codeunit "NPR SendGrid Client";
        TempNPEmailDomain: Record "NPR NP Email Domain" temporary;
        DomainMustBeFilledErr: Label 'The domain field must be filled before proceeding.';
    begin
        case _CurrentStep of
            _CurrentStep::Intro:
                _CurrentStep := _CurrentStep::Domain;
            _CurrentStep::Domain:
                begin
                    if (_Domain = '') then
                        Error(DomainMustBeFilledErr);
                    SendGridClient.CreateDomain(_NPEmailAccount, _Domain, TempNPEmailDomain, _DomainDNSRecord);
                    CurrPage.DNSRecords.Page.SetTempRecord(_DomainDNSRecord);
                    _CurrentStep := _CurrentStep::DNSSetup;
                end;
            _CurrentStep::DNSSetup:
                CurrPage.Close();
        end;
    end;
}
#endif