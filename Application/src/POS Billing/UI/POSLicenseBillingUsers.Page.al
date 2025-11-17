#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185094 "NPR POS License Billing Users"
{
    Caption = 'NPR Licensed Users';
    PageType = List;
    SourceTable = "NPR POS License Billing User";
    Extensible = false;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    AboutText = '<p>This page displays all users with a valid POS license.</p>';
    AboutTitle = 'NPR Licensed Users';
    AdditionalSearchTerms = 'POS, License, User, Licensed users';
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(MainRepeaterControl)
            {
                ShowCaption = false;

                field("User Security ID"; Rec."User Security ID")
                {
                }
                field("License Type"; Rec."License Type")
                {
                }
                field("User Name"; Rec."User Name")
                {
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        UserCard: Page "User Card";
                        UserRec: Record User;
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
                field("Activated At"; Rec."Activated At")
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
                field("Last Login (DateTime)"; Rec."Last Login (DateTime)")
                {
                    Visible = false;
                }
            }
        }

        area(factboxes)
        {
            part(LicenseAllowancesSubpart; "NPR POS Lic. Bill. Allowances")
            {
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
        area(processing)
        {
            group(UserActionsGroup)
            {
                Caption = 'User Actions';

                action(ViewUserCard)
                {
                    Caption = 'View User Card';
                    ToolTip = 'Open the user card for the selected user.';
                    Image = User;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        UserCard: Page "User Card";
                        UserRec: Record User;
                    begin
                        if IsNullGuid(Rec."User Security ID") then
                            Error(UserNotSelectedErr);

                        if UserRec.Get(Rec."User Security ID") then begin
                            UserCard.SetRecord(UserRec);
                            UserCard.Run();
                        end else
                            Error(UserNotFoundErr);
                    end;
                }
            }

            group(ChangeStatusActions)
            {
                Caption = 'Change User License Status';

                action(ActivateUserLicenseAction)
                {
                    Caption = 'Activate User License';
                    ToolTip = 'Activate the selected user license.';
                    Image = ApprovalSetup;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Enabled = SyncedFromPosBillingAPI;

                    trigger OnAction()
                    begin
                        Rec.Validate(Status, Rec.Status::Active);
                        Rec.Modify(true);

                        Message(DoneMsg);
                    end;
                }

                action(DeactivateUserLicenseAction)
                {
                    Caption = 'Deactivate User License';
                    ToolTip = 'Deactivate the selected user license.';
                    Image = CancelLine;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Rec.Validate(Status, Rec.Status::DisabledManually);
                        Rec.Modify(true);

                        Message(DoneMsg);
                    end;
                }
            }

            action(ForceRefreshAction)
            {
                Caption = 'Force Refresh';
                ToolTip = 'Forces a refresh of the license allowance data from the server.';
                Image = Refresh;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    POSLicenseBillingMgt: Codeunit "NPR POS License Billing Mgt.";
                begin
                    POSLicenseBillingMgt.ForceSyncCurrentLicenseAllowanceFromApi();
                    LicenseTypeAllowances := POSLicenseBillingMgt.GetAllowanceDictionaryPerLicenseType(SyncedFromPosBillingAPI);
                    Message(DoneMsg);
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
                    POSLicenseBillingMgt: Codeunit "NPR POS License Billing Mgt.";
                begin
                    Hyperlink(POSLicenseBillingMgt.GetCustomerPortalUrl());
                end;
            }
        }

        area(navigation)
        {
            action(Users)
            {
                Caption = 'Users';
                ToolTip = 'View all users in the system.';
                Image = Users;
                RunObject = Page Users;
            }
        }
    }

    views
    {
        view(AllListedUsers)
        {
            Caption = 'All Users';
            Filters = where("User Security ID" = filter(<> ''));
        }
    }

    var
        UserNotSelectedErr: Label 'Please select a user.';
        UserNotFoundErr: Label 'User not found.';
        DoneMsg: Label 'Done.';
        LicenseTypeAllowances: Dictionary of [Integer, Integer];
        SyncedFromPosBillingAPI: Boolean;

    trigger OnOpenPage()
    var
        POSLicenseBillingMgt: Codeunit "NPR POS License Billing Mgt.";
    begin
        POSLicenseBillingMgt.SyncTenantEnvironmentCompany(false);
        LicenseTypeAllowances := POSLicenseBillingMgt.GetAllowanceDictionaryPerLicenseType(SyncedFromPosBillingAPI);
    end;
}
#endif