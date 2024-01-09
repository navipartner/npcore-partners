﻿page 6060127 "NPR MM Memberships"
{
    Extensible = False;

    Caption = 'Memberships';
    CardPageID = "NPR MM Membership Card";
    DataCaptionExpression = Rec."External Membership No.";
    InsertAllowed = false;
    Editable = true;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Membership";
    UsageCategory = Lists;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                    Membership: Record "NPR MM Membership";
                    SmartSearch: Codeunit "NPR MM Smart Search";
                begin
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);
                    if (_SearchTerm = '') then begin
                        CurrPage.Update(false);
                        exit;
                    end;

                    SmartSearch.SearchMembership(_SearchTerm, Membership);

                    Rec.Copy(Membership);
                    Rec.SetLoadFields();
                    Rec.MarkedOnly(true);
                    CurrPage.Update(false);
                end;
            }
            repeater(Group)
            {
                Editable = false;
                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the external membership number.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    trigger OnDrillDown()
                    var
                        Card: Page "NPR MM Membership Card";
                    begin
                        Card.SetRecord(Rec);
                        Card.Run();
                    end;
                }
                field("Community Code"; Rec."Community Code")
                {
                    ToolTip = 'Specifies the community code.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer number.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the company name.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the membership code.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Issued Date"; Rec."Issued Date")
                {
                    ToolTip = 'Specifies the issued date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies if the membership is blocked.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ToolTip = 'Specifies when the membership was blocked.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew"; Rec."Auto-Renew")
                {
                    ToolTip = 'Specifies if the membership is auto-renewable.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew Payment Method Code"; Rec."Auto-Renew Payment Method Code")
                {
                    ToolTip = 'Specifies the payment method code for auto-renewal.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(DisplayName; DisplayName)
                {
                    Caption = 'Member Display Name';
                    ToolTip = 'Specifies the member display name.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    begin
                        SetMasterDataAttributeValue(10);
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(MembershipFactBox; "NPR MM Membership FactBox")
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Membership Details';
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OpenMembershipCard)
            {
                Caption = 'Membership';
                Ellipsis = true;
                Image = CustomerList;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                Scope = Repeater;

                ToolTip = 'Opens Membership Card';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;

                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;

                RunObject = Page "NPR MM Create Membership";

                ToolTip = 'Opens the form to create a new membership.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Update Customer")
            {
                Caption = 'Update Customer Information';
                Image = CreateInteraction;

                ToolTip = 'Updates the customer information.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    SyncContacts();
                end;
            }
            action(AddToAlterationJnl)
            {
                Caption = 'Add to alternation journal';
                Ellipsis = true;
                Image = Journal;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;


                ToolTip = 'Adds membership to alternation journal.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    AddToAlterationJournal();
                end;
            }

            action(SetNPRAttributeFilter)
            {
                Caption = 'Set client attribute filter.';
                Image = "Filter";
                Ellipsis = true;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = NPRAttrVisible01 OR NPRAttrVisible02 OR NPRAttrVisible03 OR NPRAttrVisible04 OR NPRAttrVisible05 OR NPRAttrVisible06 OR NPRAttrVisible07 OR NPRAttrVisible08 OR NPRAttrVisible09 OR NPRAttrVisible10;

                ToolTip = 'Sets filters for client''s attributes.';
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
            action(Notifications)
            {
                Caption = 'Notifications';
                Ellipsis = true;
                Image = Interaction;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                RunObject = Page "NPR MM Membership Notific.";
                RunPageLink = "Membership Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Membership Entry No.");
                Scope = Repeater;

                ToolTip = 'Opens membership notifications';
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
                RunPageLink = "External Membership No." = FIELD("External Membership No.");
                Scope = Repeater;

                ToolTip = 'Opens arrival log list';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Open Coupons")
            {
                Caption = 'Coupons';
                Ellipsis = true;
                Image = Voucher;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                RunObject = Page "NPR NpDc Coupons";
                RunPageLink = "Customer No." = FIELD("Customer No.");
                Scope = Repeater;

                ToolTip = 'Opens coupons list';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action(Achievements)
            {
                Caption = 'Achievements';
                ToolTip = 'This action opens the achievements and progress list for the membership.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = History;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    MemberGoals: Page "NPR MM AchMemberGoalList";
                    Goals: Record "NPR MM AchGoal";
                begin
                    Goals.FilterGroup(248);
                    Goals.SetFilter(CommunityCode, '=%1', Rec."Community Code");
                    Goals.SetFilter(MembershipCode, '=%1', Rec."Membership Code");
                    Goals.SetFilter(Activated, '=%1', true);
                    Goals.SetFilter(MembershipEntryNoFilter, '=%1', Rec."Entry No.");
                    Goals.FilterGroup(0);
                    MemberGoals.SetTableView(Goals);
                    MemberGoals.Run();
                end;
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
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = FIELD("Customer No.");
                    RunPageView = SORTING("Customer No.");
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'Opens ledger entries for the selected record.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action(ItemLedgerEntries)
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Source No." = FIELD("Customer No.");
                    RunPageView = SORTING("Source Type", "Source No.", "Posting Date")
                                  ORDER(Descending)
                                  WHERE("Source Type" = CONST(Customer));

                    ToolTip = 'Opens item ledger entries for the selected record.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Customer Statistics";
                    RunPageLink = "No." = FIELD("Customer No.");
                    ShortCutKey = 'F7';

                    ToolTip = 'Opens the statistics for the selected record.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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

                    ToolTip = 'Opens the browsing history for the selected record.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin
                        Rec.TestField("Customer No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory(), true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Rec."Customer No.");
                    end;
                }
                action(RaptorRecommendations)
                {
                    Caption = 'Recommendations';
                    Enabled = RaptorEnabled;
                    Image = SuggestElectronicDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Visible = RaptorEnabled;

                    ToolTip = 'Displays recommendations for the selected record.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin
                        Rec.TestField("Customer No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations(), true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Rec."Customer No.");
                    end;
                }
            }
        }

        area(Reporting)
        {
            group(Loyalty)
            {
                action("Loyalty Point Summary")
                {
                    Caption = 'Loyalty Point Summary';
                    Image = CreditCard;
                    RunObject = Report "NPR MM Membersh. Points Summ.";

                    ToolTip = 'Displays loyalty point summary for the selected record.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action("Loyalty Point Value")
                {
                    Caption = 'Loyalty Point Value';
                    Image = LimitedCredit;
                    RunObject = Report "NPR MM Membership Points Value";

                    ToolTip = 'Displays loyalty point value for the selected record.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action("Loyalty Point Details")
                {
                    Caption = 'Loyalty Point Details';
                    Image = CreditCardLog;
                    RunObject = Report "NPR MM Membership Points Det.";

                    ToolTip = 'Displays loyalty point details for the selected record.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }

    }

    trigger OnAfterGetRecord()
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        MembershipRole.SetFilter("Membership Entry No.", '=%1', Rec."Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::GUARDIAN);
        DisplayName := '';
        if (MembershipRole.FindFirst()) then begin
            MembershipRole.CalcFields("Member Display Name");
            DisplayName := MembershipRole."Member Display Name";
        end;

        GetMasterDataAttributeValue();

    end;

    trigger OnOpenPage()
    var
        RaptorSetup: Record "NPR Raptor Setup";
    begin
        Rec.SetFilter(Blocked, '=%1', false);

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

        RaptorEnabled := (RaptorSetup.Get() and RaptorSetup."Enable Raptor Functions");

    end;

    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        _SearchTerm: Text[100];
        CONFIRM_SYNC: Label 'Do you want to sync the customers and contacts for %1 memberships?';
        DisplayName: Text[200];
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

    local procedure SyncContacts()
    var
        Membership: Record "NPR MM Membership";
    begin
        CurrPage.SetSelectionFilter(Membership);
        if (Membership.FindSet()) then begin
            if (Membership.Count() > 1) then
                if (not Confirm(CONFIRM_SYNC, true, Membership.Count())) then
                    Error('');
            repeat
                MembershipManagement.SynchronizeCustomerAndContact(Membership."Entry No.");
            until (Membership.Next() = 0);
        end;
    end;


    local procedure AddToAlterationJournal()
    var
        Membership: Record "NPR MM Membership";
    begin
        CurrPage.SetSelectionFilter(Membership);
        if Membership.FindSet() then begin
            repeat
                MembershipManagement.AddToAlterationJournal(Membership);
            until Membership.Next() = 0;
        end;
    end;

    local procedure SetMasterDataAttributeValue(AttributeNumber: Integer)
    begin
        NPRAttrManagement.SetEntryAttributeValue(GetAttributeTableId(), AttributeNumber, Rec."Entry No.", NPRAttrTextArray[AttributeNumber]);
    end;

    local procedure GetMasterDataAttributeValue()
    begin
        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, GetAttributeTableId(), Rec."Entry No.");
        NPRAttrEditable := CurrPage.Editable();
    end;

    internal procedure GetAttributeVisibility(AttributeNumber: Integer): Boolean
    begin
        exit(NPRAttrVisibleArray[AttributeNumber]);
    end;

    local procedure GetAttributeTableId(): Integer
    begin
        exit(DATABASE::"NPR MM Membership");
    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    var
        PlaceHolderLbl: Label '6014555,%1,%2,2', Locked = true;
    begin
        exit(StrSubstNo(PlaceHolderLbl, GetAttributeTableId(), AttributeNumber));
    end;

}

