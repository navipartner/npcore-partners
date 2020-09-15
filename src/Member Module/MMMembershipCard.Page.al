page 6060137 "NPR MM Membership Card"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.02/TSA/20151228  CASE 229980 Print Membercard
    // MM1.08/TSA/20160223  CASE 234913 Include company name field on membership
    // MM1.10/TSA/20160404  CASE 233948 Added a the Update Customer button to sync customer and contact
    // MM1.14/TSA/20160523  CASE 240871 Notification Service
    // MM1.15/TSA/20160817  CASE 244443 Transport MM1.15 - 19 July 2016
    // MM1.17/TSA/20161205  CASE 260181 Added Item No. to rec used to add member to membership in order for wizzard page to provide defaults
    // MM1.17/TSA/20161214  CASE 243075 Member Point System
    // MM1.17/TSA/20161229  CASE 262040 Signature Change on AddMemberAndCard
    // MM1.21/TSA/20170612  CASE 260181 Added UPGRADE as search option as that would change the base product
    // MM1.21/TSA /20170721 CASE 284653 Added button "Arrival Log"
    // MM1.22/TSA /20170731 CASE 285403 Added Action to Issue Coupon For Loyalty points, RedeemPoints()
    // MM1.22/TSA /20170823 CASE 287080 Added Member Count breakdown
    // MM1.22/TSA /20170825 CASE 278175 Added a button to activate membership manually.
    // MM1.22/TSA /20170829 CASE 286922 Added field "Auto-Renew"
    // MM1.22/TSA /20170831 CASE 288919 Changed resolve of Item No to follow the business flow
    // MM1.25/TSA /20171213 CASE 299690 Added global function AddGuardianMember()
    // MM1.25/TSA /20180112 CASE 302302 Supercharging the activate membership
    // MM1.25/TSA /20180119 CASE 302598 New action "Auto-Renew"
    // MM1.26/TSA /20180206 CASE 304579 Added Customer History
    // MM1.27/TSA /20180315 CASE 306002 Made 3 system fields uneditable
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018
    // MM1.29.02/NPKNAV/20180531  CASE 314131-01 Transport TM1.29.02 - 31 May 2018
    // MM1.32/TSA /20180711 CASE 318132 Added Create Wallet Notification action
    // MM1.33/TSA/20180830  CASE 324065 Transport MM1.33 - 30 August 2018
    // MM1.34/JDH /20181109 CASE 334163 Added Caption to Actions
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.40/TSA /20190822 CASE 360242 Adding NPR Attributes
    // MM1.41/TSA /20191009 CASE 367471 Added Sponsorship Tickets
    // MM1.42/TSA /20191024 CASE 374403 Changed signature on IssueOneCoupon(), IssueOneCouponAndPrint(), and IssueCoupon()
    // MM1.42/ALPO/20191125 CASE 377727 Raptor integration
    // MM1.44/TSA /20200512 CASE 383842 Fixed attribute lookup reference issue
    // MM1.45/TSA /20200709 CASE 411768 Added Pointsummary page part
    // MM1.45/TSA /20200717 CASE 415293 Added a warning when updating external number

    Caption = 'Membership Card';
    DataCaptionExpression = "External Membership No." + ' - ' + "Membership Code";
    InsertAllowed = false;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Membership";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin

                        //-MM1.45 [415293]
                        if ((Rec."External Membership No." <> xRec."External Membership No.") and (xRec."External Membership No." <> '')) then
                            if (not Confirm(EXT_NO_CHANGE, false)) then
                                Error('');
                        //+MM1.45 [415293]
                    end;
                }
                field(ShowMemberCountAs; ShowMemberCountAs)
                {
                    ApplicationArea = All;
                    Caption = 'Members (Admin/Member/Anonymous)';
                    Editable = false;
                }
                field(ShowCurrentPeriod; ShowCurrentPeriod)
                {
                    ApplicationArea = All;
                    Caption = 'Current Period';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = NeedsActivation;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Issued Date"; "Issued Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                }
                field(Control6014412; "Auto-Renew")
                {
                    ApplicationArea = All;
                }
                field("Auto-Renew Payment Method Code"; "Auto-Renew Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Document ID"; "Document ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
            }
            part(Control6150625; "NPR MM Members.Member ListPart")
            {
                SubPageLink = "Membership Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Membership Entry No.", "Member Entry No.");
                ApplicationArea = All;
            }
            part(Control6150624; "NPR MM Members. Ledger Entries")
            {
                SubPageLink = "Membership Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Membership Entry No.");
                ApplicationArea = All;
            }
            group(Points)
            {
                Caption = 'Points';
                field("Awarded Points (Sale)"; "Awarded Points (Sale)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Awarded Points (Refund)"; "Awarded Points (Refund)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Redeemed Points (Withdrawl)"; "Redeemed Points (Withdrawl)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Redeemed Points (Deposit)"; "Redeemed Points (Deposit)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Expired Points"; "Expired Points")
                {
                    ApplicationArea = All;
                }
                field("Remaining Points"; "Remaining Points")
                {
                    ApplicationArea = All;
                }
            }
            part(PointsSummary; "NPR MM Members. Points Summary")
            {
                ShowFilter = false;
                SubPageLink = "Membership Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Membership Entry No.", "Relative Period")
                              ORDER(Descending);
                UpdatePropagation = Both;
                ApplicationArea = All;
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
            systempart(Control6150629; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
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
            action("Add Member")
            {
                Caption = 'Add Member';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    AddMembershipMember();
                    CurrPage.Update(false);
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
            action("Update Customer")
            {
                Caption = 'Update Customer Information';
                Image = CreateInteraction;
                ApplicationArea = All;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                begin
                    MembershipManagement.SynchronizeCustomerAndContact("Entry No.");
                end;
            }
            action("Redeem Points")
            {
                Caption = 'Redeem Points';
                Image = PostedVoucherGroup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin

                    RedeemPoints(Rec);
                end;
            }
            action("Auto-Renew")
            {
                Caption = 'Auto-Renew';
                Image = Invoice;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    AutoRenewMembership(Rec."Entry No.");
                end;
            }
            action("Create Welcome Notification")
            {
                Caption = 'Create Welcome Notification';
                Image = Interaction;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    EntryNo: Integer;
                begin
                    EntryNo := MemberNotification.AddMemberWelcomeNotification(Rec."Entry No.", 0);
                    if (MembershipNotification.Get(EntryNo)) then
                        if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                            MemberNotification.HandleMembershipNotification(MembershipNotification);
                end;
            }
            action("Create Wallet Notification")
            {
                Caption = 'Create Wallet Notification';
                Image = Interaction;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    EntryNo: Integer;
                begin

                    EntryNo := MemberNotification.CreateWalletSendNotification(Rec."Entry No.", 0, 0);
                    if (MembershipNotification.Get(EntryNo)) then
                        if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                            MemberNotification.HandleMembershipNotification(MembershipNotification);
                end;
            }
            action("Issue Sponsorship Tickets")
            {
                Caption = 'Issue Sponsorship Tickets';
                Image = TeamSales;
                ApplicationArea = All;

                trigger OnAction()
                begin

                    IssueAdHocSponsorshipTickets(Rec."Entry No.");
                end;
            }
        }
        area(navigation)
        {
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Membership Notific.";
                RunPageLink = "Membership Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Membership Entry No.");
                ApplicationArea = All;
            }
            action("Show Sponsorship Tickets")
            {
                Caption = 'Show Sponsorship Tickets';
                Ellipsis = true;
                Image = SalesPurchaseTeam;
                RunObject = Page "NPR MM Sponsor. Ticket Entry";
                RunPageLink = "Membership Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Membership Entry No.", "Event Type");
                ApplicationArea = All;
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
                RunPageLink = "External Membership No." = FIELD("External Membership No.");
                ApplicationArea = All;
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = FIELD("Customer No.");
                    RunPageView = SORTING("Customer No.");
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = All;
                }
                action(ItemLedgerEntries)
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Source No." = FIELD("Customer No.");
                    RunPageView = SORTING("Source Type", "Source No.", "Posting Date")
                                  ORDER(Descending)
                                  WHERE("Source Type" = CONST(Customer));
                    ApplicationArea = All;
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Customer Statistics";
                    RunPageLink = "No." = FIELD("Customer No.");
                    ShortCutKey = 'F7';
                    ApplicationArea = All;
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
                        TestField("Customer No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, "Customer No.");
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
                        TestField("Customer No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, "Customer No.");
                        //+MM1.42 [377727]
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipRole: Record "NPR MM Membership Role";
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin
        MembershipManagement.GetMemberCount(Rec."Entry No.", AdminMemberCount, MemberMemberCount, AnonymousMemberCount);
        ShowMemberCountAs := StrSubstNo('%1 / %2 / %3', AdminMemberCount, MemberMemberCount, AnonymousMemberCount);

        NeedsActivation := MembershipManagement.MembershipNeedsActivation(Rec."Entry No.");
        ShowCurrentPeriod := NOT_ACTIVATED;
        if (not NeedsActivation) then begin
            MembershipManagement.GetMembershipValidDate(Rec."Entry No.", Today, ValidFromDate, ValidUntilDate);
            ShowCurrentPeriod := StrSubstNo('%1 - %2', ValidFromDate, ValidUntilDate);
            if (ValidUntilDate < Today) then
                ShowCurrentPeriod := StrSubstNo('%1 - %2 (%3)', ValidFromDate, ValidUntilDate, MEMBERSHIP_EXPIRED);
        end;

        //-MM1.40 [360242]
        NPRAttrEditable := CurrPage.Editable();
        //+MM1.40 [360242]

        //-MM1.45 [411768]
        CurrPage.PointsSummary.PAGE.FillPageSummary(Rec."Entry No.");
        CurrPage.PointsSummary.PAGE.Update(false);
        //+MM1.45 [411768]
    end;

    trigger OnAfterGetRecord()
    begin

        //-MM1.40 [360242]
        GetMasterDataAttributeValue();
        //+MM1.40 [360242]
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
        AdminMemberCount: Integer;
        MemberMemberCount: Integer;
        AnonymousMemberCount: Integer;
        ShowMemberCountAs: Text[30];
        ShowCurrentPeriod: Text[30];
        NeedsActivation: Boolean;
        NOT_ACTIVATED: Label 'Not activated';
        ADD_MEMBER_SETUP: Label 'Could not find %1 with %2 set to option %3 for %4 %5. Additional members can''t be added until setup is completed.';
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
        MEMBERSHIP_EXPIRED: Label 'Expired';
        EXT_NO_CHANGE: Label 'Please note that changing the external number requires re-printing of documents where this number is used. Do you want to continue?';

    local procedure AddMembershipMember()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipRole: Record "NPR MM Membership Role";
        GuardianMember: Record "NPR MM Member";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ResponseMessage: Text;
    begin

        MemberInfoCapture.Init();

        MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
        MembershipSalesSetup.SetFilter("Membership Code", '=%1', "Membership Code");
        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER);
        if (not MembershipSalesSetup.FindFirst()) then
            Error(ADD_MEMBER_SETUP, MembershipSalesSetup.TableCaption,
              MembershipSalesSetup.FieldCaption("Business Flow Type"), MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER,
              FieldCaption("Membership Code"), "Membership Code");

        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
        MemberInfoCapture."Membership Entry No." := "Entry No.";
        MemberInfoCapture."External Membership No." := "External Membership No.";

        //-MM1.33 [324065]
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindFirst()) then begin
            GuardianMember.Get(MembershipRole."Member Entry No.");
            MemberInfoCapture."Guardian External Member No." := GuardianMember."External Member No.";
            MemberInfoCapture."E-Mail Address" := GuardianMember."E-Mail Address";
        end;
        //+MM1.33 [324065]

        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        Commit();

        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();
        if (PageAction = ACTION::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);
            MembershipManagement.AddMemberAndCard(true, "Entry No.", MemberInfoCapture, false, MemberInfoCapture."Member Entry No", ResponseMessage);

        end;
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

        MemberInfoCapture."Membership Entry No." := "Entry No.";
        MemberInfoCapture."External Membership No." := "External Membership No.";
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
            //-MM1.29 [313795]
            // MembershipManagement.AddGuardianMember (Rec."Entry No.", MemberInfoCapture."Guardian External Member No.");
            MembershipManagement.AddGuardianMember(Rec."Entry No.", MemberInfoCapture."Guardian External Member No.", MemberInfoCapture."GDPR Approval");
            //+MM1.29 [313795]
        end;
    end;

    local procedure RedeemPoints(Membership: Record "NPR MM Membership")
    var
        LoyaltyPointMgt: Codeunit "NPR MM Loyalty Point Mgt.";
        LoyaltyCouponMgr: Codeunit "NPR MM Loyalty Coupon Mgr";
        TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
    begin

        if (LoyaltyPointMgt.GetCouponToRedeemPOS(Membership."Entry No.", TmpLoyaltyPointsSetup, 999999)) then begin
            repeat
                Membership.CalcFields("Remaining Points");

                if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then
                    if (TmpLoyaltyPointsSetup."Points Threshold" <= Membership."Remaining Points") then
                        //-MM1.42 [374403]
                        //LoyaltyCouponMgr.IssueOneCouponAndPrint (TmpLoyaltyPointsSetup."Coupon Type Code", Membership."Entry No.", TmpLoyaltyPointsSetup."Points Threshold",0);
                        LoyaltyCouponMgr.IssueOneCouponAndPrint(TmpLoyaltyPointsSetup."Coupon Type Code", Membership."Entry No.", Membership."External Membership No.", Today, TmpLoyaltyPointsSetup."Points Threshold", 0);
            //+MM1.42 [374403]

            until (TmpLoyaltyPointsSetup.Next() = 0);
        end;
    end;

    local procedure ActivateMembership()
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        //-MM1.25 [302302]
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Rec."Entry No.");
        if (MembershipEntry.IsEmpty()) then begin
            MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
            MembershipSalesSetup.SetFilter("Membership Code", '=%1', Rec."Membership Code");
            MembershipSalesSetup.SetFilter(Blocked, '=%1', false);
            MembershipSalesSetup.FindFirst();

            MemberInfoCapture.Init;
            MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

            MembershipManagement.AddMembershipLedgerEntry_NEW(Rec."Entry No.", Rec."Issued Date", MembershipSalesSetup, MemberInfoCapture);

        end;
        //+MM1.25 [302302]

        MembershipManagement.ActivateMembershipLedgerEntry(Rec."Entry No.", Today);
    end;

    local procedure AutoRenewMembership(MembershipEntryNo: Integer)
    var
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        TmpMembershipAutoRenew: Record "NPR MM Membership Auto Renew" temporary;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        RenewStartDate: Date;
        RenewUntilDate: Date;
        RenewUnitPrice: Decimal;
        EntryNo: Integer;
        SalesHeader: Record "Sales Header";
        SalesInvoicePage: Page "Sales Invoice";
    begin

        TmpMembershipAutoRenew.Init;
        MembershipManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, TmpMembershipAutoRenew."Valid Until Date");
        EntryNo := MembershipAutoRenew.AutoRenewOneMembership(0, MembershipEntryNo, TmpMembershipAutoRenew, RenewStartDate, RenewUntilDate, RenewUnitPrice, false);
        MemberInfoCapture.Get(EntryNo);
        if (MemberInfoCapture."Response Status" <> MemberInfoCapture."Response Status"::COMPLETED) then
            Error(MemberInfoCapture."Response Message");

        Commit;
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, TmpMembershipAutoRenew."Last Invoice No.");
        SalesInvoicePage.SetRecord(SalesHeader);
        SalesInvoicePage.RunModal();
    end;

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
        exit(DATABASE::"NPR MM Membership");
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

    local procedure IssueAdHocSponsorshipTickets(MembershipEntryNo: Integer)
    var
        SponsorshipTicketMgmt: Codeunit "NPR MM Sponsorship Ticket Mgt";
        ResponseMessage: Text;
    begin

        if (not SponsorshipTicketMgmt.IssueAdHocTicket(MembershipEntryNo, ResponseMessage)) then
            Error(ResponseMessage);
    end;
}

