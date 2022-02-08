page 6060126 "NPR MM Members"
{
    Extensible = False;
    Caption = 'Members';
    AdditionalSearchTerms = 'Member List';
    CardPageID = "NPR MM Member Card";
    DataCaptionExpression = Rec."External Member No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Editable = true;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Member";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

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
                    Member: Record "NPR MM Member";
                    SmartSearch: Codeunit "NPR MM Smart Search";
                begin
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);
                    if (_SearchTerm = '') then begin
                        CurrPage.Update(false);
                        exit;
                    end;

                    SmartSearch.SearchMember(_SearchTerm, Member);

                    Rec.Copy(Member);
                    Rec.SetLoadFields();
                    Rec.MarkedOnly(true);
                    CurrPage.Update(false);
                end;
            }
            repeater(Group)
            {
                Editable = false;
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    var
                        Card: Page "NPR MM Member Card";
                    begin
                        Card.SetRecord(Rec);
                        Card.Run();
                    end;

                }
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ToolTip = 'Specifies the value of the ZIP Code field';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Country; Rec.Country)
                {
                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(MemberFactBox; "NPR MM Member FactBox")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Member Details';
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
            part(MemberAttributeFactBox; "NPR MM Member Attr FactBox")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Attributes';
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;

                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;

                RunObject = Page "NPR MM Create Membership";

                ToolTip = 'Executes the Create Membership action';
                ApplicationArea = NPRRetail;
            }
            action(Members)
            {
                Caption = 'Edit';
                Ellipsis = true;
                Image = Customer;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                Scope = Repeater;
                ToolTip = 'Opens Members Card';
                ApplicationArea = NPRRetail;
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

                    if (not MemberWebService.MemberRegisterArrival(Rec."External Member No.", '', 'RTC-CLIENT', ResponseMessage)) then
                        Error(ResponseMessage);

                    Message(ResponseMessage);

                end;
            }
            action("Update Contact")
            {
                Caption = 'Synchronize Contact';
                Image = CreateInteraction;
                ToolTip = 'Executes the Synchronize Contact action';
                ApplicationArea = NPRRetail;
                Scope = Repeater;

                trigger OnAction()
                begin
                    SyncContact();
                end;
            }
            action(SetNPRAttributeFilter)
            {
                Caption = 'Set Client Attribute Filter';
                Image = "Filter";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                ToolTip = 'Executes the Set Client Attribute Filter action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NPRAttributeValueSet: Record "NPR Attribute Value Set";
                begin
                    if (not NPRAttrManagement.SetAttributeFilter(NPRAttributeValueSet)) then
                        exit;

                    Rec.SetView(NPRAttrManagement.GetAttributeFilterView(NPRAttributeValueSet, Rec));

                end;
            }
        }
        area(navigation)
        {
            action("Preferred Communication Methods")
            {
                Caption = 'Preferred Com. Methods';
                Ellipsis = true;
                Image = ChangeDimensions;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                RunObject = Page "NPR MM Member Communication";
                RunPageLink = "Member Entry No." = FIELD("Entry No.");
                Scope = Repeater;

                ToolTip = 'Executes the Preferred Com. Methods action';
                ApplicationArea = NPRRetail;
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
                RunPageLink = "External Member No." = FIELD("External Member No.");
                Scope = Repeater;

                ToolTip = 'Opens Arrival Log List';
                ApplicationArea = NPRRetail;
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
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        Membership: Record "NPR MM Membership";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin
                        GetMembershipFromRole(Membership);
                        if (Membership."Customer No." = '') then
                            Error(EntriesNotFoundForMemberErr, Rec."External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory(), true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");

                    end;
                }
                action(RaptorReShowRaptorDatacommendations)
                {
                    Caption = 'Recommendations';
                    Enabled = RaptorEnabled;
                    Image = SuggestElectronicDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;
                    ToolTip = 'Executes the Recommendations action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        Membership: Record "NPR MM Membership";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin
                        GetMembershipFromRole(Membership);
                        if (Membership."Customer No." = '') then
                            Error(EntriesNotFoundForMemberErr, Rec."External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations(), true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");

                    end;
                }
            }
        }
    }



    trigger OnOpenPage()
    var
        RaptorSetup: Record "NPR Raptor Setup";
    begin
        RaptorEnabled := (RaptorSetup.Get() and RaptorSetup."Enable Raptor Functions");
    end;

    var
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        RaptorEnabled: Boolean;
        ConfirmContactSynchQst: Label 'Do you want to sync the contacts for %1 members?', Comment = '%1=Member.Count()';
        EntriesNotFoundForMemberErr: Label 'No entries found for member %1.', Comment = '%1=Rec."External Member No."';
        _SearchTerm: Text[100];

    local procedure SyncContact()
    var
        Member: Record "NPR MM Member";
        MemberCount: Integer;
    begin
        CurrPage.SetSelectionFilter(Member);
        if not Member.IsEmpty() then begin
            MemberCount := Member.Count();
            if MemberCount > 1 then
                if not Confirm(ConfirmContactSynchQst, true, MemberCount) then
                    Error('');

            Member.FindSet(true);
            repeat
                Member.UpdateContactFromMember();
                Member.Modify();
            until (Member.Next() = 0);
        end;
    end;

    local procedure GetMembershipFromRole(var Membership: Record "NPR MM Membership")
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        Clear(Membership);
        MembershipRole.SetRange("Member Entry No.", Rec."Entry No.");
        MembershipRole.SetRange(Blocked, false);
        if MembershipRole.FindFirst() then
            Membership.Get(MembershipRole."Membership Entry No.");
    end;
}

