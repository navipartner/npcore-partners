page 6060137 "NPR MM Membership Card"
{

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
                    ToolTip = 'Specifies the value of the External Membership No. field';

                    trigger OnValidate()
                    begin

                        if ((Rec."External Membership No." <> xRec."External Membership No.") and (xRec."External Membership No." <> '')) then
                            if (not Confirm(EXT_NO_CHANGE, false)) then
                                Error('');

                    end;
                }
                field(ShowMemberCountAs; ShowMemberCountAs)
                {
                    ApplicationArea = All;
                    Caption = 'Members (Admin/Member/Anonymous)';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Members (Admin/Member/Anonymous) field';
                }
                field(ShowCurrentPeriod; ShowCurrentPeriod)
                {
                    ApplicationArea = All;
                    Caption = 'Current Period';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = NeedsActivation;
                    ToolTip = 'Specifies the value of the Current Period field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Issued Date"; "Issued Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Issued Date field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field(Control6014412; "Auto-Renew")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew field';
                }
                field("Auto-Renew Payment Method Code"; "Auto-Renew Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew Payment Method Code field';
                }
                field("Document ID"; "Document ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document ID field';
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
                    ToolTip = 'Specifies the value of the Awarded Points (Sale) field';
                }
                field("Awarded Points (Refund)"; "Awarded Points (Refund)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Awarded Points (Refund) field';
                }
                field("Redeemed Points (Withdrawl)"; "Redeemed Points (Withdrawl)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Redeemed Points (Withdrawl) field';
                }
                field("Redeemed Points (Deposit)"; "Redeemed Points (Deposit)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Redeemed Points (Deposit) field';
                }
                field("Expired Points"; "Expired Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expired Points field';
                }
                field("Remaining Points"; "Remaining Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Points field';
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
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(2);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(3);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(4);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(5);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(6);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(7);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(8);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(9);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';

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
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(10);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';

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
                ToolTip = 'Executes the Activate Membership action';

                trigger OnAction()
                begin

                    ActivateMembership();

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
                ToolTip = 'Executes the Add Member action';

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
                ToolTip = 'Executes the Add Guardian action';

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
                ToolTip = 'Executes the Update Customer Information action';
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
                ToolTip = 'Executes the Redeem Points action';

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
                ToolTip = 'Executes the Auto-Renew action';

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
                ToolTip = 'Executes the Create Welcome Notification action';

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
                ToolTip = 'Executes the Create Wallet Notification action';

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipNotification: Record "NPR MM Membership Notific.";
                    EntryNo: Integer;
                begin

                    EntryNo := MemberNotification.CreateWalletSendNotification(Rec."Entry No.", 0, 0, Today);
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
                ToolTip = 'Executes the Issue Sponsorship Tickets action';

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
                ToolTip = 'Executes the Notifications action';
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
                ToolTip = 'Executes the Show Sponsorship Tickets action';
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
                ToolTip = 'Executes the Arrival Log action';
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
                    ToolTip = 'Executes the Ledger E&ntries action';
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
                    ToolTip = 'Executes the Item Ledger Entries action';
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
                    ToolTip = 'Executes the Statistics action';
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
                    ToolTip = 'Executes the Browsing History action';

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        TestField("Customer No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, "Customer No.");

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
                    ToolTip = 'Executes the Recommendations action';

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        TestField("Customer No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, "Customer No.");

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

        NPRAttrEditable := CurrPage.Editable();

        CurrPage.PointsSummary.PAGE.FillPageSummary(Rec."Entry No.");
        CurrPage.PointsSummary.PAGE.Update(false);

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

        RaptorEnabled := (RaptorSetup.Get and RaptorSetup."Enable Raptor Functions");

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

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindFirst()) then begin
            GuardianMember.Get(MembershipRole."Member Entry No.");
            MemberInfoCapture."Guardian External Member No." := GuardianMember."External Member No.";
            MemberInfoCapture."E-Mail Address" := GuardianMember."E-Mail Address";
        end;

        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        Commit();

        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();
        if (PageAction = ACTION::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);
            MembershipManagement.AddMemberAndCard("Entry No.", MemberInfoCapture, false, MemberInfoCapture."Member Entry No", ResponseMessage);

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

            // MembershipManagement.AddGuardianMember (Rec."Entry No.", MemberInfoCapture."Guardian External Member No.");
            MembershipManagement.AddGuardianMember(Rec."Entry No.", MemberInfoCapture."Guardian External Member No.", MemberInfoCapture."GDPR Approval");

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

                        //LoyaltyCouponMgr.IssueOneCouponAndPrint (TmpLoyaltyPointsSetup."Coupon Type Code", Membership."Entry No.", TmpLoyaltyPointsSetup."Points Threshold",0);
                        LoyaltyCouponMgr.IssueOneCouponAndPrint(TmpLoyaltyPointsSetup."Coupon Type Code", Membership."Entry No.", Membership."External Membership No.", Today, TmpLoyaltyPointsSetup."Points Threshold", 0);

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

        Commit();
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, TmpMembershipAutoRenew."Last Invoice No.");
        SalesInvoicePage.SetRecord(SalesHeader);
        SalesInvoicePage.RunModal();
    end;

    local procedure SetMasterDataAttributeValue(AttributeNumber: Integer)
    begin

        NPRAttrManagement.SetEntryAttributeValue(GetAttributeTableId(), AttributeNumber, "Entry No.", NPRAttrTextArray[AttributeNumber]);

    end;

    local procedure GetMasterDataAttributeValue()
    begin

        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, GetAttributeTableId, "Entry No.");
        NPRAttrEditable := CurrPage.Editable();

    end;

    procedure GetAttributeVisibility(AttributeNumber: Integer): Boolean
    begin

        exit(NPRAttrVisibleArray[AttributeNumber]);

    end;

    local procedure GetAttributeTableId(): Integer
    begin

        exit(DATABASE::"NPR MM Membership");

    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    begin

        exit(StrSubstNo('6014555,%1,%2,2', GetAttributeTableId(), AttributeNumber));

    end;

    local procedure OnAttributeLookup(AttributeNumber: Integer)
    begin

        //NPRAttrManagement.OnPageLookUp (GetAttributeTableId, AttributeNumber, FORMAT (AttributeNumber,0,'<integer>'), NPRAttrTextArray[AttributeNumber] );
        NPRAttrManagement.OnPageLookUp(GetAttributeTableId, AttributeNumber, Format("Entry No.", 0, '<integer>'), NPRAttrTextArray[AttributeNumber]);

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

