page 6184516 "NPR Licensed Users"
{
    Caption = 'NPR Licensed Users';
    PageType = List;
    SourceTable = "NPR License User";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    DelayedInsert = true;
    Extensible = false;
    AboutText = '<p>This page displays all users with a module license.</p>';
    AboutTitle = 'NPR Licensed Users';
    AdditionalSearchTerms = 'POS, KDS, Scanner, License, User';
    layout
    {
        area(Content)
        {
            repeater(MainRepeaterControl)
            {
                field(Module; Rec.Module)
                {
                }
                field("User Security ID"; Rec."User Security ID")
                {
                }
                field("License Term"; Rec."License Term")
                {
                }
                field("User Name"; Rec."User Name")
                {
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        UserRec: Record User;
                        UserCard: Page "User Card";
                    begin
                        if UserRec.Get(Rec."User Security ID") then begin
                            UserCard.SetRecord(UserRec);
                            UserCard.Run();
                        end;
                    end;
                }
                field("Full Name"; Rec."Full Name")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Activated By"; Rec."Activated By")
                {
                    Visible = false;
                }
                field("Activated By Name"; Rec."Activated By Name")
                {
                    Visible = false;
                }
                field("Deactivated At"; Rec."Deactivated At")
                {
                }
                field("Deactivated By"; Rec."Deactivated By")
                {
                    Visible = false;
                }
                field("Deactivated By Name"; Rec."Deactivated By Name")
                {
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(LicensePoolsPart; "NPR License Pools")
            {
                SubPageLink = Module = field(Module);
            }
            part(LicenseStatisticsPart; "NPR License Statistics")
            {
                SubPageLink = Module = field(Module);
            }
            systempart(RecordLinksFactBox; Links)
            {
            }
            systempart(NotesFactBox; Notes)
            {
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActivateUser)
            {
                Caption = 'Activate License';
                ToolTip = 'Activate the selected user license.';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "NPR License Mgt.";
                begin
                    Rec.TestField("License Term");
                    LicenseMgt.ActivateUser(Rec.Module, Rec."User Security ID", Rec."License Term");
                    CurrPage.Update(false);
                end;
            }
            action(DeactivateUser)
            {
                Caption = 'Deactivate License';
                ToolTip = 'Deactivate the selected user license.';
                Image = Reject;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "NPR License Mgt.";
                begin
                    LicenseMgt.DeactivateUser(Rec.Module, Rec."User Security ID");
                    CurrPage.Update(false);
                end;
            }
            action(ForceRefresh)
            {
                Caption = 'Refresh from Portal';
                ToolTip = 'Re-sync license pools from Customer Portal using billing API.';
                Image = Refresh;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "NPR License Mgt.";
                begin
                    if not LicenseMgt.SyncLicensePools(true) then
                        Message(RefreshFailedMsg, LicenseMgt.GetLastSyncFailureReason());
                    CurrPage.Update(false);
                end;
            }

            action(VisitCustomerPortalAction)
            {
                Caption = 'Visit Customer Portal';
                ToolTip = 'Open the customer portal.';
                Image = CurrencyExchangeRates;
                Promoted = false;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "NPR License Mgt.";
                begin
                    Hyperlink(LicenseMgt.GetCustomerPortalUrl());
                end;
            }

        }
    }

    var
        RefreshFailedMsg: Label 'Could not refresh license pools from the portal.\%1', Comment = '%1 = brief failure detail (HTTP status, not-in-production, or no data)';

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        LicenseMgt.SyncTenantEnvironmentCompany(false);
        LicenseMgt.SyncLicensePools(false);
    end;
}
