page 6060126 "NPR MM Members"
{
    // TM1.00/TSA/20151215  CASE 228982 NaviPartner Ticket Management
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.17/TSA/20161227  CASE 262040 Added Suggested Membercount In Sales
    // MM1.18/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // NPR5.43/TSA/20170328  CASE 270067 Added register arrival button for member.
    // MM1.19/NPKNAV/20170331  CASE 270627 Transport MM1.19 - 31 March 2017
    // MM1.21/TSA /20170721 CASE 284653 Added button "Arrival Log"
    // MM1.22/TSA /20170905 CASE 289429 Removed Delete Member option from List Page, Removed Blocked Filter
    // MM1.24/TSA /20171115 CASE 296437 Bugfix
    // NPR5.43/TS  /20180626 CASE 320616 Added Field Contact No.
    // MM1.32/TSA/20180725  CASE 323333 Transport MM1.32 - 25 July 2018
    // MM1.40/TSA /20190822 CASE 360242 Adding NPR Attributes
    // MM1.41/TSA /20191007 CASE 365970 Update Contact
    // MM1.42/TSA /20191219 CASE 382728 Added Preferred Com. Method related action
    // MM1.42/TSA /20200114 CASE 385449 Added CreateMembership action
    // MM1.43/ALPO/20191125 CASE 387750 Added Raptor integration page actions: Browsing History, Recommendations

    Caption = 'Members';
    CardPageID = "NPR MM Member Card";
    DataCaptionExpression = "External Member No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,History,Raptor';
    SourceTable = "NPR MM Member";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
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
                field(Blocked; Blocked)
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
                field("Contact No."; "Contact No.")
                {
                    ApplicationArea = All;
                }
                field("E-Mail News Letter"; "E-Mail News Letter")
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
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                }
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

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

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue(10);
                        //+MM1.40 [360242]
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

                trigger OnAction()
                var
                    MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
                    MembershipRole: Record "NPR MM Membership Role";
                    MembershipEntryNo: Integer;
                begin

                    //-MM1.42 [385449]
                    if (SelectMembershipSetup(MembershipSalesSetup)) then
                        MembershipEntryNo := CreateMembership(MembershipSalesSetup);

                    if (MembershipEntryNo > 0) then begin
                        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                        MembershipRole.FindFirst();
                        Rec.SetFilter("Entry No.", '=%1', MembershipRole."Member Entry No.");
                        CurrPage.Update(false);
                    end;
                    //+MM1.42 [385449]
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

                trigger OnAction()
                var
                    MemberWebService: Codeunit "NPR MM Member WebService";
                    ResponseMessage: Text;
                begin
                    //-MM1.19 [270067]
                    //-MM1.24 [296437]
                    if (not MemberWebService.MemberRegisterArrival("External Member No.", '', 'RTC-CLIENT', ResponseMessage)) then
                        Error(ResponseMessage);

                    Message(ResponseMessage);
                    //+MM1.19 [270067]
                end;
            }
            action("Update Contact")
            {
                Caption = 'Synchronize Contact';
                Image = CreateInteraction;
                ApplicationArea = All;

                trigger OnAction()
                begin

                    //-MM1.41 [365970]
                    SyncContact();
                    //+MM1.41 [365970]
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
            group("NPR FacialRecognition")
            {
                Caption = 'Facial Recognition';
                Image = PersonInCharge;
                action("NPR ImportFace")
                {
                    Caption = 'Import Face Image';
                    ApplicationArea = All;
                    Image = Picture;

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
                        //-MM1.43 [387750]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, "External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserIdHistory, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");
                        //+MM1.43 [387750]
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

                    trigger OnAction()
                    var
                        RaptorAction: Record "NPR Raptor Action";
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin
                        //-MM1.43 [387750]
                        if (Membership."Customer No." = '') then
                            Error(NO_ENTRIES, "External Member No.");
                        if RaptorMgt.SelectRaptorAction(RaptorMgt.RaptorModule_GetUserRecommendations, true, RaptorAction) then
                            RaptorMgt.ShowRaptorData(RaptorAction, Membership."Customer No.");
                        //+MM1.43 [387750]
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        //-MM1.43 [387750]
        Clear(Membership);
        MembershipRole.SetRange("Member Entry No.", "Entry No.");
        MembershipRole.SetRange(Blocked, false);
        if MembershipRole.FindFirst() then
            Membership.Get(MembershipRole."Membership Entry No.");
        //+MM1.43 [387750]
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
        //+MM1.40 [360242]
        //-MM1.43 [387750]
        RaptorEnabled := (RaptorSetup.Get and RaptorSetup."Enable Raptor Functions");
        //+MM1.43 [387750]
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

    local procedure SyncContact()
    var
        Member: Record "NPR MM Member";
    begin

        //-MM1.41 [365970]
        CurrPage.SetSelectionFilter(Member);
        if (Member.FindSet()) then begin
            if (Member.Count() > 1) then
                if (not Confirm(CONFIRM_SYNC, true, Member.Count())) then
                    Error('');
            repeat
                Member.Modify(true);
            until (Member.Next() = 0);
        end;
        //+MM1.41 [365970]
    end;

    local procedure SelectMembershipSetup(var MembershipSalesSetup: Record "NPR MM Members. Sales Setup"): Boolean
    var
        MembershipSalesSetupPage: Page "NPR MM Membership Sales Setup";
    begin

        //-MM1.42 [385449]
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
        //+MM1.42 [385449]
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

        //-MM1.42 [385449]
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
        //+MM1.42 [385449]
    end;
}

