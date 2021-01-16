page 6060127 "NPR MM Memberships"
{

    Caption = 'Memberships';
    CardPageID = "NPR MM Membership Card";
    DataCaptionExpression = "External Membership No.";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Membership";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Issued Date"; "Issued Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issued Date field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                field("Auto-Renew"; "Auto-Renew")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew field';
                }
                field("Auto-Renew Payment Method Code"; "Auto-Renew Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew Payment Method Code field';
                }
                field(DisplayName; DisplayName)
                {
                    ApplicationArea = All;
                    Caption = 'Member Display Name';
                    ToolTip = 'Specifies the value of the Member Display Name field';
                }
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';

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

                    trigger OnValidate()
                    begin

                        SetMasterDataAttributeValue(10);

                    end;
                }
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Membership action';
            }
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = Interaction;
                RunObject = Page "NPR MM Membership Notific.";
                RunPageLink = "Membership Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Membership Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Notifications action';
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
            action("Open Coupons")
            {
                Caption = 'Open Coupons';
                Image = Voucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NpDc Coupons";
                RunPageLink = "Customer No." = FIELD("Customer No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Open Coupons action';
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
        area(processing)
        {
            action("Update Customer")
            {
                Caption = 'Update Customer Information';
                Image = CreateInteraction;
                ApplicationArea = All;
                ToolTip = 'Executes the Update Customer Information action';
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                begin
                    SyncContacts();
                end;
            }
            group(Loyalty)
            {
                action("Loyalty Point Summary")
                {
                    Caption = 'Loyalty Point Summary';
                    Image = CreditCard;
                    RunObject = Report "NPR MM Membersh. Points Summ.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Loyalty Point Summary action';
                }
                action("Loyalty Point Value")
                {
                    Caption = 'Loyalty Point Value';
                    Image = LimitedCredit;
                    RunObject = Report "NPR MM Membership Points Value";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Loyalty Point Value action';
                }
                action("Loyalty Point Details")
                {
                    Caption = 'Loyalty Point Details';
                    Image = CreditCardLog;
                    RunObject = Report "NPR MM Membership Points Det.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Loyalty Point Details action';
                }
            }
            action(SetNPRAttributeFilter)
            {
                Caption = 'Set Client Attribute Filter';
                Image = "Filter";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                Visible = NPRAttrVisible01 OR NPRAttrVisible02 OR NPRAttrVisible03 OR NPRAttrVisible04 OR NPRAttrVisible05 OR NPRAttrVisible06 OR NPRAttrVisible07 OR NPRAttrVisible08 OR NPRAttrVisible09 OR NPRAttrVisible10;
                ApplicationArea = All;
                ToolTip = 'Executes the Set Client Attribute Filter action';

                trigger OnAction()
                var
                    NPRAttributeValueSet: Record "NPR Attribute Value Set";
                begin

                    if (not NPRAttrManagement.SetAttributeFilter(NPRAttributeValueSet)) then
                        exit;

                    SetView(NPRAttrManagement.GetAttributeFilterView(NPRAttributeValueSet, Rec));

                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
    begin
        MembershipRole.SetFilter("Membership Entry No.", '=%1', "Entry No.");
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
        n: Integer;
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

        RaptorEnabled := (RaptorSetup.Get and RaptorSetup."Enable Raptor Functions");

    end;

    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
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
}

