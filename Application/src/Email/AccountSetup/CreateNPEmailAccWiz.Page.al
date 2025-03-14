#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6184994 "NPR CreateNPEmailAccWiz"
{
    Extensible = false;
    Caption = 'Create NP Email Account Wizard';
    PageType = NavigatePage;
    SourceTable = "NPR NP Email Account";
    SourceTableTemporary = true;
    Permissions = tabledata "NPR NP Email Account" = rimd;
    UsageCategory = None;
    Editable = true;

    layout
    {
        area(Content)
        {
            group(IntroStep)
            {
                Visible = (_CurrentStep = _CurrentStep::Intro);
                Caption = 'Welcome to NP Email';
                InstructionalText = 'This guide will help you set up an NP Email Account. This account will hold all setup related and the individual accounts, you''ll be sending from will be associated with it.';
            }

            group(AccountDetailsStep)
            {
                Visible = (_CurrentStep = _CurrentStep::AccountDetail);

                field(Username; Rec.Username)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the username for the NP Email Account.';
                    Editable = false;
                }
                field(CompanyName; Rec.CompanyName)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the Company Name for the NP Email Account.';
                }
                field(BillingEmail; Rec.BillingEmail)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the Billing E-mail for the NP Email Account.';
                }
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
            action(DownloadAsExcel)
            {
                ApplicationArea = NPRNPEmail;
                Visible = (_CurrentStep = _CurrentStep::DNSSetup);
                Caption = 'Download as Excel';
                ToolTip = 'Download as Excel';
                Image = Download;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.DNSRecords.Page.DownloadAsExcel();
                end;
            }
        }
    }

    var
        _CurrentStep: Option Intro,AccountDetail,Domain,DNSSetup;
        _DomainDNSRecord: Record "NPR NPEmailDomainDNSRecord";
        _Domain: Text[255];
        _NPEmailAccount: Record "NPR NP Email Account";

    trigger OnOpenPage()
    var
        CompanyInformation: Record "Company Information";
        SendGridClient: Codeunit "NPR SendGrid Client";
    begin
        if (_NPEmailAccount.FindFirst()) then begin
            Rec := _NPEmailAccount;
            Rec.Insert();
            _CurrentStep := _CurrentStep::Domain;
            exit;
        end;

        if (not CompanyInformation.Get()) then;

        Rec.Init();
#pragma warning disable AA0139
        Rec.Username := SendGridClient.GetEnvironmentIdentifier();
#pragma warning restore AA0139
        Rec.CompanyName := CompanyInformation.Name;
        Rec.Insert();
    end;

    local procedure NextStep()
    var
        SendGridClient: Codeunit "NPR SendGrid Client";
        NPEmailDomain: Record "NPR NP Email Domain";
        DomainMustBeFilledErr: Label 'The domain field must be filled before proceeding.';
    begin
        case _CurrentStep of
            _CurrentStep::Intro:
                begin
                    _CurrentStep := _CurrentStep::AccountDetail;
                end;
            _CurrentStep::AccountDetail:
                begin
                    _NPEmailAccount := Rec;
                    SendGridClient.CreateSubuser(SendGridClient.GetEnvironmentIdentifier(), _NPEmailAccount);
                    _CurrentStep := _CurrentStep::Domain;
                end;
            _CurrentStep::Domain:
                begin
                    if (_Domain = '') then
                        Error(DomainMustBeFilledErr);
                    SendGridClient.CreateDomain(_NPEmailAccount, _Domain, NPEmailDomain, _DomainDNSRecord);
                    CurrPage.DNSRecords.Page.SetTempRecord(_DomainDNSRecord);
                    _CurrentStep := _CurrentStep::DNSSetup;
                end;
            _CurrentStep::DNSSetup:
                CurrPage.Close();
        end;
    end;
}
#endif