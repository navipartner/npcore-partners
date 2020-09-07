page 6060136 "NPR MM Member Card"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM80.1.02/TSA/20151228 CASE 229980 Print function
    // MM1.10/TSA/20160325  CASE 236532 Picture field
    // MM1.10/TSA/20160405  CASE 237670 Transport MM1.10 - 22 March 2016
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.15/TSA/20160817  CASE 238445 Transport MM1.15 - 19 July 2016
    // NPR5.26/CLVA/20160903 CASE 248272 Added action "Take Picture"
    // NPR5.26/CLVA/20160914 CASE 248272 Added action "Import Picture"
    // MM1.17/TSA/20161229  CASE 261216 Signature Change on IssueNewMemberCard
    // MM1.18/TS  /20170208 CASE 265032 Change type of Page from Card to Document so it could be use in Tablet
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.21/TSA /20170721 CASE 284653 Added button "Arrival Log"
    // MM1.22/TSA /20170825 CASE 278175 Added prompt for activation when creating a new card
    // MM1.22/TSA /20170905 CASE 289434 Print of the selected card not the last card
    // MM1.25/TSA /20180115 CASE 302353 Changed sort order to descending on member card subpage
    // MM1.28/TSA /20180420 CASE 310132 Providing default date for new card
    // MM1.29/TSA /20180515 CASE 312939 "Generate New Card" action gets the selected membership from the subpage
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018
    // MM1.34/JDH /20181109 CASE 334163 Added Caption to Actions
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.40/TSA /20190822 CASE 360242 Adding NPR Attributes
    // MM1.42/ALPO/20191125 CASE 377727 Raptor integration
    // MM1.42/TSA /20191205 CASE 372557 Added Wallet Create and Welcome message create to member card
    // MM1.42/TSA /20191219 CASE 382728 Added Preferred Com. Methods related action
    // MM1.44/TSA /20200512 CASE 383842 Fixed attribute lookup reference issue
    // MM1.45/TSA /20200717 CASE 415293 Added a warning when updating external number

    Caption = 'Member Card';
    DataCaptionExpression = "External Member No.";
    InsertAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
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
                    Importance = Promoted;

                    trigger OnValidate()
                    begin

                        //-MM1.45 [415293]
                        if ((Rec."External Member No." <> xRec."External Member No.") and (xRec."External Member No." <> '')) then
                            if (not Confirm(EXT_NO_CHANGE, false)) then
                                Error('');
                        //+MM1.45 [415293]
                    end;
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                }
                field("Middle Name"; "Middle Name")
                {
                    ApplicationArea = All;
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = All;
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Social Security No."; "Social Security No.")
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Post Code Code"; "Post Code Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field(Country; Country)
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
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
                }
                field("E-Mail News Letter"; "E-Mail News Letter")
                {
                    ApplicationArea = All;
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = All;

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
            }
            part(MembershipListPart; "NPR MM Member Members.ListPart")
            {
                SubPageLink = "Member Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Member Entry No.", "Membership Entry No.");
                ApplicationArea=All;
            }
            part(MemberCardsSubpage; "NPR MM Member Cards ListPart")
            {
                SubPageLink = "Member Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Entry No.")
                              ORDER(Descending);
                ApplicationArea=All;
            }
            group(Attributes)
            {
                Caption = 'Attributes';
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(1);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(1);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(2);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(2);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(2);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(3);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(3);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(3);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(4);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(4);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(4);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(5);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(5);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(5);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(6);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(6);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(6);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(7);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(7);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(7);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(8);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(8);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(8);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(9);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(9);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(9);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(10);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup(10);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(10);
                        //+MM1.40 [360242]
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6150638; Notes)
            {
                ApplicationArea=All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(PrintAccountCard)
            {
                Caption = 'Print Member Account Card';
                Ellipsis = true;
                Image = PrintCheck;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;

                trigger OnAction()
                begin

                    if (Confirm(CONFIRM_PRINT, true, StrSubstNo(CONFIRM_PRINT_FMT, "External Member No.", "Display Name"))) then
                        MemberRetailIntegration.PrintMemberAccountCard("External Member No.");
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
                ApplicationArea=All;

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
            action("Generate New Card")
            {
                Caption = 'Generate New Card';
                Image = PostedPayableVoucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

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


                    //-MM1.22 [278175]
                    //-#312939 [312939]
                    //MembershipEntryNo := MembershipManagement.GetMembershipFromExtMemberNo (Rec."External Member No.");
                    MembershipEntryNo := CurrPage.MembershipListPart.PAGE.GetSelectedMembershipEntryNo();
                    //+#312939 [312939]

                    if (MembershipManagement.MembershipNeedsActivation(MembershipEntryNo)) then
                        if (Confirm(ACTIVATE_MEMBERSHIP, true)) then
                            MembershipManagement.ActivateMembershipLedgerEntry(MembershipEntryNo, Today);
                    //+MM1.22 [278175]

                    //-#312939 [312939]
                    //MembershipManagement.IssueNewMemberCard (TRUE, "Entry No.", CardEntryNo, ResponseMessage);
                    MemberInfoCapture."Member Entry No" := Rec."Entry No.";
                    MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                    MembershipManagement.IssueMemberCard(true, MemberInfoCapture, CardEntryNo, ResponseMessage);
                    //+#312939 [312939]

                    MemberCard.Get(CardEntryNo);

                    //-#310132 [310132]
                    Membership.Get(MembershipEntryNo);
                    MembershipSetup.Get(Membership."Membership Code");

                    case MembershipSetup."Card Expire Date Calculation" of
                        MembershipSetup."Card Expire Date Calculation"::NA:
                            MemberCard."Valid Until" := 0D;
                        MembershipSetup."Card Expire Date Calculation"::DATEFORMULA:
                            MemberCard."Valid Until" := CalcDate(MembershipSetup."Card Number Valid Until", Today);
                        MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED:
                            MembershipManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, MemberCard."Valid Until");
                    end;
                    MemberCard.Modify();
                    //+#310132 [310132]

                    PAGE.Run(6060133, MemberCard);
                end;
            }
            action("Take Picture")
            {
                Caption = 'Take Picture';
                Image = Camera;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    MCSWebcamAPI: Codeunit "NPR MCS Webcam API";
                begin
                    MCSWebcamAPI.CallCaptureStartByMMMember(Rec, true);
                end;
            }
            action("Import Picture")
            {
                Caption = 'Import Picture';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    MCSFaceServiceAPI: Codeunit "NPR MCS Face Service API";
                begin
                    MCSFaceServiceAPI.ImportPersonPicture(Rec, true);
                end;
            }
            action("Member Anonymization")
            {
                Caption = 'Member Anonymization';
                Ellipsis = true;
                Image = AbsenceCategory;
                ApplicationArea=All;
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
            action("Create Welcome Notification")
            {
                Caption = 'Create Welcome Notification';
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    MembershipRole: Record "NPR MM Membership Role";
                    EntryNo: Integer;
                begin

                    //-MM1.42 [372557]
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
                    //+MM1.42 [372557]
                end;
            }
            action("Create Wallet Notification")
            {
                Caption = 'Create Wallet Notification';
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    MembershipRole: Record "NPR MM Membership Role";
                    EntryNo: Integer;
                begin

                    //-MM1.42 [372557]
                    MembershipRole.SetFilter("Member Entry No.", '=%1', Rec."Entry No.");
                    MembershipRole.SetFilter(Blocked, '=%1', false);
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            EntryNo := MemberNotification.CreateWalletSendNotification(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", 0);
                            if (MembershipNotification.Get(EntryNo)) then
                                if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                                    MemberNotification.HandleMembershipNotification(MembershipNotification);
                        until (MembershipRole.Next() = 0);
                    end;
                    //+MM1.42 [372557]
                end;
            }
        }
        area(navigation)
        {
            action("Issued Tickets")
            {
                Caption = 'Issued Tickets';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "External Member Card No." = FIELD("External Member No.");
                ApplicationArea=All;
            }
            action("Preferred Communication Methods")
            {
                Caption = 'Preferred Com. Methods';
                Ellipsis = true;
                Image = ChangeDimensions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Communication";
                RunPageLink = "Member Entry No." = FIELD("Entry No.");
                ApplicationArea=All;
            }
            action("Member Notifications")
            {
                Caption = 'Member Notifications';
                Image = InteractionLog;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR MM Member Notific. Entry";
                RunPageLink = "Member Entry No." = FIELD("Entry No.");
                ApplicationArea=All;
            }
            action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Arrival Log";
                RunPageLink = "External Member No." = FIELD("External Member No.");
                ApplicationArea=All;
            }
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
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        CustLedgerEntry: Record "Cust. Ledger Entry";
                        CustomerLedgerEntries: Page "Customer Ledger Entries";
                    begin
                        //-MM1.42 [377727]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        CustLedgerEntry.FilterGroup(2);
                        CustLedgerEntry.SetRange("Customer No.", Membership."Customer No.");
                        CustLedgerEntry.FilterGroup(0);

                        CustomerLedgerEntries.Editable(false);
                        CustomerLedgerEntries.SetTableView(CustLedgerEntry);
                        CustomerLedgerEntries.RunModal;
                        //+MM1.42 [377727]
                    end;
                }
                action(ItemLedgerEntries)
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ApplicationArea=All;

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
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        CustomerStatistics: Page "Customer Statistics";
                    begin
                        //-MM1.42 [377727]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, Rec."External Member No.");

                        Customer.Get(Membership."Customer No.");
                        CustomerStatistics.SetRecord(Customer);
                        CustomerStatistics.Editable(false);
                        CustomerStatistics.RunModal;
                        //+MM1.42 [377727]
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
                    ApplicationArea=All;

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
                action(RaptorReShowRaptorDatacommendations)
                {
                    Caption = 'Recommendations';
                    Enabled = RaptorEnabled;
                    Image = SuggestElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;
                    ApplicationArea=All;

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

    trigger OnAfterGetCurrRecord()
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        //-MM1.42 [377727]
        Clear(Membership);
        MembershipRole.SetRange("Member Entry No.", "Entry No.");
        MembershipRole.SetRange(Blocked, false);
        if MembershipRole.FindFirst() then
            Membership.Get(MembershipRole."Membership Entry No.");
        //+MM1.42 [377727]
    end;

    trigger OnAfterGetRecord()
    begin

        //+MM1.40 [360242]
        GetMasterDataAttributeValue();
        //-MM1.40 [360242]
    end;

    trigger OnOpenPage()
    var
        RaptorSetup: Record "NPR Raptor Setup";
    begin

        //-MM1.40 [360242]
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
        //+MM1.40 [360242]
        //-MM1.42 [377727]
        RaptorEnabled := (RaptorSetup.Get and RaptorSetup."Enable Raptor Functions");
        //+MM1.42 [377727]
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

        //-MM1.40 [360242]
        NPRAttrManagement.SetEntryAttributeValue(GetAttributeTableId(), AttributeNumber, "Entry No.", NPRAttrTextArray[AttributeNumber]);
        //+MM1.40 [360242]
    end;

    local procedure GetMasterDataAttributeValue()
    begin

        //-MM1.40 [360242]
        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, GetAttributeTableId, "Entry No.");
        NPRAttrEditable := CurrPage.Editable();
        //+MM1.40 [360242]
    end;

    procedure GetAttributeVisibility(AttributeNumber: Integer): Boolean
    begin

        //-MM1.40 [360242]
        exit(NPRAttrVisibleArray[AttributeNumber]);
        //+MM1.40 [360242]
    end;

    local procedure GetAttributeTableId(): Integer
    begin

        //-MM1.40 [360242]
        exit(DATABASE::"NPR MM Member");
        //+MM1.40 [360242]
    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    begin

        //-MM1.40 [360242]
        exit(StrSubstNo('6014555,%1,%2,2', GetAttributeTableId(), AttributeNumber));
        //+MM1.40 [360242]
    end;

    local procedure OnAttributeLookup(AttributeNumber: Integer)
    begin

        //-MM1.44 [383842]
        //-MM1.40 [360242]
        //NPRAttrManagement.OnPageLookUp (GetAttributeTableId, AttributeNumber, FORMAT (AttributeNumber,0,'<integer>'), NPRAttrTextArray[AttributeNumber] );
        NPRAttrManagement.OnPageLookUp(GetAttributeTableId, AttributeNumber, Format("Entry No.", 0, '<integer>'), NPRAttrTextArray[AttributeNumber]);
        //+MM1.40 [360242]
        //+MM1.44 [383842]
    end;
}

