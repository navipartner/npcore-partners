page 6060130 "NPR MM Member Card List"
{

    Caption = 'Member Cards';
    AdditionalSearchTerms = ' Member Card List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = true;
    PageType = Worksheet;
    SourceTable = "NPR MM Member Card";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    CardPageId = "NPR MM Member Card Card";
    layout
    {
        area(content)
        {
            field(Search; _SearchTerm)
            {
                Editable = true;
                Caption = 'Smart Search';
                ApplicationArea = NPRRetail;
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
                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRRetail;
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
                    ToolTip = 'Specifies the value of the Valid Until field';
                    ApplicationArea = NPRRetail;
                }

                field("External Membership No."; Rec."External Membership No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Membership No.';
                    ApplicationArea = NPRRetail;
                    DrillDownPageId = "NPR MM Membership Card";
                }
                field("External Member No."; Rec."External Member No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Member No.';
                    ApplicationArea = NPRRetail;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field("Display Name"; Rec."Display Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Display Name.';
                    ApplicationArea = NPRRetail;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the member E-Mail Address';
                    ApplicationArea = NPRRetail;
                    DrillDownPageId = "NPR MM Member Card";
                }
            }
        }
        area(FactBoxes)
        {
            part(MemberCard; "NPR MM Member Card FactBox")
            {
                Caption = 'Member Card Details';
                ApplicationArea = NPRRetail;
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");
                Scope = Repeater;
                ToolTip = 'Opens Membership Card';
                ApplicationArea = NPRRetail;
            }
            action(Members)
            {
                Caption = 'Members';
                Ellipsis = true;
                Image = Customer;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Card";
                RunPageLink = "Entry No." = FIELD("Member Entry No.");
                Scope = Repeater;
                ToolTip = 'Opens Members Card';
                ApplicationArea = NPRRetail;
            }
            separator(Separator6014401)
            {
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
                ApplicationArea = NPRRetail;
                Scope = Repeater;

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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Arrival Log";
                RunPageLink = "External Card No." = FIELD("External Card No.");
                Scope = Repeater;
                ToolTip = 'Opens Arrival Log List';
                ApplicationArea = NPRRetail;
            }
        }
        area(Processing)
        {
            action("Print Card")
            {
                Caption = 'Print Card';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Executes the Print Card action';
                ApplicationArea = NPRRetail;

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

