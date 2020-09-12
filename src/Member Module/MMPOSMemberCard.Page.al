page 6060140 "NPR MM POS Member Card"
{
    // MM1.10/TSA/20160405  CASE 234209 Transport MM1.10 - 22 March 2016
    // MM1.11/TSA/20160418  CASE 239328 Added some more fields and chroma coding of good and abad values
    // MM1.18/NAV/20170309  CASE 263198 Transport MM1.18 - 8 March 2017
    // MM1.19/TSA/20170518  CASE 276779 Better handling of ValidUntilDate when membership is expired.
    // MM1.19/TSA/20170519  case 276779 added the GetMembershipMaxValidUntilDate() function
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.23/NPKNAV/20171025  CASE 257011 Transport MM1.23 - 25 October 2017
    // MM1.26/TSA /20180124 CASE 299690 Added button Add Guardian and Activate Membership, clean-up
    // MM1.27/TSA /20180321 CASE 308756 Added output for RemainingPoints
    // MM1.29/TSA /20180511 CASE 314687 Added Contact Profile Questionnair
    // MM1.29/TSA /20180511 CASE 313795 Added GDPR option for guardian
    // MM1.34/TSA /20180907 CASE 327605 Open / Due Amount field
    // MM1.40/TSA /20190823 CASE 360242 Cleaned Green Code
    // MM1.41/TSA /20191008 CASE 366261 When Clienttype is Phone, there is no "LookupOK"
    // MM1.42/TSA /20191118 CASE 378190 Adding Statistics and Ledger Entry Button
    // MM1.42/ALPO/20191125 CASE 377727 Raptor integration: new page actions "Raptor Order History", "Raptor Recommendations"
    // MM1.42/ALPO/20191127 CASE 379072 New tab 'CRM', same as on the page 6060136 "MM Member Card".
    //                                     - Controls moved to the tab: Picture, Gender, Birthday, "E-Mail News Letter"

    Caption = 'Member Details';
    DataCaptionExpression = "External Member No." + ' - ' + "Display Name";
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
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = IsInvalid;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = IsInvalid;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                }
                field("MembershipRoleDisplay.""GDPR Approval"""; MembershipRoleDisplay."GDPR Approval")
                {
                    ApplicationArea = All;
                    Caption = 'GDPR Approval';
                    Editable = false;
                }
            }
            group(CRM)
            {
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                }
                field(Gender; Gender)
                {
                    ApplicationArea = All;
                }
                field(Birthday; Birthday)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = IsBirthday;
                }
                field("E-Mail News Letter"; "E-Mail News Letter")
                {
                    ApplicationArea = All;
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = All;
                }
            }
            group(Membership)
            {
                Caption = 'Membership';
                Editable = false;
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Columns;
                field("Membership.""External Membership No."""; Membership."External Membership No.")
                {
                    ApplicationArea = All;
                    Caption = 'External Membership No.';
                }
                field("Membership.""Membership Code"""; Membership."Membership Code")
                {
                    ApplicationArea = All;
                    Caption = 'Membership Code';
                }
                field("Membership.""Company Name"""; Membership."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                }
                group(Control6014407)
                {
                    ShowCaption = false;
                    field(RemainingPoints; RemainingPoints)
                    {
                        ApplicationArea = All;
                        Caption = 'Remaining Points';
                        Editable = false;
                    }
                    field(ValidFromDate; ValidFromDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Valid From Date';
                        Visible = false;
                    }
                    field(ValidUntilDate; ValidUntilDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Valid Until Date';
                        Style = Unfavorable;
                        StyleExpr = UntilDateAttentionAccent;
                    }
                    field(RemainingAmountText; RemainingAmountText)
                    {
                        ApplicationArea = All;
                        Caption = 'Open / Due Amount.';
                        Style = Unfavorable;
                        StyleExpr = AccentuateDueAmount;
                    }
                }
            }
            part(MemberCardsSubpage; "NPR MM Member Cards ListPart")
            {
                SubPageLink = "Member Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Entry No.")
                              ORDER(Descending);
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            systempart(Control6014400; Notes)
            {
                ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
            }
            action("Register Arrival")
            {
                Caption = 'Register Arrival';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MemberWebService: Codeunit "NPR MM Member WebService";
                    ResponseMessage: Text;
                begin

                    //-MM1.41 [366261]
                    if (not MemberWebService.MemberRegisterArrival("External Member No.", '', 'RTC-CLIENT', ResponseMessage)) then
                        Error(ResponseMessage);

                    Message(ResponseMessage);
                    //+MM1.41 [366261]
                end;
            }
            action("Activate Membership")
            {
                Caption = 'Activate Membership';
                Enabled = NeedsActivation;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                begin

                    //-MM1.22 [278175]
                    ActivateMembership();

                    //+MM1.22 [278175]
                end;
            }
            action("Add Guardian")
            {
                Caption = 'Add Guardian';
                Ellipsis = true;
                Image = ChangeCustomer;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                ApplicationArea = All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                    MemberCardEntryNo: Integer;
                begin
                    //-MM1.22 [289434]
                    if (Confirm(CONFIRM_PRINT, true, StrSubstNo(CONFIRM_PRINT_FMT, "External Member No.", "Display Name"))) then begin
                        //MemberRetailIntegration.PrintMemberCard ("Entry No.", MembershipManagement.GetMemberCardEntryNo ("Entry No.", TODAY));
                        MemberCardEntryNo := CurrPage.MemberCardsSubpage.PAGE.GetCurrentEntryNo();
                        MemberRetailIntegration.PrintMemberCard("Entry No.", MemberCardEntryNo);
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
                action(LedgerEntries)
                {
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CustLedgerEntry: Record "Cust. Ledger Entry";
                        CustomerLedgerEntries: Page "Customer Ledger Entries";
                    begin

                        //-MM1.42 [378190]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        CustLedgerEntry.FilterGroup(2);
                        CustLedgerEntry.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                        CustLedgerEntry.FilterGroup(0);

                        CustomerLedgerEntries.Editable(false);
                        CustomerLedgerEntries.SetTableView(CustLedgerEntry);
                        CustomerLedgerEntries.RunModal();
                        //+MM1.42 [378190]
                    end;
                }
                action(ItemLedgerEntries)
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin
                        //-MM1.42 [377727]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        ItemLedgerEntry.SetCurrentKey("Source Type", "Source No.", "Posting Date");
                        ItemLedgerEntry.FilterGroup(2);
                        ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Customer);
                        ItemLedgerEntry.SetRange("Source No.", Membership."Customer No.");
                        ItemLedgerEntry.FilterGroup(0);
                        ItemLedgerEntry.Ascending(false);
                        if ItemLedgerEntry.FindFirst then;
                        PAGE.RunModal(0, ItemLedgerEntry);
                        //+MM1.42 [377727]
                    end;
                }
                action(CustomerStatisics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'F7';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        CustomerStatistics: Page "Customer Statistics";
                    begin

                        //-MM1.42 [378190]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        Customer.Get(Membership."Customer No.");
                        CustomerStatistics.SetRecord(Customer);
                        CustomerStatistics.Editable(false);
                        CustomerStatistics.RunModal();
                        //+MM1.42 [378190]
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
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin
                        //-MM1.42 [377727]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, "External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");
                        //+MM1.42 [377727]
                    end;
                }
                action(RaptorRecommendations)
                {
                    Caption = 'Recommendations';
                    Enabled = RaptorEnabled;
                    Image = SuggestElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin
                        //-MM1.42 [377727]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, "External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");
                        //+MM1.42 [377727]
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ValidFrom2: Date;
        ValidUntil2: Date;
        RemainAmt: Decimal;
        OrigAmt: Decimal;
        RemainingAmount: Decimal;
        DueAmount: Decimal;
        DueDate: Date;
    begin
        Clear(Membership);
        ValidFromDate := 0D;
        ValidUntilDate := 0D;

        if (GMembershipEntryNo <> 0) then
            MembershipRole.SetFilter("Membership Entry No.", '=%1', GMembershipEntryNo);

        MembershipRole.SetFilter("Member Entry No.", '=%1', "Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindFirst()) then begin
            Membership.Get(MembershipRole."Membership Entry No.");

            Membership.CalcFields("Remaining Points");
            RemainingPoints := Membership."Remaining Points";

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
            RemainingAmountText := StrSubstNo('%1 / %2', Format(RemainingAmount, 0, '<Precision,2:2><Integer><Decimals>'), Format(DueAmount, 0, '<Precision,2:2><Integer><Decimals>'));

        end;

        if (Birthday <> 0D) then
            IsBirthday := ((Date2DMY(Birthday, 1) = Date2DMY(Today, 1)) and (Date2DMY(Birthday, 2) = Date2DMY(Today, 2)));

        IsInvalid := (Blocked);
    end;

    trigger OnOpenPage()
    var
        RaptorSetup: Record "NPR Raptor Setup";
    begin
        //-MM1.42 [377727]
        RaptorEnabled := (RaptorSetup.Get and RaptorSetup."Enable Raptor Functions");
        //+MM1.42 [377727]
    end;

    var
        Membership: Record "NPR MM Membership";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        IsInvalid: Boolean;
        IsBirthday: Boolean;
        IsAboutToExpire: Boolean;
        UntilDateAttentionAccent: Boolean;
        NeedsActivation: Boolean;
        GMembershipEntryNo: Integer;
        RemainingPoints: Integer;
        NO_QUESTIONNAIR: Label 'The profile questionnair is not available right now.';
        MembershipRoleDisplay: Record "NPR MM Membership Role";
        RemainingAmountText: Text[50];
        AccentuateDueAmount: Boolean;
        CONFIRM_PRINT: Label 'Do you want to print a member account card for %1?';
        CONFIRM_PRINT_FMT: Label '[%1] - %2';
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        NO_ENTRIES: Label 'No entries found for member %1.';
        RaptorEnabled: Boolean;

    procedure SetMembershipEntryNo(MembershipEntryNo: Integer)
    begin

        GMembershipEntryNo := MembershipEntryNo;
        Membership.Get(MembershipEntryNo);
    end;

    local procedure AddMembershipGuardian()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ResponseMessage: Text;
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
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
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

            MemberInfoCapture.Init;
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
            Error(NO_QUESTIONNAIR);

        if (not Contact.Get(MembershipRole."Contact No.")) then
            Error(NO_QUESTIONNAIR);

        ProfileManagement.ShowContactQuestionnaireCard(Contact, '', 0);
    end;

    local procedure CreateMembership()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipSalesSetupPage: Page "NPR MM Membership Sales Setup";
    begin

        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
        if (MembershipSalesSetup.Count() = 1) then begin
            MembershipSalesSetup.FindFirst();
            MembershipSalesSetupPage.CreateMembership(MembershipSalesSetup);
        end else begin
            MembershipSalesSetupPage.SetTableView(MembershipSalesSetup);
            MembershipSalesSetupPage.RunModal();
        end;
    end;
}

