page 6184670 "NPR MM Members MPos"
{
    Extensible = True;
    Caption = 'Members (Phone)';
    ContextSensitiveHelpPage = 'docs/entertainment/membership/intro/';
    CardPageID = "NPR MM Member Card";
    DataCaptionExpression = Rec."External Member No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Member";
    UsageCategory = None;

    layout
    {
        area(content)
        {

            repeater(Group)
            {
                Editable = false;
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ToolTip = 'Specifies the value of the ZIP Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Country; Rec.Country)
                {
                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Birthday; Rec.Birthday)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Birthday field';
                }
                field("E-Mail News Letter"; Rec."E-Mail News Letter")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the E-Mail News Letter field';
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
        area(factboxes)
        {
            part(MemberFactBox; "NPR MM Member FactBox")
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Member Details';
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
            part(MemberAttributeFactBox; "NPR MM Member Attr FactBox")
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                Scope = Repeater;

                trigger OnAction()
                var
                    MemberWebService: Codeunit "NPR MM Member WebService";
                    MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
                    MembershipSetup: Record "NPR MM Membership Setup";
                    Membership: Record "NPR MM Membership";
                    MemberCard: Record "NPR MM Member Card";
                    TicketBom: Record "NPR TM Ticket Admission BOM";
                    MemberCardList: Page "NPR MM Member Card List";
                    AdmissionSelection: Page "NPR TM Select Ticket Admission";
                    VariantCode: Code[10];
                    ItemNo: Code[20];
                    ResolvingTable: Integer;
                    MemberCardCount: Integer;
                    AdmissionCount: Integer;
                    ResponseMessage: Text;
                    AbortedLabel: Label 'Register arrival for member was aborted.';
                    NoCardsFoundLabel: Label 'No active member cards found for this member.';
                    NoAdmissionFoundLabel: Label 'No admissions found for the ticket item %1 setup on the membership code %2';
                begin

                    // Select Card and thus membership when multiple
                    MemberCard.SetCurrentKey("Member Entry No.");
                    MemberCard.SetFilter("Member Entry No.", '=%1', Rec."Entry No.");
                    MemberCard.SetFilter(Blocked, '=%1', false);
                    MemberCard.SetFilter("Valid Until", '=%1|>=%2', 0D, Today());
                    MemberCardCount := MemberCard.Count();

                    case true of
                        MemberCardCount > 1:
                            begin
                                MemberCardList.SetTableView(MemberCard);
                                MemberCardList.Editable(false);
                                MemberCardList.LookupMode(true);
                                if (Action::LookupOK <> MemberCardList.RunModal()) then
                                    Error(AbortedLabel);

                                MemberCardList.GetRecord(MemberCard);
                            end;
                        MemberCardCount = 1:
                            begin
                                MemberCard.FindFirst();
                            end;
                        else
                            Error(NoCardsFoundLabel);
                    end;

                    Membership.Get(MemberCard."Membership Entry No.");
                    MembershipSetup.Get(Membership."Membership Code");
                    MembershipSetup.TestField("Ticket Item Barcode");

                    if (not (MemberRetailIntegration.TranslateBarcodeToItemVariant(MembershipSetup."Ticket Item Barcode", ItemNo, VariantCode, ResolvingTable))) then
                        Error(AbortedLabel);

                    // Select admissions from Ticket (from Membership setup) when multiple
                    TicketBom.SetFilter("Item No.", '=%1', ItemNo);
                    TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
                    AdmissionCount := TicketBom.Count();

                    case true of
                        AdmissionCount = 1:
                            TicketBom.FindFirst();
                        AdmissionCount > 1:
                            begin
                                AdmissionSelection.SetTableView(TicketBom);
                                AdmissionSelection.Editable(false);
                                AdmissionSelection.LookupMode(true);
                                if (Action::LookupOK <> AdmissionSelection.RunModal()) then
                                    Error(AbortedLabel);
                                AdmissionSelection.GetRecord(TicketBom);
                            end;
                        else
                            Error(NoAdmissionFoundLabel, MembershipSetup."Ticket Item Barcode", Membership."Membership Code");
                    end;

                    if (not MemberWebService.MemberCardRegisterArrival(MemberCard."External Card No.", TicketBom."Admission Code", 'BackOffice', ResponseMessage)) then
                        Error(ResponseMessage);

                    Message(ResponseMessage);

                end;
            }
            action("Update Contact")
            {
                Caption = 'Synchronize Contact';
                Image = CreateInteraction;
                ToolTip = 'Executes the Synchronize Contact action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Scope = Repeater;
                Promoted = true;

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
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

