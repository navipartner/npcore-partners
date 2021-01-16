page 6060126 "NPR MM Members"
{

    Caption = 'Members';
    CardPageID = "NPR MM Member Card";
    DataCaptionExpression = "External Member No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Member";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Middle Name"; "Middle Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Middle Name field';
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Gender; Gender)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gender field';
                }
                field(Birthday; Birthday)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Birthday field';
                }
                field("Contact No."; "Contact No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact No. field';
                }
                field("E-Mail News Letter"; "E-Mail News Letter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail News Letter field';
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code Code"; "Post Code Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ZIP Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(Country; Country)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country field';
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Name field';
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
        area(processing)
        {
            action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Membership action';

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
            action("Register Arrival")
            {
                Caption = 'Register Arrival';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Register Arrival action';

                trigger OnAction()
                var
                    MemberWebService: Codeunit "NPR MM Member WebService";
                    ResponseMessage: Text;
                begin

                    if (not MemberWebService.MemberRegisterArrival("External Member No.", '', 'RTC-CLIENT', ResponseMessage)) then
                        Error(ResponseMessage);

                    Message(ResponseMessage);

                end;
            }
            action("Update Contact")
            {
                Caption = 'Synchronize Contact';
                Image = CreateInteraction;
                ApplicationArea = All;
                ToolTip = 'Executes the Synchronize Contact action';

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
            group("NPR FacialRecognition")
            {
                Caption = 'Facial Recognition';
                Image = PersonInCharge;
                action("NPR ImportFace")
                {
                    Caption = 'Import Face Image';
                    ApplicationArea = All;
                    Image = Picture;
                    ToolTip = 'Executes the Import Face Image action';

                    trigger OnAction()
                    var
                        Contact: Record Contact;
                        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
                        FacialRecognitionDetect: Codeunit "NPR Detect Face";
                        FacialRecognitionPersonGroup: Codeunit "NPR Create Person Group";
                        FacialRecognitionPerson: Codeunit "NPR Create Person";
                        FacialRecognitionPersonFace: Codeunit "NPR Add Person Face";
                        FacialRecognitionTrainPersonGroup: Codeunit "NPR Train Person Group";
                        ImageMgt: Codeunit "NPR Image Mgt.";
                        ImageFilePath: Text;
                        EntryNo: Integer;
                        CalledFrom: Option Contact,Member;
                        NotSetUp: Label 'Facial Recognition is not active. \It can be enabled from the Facial Recognition setup.';
                        ImgCantBeProcessed: Label 'Media not supported \ \Image can''t be processed. \Please use .jpg or .png images .';
                        ConnectionError: Label 'The API can''t be reached. \Please contact your administrator.';
                        NoNameError: Label 'Member information is not complete. \Action aborted.';
                    begin
                        if not FacialRecognitionSetup.FindFirst() or not FacialRecognitionSetup.Active then begin
                            Message(NotSetUp);
                            exit;
                        end;

                        if not FacialRecognitionPersonGroup.GetPersonGroups() then begin
                            Message(ConnectionError);
                            exit;
                        end;

                        if not Contact.Get("Contact No.") then
                            exit;

                        if Contact."Name" = '' then begin
                            Message(NoNameError);
                            exit;
                        end;

                        FacialRecognitionPersonGroup.CreatePersonGroup(Contact, false);

                        FacialRecognitionPerson.CreatePerson(Contact, false);

                        FacialRecognitionDetect.DetectFace(Contact, ImageFilePath, EntryNo, false, CalledFrom::Member);
                        case ImageFilePath of
                            '':
                                exit;
                            'WrongExtension':
                                begin
                                    Message(ImgCantBeProcessed);
                                    exit;
                                end;
                        end;

                        if FacialRecognitionPersonFace.AddPersonFace(Contact, ImageFilePath, EntryNo) then begin
                            FacialRecognitionTrainPersonGroup.TrainPersonGroup(Contact, false);
                            ImageMgt.UpdateRecordImage("External Member No.", CalledFrom::Member, ImageFilePath);
                        end else
                            Message(ImgCantBeProcessed);
                    end;
                }

                action("NPR IdentifyFace")
                {
                    Caption = 'Identify Person';
                    ApplicationArea = All;
                    Image = AnalysisView;
                    ToolTip = 'Executes the Identify Person action';

                    trigger OnAction()
                    var
                        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
                        FacialRecognitionIdentify: Codeunit "NPR Identify Person";
                        NotSetUp: Label 'Facial Recognition is not active. \It can be enabled from the Facial Recognition setup.';
                        CalledFrom: Option Contact,Member;
                    begin
                        if not FacialRecognitionSetup.FindFirst() or not FacialRecognitionSetup.Active then begin
                            Message(NotSetUp);
                            exit;
                        end;

                        FacialRecognitionIdentify.IdentifyPersonFace(CalledFrom::Member);
                    end;
                }
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Communication";
                RunPageLink = "Member Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Preferred Com. Methods action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Arrival Log action';
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

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, "External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Recommendations action';

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin

                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, "External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations, true, RaptorAction) then
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
        MembershipRole.SetRange("Member Entry No.", "Entry No.");
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

        RaptorEnabled := (RaptorSetup.Get and RaptorSetup."Enable Raptor Functions");

    end;

    var
        Membership: Record "NPR MM Membership";
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
        CONFIRM_SYNC: Label 'Do you want to sync the contacts for %1 members?';
        RaptorEnabled: Boolean;
        NO_ENTRIES: Label 'No entries found for member %1.';

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

        exit(DATABASE::"NPR MM Member");

    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    begin

        exit(StrSubstNo('6014555,%1,%2,2', GetAttributeTableId(), AttributeNumber));

    end;

    local procedure SyncContact()
    var
        Member: Record "NPR MM Member";
    begin

        CurrPage.SetSelectionFilter(Member);
        if (Member.FindSet()) then begin
            if (Member.Count() > 1) then
                if (not Confirm(CONFIRM_SYNC, true, Member.Count())) then
                    Error('');
            repeat
                Member.Modify(true);
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
            if (ACTION::LookupOK = MembershipSalesSetupPage.RunModal()) then begin
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
        MembershipPage: Page "NPR MM Membership Card";
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

        if (PageAction = ACTION::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);

            case MembershipSalesSetup."Business Flow Type" of
                MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                    MembershipEntryNo := MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);
                else
                    Error('Not implemented.');
            end;

        end;

    end;
}

