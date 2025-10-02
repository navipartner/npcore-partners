#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185094 "NPR POS License Billing Users"
{
    Caption = 'NPR Licensed Users';
    PageType = List;
    SourceTable = "NPR POS License Billing User";
    InsertAllowed = false;
    ModifyAllowed = false;
    Extensible = false;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    AboutText = '<p>This page displays all users with a valid POS license.</p>';
    AboutTitle = 'NPR Licensed Users';
    AdditionalSearchTerms = 'POS, License, User, Licensed users';

    layout
    {
        area(content)
        {
            group(LicenseInfoGroupControl)
            {
                Caption = 'License Information';

                field(AllowedLicenses; AllowedLicenses)
                {
                    Caption = 'Concurrent Licenses';
                    ToolTip = 'The number of concurrent licenses available for this environment.';
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        POSLicenseBillingMgt: Codeunit "NPR POS License Billing Mgt.";
                    begin
                        Hyperlink(POSLicenseBillingMgt.GetCustomerPortalUrl());
                    end;
                }
            }
            repeater(MainRepeaterControl)
            {
                ShowCaption = false;



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

                field("Last Login (DateTime)"; Rec."Last Login (DateTime)")
                {
                }
            }
        }

        area(factboxes)
        {
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
            action(AddUser)
            {
                Caption = 'Add User';
                ToolTip = 'Add a new licensed user.';
                Image = Add;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    UserRec: Record User;
                    POSLicenseBillingUser: Record "NPR POS License Billing User";
                    UsersPage: Page Users;
                begin
                    UsersPage.LookupMode(true);
                    if (UsersPage.RunModal() = Action::LookupOK) then begin
                        UsersPage.GetRecord(UserRec);
                        if (POSLicenseBillingUser.Get(UserRec."User Security ID")) then
                            Message(UserAlreadyLicensedMsg, UserRec."User Name")
                        else begin
                            POSLicenseBillingUser.Init();
                            POSLicenseBillingUser."User Security ID" := UserRec."User Security ID";
                            POSLicenseBillingUser.Insert(true);
                        end;
                    end;
                end;
            }

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
        UserAlreadyLicensedMsg: Label 'User %1 is already a licensed POS user.', Comment = '%1 = User Name';
        AllowedLicenses: Integer;

    trigger OnOpenPage()
    var
        POSLicenseBillingMgt: Codeunit "NPR POS License Billing Mgt.";
    begin
        AllowedLicenses := POSLicenseBillingMgt.GetAllowedLicenses();
    end;
}
#endif