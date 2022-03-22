﻿page 6014587 "NPR MM Members TEMP"
{
    Extensible = False;
    Caption = 'Members (search result)';
    CardPageID = "NPR MM Member Card";
    DataCaptionExpression = Rec."External Member No.";
    Editable = false;
    PageType = List;
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Member";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ToolTip = 'Specifies the value of the Middle Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Gender; Rec.Gender)
                {
                    ToolTip = 'Specifies the value of the Gender field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Birthday; Rec.Birthday)
                {
                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Contact No."; Rec."Contact No.")
                {
                    ToolTip = 'Specifies the value of the Contact No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("E-Mail News Letter"; Rec."E-Mail News Letter")
                {
                    ToolTip = 'Specifies the value of the E-Mail News Letter field';
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
                field(Country; Rec.Country)
                {
                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the value of the Store Code field';
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
    }

    actions
    {
        area(processing)
        {
            Action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                ToolTip = 'Executes the Create Membership action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
                    MembershipRole: Record "NPR MM Membership Role";
                    MembershipEntryNo: Integer;
                begin

                    if (SelectMembershipSetup(MembershipSalesSetup)) then
                        MembershipEntryNo := CreateMembership(MembershipSalesSetup);

                    if (MembershipEntryNo > 0) then begin
                        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                        MembershipRole.FindFirst();
                        Rec.SetFilter("Entry No.", '=%1', MembershipRole."Member Entry No.");
                        CurrPage.Update(false);
                    end;

                end;
            }
            Action("Register Arrival")
            {
                Caption = 'Register Arrival';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Register Arrival action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
            Action("Update Contact")
            {
                Caption = 'Synchronize Contact';
                Image = CreateInteraction;
                ToolTip = 'Executes the Synchronize Contact action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    SyncContact();
                end;
            }
            Action(SetNPRAttributeFilter)
            {
                Caption = 'Set Client Attribute Filter';
                Image = "Filter";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                Visible = AttributesVisible;
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
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                        if (RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory(), true, RaptorAction)) then
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
                        if (RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations(), true, RaptorAction)) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");

                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetMasterDataAttributeValue();
    end;

    trigger OnOpenPage()
    var
        RaptorSetup: Record "NPR Raptor Setup";
        i: Integer;
    begin
        NPRAttrManagement.GetAttributeVisibility(GetAttributeTableId(), NPRAttrVisibleArray);
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

        for i := 1 to ArrayLen(NPRAttrVisibleArray) do
            AttributesVisible := AttributesVisible or NPRAttrVisibleArray[i];

        RaptorEnabled := (RaptorSetup.Get() and RaptorSetup."Enable Raptor Functions");

    end;

    var
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
        AttributesVisible: Boolean;
        RaptorEnabled: Boolean;
        ConfirmContactSynchQst: Label 'Do you want to sync the contacts for %1 members?', Comment = '%1=Member.Count()';
        EntriesNotFoundForMemberErr: Label 'No entries found for member %1.', Comment = '%1=Rec."External Member No."';

    local procedure SetMasterDataAttributeValue(AttributeNumber: Integer)
    begin

        NPRAttrManagement.SetEntryAttributeValue(GetAttributeTableId(), AttributeNumber, Rec."Entry No.", NPRAttrTextArray[AttributeNumber]);

    end;

    local procedure GetMasterDataAttributeValue()
    begin
        if (AttributesVisible) then begin
            NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, GetAttributeTableId(), Rec."Entry No.");
            NPRAttrEditable := CurrPage.Editable();
        end;
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

    local procedure SyncContact()
    var
        Member: Record "NPR MM Member";
        MemberCount: Integer;
    begin
        CurrPage.SetSelectionFilter(Member);
        if (not Member.IsEmpty()) then begin
            MemberCount := Member.Count();
            if (MemberCount > 1) then
                if (not Confirm(ConfirmContactSynchQst, true, MemberCount)) then
                    Error('');

            Member.FindSet(true);
            repeat
                Member.UpdateContactFromMember();
                Member.Modify();
            until (Member.Next() = 0);
        end;
    end;

    local procedure SelectMembershipSetup(var MembershipSalesSetup: Record "NPR MM Members. Sales Setup"): Boolean
    var
        MembershipSalesSetupPage: Page "NPR MM Membership Sales Setup";
    begin

        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
        if (MembershipSalesSetup.Count() = 1) then begin
            exit(MembershipSalesSetup.FindFirst());

        end else begin
            MembershipSalesSetupPage.SetTableView(MembershipSalesSetup);
            MembershipSalesSetupPage.LookupMode(true);
            if (Action::LookupOK = MembershipSalesSetupPage.RunModal()) then begin
                MembershipSalesSetupPage.GetRecord(MembershipSalesSetup);
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure CreateMembership(MembershipSalesSetup: Record "NPR MM Members. Sales Setup") MembershipEntryNo: Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");

        MemberCommunity.Get(MembershipSetup."Community Code");
        MemberCommunity.CalcFields("Foreign Membership");
        MemberCommunity.TestField("Foreign Membership", false);

        MemberInfoCapture.Init();
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        Commit();

        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();

        if (PageAction = Action::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);

            case MembershipSalesSetup."Business Flow Type" of
                MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                    MembershipEntryNo := MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);
                else
                    Error('Not implemented.');
            end;
        end;
    end;

    local procedure GetMembershipFromRole(var Membership: Record "NPR MM Membership")
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        Clear(Membership);
        MembershipRole.SetRange("Member Entry No.", Rec."Entry No.");
        MembershipRole.SetRange(Blocked, false);
        if (MembershipRole.FindFirst()) then
            Membership.Get(MembershipRole."Membership Entry No.");
    end;

    internal procedure FillPage(var TmpMember: Record "NPR MM Member" temporary)
    begin
        if (not Rec.IsTemporary) then
            Error('This page must operate on a temporary copy of Member table.');

        Rec.Copy(TmpMember, true);
    end;
}


