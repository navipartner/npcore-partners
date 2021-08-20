page 6060136 "NPR MM Member Card"
{
    Caption = 'Member Card';
    DataCaptionExpression = Rec."External Member No.";
    InsertAllowed = false;
    PageType = Document;
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Member";
    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Member No."; Rec."External Member No.")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin

                        if ((Rec."External Member No." <> xRec."External Member No.") and (xRec."External Member No." <> '')) then
                            if (not Confirm(EXT_NO_CHANGE, false)) then
                                Error('');

                    end;
                }
                field("Display Name"; Rec."Display Name")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRRetail;
                }
                field("First Name"; Rec."First Name")
                {

                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Middle Name"; Rec."Middle Name")
                {

                    ToolTip = 'Specifies the value of the Middle Name field';
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
                field("Social Security No."; Rec."Social Security No.")
                {

                    ToolTip = 'Specifies the value of the Social Security No. field';
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
                field(CountryCode; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRRetail;
                }

                field(Country; Rec.Country)
                {

                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(CRM)
            {
                field(Gender; Rec.Gender)
                {

                    ToolTip = 'Specifies the value of the Gender field';
                    ApplicationArea = NPRRetail;
                }
                field(Birthday; Rec.Birthday)
                {

                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail News Letter"; Rec."E-Mail News Letter")
                {

                    ToolTip = 'Specifies the value of the E-Mail News Letter field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Method"; Rec."Notification Method")
                {

                    ToolTip = 'Specifies the value of the Notification Method field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        MemberCommunication: Record "NPR MM Member Communication";
                        PageMemberCommunication: Page "NPR MM Member Communication";
                    begin

                        MemberCommunication.SetFilter("Member Entry No.", '=%1', Rec."Entry No.");
                        PageMemberCommunication.SetTableView(MemberCommunication);
                        PageMemberCommunication.RunModal();
                    end;
                }
                field("Store Code"; Rec."Store Code")
                {

                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(MembershipListPart; "NPR MM Member Members.ListPart")
            {
                SubPageLink = "Member Entry No." = field("Entry No.");
                SubPageView = sorting("Member Entry No.", "Membership Entry No.");
                ApplicationArea = NPRRetail;

            }
            part(MemberCardsSubpage; "NPR MM Member Cards ListPart")
            {
                SubPageLink = "Member Entry No." = field("Entry No.");
                SubPageView = sorting("Entry No.")
                              ORDER(Descending);
                ApplicationArea = NPRRetail;

            }
            group(Attributes)
            {
                Caption = 'Attributes';
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {

                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(1);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(1);

                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {

                    CaptionClass = GetAttributeCaptionClass(2);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        SetMasterDataAttributeValue(2);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(2);

                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {

                    CaptionClass = GetAttributeCaptionClass(3);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(3);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(3);

                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {

                    CaptionClass = GetAttributeCaptionClass(4);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(4);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(4);

                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {

                    CaptionClass = GetAttributeCaptionClass(5);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(5);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(5);

                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {

                    CaptionClass = GetAttributeCaptionClass(6);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(6);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(6);

                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {

                    CaptionClass = GetAttributeCaptionClass(7);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(7);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(7);

                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {

                    CaptionClass = GetAttributeCaptionClass(8);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(8);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(8);

                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {

                    CaptionClass = GetAttributeCaptionClass(9);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(9);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(9);

                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {

                    CaptionClass = GetAttributeCaptionClass(10);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        OnAttributeLookup(10);

                    end;

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(10);

                    end;
                }
            }
        }
        area(factboxes)
        {
            part(MMMemberPicture; "NPR MM Member Picture")
            {

                Caption = 'Picture';
                SubPageLink = "Entry No." = field("Entry No.");
                ApplicationArea = NPRRetail;
            }
            systempart(Control6150638; Notes)
            {
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            Action(PrintAccountCard)
            {
                Caption = 'Print Member Account Card';
                Ellipsis = true;
                Image = PrintCheck;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Print Member Account Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin

                    if (Confirm(CONFIRM_PRINT, true, StrSubstNo(CONFIRM_PRINT_FMT, Rec."External Member No.", Rec."Display Name"))) then
                        MemberRetailIntegration.PrintMemberAccountCard(Rec."External Member No.");
                end;
            }
            Action(PrintCard)
            {
                Caption = 'Print Member Card';
                Ellipsis = true;
                Image = PrintVoucher;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Print Member Card action';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    MemberCardEntryNo: Integer;
                    MemberCard: Record "NPR MM Member Card";
                    Membership: Record "NPR MM Membership";
                    MembershipSetup: Record "NPR MM Membership Setup";
                    CONFIRM_CARD_BLOCKED: Label 'This member card is blocked, do you want to continue anyway?';
                begin

                    if (Confirm(CONFIRM_PRINT, true, StrSubstNo(CONFIRM_PRINT_FMT, Rec."External Member No.", Rec."Display Name"))) then begin
                        MemberCardEntryNo := CurrPage.MemberCardsSubpage.Page.GetCurrentEntryNo();

                        MemberCard.Get(MemberCardEntryNo);
                        Membership.Get(MemberCard."Membership Entry No.");
                        MembershipSetup.Get(Membership."Membership Code");

                        if ((MemberCard.Blocked) or (Membership.Blocked)) then
                            if (not Confirm(CONFIRM_CARD_BLOCKED, true)) then
                                Error('');

                        MemberCard.SetFilter("Entry No.", '=%1', MemberCardEntryNo);
                        MemberRetailIntegration.PrintMemberCardWorker(MemberCard, MembershipSetup);

                    end;
                end;
            }
            Action("Generate New Card")
            {
                Caption = 'Generate New Card';
                Image = PostedPayableVoucher;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Generate New Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                    MemberCard: Record "NPR MM Member Card";
                    CardEntryNo: Integer;
                    ResponseMessage: Text;
                    MembershipEntryNo: Integer;
                    Membership: Record "NPR MM Membership";
                    MembershipSetup: Record "NPR MM Membership Setup";
                    MemberInfoCapture: Record "NPR MM Member Info Capture";
                begin

                    //MembershipEntryNo := MembershipManagement.GetMembershipFromExtMemberNo (Rec."External Member No.");
                    MembershipEntryNo := CurrPage.MembershipListPart.Page.GetSelectedMembershipEntryNo();

                    if (MembershipManagement.MembershipNeedsActivation(MembershipEntryNo)) then
                        if (Confirm(ACTIVATE_MEMBERSHIP, true)) then
                            MembershipManagement.ActivateMembershipLedgerEntry(MembershipEntryNo, Today);

                    //MembershipManagement.IssueNewMemberCard (TRUE, "Entry No.", CardEntryNo, ResponseMessage);
                    MemberInfoCapture."Member Entry No" := Rec."Entry No.";
                    MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                    MembershipManagement.IssueMemberCard(MemberInfoCapture, CardEntryNo, ResponseMessage);

                    MemberCard.Get(CardEntryNo);

                    Membership.Get(MembershipEntryNo);
                    MembershipSetup.Get(Membership."Membership Code");

                    case MembershipSetup."Card Expire Date Calculation" of
                        MembershipSetup."Card Expire Date Calculation"::NA:
                            MemberCard."Valid Until" := 0D;
                        MembershipSetup."Card Expire Date Calculation"::DateFormula:
                            MemberCard."Valid Until" := CalcDate(MembershipSetup."Card Number Valid Until", Today);
                        MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED:
                            MembershipManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, MemberCard."Valid Until");
                    end;
                    MemberCard.Modify();

                    Page.Run(6060133, MemberCard);
                end;
            }
            Action("Take Picture")
            {
                Caption = 'Take Picture';
                Image = Camera;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Take Picture action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                begin
                    MembershipManagement.TakeMemberPicture(Rec);
                end;
            }

            Action("Import Picture")
            {
                Caption = 'Import Picture';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Import Picture action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MCSFaceServiceAPI: Codeunit "NPR MCS Face Service API";
                begin
                    MCSFaceServiceAPI.ImportMemberPicture(Rec);
                end;
            }
            Action("Member Anonymization")
            {
                Caption = 'Member Anonymization';
                Ellipsis = true;
                Image = AbsenceCategory;

                ToolTip = 'Executes the Member Anonymization action';
                ApplicationArea = NPRRetail;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    GDPRManagement: Codeunit "NPR MM GDPR Management";
                    ReasonText: Text;
                begin
                    if (GDPRManagement.AnonymizeMember(Rec."Entry No.", false, ReasonText)) then
                        if (not Confirm('Member informtion will be lost! Do you want to continue?', false)) then
                            Error('');

                    Message(ReasonText);
                end;
            }
            Action("Create Welcome Notification")
            {
                Caption = 'Create Welcome Notification';
                Image = Interaction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Create Welcome Notification action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    MembershipRole: Record "NPR MM Membership Role";
                    EntryNo: Integer;
                begin

                    MembershipRole.SetFilter("Member Entry No.", '=%1', Rec."Entry No.");
                    MembershipRole.SetFilter(Blocked, '=%1', false);
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            EntryNo := MemberNotification.AddMemberWelcomeNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.");
                            if (MembershipNotification.Get(EntryNo)) then
                                if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                                    MemberNotification.HandleMembershipNotification(MembershipNotification);

                        until (MembershipRole.Next() = 0);
                    end;

                end;
            }
            Action("Send Wallet Notification")
            {
                Caption = 'Send Wallet Notification';
                Image = Interaction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Creates a wallet notification message and sends it when processing method is set to inline';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    MembershipRole: Record "NPR MM Membership Role";
                    EntryNo: Integer;
                begin

                    MembershipRole.SetFilter("Member Entry No.", '=%1', Rec."Entry No.");
                    MembershipRole.SetFilter(Blocked, '=%1', false);
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            if (MembershipRole."Wallet Pass Id" <> '') then
                                EntryNo := MemberNotification.CreateUpdateWalletNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0, TODAY);

                            if (MembershipRole."Wallet Pass Id" = '') then
                                EntryNo := MemberNotification.CreateWalletSendNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0, TODAY);

                            if (MembershipNotification.Get(EntryNo)) then
                                if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                                    MemberNotification.HandleMembershipNotification(MembershipNotification);
                        until (MembershipRole.Next() = 0);
                    end;

                end;
            }
        }
        area(navigation)
        {
            Action("Issued Tickets")
            {
                Caption = 'Issued Tickets';
                Image = ShowList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "External Member Card No." = field("External Member No.");

                ToolTip = 'Executes the Issued Tickets action';
                ApplicationArea = NPRRetail;
            }
            Action("Preferred Communication Methods")
            {
                Caption = 'Preferred Com. Methods';
                Ellipsis = true;
                Image = ChangeDimensions;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Communication";
                RunPageLink = "Member Entry No." = field("Entry No.");

                ToolTip = 'Executes the Preferred Com. Methods action';
                ApplicationArea = NPRRetail;
            }
            Action("Member Notifications")
            {
                Caption = 'Member Notifications';
                Image = InteractionLog;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR MM Member Notific. Entry";
                RunPageLink = "Member Entry No." = field("Entry No.");

                ToolTip = 'Executes the Member Notifications action';
                ApplicationArea = NPRRetail;
            }
            Action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Arrival Log";
                RunPageLink = "External Member No." = field("External Member No.");

                ToolTip = 'Executes the Arrival Log action';
                ApplicationArea = NPRRetail;
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                Action(LedgerEntries)
                {
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'Executes the Ledger E&ntries action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        CustLedgerEntry: Record "Cust. Ledger Entry";
                        CustomerLedgerEntries: Page "Customer Ledger Entries";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        CustLedgerEntry.FilterGroup(2);
                        CustLedgerEntry.SetRange("Customer No.", Membership."Customer No.");
                        CustLedgerEntry.FilterGroup(0);

                        CustomerLedgerEntries.Editable(false);
                        CustomerLedgerEntries.SetTableView(CustLedgerEntry);
                        CustomerLedgerEntries.RunModal();

                    end;
                }
                Action(ItemLedgerEntries)
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    ToolTip = 'Executes the Item Ledger Entries action';
                    ApplicationArea = NPRRetail;

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
                        if ItemLedgerEntry.FindFirst() then;
                        Page.RunModal(0, ItemLedgerEntry);

                    end;
                }
                Action(CustomerStatisics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'F7';

                    ToolTip = 'Executes the Statistics action';
                    ApplicationArea = NPRRetail;

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
                Action(RaptorBrowsingHistory)
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
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory(), true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");

                    end;
                }
                Action(RaptorReShowRaptorDatacommendations)
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
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations(), true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");

                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin

        Clear(Membership);
        MembershipRole.SetRange("Member Entry No.", Rec."Entry No.");
        MembershipRole.SetRange(Blocked, false);
        if MembershipRole.FindFirst() then
            Membership.Get(MembershipRole."Membership Entry No.");

    end;

    trigger OnAfterGetRecord()
    begin
        GetMasterDataAttributeValue();
    end;

    trigger OnOpenPage()
    var
        RaptorSetup: Record "NPR Raptor Setup";
    begin

        NPRAttrManagement.GetAttributeVisibility(GetAttributeTableId(), NPRAttrVisibleArray);
        // Because NAV is stupid!
        NPRAttrVisible01 := NPRAttrVisibleArray[1];
        NPRAttrVisible02 := NPRAttrVisibleArray[2];
        NPRAttrVisible03 := NPRAttrVisibleArray[3];
        NPRAttrVisible04 := NPRAttrVisibleArray[4];
        NPRAttrVisible05 := NPRAttrVisibleArray[5];
        NPRAttrVisible06 := NPRAttrVisibleArray[6];
        NPRAttrVisible07 := NPRAttrVisibleArray[7];
        NPRAttrVisible08 := NPRAttrVisibleArray[8];
        NPRAttrVisible09 := NPRAttrVisibleArray[9];
        NPRAttrVisible10 := NPRAttrVisibleArray[10];
        NPRAttrEditable := CurrPage.Editable();

        RaptorEnabled := (RaptorSetup.Get() and RaptorSetup."Enable Raptor Functions");

    end;

    var
        Membership: Record "NPR MM Membership";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        CONFIRM_PRINT: Label 'Do you want to print a member account card for %1?';
        CONFIRM_PRINT_FMT: Label '[%1] - %2';
        ACTIVATE_MEMBERSHIP: Label 'The membership has not been activated yet. Do you want to activate it now?';
        NPRAttrTextArray: array[40] of Text[250];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        NPRAttrVisible01: Boolean;
        NPRAttrVisible02: Boolean;
        NPRAttrVisible03: Boolean;
        NPRAttrVisible04: Boolean;
        NPRAttrVisible05: Boolean;
        NPRAttrVisible06: Boolean;
        NPRAttrVisible07: Boolean;
        NPRAttrVisible08: Boolean;
        NPRAttrVisible09: Boolean;
        NPRAttrVisible10: Boolean;
        RaptorEnabled: Boolean;
        NO_ENTRIES: Label 'No entries found for member %1.';
        EXT_NO_CHANGE: Label 'Please note that changing the external number requires re-printing of documents where this number is used. Do you want to continue?';

    local procedure SetMasterDataAttributeValue(AttributeNumber: Integer)
    begin

        NPRAttrManagement.SetEntryAttributeValue(GetAttributeTableId(), AttributeNumber, Rec."Entry No.", NPRAttrTextArray[AttributeNumber]);

    end;

    local procedure GetMasterDataAttributeValue()
    begin

        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, GetAttributeTableId(), Rec."Entry No.");
        NPRAttrEditable := CurrPage.Editable();

    end;

    procedure GetAttributeVisibility(AttributeNumber: Integer): Boolean
    begin

        exit(NPRAttrVisibleArray[AttributeNumber]);

    end;

    local procedure GetAttributeTableId(): Integer
    begin

        exit(Database::"NPR MM Member");

    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    var
        PlaceHolderLbl: Label '6014555,%1,%2,2', Locked = true;
    begin
        exit(StrSubstNo(PlaceHolderLbl, GetAttributeTableId(), AttributeNumber));

    end;

    local procedure OnAttributeLookup(AttributeNumber: Integer)
    begin
        NPRAttrManagement.OnPageLookUp(GetAttributeTableId(), AttributeNumber, Format(Rec."Entry No.", 0, '<integer>'), NPRAttrTextArray[AttributeNumber]);
    end;
}

