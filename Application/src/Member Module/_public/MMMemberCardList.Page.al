page 6060130 "NPR MM Member Card List"
{
    Caption = 'Member Cards';
    ContextSensitiveHelpPage = 'docs/entertainment/membership/intro/';
    AdditionalSearchTerms = ' Member Card List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = true;
    PageType = Worksheet;
    SourceTable = "NPR MM Member Card";
    UsageCategory = Lists;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    CardPageId = "NPR MM Member Card Card";
    PromotedActionCategories = 'New,Manage,Report,History,Raptor,Navigate,Arrival,Print';

    layout
    {
        area(content)
        {
            field(Search; _SearchTerm)
            {
                Editable = true;
                Caption = 'Smart Search';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ToolTip = 'This search is optimized to search relevant columns only.';
                trigger OnValidate()
                var
                    MemberCard: Record "NPR MM Member Card";
                    SmartSearch: Codeunit "NPR MM Smart Search";
                begin
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);
                    if (_SearchTerm = '') then begin
                        CurrPage.Update(false);
                        exit;
                    end;

                    SmartSearch.SearchMemberCard(_SearchTerm, MemberCard);

                    Rec.Copy(MemberCard);
                    Rec.SetLoadFields();
                    Rec.MarkedOnly(true);
                    CurrPage.Update(false);
                end;
            }
            repeater(Group)
            {
                Editable = false;
                field("External Card No."; Rec."External Card No.")
                {
                    ToolTip = 'Specifies the value of the External Card No.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    trigger OnDrillDown()
                    var
                        MemberCard: Page "NPR MM Member Card";
                        MembershipCard: Page "NPR MM Membership Card";
                        Member: Record "NPR MM Member";
                        Membership: Record "NPR MM Membership";
                    begin
                        if (Member.Get(Rec."Member Entry No.")) then begin
                            MemberCard.SetRecord(Member);
                            MemberCard.Run();
                        end else begin
                            Membership.Get(Rec."Membership Entry No.");
                            MembershipCard.SetRecord(Membership);
                            MembershipCard.Run();
                        end;
                    end;
                }
                field("Valid Until"; Rec."Valid Until")
                {
                    ToolTip = 'Specifies until when the card will be valid.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

                field("External Membership No."; Rec."External Membership No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the external number of the membership.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Membership Card";
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the code for the member.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Membership Card";
                }
                field("External Member No."; Rec."External Member No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the external member number.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field("Display Name"; Rec."Display Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the name to be displayed.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    Editable = false;
                    ToolTip = 'Specifies the e-mail address for the member.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Blocked field';
                    Editable = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(MMMemberPicture; "NPR MM Member Picture")
            {
                Caption = 'Picture';
                SubPageLink = "Entry No." = field("Member Entry No.");
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Visible = false;
            }
            part(MemberCard; "NPR MM Member Card FactBox")
            {
                Caption = 'Member Card Details';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Membership)
            {
                Caption = 'Membership';
                Ellipsis = true;
                Image = CustomerList;

                ToolTip = 'Opens Membership Card';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Scope = Repeater;

                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");
            }
            action(Members)
            {
                Caption = 'Members';
                Ellipsis = true;
                Image = Customer;

                ToolTip = 'Opens Members Card';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Scope = Repeater;

                RunObject = Page "NPR MM Member Card";
                RunPageLink = "Entry No." = FIELD("Member Entry No.");
            }
            action("Open Coupons")
            {
                Caption = 'Coupons';
                Ellipsis = true;
                Image = Voucher;

                ToolTip = 'Opens coupons list';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Scope = Repeater;
                trigger OnAction()
                var
                    Membership: Record "NPR MM Membership";
                    CouponList: Page "NPR NpDc Coupons";
                    Coupons: Record "NPR NpDc Coupon";
                begin
                    Membership.Get(Rec."Membership Entry No.");
                    if (Membership."Customer No." = '') then
                        exit;

                    Coupons.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                    CouponList.SetTableView(Coupons);
                    CouponList.Run();
                end;
            }
            action(Achievements)
            {
                Caption = 'Achievements';
                Ellipsis = true;
                Image = History;

                ToolTip = 'This action opens the achievements and progress list for the membership.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category6;

                trigger OnAction()
                var
                    Membership: Record "NPR MM Membership";
                    MemberGoals: Page "NPR MM AchMemberGoalList";
                    Goals: Record "NPR MM AchGoal";
                begin
                    Membership.Get(Rec."Membership Entry No.");
                    Goals.FilterGroup(248);
                    Goals.SetFilter(CommunityCode, '=%1', Membership."Community Code");
                    Goals.SetFilter(MembershipCode, '=%1', Membership."Membership Code");
                    Goals.SetFilter(Activated, '=%1', true);
                    Goals.SetFilter(MembershipEntryNoFilter, '=%1', Rec."Entry No.");
                    Goals.FilterGroup(0);
                    MemberGoals.SetTableView(Goals);
                    MemberGoals.Run();
                end;
            }
            action(Notifications)
            {
                Caption = 'Notifications';
                Ellipsis = true;
                Image = Interaction;

                ToolTip = 'Opens membership notifications';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category6;

                RunObject = Page "NPR MM Membership Notific.";
                RunPageLink = "Membership Entry No." = FIELD("Membership Entry No.");
                RunPageView = SORTING("Membership Entry No.");
            }
            action("Register Arrival")
            {
                Caption = 'Register Arrival';
                Image = Approve;

                ToolTip = 'Executes the Register Arrival action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category7;

                trigger OnAction()
                var
                    MemberWebService: Codeunit "NPR MM Member WebService";
                    ResponseMessage: Text;
                begin
                    if (not MemberWebService.MemberCardRegisterArrival(Rec."External Card No.", '', 'RTC-CLIENT', ResponseMessage)) then
                        Error(ResponseMessage);

                    Message(ResponseMessage);
                end;
            }
            action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;

                ToolTip = 'Opens Arrival Log List';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category7;
                Scope = Repeater;

                RunObject = Page "NPR MM Member Arrival Log";
                RunPageLink = "External Card No." = FIELD("External Card No.");
            }
            action("Ledger E&ntries")
            {
                Caption = 'Ledger E&ntries';
                Image = CustomerLedger;

                ToolTip = 'Opens ledger entries for the selected record.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Ctrl+F7';

                trigger OnAction()
                var
                    Membership: Record "NPR MM Membership";
                    CustomerLedgerEntries: Page "Customer Ledger Entries";
                    Entries: Record "Cust. Ledger Entry";
                begin
                    Membership.Get(Rec."Membership Entry No.");
                    if (Membership."Customer No." = '') then
                        exit;
                    Entries.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                    CustomerLedgerEntries.SetTableView(Entries);
                    CustomerLedgerEntries.Run();
                end;
            }
            action(ItemLedgerEntries)
            {
                Caption = 'Item Ledger Entries';
                Image = ItemLedger;

                ToolTip = 'Opens item ledger entries for the selected record.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    Membership: Record "NPR MM Membership";
                    ItemLedgerEntries: Page "Item Ledger Entries";
                    Entries: Record "Item Ledger Entry";
                begin
                    Membership.Get(Rec."Membership Entry No.");
                    if (Membership."Customer No." = '') then
                        exit;
                    Entries.SetFilter("Source Type", '=%1', Entries."Source Type"::Customer);
                    Entries.SetFilter("Source No.", '=%1', Membership."Customer No.");
                    ItemLedgerEntries.SetTableView(Entries);
                    ItemLedgerEntries.Run();
                end;
            }
            action(Statistics)
            {
                Caption = 'Statistics';
                Image = Statistics;

                ToolTip = 'Opens the statistics for the selected record.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                ShortCutKey = 'F7';

                trigger OnAction()
                var
                    Membership: Record "NPR MM Membership";
                    CustomerStatistics: Page "Customer Statistics";
                    Customer: Record "Customer";
                begin
                    Membership.Get(Rec."Membership Entry No.");
                    if (Membership."Customer No." = '') then
                        exit;
                    Customer.SetFilter("No.", '=%1', Membership."Customer No.");
                    CustomerStatistics.SetTableView(Customer);
                    CustomerStatistics.Run();
                end;
            }
            separator(Separator6014401)
            {
            }
        }
        area(Processing)
        {
            action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;

                ToolTip = 'Opens the form to create a new membership.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                RunObject = Page "NPR MM Create Membership";
            }
            action("Print Card")
            {
                Caption = 'Print Card';
                Image = PrintVoucher;

                ToolTip = 'Executes the Print Card action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
                begin
                    MemberRetailIntegration.PrintMemberCard(Rec."Member Entry No.", Rec."Entry No.");
                end;
            }
        }
    }
    var
        _SearchTerm: Text[100];
}

