page 6060140 "NPR MM POS Member Card"
{
    UsageCategory = None;
    Caption = 'Member Details';
    DataCaptionExpression = Rec."External Member No." + ' - ' + Rec."Display Name";
    DeleteAllowed = false;
    InsertAllowed = false;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    ShowFilter = false;
    SourceTable = "NPR MM Member";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Member No."; Rec."External Member No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    Style = Unfavorable;
                    StyleExpr = IsInvalid;
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    Style = Unfavorable;
                    StyleExpr = IsInvalid;
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    trigger OnValidate()
                    begin
                        ValidateMemberPhoneNumber(Rec);
                    end;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    trigger OnValidate()
                    begin
                        ValidateMemberEmail(Rec);
                    end;
                }
                field("GDPR Approval"; MembershipRoleDisplay."GDPR Approval")
                {
                    Caption = 'GDPR Approval';
                    Editable = false;
                    ToolTip = 'Specifies the value of the GDPR Approval field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(CRM)
            {
                group(MemberImage)
                {
                    Caption = 'Member Image';
                    ShowCaption = false;
                    field(Picture; Rec.Image)
                    {
                        ToolTip = 'Specifies the value of the Picture field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Needs to be in a Card Part, but it is breaking change to delete.';
                        Visible = false;
                    }
                    part(MemberPicture; "NPR MM Member Picture")
                    {
                        Caption = 'Picture';
                        ShowFilter = false;
                        SubPageLink = "Entry No." = field("Entry No.");
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        Visible = not _CloudflareMediaVisible;
                    }
                    part(CloudflareMedia; "NPR MMMemberExtImageFactBox")
                    {
                        Caption = 'Picture';
                        ShowFilter = false;
                        SubPageLink = "Entry No." = field("Entry No.");
                        Visible = _CloudflareMediaVisible;
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
                field(Gender; Rec.Gender)
                {
                    ToolTip = 'Specifies the value of the Gender field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Birthday; Rec.Birthday)
                {
                    Style = Favorable;
                    StyleExpr = IsBirthday;
                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ShowMandatory = _IsBirthdayMandatory;

                    trigger OnValidate()
                    var
                        FutureDoB: Label 'Date of birth is mandatory! Setting a date into the future will bypass essential features. Do you wish to keep the future date of birth?';
                    begin
                        Rec.Modify(); // To ensure that the ValidateAgeForMember procedure sees the new value
                        ValidateAgeForMember(Rec);

                        if (_IsBirthdayMandatory and (Rec.Birthday > Today())) then begin
                            if (not Confirm(FutureDoB, true)) then
                                Rec.Birthday := 0D;
                        end;

                        CurrPage.Update(false);
                    end;
                }

                field("E-Mail News Letter"; Rec."E-Mail News Letter")
                {
                    ToolTip = 'Specifies the value of the E-Mail News Letter field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ToolTip = 'Specifies the value of the Notification Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(Membership)
            {
                Caption = 'Membership';
                Editable = false;
                field("External Membership No."; Membership."External Membership No.")
                {
                    Caption = 'External Membership No.';
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Membership."Membership Code")
                {
                    Caption = 'Membership Code';
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Company Name"; Membership."Company Name")
                {
                    Caption = 'Company Name';
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Remaining Points"; RemainingPoints)
                    {
                        Caption = 'Remaining Points';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Remaining Points field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Valid From Date"; ValidFromDate)
                    {
                        Caption = 'Valid From Date';
                        Visible = false;
                        ToolTip = 'Specifies the value of the Valid From Date field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Valid Until Date"; ValidUntilDate)
                    {
                        Caption = 'Valid Until Date';
                        Style = Unfavorable;
                        StyleExpr = UntilDateAttentionAccent;
                        ToolTip = 'Specifies the value of the Valid Until Date field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Remaining Amount Text"; RemainingAmountText)
                    {
                        Caption = 'Open / Due Amount.';
                        Style = Unfavorable;
                        StyleExpr = AccentuateDueAmount;
                        ToolTip = 'Specifies the value of the Open / Due Amount. field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field(AutoRenewal; _AutoRenewal)
                    {
                        Caption = 'Auto Renewal';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Auto Renewal field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }

                }
            }
            group(points)
            {
                Caption = 'Points Summary';
                Editable = false;
                part("PointsSummary"; "NPR MM Members. Points Summary")
                {
                    SubPageView = SORTING("Membership Entry No.", "Relative Period") ORDER(Descending);
                    ShowFilter = false;
                    UpdatePropagation = Both;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(card)
            {
                Caption = 'Membership Cards';
                Editable = false;
                part("Member Cards Subpage"; "NPR MM Member Cards ListPart")
                {
                    SubPageLink = "Member Entry No." = FIELD("Entry No.");
                    SubPageView = SORTING("Entry No.") ORDER(Descending);
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ShowFilter = false;
                }
            }
        }
        area(factboxes)
        {
            part(MMMemberPicture; "NPR MM Member Picture")
            {
                Caption = 'Picture';
                ShowFilter = false;
                SubPageLink = "Entry No." = field("Entry No.");
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Visible = not _CloudflareMediaVisible;
            }
            part(CloudflareMediaFactBox; "NPR MMMemberExtImageFactBox")
            {
                Caption = 'Picture';
                ShowFilter = false;
                SubPageLink = "Entry No." = field("Entry No.");
                Visible = _CloudflareMediaVisible;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            systempart(Control6014400; Notes)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Member Card")
            {
                Caption = 'Member Card';
                Image = Customer;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");

                ToolTip = 'Executes the Member Card action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Register Arrival")
            {
                Caption = 'Register Arrival';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Register Arrival action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MemberWebService: Codeunit "NPR MM Member WebService";
                    ResponseMessage: Text;
                begin

                    if (not MemberWebService.MemberRegisterArrival(Rec."External Member No.", '', 'RTC-CLIENT', ResponseMessage)) then
                        Error(ResponseMessage);

                    Message(ResponseMessage);

                end;
            }
            action("Activate Membership")
            {
                Caption = 'Activate Membership';
                Enabled = NeedsActivation;
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Activate Membership action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    ActivateMembership();
                end;
            }
            action("Add Guardian")
            {
                Caption = 'Add Guardian';
                Ellipsis = true;
                Image = ChangeCustomer;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;

                ToolTip = 'Executes the Add Guardian action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    AddMembershipGuardian();
                    CurrPage.Update(false);
                end;
            }
            action(Profiles)
            {
                Caption = 'Profiles';
                Image = Answers;
                Promoted = true;
                PromotedOnly = true;

                ToolTip = 'Executes the Profiles action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    ContactQuestionnaire();
                end;
            }
            action(PrintCard)
            {
                Caption = 'Print Member Card';
                Ellipsis = true;
                Image = PrintVoucher;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Print Member Card action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MemberCardEntryNo: Integer;
                begin

                    if (Confirm(CONFIRM_PRINT, true, StrSubstNo(CONFIRM_PRINT_FMT, Rec."External Member No.", Rec."Display Name"))) then begin
                        //MemberRetailIntegration.PrintMemberCard ("Entry No.", MembershipManagement.GetMemberCardEntryNo ("Entry No.", TODAY));
                        MemberCardEntryNo := CurrPage."Member Cards Subpage".PAGE.GetCurrentEntryNo();
                        MemberRetailIntegration.PrintMemberCard(Rec."Entry No.", MemberCardEntryNo);
                    end;
                end;
            }
            action(TakePicture)
            {
                Caption = 'Take Picture';
                Image = Camera;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Take Picture action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
                begin
                    MembershipManagement.TakeMemberPicture(Rec);
                    if (_CloudflareMediaVisible) then begin
                        CurrPage.CloudflareMedia.Page.RefreshImage();
                        CurrPage.CloudflareMediaFactBox.Page.RefreshImage();
                    end;
                end;
            }
        }
        area(navigation)
        {
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Ledger Entries")
                {
                    Caption = 'Ledger Entries';
                    Image = CustomerLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Executes the Ledger Entries action';

                    trigger OnAction()
                    var
                        CustLedgerEntry: Record "Cust. Ledger Entry";
                        CustomerLedgerEntries: Page "Customer Ledger Entries";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        CustLedgerEntry.FilterGroup(2);
                        CustLedgerEntry.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                        CustLedgerEntry.FilterGroup(0);

                        CustomerLedgerEntries.Editable(false);
                        CustomerLedgerEntries.SetTableView(CustLedgerEntry);
                        CustomerLedgerEntries.RunModal();

                    end;
                }
                action("Item Ledger Entries")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    ToolTip = 'Executes the Item Ledger Entries action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        ItemLedgerEntry.SetCurrentKey("Source Type", "Source No.", "Posting Date");
                        ItemLedgerEntry.FilterGroup(2);
                        ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Customer);
                        ItemLedgerEntry.SetRange("Source No.", Membership."Customer No.");
                        ItemLedgerEntry.FilterGroup(0);
                        ItemLedgerEntry.Ascending(false);
                        if (ItemLedgerEntry.FindFirst()) then;
                        PAGE.RunModal(0, ItemLedgerEntry);

                    end;
                }
                action("Customer Statisics")
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'F7';

                    ToolTip = 'Executes the Statistics action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        CustomerStatistics: Page "Customer Statistics";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        Customer.Get(Membership."Customer No.");
                        CustomerStatistics.SetRecord(Customer);
                        CustomerStatistics.Editable(false);
                        CustomerStatistics.RunModal();

                    end;
                }
            }
            group("Raptor Integration")
            {
                Caption = 'Raptor Integration';
                action(RaptorBrowsingHistory)
                {
                    Caption = 'Browsing History';
                    Enabled = RaptorEnabled;
                    Image = ViewRegisteredOrder;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;

                    ToolTip = 'Executes the Browsing History action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");
                        if (RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory(), true, RaptorAction)) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");

                    end;
                }
                action("Raptor Recommendations")
                {
                    Caption = 'Recommendations';
                    Enabled = RaptorEnabled;
                    Image = SuggestElectronicDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;

                    ToolTip = 'Executes the Recommendations action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");
                        if (RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations(), true, RaptorAction)) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");

                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ValidFrom2: Date;
        ValidUntil2: Date;
        RemainAmt: Decimal;
        OrigAmt: Decimal;
        RemainingAmount: Decimal;
        DueAmount: Decimal;
        DueDate: Date;
        IsAboutToExpire: Boolean;
        PlaceHolderLbl: Label '%1 / %2', Locked = true;
    begin
        Clear(Membership);
        ValidFromDate := 0D;
        ValidUntilDate := 0D;

        if (GMembershipEntryNo <> 0) then
            MembershipRole.SetFilter("Membership Entry No.", '=%1', GMembershipEntryNo);

        MembershipRole.SetFilter("Member Entry No.", '=%1', Rec."Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindFirst()) then begin
            Membership.Get(MembershipRole."Membership Entry No.");
            _AutoRenewal := (Membership."Auto-Renew" <> Membership."Auto-Renew"::No);

            Membership.CalcFields("Remaining Points");
            RemainingPoints := Membership."Remaining Points";

            CurrPage.PointsSummary.Page.FillPageSummary(GMembershipEntryNo);
            CurrPage.PointsSummary.Page.Update(false);

            MembershipRoleDisplay.Get(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.");
            MembershipRoleDisplay.CalcFields("GDPR Approval");

            MembershipManagement.GetMembershipMaxValidUntilDate(MembershipRole."Membership Entry No.", ValidUntilDate);

            if (ValidUntilDate <> 0D) then
                IsAboutToExpire := ((CalcDate('<-1M>', ValidUntilDate) < Today) and (ValidUntilDate > Today));

            if (IsAboutToExpire) then begin
                MembershipManagement.GetMembershipValidDate(MembershipRole."Membership Entry No.", CalcDate('<+1D>', ValidUntilDate), ValidFrom2, ValidUntil2);

                if (ValidUntil2 > ValidUntilDate) then begin
                    ValidUntilDate := ValidUntil2;
                    IsAboutToExpire := false;
                end;

            end;

            if (ValidUntilDate < Today) then
                UntilDateAttentionAccent := true;

            if (IsAboutToExpire) then
                UntilDateAttentionAccent := true;

            OrigAmt := 0;
            RemainAmt := 0;
            MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipRole."Membership Entry No.");
            if (MembershipEntry.FindSet()) then begin
                repeat
                    if (MembershipManagement.CalculateRemainingAmount(MembershipEntry, OrigAmt, RemainAmt, DueDate)) then begin
                        if (DueDate < Today) then
                            DueAmount += RemainAmt
                        else
                            RemainingAmount += RemainAmt;
                    end;
                until (MembershipEntry.Next() = 0);
            end;
            AccentuateDueAmount := (DueAmount > 0);
            RemainingAmountText := StrSubstNo(PlaceHolderLbl, Format(RemainingAmount, 0, '<Precision,2:2><Integer><Decimals>'), Format(DueAmount, 0, '<Precision,2:2><Integer><Decimals>'));

        end;

        _IsBirthdayMandatory := CheckBirthdayMandatory(Rec);
        _InitialBirthday := Rec.Birthday;
        if (_IsBirthdayMandatory and (Rec.Birthday > Today())) then
            Rec.Birthday := 0D;

        if (Rec.Birthday <> 0D) then
            IsBirthday := ((Date2DMY(Rec.Birthday, 1) = Date2DMY(Today, 1)) and (Date2DMY(Rec.Birthday, 2) = Date2DMY(Today, 2)));

        IsInvalid := (Rec.Blocked);
    end;

    trigger OnOpenPage()
    var
        RaptorSetup: Record "NPR Raptor Setup";
        CloudflareMediaFeature: Codeunit "NPR MemberImageMediaFeature";
    begin
        RaptorEnabled := (RaptorSetup.Get() and RaptorSetup."Enable Raptor Functions");
        _CloudflareMediaVisible := CloudflareMediaFeature.IsFeatureEnabled();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (not (CloseAction in [Action::OK, Action::LookupOK, Action::Yes])) then begin
            if (_IsBirthdayMandatory and (Rec.Birthday = 0D)) then begin
                Rec.Birthday := _InitialBirthday;
                Rec.Modify();
            end;
            exit(true);
        end;

        if (_IsBirthdayMandatory and (Rec.Birthday = 0D)) then begin
            Message('Date of birth is mandatory. Please enter a valid date of birth before leaving the member card.');
            exit(false);
        end;

        exit(true);
    end;

    var
        Membership: Record "NPR MM Membership";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        IsInvalid: Boolean;
        IsBirthday: Boolean;
        _IsBirthdayMandatory: Boolean;
        _InitialBirthday: Date;

        UntilDateAttentionAccent: Boolean;
        NeedsActivation: Boolean;
        GMembershipEntryNo: Integer;
        RemainingPoints: Integer;
        NO_QUESTIONNAIRE: Label 'The profile questionnair is not available right now.';
        MembershipRoleDisplay: Record "NPR MM Membership Role";
        RemainingAmountText: Text[50];
        AccentuateDueAmount: Boolean;
        CONFIRM_PRINT: Label 'Do you want to print a member account card for %1?';
        CONFIRM_PRINT_FMT: Label '[%1] - %2';
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        NO_ENTRIES: Label 'No entries found for member %1.';
        RaptorEnabled: Boolean;
        _AutoRenewal: Boolean;
        _CloudflareMediaVisible: Boolean;

    internal procedure SetMembershipEntryNo(MembershipEntryNo: Integer)
    begin

        GMembershipEntryNo := MembershipEntryNo;
        Membership.Get(MembershipEntryNo);
    end;

    local procedure AddMembershipGuardian()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        Commit();

        MemberInfoCapturePage.SetAddMembershipGuardianMode();
        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();
        if (PageAction = ACTION::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);
            MembershipManagement.AddGuardianMember(Membership."Entry No.", MemberInfoCapture."Guardian External Member No.", MemberInfoCapture."GDPR Approval");

        end;
    end;

    local procedure ActivateMembership()
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        if (MembershipEntry.IsEmpty()) then begin
            MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
            MembershipSalesSetup.SetFilter("Membership Code", '=%1', Membership."Membership Code");
            MembershipSalesSetup.SetFilter(Blocked, '=%1', false);
            MembershipSalesSetup.FindFirst();

            MemberInfoCapture.Init();
            MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

            MembershipManagement.AddMembershipLedgerEntry_NEW(Membership."Entry No.", Membership."Issued Date", MembershipSalesSetup, MemberInfoCapture);

        end;

        MembershipManagement.ActivateMembershipLedgerEntry(Membership."Entry No.", Today);
    end;

    local procedure ContactQuestionnaire()
    var
        ProfileManagement: Codeunit ProfileManagement;
        MembershipRole: Record "NPR MM Membership Role";
        Contact: Record Contact;
    begin

        if (not MembershipRole.Get(GMembershipEntryNo, Rec."Entry No.")) then
            Error(NO_QUESTIONNAIRE);

        if (not Contact.Get(MembershipRole."Contact No.")) then
            Error(NO_QUESTIONNAIRE);

        ProfileManagement.ShowContactQuestionnaireCard(Contact, '', 0);
    end;

    local procedure ValidateMemberPhoneNumber(Member: Record "NPR MM Member")
    var
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MemberManagement.ValidateMemberPhoneNumber(Member);
    end;

    local procedure ValidateMemberEmail(Member: Record "NPR MM Member")
    var
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MemberManagement.ValidateMemberEmail(Member)
    end;

    local procedure CheckBirthdayMandatory(Member: Record "NPR MM Member"): Boolean
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        exit(MembershipManagement.IsBirthdayMandatory(Member));
    end;

    local procedure ValidateAgeForMember(var Member: Record "NPR MM Member"): Boolean
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ReasonText: Text;
    begin
        if (CheckBirthdayMandatory(Member)) then begin
            if (Member.Birthday = 0D) then
                exit(false);

            if (Member.Birthday > Today()) then
                exit(true); // Allow future DoB, but warn user

            if (not MembershipManagement.IsAgeValidForMember(Member, Today, ReasonText)) then
                Error(ReasonText);
        end;
    end;

}

