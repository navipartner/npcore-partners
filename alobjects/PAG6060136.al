page 6060136 "MM Member Card"
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

    Caption = 'Member Card';
    DataCaptionExpression = "External Member No.";
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "MM Member";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Member No.";"External Member No.")
                {
                    Importance = Promoted;
                }
                field("Display Name";"Display Name")
                {
                    Importance = Promoted;
                }
                field("First Name";"First Name")
                {
                }
                field("Middle Name";"Middle Name")
                {
                }
                field("Last Name";"Last Name")
                {
                }
                field("E-Mail Address";"E-Mail Address")
                {
                }
                field("Phone No.";"Phone No.")
                {
                    Importance = Additional;
                }
                field("Social Security No.";"Social Security No.")
                {
                }
                field(Address;Address)
                {
                }
                field("Post Code Code";"Post Code Code")
                {
                }
                field(City;City)
                {
                }
                field(Country;Country)
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
            }
            group(CRM)
            {
                field(Picture;Picture)
                {
                }
                field(Gender;Gender)
                {
                }
                field(Birthday;Birthday)
                {
                }
                field("E-Mail News Letter";"E-Mail News Letter")
                {
                }
                field("Notification Method";"Notification Method")
                {
                }
            }
            part(MembershipListPart;"MM Member Membership ListPart")
            {
                SubPageLink = "Member Entry No."=FIELD("Entry No.");
                SubPageView = SORTING("Member Entry No.","Membership Entry No.");
            }
            part(MemberCardsSubpage;"MM Member Cards ListPart")
            {
                SubPageLink = "Member Entry No."=FIELD("Entry No.");
                SubPageView = SORTING("Entry No.")
                              ORDER(Descending);
            }
            group(Attributes)
            {
                Caption = 'Attributes';
                field(NPRAttrTextArray_01;NPRAttrTextArray[1])
                {
                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (1);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (2);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (3);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (4);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (5);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (6);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (7);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (8);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (9);
                        //+MM1.40 [360242]
                    end;

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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-MM1.40 [360242]
                        OnAttributeLookup (10);
                        //+MM1.40 [360242]
                    end;

                    trigger OnValidate()
                    begin
                        //-MM1.40 [360242]
                        SetMasterDataAttributeValue (10);
                        //+MM1.40 [360242]
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6150638;Notes)
            {
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

                trigger OnAction()
                begin

                    if (Confirm (CONFIRM_PRINT, true, StrSubstNo (CONFIRM_PRINT_FMT, "External Member No.", "Display Name"))) then
                      MemberRetailIntegration.PrintMemberAccountCard ("External Member No.");
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

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "MM Membership Management";
                    MemberCardEntryNo: Integer;
                begin
                    //-MM1.22 [289434]
                    if (Confirm (CONFIRM_PRINT, true, StrSubstNo (CONFIRM_PRINT_FMT, "External Member No.", "Display Name"))) then begin
                      //MemberRetailIntegration.PrintMemberCard ("Entry No.", MembershipManagement.GetMemberCardEntryNo ("Entry No.", TODAY));
                      MemberCardEntryNo := CurrPage.MemberCardsSubpage.PAGE.GetCurrentEntryNo ();
                      MemberRetailIntegration.PrintMemberCard ("Entry No.", MemberCardEntryNo);
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

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "MM Membership Management";
                    MemberCard: Record "MM Member Card";
                    CardEntryNo: Integer;
                    ResponseMessage: Text;
                    MembershipEntryNo: Integer;
                    Membership: Record "MM Membership";
                    MembershipSetup: Record "MM Membership Setup";
                    MemberInfoCapture: Record "MM Member Info Capture";
                begin


                    //-MM1.22 [278175]
                    //-#312939 [312939]
                    //MembershipEntryNo := MembershipManagement.GetMembershipFromExtMemberNo (Rec."External Member No.");
                    MembershipEntryNo := CurrPage.MembershipListPart.PAGE.GetSelectedMembershipEntryNo ();
                    //+#312939 [312939]

                    if (MembershipManagement.MembershipNeedsActivation (MembershipEntryNo)) then
                      if (Confirm (ACTIVATE_MEMBERSHIP, true)) then
                        MembershipManagement.ActivateMembershipLedgerEntry (MembershipEntryNo, Today);
                    //+MM1.22 [278175]

                    //-#312939 [312939]
                    //MembershipManagement.IssueNewMemberCard (TRUE, "Entry No.", CardEntryNo, ResponseMessage);
                    MemberInfoCapture."Member Entry No" := Rec."Entry No.";
                    MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                    MembershipManagement.IssueMemberCard (true, MemberInfoCapture, CardEntryNo, ResponseMessage);
                    //+#312939 [312939]

                    MemberCard.Get (CardEntryNo);

                    //-#310132 [310132]
                    Membership.Get (MembershipEntryNo);
                    MembershipSetup.Get (Membership."Membership Code");

                    case MembershipSetup."Card Expire Date Calculation" of
                      MembershipSetup."Card Expire Date Calculation"::NA : MemberCard."Valid Until" := 0D;
                      MembershipSetup."Card Expire Date Calculation"::DATEFORMULA : MemberCard."Valid Until"  := CalcDate (MembershipSetup."Card Number Valid Until", Today);
                      MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED : MembershipManagement.GetMembershipMaxValidUntilDate (MembershipEntryNo, MemberCard."Valid Until");
                    end;
                    MemberCard.Modify ();
                    //+#310132 [310132]

                    PAGE.Run (6060133, MemberCard);
                end;
            }
            action("Take Picture")
            {
                Caption = 'Take Picture';
                Image = Camera;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MCSWebcamAPI: Codeunit "MCS Webcam API";
                begin
                    MCSWebcamAPI.CallCaptureStartByMMMember(Rec,true);
                end;
            }
            action("Import Picture")
            {
                Caption = 'Import Picture';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MCSFaceServiceAPI: Codeunit "MCS Face Service API";
                begin
                    MCSFaceServiceAPI.ImportPersonPicture(Rec,true);
                end;
            }
            action("Member Anonymization")
            {
                Caption = 'Member Anonymization';
                Ellipsis = true;
                Image = AbsenceCategory;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    GDPRManagement: Codeunit "MM GDPR Management";
                    ReasonText: Text;
                begin
                    if (GDPRManagement.AnonymizeMember (Rec."Entry No.", false, ReasonText)) then
                      if (not Confirm ('Member informtion will be lost! Do you want to continue?', false)) then
                        Error ('');

                    Message (ReasonText);
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
                RunObject = Page "TM Ticket List";
                RunPageLink = "External Member Card No."=FIELD("External Member No.");
            }
            action("Member Notifications")
            {
                Caption = 'Member Notifications';
                Image = InteractionLog;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "MM Member Notification Entry";
                RunPageLink = "Member Entry No."=FIELD("Entry No.");
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
                RunPageLink = "External Member No."=FIELD("External Member No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        //+MM1.40 [360242]
        GetMasterDataAttributeValue ();
        //-MM1.40 [360242]
    end;

    trigger OnOpenPage()
    begin

        //-MM1.40 [360242]
        NPRAttrManagement.GetAttributeVisibility (GetAttributeTableId (), NPRAttrVisibleArray);
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
        NPRAttrEditable := CurrPage.Editable ();
        //+MM1.40 [360242]
    end;

    var
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        CONFIRM_PRINT: Label 'Do you want to print a member account card for %1?';
        CONFIRM_PRINT_FMT: Label '[%1] - %2';
        ACTIVATE_MEMBERSHIP: Label 'The membership has not been activated yet. Do you want to activate it now?';
        NPRAttrTextArray: array [40] of Text[250];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array [40] of Boolean;
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

    local procedure SetMasterDataAttributeValue(AttributeNumber: Integer)
    begin

        //-MM1.40 [360242]
        NPRAttrManagement.SetEntryAttributeValue (GetAttributeTableId (), AttributeNumber, "Entry No.", NPRAttrTextArray[AttributeNumber]);
        //+MM1.40 [360242]
    end;

    local procedure GetMasterDataAttributeValue()
    begin

        //-MM1.40 [360242]
        NPRAttrManagement.GetEntryAttributeValue (NPRAttrTextArray, GetAttributeTableId, "Entry No.");
        NPRAttrEditable := CurrPage.Editable ();
        //+MM1.40 [360242]
    end;

    procedure GetAttributeVisibility(AttributeNumber: Integer): Boolean
    begin

        //-MM1.40 [360242]
        exit (NPRAttrVisibleArray [AttributeNumber]);
        //+MM1.40 [360242]
    end;

    local procedure GetAttributeTableId(): Integer
    begin

        //-MM1.40 [360242]
        exit (DATABASE::"MM Member");
        //+MM1.40 [360242]
    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    begin

        //-MM1.40 [360242]
        exit (StrSubstNo ('6014555,%1,%2,2', GetAttributeTableId(), AttributeNumber));
        //+MM1.40 [360242]
    end;

    local procedure OnAttributeLookup(AttributeNumber: Integer)
    begin

        //-MM1.40 [360242]
        NPRAttrManagement.OnPageLookUp (GetAttributeTableId, AttributeNumber, Format (AttributeNumber,0,'<integer>'), NPRAttrTextArray[AttributeNumber] );
        //+MM1.40 [360242]
    end;
}

