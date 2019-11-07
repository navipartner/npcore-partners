page 6060127 "MM Memberships"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.08/TSA/20160223  CASE 234913 Include company name field on membership
    // MM1.10/TSA/20160404  CASE 233948 Added a the Update Customer button to sync customer and contact
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.17/TSA/20170125  CASE 243075 Added the loyality reports
    // MM1.18/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.21/TSA /20170721 CASE 284653 Added button "Arrival Log"
    // MM1.22/TSA /20170829 CASE 286922 Added field "Auto-Renew"
    // MM1.22/NPKNAV/20170914  CASE 285403 Transport MM1.22 - 13 September 2017
    // MM1.34/TSA/20180927  CASE 327637 Transport MM1.34 - 27 September 2018
    // NPR5.46/BHR/20180110 CASE 330112 Added field "Auto-Renew Payment Method Code"
    // MM1.40/TSA /20190822 CASE 360242 Adding NPR Attributes
    // MM1.40.01/TSA /20190822 CASE 360242 removing grouping withing repeater

    Caption = 'Memberships';
    CardPageID = "MM Membership Card";
    DataCaptionExpression = "External Membership No.";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MM Membership";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Membership No."; "External Membership No.")
                {
                }
                field("Community Code"; "Community Code")
                {
                }
                field("Customer No."; "Customer No.")
                {
                }
                field("Company Name"; "Company Name")
                {
                }
                field("Membership Code"; "Membership Code")
                {
                }
                field("Issued Date"; "Issued Date")
                {
                }
                field(Description; Description)
                {
                }
                field(Blocked; Blocked)
                {
                }
                field("Blocked At"; "Blocked At")
                {
                }
                field("Auto-Renew"; "Auto-Renew")
                {
                }
                field("Auto-Renew Payment Method Code"; "Auto-Renew Payment Method Code")
                {
                }
                field(DisplayName; DisplayName)
                {
                    Caption = 'Member Display Name';
                }
                field(NPRAttrTextArray_01;NPRAttrTextArray[1])
                {
                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (1);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_02;NPRAttrTextArray[2])
                {
                    CaptionClass = GetAttributeCaptionClass(2);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (2);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_03;NPRAttrTextArray[3])
                {
                    CaptionClass = GetAttributeCaptionClass(3);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (3);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_04;NPRAttrTextArray[4])
                {
                    CaptionClass = GetAttributeCaptionClass(4);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (4);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_05;NPRAttrTextArray[5])
                {
                    CaptionClass = GetAttributeCaptionClass(5);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (5);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_06;NPRAttrTextArray[6])
                {
                    CaptionClass = GetAttributeCaptionClass(6);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (6);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_07;NPRAttrTextArray[7])
                {
                    CaptionClass = GetAttributeCaptionClass(7);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (7);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_08;NPRAttrTextArray[8])
                {
                    CaptionClass = GetAttributeCaptionClass(8);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (8);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_09;NPRAttrTextArray[9])
                {
                    CaptionClass = GetAttributeCaptionClass(9);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (9);
                        //+MM1.40 [360242]
                    end;
                }
                field(NPRAttrTextArray_10;NPRAttrTextArray[10])
                {
                    CaptionClass = GetAttributeCaptionClass(10);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (10);
                        //+MM1.40 [360242]
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
                RunObject = Page "MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
            }
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = Interaction;
                RunObject = Page "MM Membership Notification";
                RunPageLink = "Membership Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Membership Entry No.");
            }
            action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Member Arrival Log";
                RunPageLink = "External Membership No." = FIELD("External Membership No.");
            }
            action("Open Coupons")
            {
                Caption = 'Open Coupons';
                Image = Voucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NpDc Coupons";
                RunPageLink = "Customer No." = FIELD("Customer No.");
            }
        }
        area(processing)
        {
            action("Update Customer")
            {
                Caption = 'Update Customer Information';
                Image = CreateInteraction;
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
                    RunObject = Report "MM Membership Points Summary";
                }
                action("Loyalty Point Value")
                {
                    Caption = 'Loyalty Point Value';
                    Image = LimitedCredit;
                    RunObject = Report "MM Membership Points Value";
                }
                action("Loyalty Point Details")
                {
                    Caption = 'Loyalty Point Details';
                    Image = CreditCardLog;
                    RunObject = Report "MM Membership Points Detail";
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

                trigger OnAction()
                var
                    NPRAttributeValueSet: Record "NPR Attribute Value Set";
                begin

                    //-MM1.40 [360242]
                    if (not NPRAttrManagement.SetAttributeFilter(NPRAttributeValueSet)) then
                        exit;

                    SetView(NPRAttrManagement.GetAttributeFilterView(NPRAttributeValueSet, Rec));
                    //+MM1.40 [360242]
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MembershipRole: Record "MM Membership Role";
        Member: Record "MM Member";
    begin
        MembershipRole.SetFilter("Membership Entry No.", '=%1', "Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::GUARDIAN);
        DisplayName := '';
        if (MembershipRole.FindFirst()) then begin
            MembershipRole.CalcFields("Member Display Name");
            DisplayName := MembershipRole."Member Display Name";
        end;

        //-MM1.40 [360242]
        GetMasterDataAttributeValue();
        //+MM1.40 [360242]
    end;

    trigger OnOpenPage()
    var
        n: Integer;
    begin

        //-+MM1.18 [266769]
        Rec.SetFilter(Blocked, '=%1', false);

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
        //+MM1.40 [360242]
    end;

    var
        MembershipManagement: Codeunit "MM Membership Management";
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

    local procedure SyncContacts()
    var
        Membership: Record "MM Membership";
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
        exit(DATABASE::"MM Membership");
        //+MM1.40 [360242]
    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    begin

        //-MM1.40 [360242]
        exit(StrSubstNo('6014555,%1,%2,2', GetAttributeTableId(), AttributeNumber));
        //+MM1.40 [360242]
    end;
}

