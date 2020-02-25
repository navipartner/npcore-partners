page 6060134 "MM Member Info Capture"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.03/TSA/20160104  CASE 230647 - Added NewsLetter CRM option
    // MM1.07/TSA/20160202  CASE 232955 - Email verification does preemptive check.
    // MM1.07/TSA/20160202  CASE 233246 Changed from Card to List, added email verification
    // MM1.08/TSA/20160223  CASE 234913 - Include company name field on membership
    // MM1.10/TSA/20160325  CASE 236532 - Added picture blob field
    // MM1.11/TSA/20160502  CASE 233824 Transport MM1.11 - 29 April 2016
    // MM1.14/TSA/20160523  CASE 240871 Notification Service
    // MM1.15/CLV/20160608  CASE 243143 Picture handling
    // MM1.15/TSA/20160810  CASE 248625 Adding import log functionality to also use this page
    // MM1.15/CLVA/20160623 CASE 240868 Added action "Take Picture"
    // MM1.16/TSA/20160915  CASE 252416 Fixed the member no data required setting
    // MM1.17/TSA/20161124  CASE 259339 Added check on more required fields from setup.
    // MM1.17/TSA/20161205  CASE 260181 Added function SetDefaultvalues
    // MM1.17/TSA/20161208  CASE 259671 Added Document Date to page so defered activation can be registered
    // MM1.17/TSA/20161227  CASE 262040 Making page responsive to field MembershipSalesSetup."Business Flow Type"::add_member
    // MM1.17/TSA/20161229  CASE 261216 Making page responsive to field MembershipSalesSetup."Business Flow Type"::add_card
    // MM1.19/CLVA/20170406 CASE 271377 Change pagetype from ListPlus to Card because of runtime errors
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.21/NPKNAV/20170728  CASE 284653 Transport MM1.21 - 28 July 2017
    // MM1.22/TSA /20170807 CASE 276832 Encapsulated the member email check to respect community setup
    // MM1.22/TSA /20170816 CASE 287080 Handling Businessflow for Anononymous Member
    // MM1.22/TS  /20180830  CASE 288705 Changed Importance of fields to Additional
    // MM1.22/TSA /20170831 CASE 286922 Adding field Auto-Renew to page
    // MM1.22/KENU/20170905 CASE 288705 Sections expanded initially
    // MM1.25/TSA /20171213 CASE 299690 Added the SetGuardian mode to apply a guardian from backend on existing membership
    // MM1.26/TSA /20180206 CASE 304580 Added phone no and external card no to repeater area, made fields editable
    // MM1.29/TSA /20180502 CASE 313542 Change the logic around "Valid Until" date to correspond to how new setup works
    // MM1.29/TSA /20180511 CASE 313795 GDPR Approval
    // MM1.32/TSA /20180710 CASE 318132 Member Card Type, general usability improvements
    // MM1.33/TSA /20180816 CASE 325198 Avoiding a hard error when membership sales setup does not provide a membership code.
    // MM1.33/TSA /20180821 CASE 324065 Guardian set when adding a member for membership with a guardian defined
    // MM1.34/TSA /20180906 CASE 327614 Added a test for maximum combined length of name fields
    // MM1.40/TSA /20190822 CASE 360242 Adding NPR Attributes
    // MM1.42/TSA /20191118 CASE 378202 Picture is not commited to DB, unless you commit the record and when a field is validated with code on the page, its not the same record - picture is removed.

    Caption = 'Member Information';
    DataCaptionExpression = "External Member No";
    InsertAllowed = false;
    SourceTable = "MM Member Info Capture";

    layout
    {
        area(content)
        {
            group(Membership)
            {
                Caption = 'Membership Lookup';
                Visible = ShowAddToMembershipSection;
                field("External Membership No.";"External Membership No.")
                {
                    Caption = 'Add Member to Membership';
                    Editable = ExternalMembershipNoEditable;
                    ShowMandatory = true;

                    trigger OnDrillDown()
                    var
                        MemberInfoCapture: Record "MM Member Info Capture";
                        Membership: Record "MM Membership";
                        TmpMembership: Record "MM Membership" temporary;
                    begin

                        if ("Receipt No." <> '') then begin
                          MemberInfoCapture.SetFilter ("Receipt No.", '=%1', "Receipt No.");
                          MemberInfoCapture.SetFilter ("Line No.", '<>%1', "Line No.");
                          if (MemberInfoCapture.FindSet ()) then begin
                            repeat
                              if (Membership.Get (MemberInfoCapture."Membership Entry No.")) then begin
                                TmpMembership.TransferFields (Membership, true);
                                TmpMembership.Insert ();
                              end;
                            until (MemberInfoCapture.Next () = 0);
                          end;

                          if (PAGE.RunModal (6060127, TmpMembership) = ACTION::LookupOK) then begin
                            SetExternalMembershipNo (TmpMembership."External Membership No.");
                            CurrPage.Update (true);
                          end;
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipLookup ();
                    end;

                    trigger OnValidate()
                    var
                        Membership: Record "MM Membership";
                    begin

                        SetExternalMembershipNo ("External Membership No.");
                    end;
                }
                field(Quantity;Quantity)
                {
                    Caption = 'Member Count';
                    Editable = false;
                    Visible = false;
                }
            }
            group(AddMemberCard)
            {
                Caption = 'Add Member Card';
                Visible = ShowAddMemberCardSection;
                field("External Member No";"External Member No")
                {
                    Caption = 'Add Card for Member';
                    ShowMandatory = true;

                    trigger OnDrillDown()
                    var
                        MemberInfoCapture: Record "MM Member Info Capture";
                        Member: Record "MM Member";
                        TmpMember: Record "MM Member" temporary;
                    begin

                        if ("Receipt No." <> '') then begin
                          MemberInfoCapture.SetFilter ("Receipt No.", '=%1', "Receipt No.");
                          MemberInfoCapture.SetFilter ("Line No.", '<>%1', "Line No.");
                          if (MemberInfoCapture.FindSet ()) then begin
                            repeat
                              if (Member.Get (MemberInfoCapture."Member Entry No")) then begin
                                TmpMember.TransferFields (Member, true);
                                TmpMember.Insert ();
                              end;
                            until (MemberInfoCapture.Next () = 0);
                          end;

                          if (PAGE.RunModal (6060126, TmpMember) = ACTION::LookupOK) then begin
                            "First Name" := TmpMember."First Name";
                            "Last Name" := TmpMember."Last Name";
                            "E-Mail Address" := TmpMember."E-Mail Address";
                            "Phone No." := TmpMember."Phone No.";

                            SetExternalMemberNo (TmpMember."External Member No.");

                            CurrPage.Update (true);
                          end;
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipMemberLookup ();
                    end;

                    trigger OnValidate()
                    begin

                        SetExternalMemberNo ("External Member No");
                    end;
                }
            }
            group(AddGuardian)
            {
                Caption = 'Set Membership Guardian';
                Visible = SetGuardianMode;
                field(AddGuardianToExistingMembership;"Guardian External Member No.")
                {
                    ShowMandatory = SetGuardianMode;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipMemberLookup ();
                    end;
                }
                field(GuardianGDPRApproval;"GDPR Approval")
                {
                    OptionCaption = 'Not Selected,Pending,Accepted,Rejected';
                    ShowMandatory = GDPRMandatory;
                    Style = Attention;
                    StyleExpr = NOT GDPRSelected;
                }
            }
            group(ReplaceMemberCard)
            {
                Caption = 'Replace Member Card';
                Visible = ShowReplaceCardSection;
                field(ReplaceMemberNoCard;"External Member No")
                {
                    Caption = 'Replace Card for Member';
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipMemberLookup ();
                    end;

                    trigger OnValidate()
                    begin

                        SetExternalMemberNo ("External Member No");
                    end;
                }
                field("Replace External Card No.";"Replace External Card No.")
                {
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MemberCardLookup ("Member Entry No", true);
                    end;

                    trigger OnValidate()
                    var
                        MembershipManagement: Codeunit "MM Membership Management";
                        Member: Record "MM Member";
                        ReasonText: Text;
                    begin

                        if (not Member.Get (MembershipManagement.GetMemberFromExtCardNo ("Replace External Card No.", Today, ReasonText))) then
                          Error (ReasonText);

                        Validate ("External Member No", Member."External Member No.");
                        CurrPage.Update (true);

                        SetExternalMemberNo (Member."External Member No.");
                        CurrPage.Update (true);
                    end;
                }
            }
            group(Cardholder)
            {
                Caption = 'Cardholder';
                Visible = ShowCardholderSection;
                field(Picture2;Picture)
                {
                    Editable = false;

                    trigger OnValidate()
                    begin
                        //-MM1.42 [378202]
                        Commit;
                        //+MM1.42 [378202]
                    end;
                }
                field(FirstName2;"First Name")
                {
                    Editable = false;
                }
                field(LastName2;"Last Name")
                {
                    Editable = false;
                }
                field(EmailAddress2;"E-Mail Address")
                {
                    Editable = false;
                    ShowMandatory = EmailMandatory;

                    trigger OnValidate()
                    begin

                        CheckEmail ();
                    end;
                }
            }
            repeater(Overview)
            {
                Visible = ShowMemberOverviewSection;
                field("Entry No.";"Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field(R_PhoneNo;"Phone No.")
                {
                    ShowMandatory = phonenomandatory;
                    Visible = false;
                }
                field(R_FirstName;"First Name")
                {
                }
                field(R_LastName;"Last Name")
                {
                }
                field(R_Email;"E-Mail Address")
                {

                    trigger OnValidate()
                    begin
                        CheckEmail ();
                    end;
                }
                field(R_ExternalCardNo;"External Card No.")
                {
                    ShowMandatory = ExternalCardNoMandatory;
                    Visible = false;
                }
            }
            group(General)
            {
                Visible = ShowNewMemberSection;
                field("Company Name";"Company Name")
                {
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
                field("Phone No.";"Phone No.")
                {
                    ShowMandatory = phonenomandatory;
                }
                field("Social Security No.";"Social Security No.")
                {
                    Importance = Additional;
                    ShowMandatory = SSNMandatory;
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
                field("Country Code";"Country Code")
                {
                }
                field("Enable Auto-Renew";"Enable Auto-Renew")
                {
                    Editable = ShowAutoRenew;
                    Importance = Additional;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if (not "Enable Auto-Renew") then
                          "Auto-Renew Payment Method Code" := '';

                        SetMandatoryVisualQue ();
                    end;
                }
                field("Auto-Renew Payment Method Code";"Auto-Renew Payment Method Code")
                {
                    Importance = Additional;
                    ShowMandatory = AutoRenewPaymentMethodMandatory;

                    trigger OnValidate()
                    begin

                        if ("Auto-Renew Payment Method Code" <> '') then
                          "Enable Auto-Renew" := true;

                        SetMandatoryVisualQue ();
                    end;
                }
            }
            group(CRM)
            {
                Visible = ShowNewMemberSection;
                field(Picture;Picture)
                {

                    trigger OnValidate()
                    begin

                        //-MM1.42 [378202]
                        Commit;
                        //+MM1.42 [378202]
                    end;
                }
                field(Gender;Gender)
                {
                }
                field(Birthday;Birthday)
                {
                    Importance = Additional;
                }
                field("E-Mail Address";"E-Mail Address")
                {
                    ShowMandatory = EmailMandatory;

                    trigger OnValidate()
                    begin

                        CheckEmail ();
                    end;
                }
                field("Guardian External Member No.";"Guardian External Member No.")
                {
                    ShowMandatory = SetGuardianMode;

                    trigger OnDrillDown()
                    var
                        TmpMember: Record "MM Member" temporary;
                        MemberInfoCapture: Record "MM Member Info Capture";
                        Member: Record "MM Member";
                        MembersPage: Page "MM Members";
                        PageAction: Action;
                    begin
                        if ("Receipt No." <> '') then begin
                          MemberInfoCapture.SetFilter ("Receipt No.", '=%1', "Receipt No.");
                          MemberInfoCapture.SetFilter ("Line No.", '<>%1', "Line No.");
                          MemberInfoCapture.SetFilter ("Guardian External Member No.", '=%1', '');
                          if (MemberInfoCapture.FindSet ()) then begin
                            repeat
                              if (Member.Get (MemberInfoCapture."Member Entry No")) then begin
                                TmpMember.TransferFields (Member, true);
                                TmpMember.Insert ();
                              end;
                            until (MemberInfoCapture.Next () = 0);
                          end;

                          if (PAGE.RunModal (6060126, TmpMember) = ACTION::LookupOK) then begin
                            "Guardian External Member No." := TmpMember."External Member No.";
                            "E-Mail Address" := TmpMember."E-Mail Address";
                            CurrPage.Update (true);
                          end;
                        end else begin

                          if (PAGE.RunModal (6060126, Member) = ACTION::LookupOK) then begin
                            "Guardian External Member No." := Member."External Member No.";
                            "E-Mail Address" := Member."E-Mail Address";
                            CurrPage.Update (true);
                          end;

                        end;
                    end;

                    trigger OnValidate()
                    var
                        MembershipManagement: Codeunit "MM Membership Management";
                        Member: Record "MM Member";
                        ReasonText: Text;
                    begin

                        if ("Guardian External Member No." = '') then begin
                          "E-Mail Address" := '';
                          CurrPage.Update (true);
                          exit;
                        end;

                        if (Member.Get (MembershipManagement.GetMemberFromExtCardNo ("Guardian External Member No.", Today, ReasonText))) then begin
                          "Guardian External Member No." := Member."External Member No.";
                          "E-Mail Address" := Member."E-Mail Address";
                          CurrPage.Update (true);
                          exit;
                        end;

                        Member.SetFilter ("External Member No.", '=%1', "Guardian External Member No.");
                        Member.SetFilter (Blocked, '=%1', false);
                        Member.FindFirst ();
                        "Guardian External Member No." := Member."External Member No.";
                        "E-Mail Address" := Member."E-Mail Address";
                        CurrPage.Update (true);
                    end;
                }
                field("News Letter";"News Letter")
                {
                    Importance = Additional;
                }
                field("GDPR Approval";"GDPR Approval")
                {
                    Editable = gdprmandatory;
                    OptionCaption = 'Not Selected,Pending,Accepted,Rejected';
                    ShowMandatory = GDPRMandatory;
                    Style = Attention;
                    StyleExpr = NOT GDPRSelected;
                }
                field("Notification Method";"Notification Method")
                {
                }
                field("User Logon ID";"User Logon ID")
                {
                    Importance = Additional;
                }
                field("Password SHA1";"Password SHA1")
                {
                    Importance = Additional;
                }
                field("Document Date";"Document Date")
                {
                    Caption = 'Activation Date';
                    Editable = ActivationDateEditable;
                    Importance = Additional;
                    ShowMandatory = ActivationDateMandatory;

                    trigger OnValidate()
                    var
                        MembershipSalesSetup: Record "MM Membership Sales Setup";
                        MembershipSetup: Record "MM Membership Setup";
                    begin

                        if ("Item No." <> '') then begin
                          MembershipSalesSetup.SetFilter (Type, '=%1', MembershipSalesSetup.Type::ITEM);
                          MembershipSalesSetup.SetFilter ("No.", '=%1', "Item No.");
                          if (MembershipSalesSetup.FindFirst ()) then begin
                            MembershipSetup.Get (MembershipSalesSetup."Membership Code");

                            if ("Document Date" > 0D) then begin
                              if (CalcDate (MembershipSalesSetup."Duration Formula", "Document Date") < WorkDate) then
                                Error (INVALID_ACTIVATION_DATE, "Document Date");

                              //-MM1.29 [313542]
                              //IF (FORMAT (MembershipSetup."Card Number Valid Until") <> '') THEN
                              //  "Valid Until" := CALCDATE (MembershipSetup."Card Number Valid Until", "Document Date");
                              case MembershipSetup."Card Expire Date Calculation" of
                                MembershipSetup."Card Expire Date Calculation"::DATEFORMULA :  "Valid Until" := CalcDate (MembershipSetup."Card Number Valid Until", "Document Date");
                                MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED : "Valid Until" := CalcDate (MembershipSalesSetup."Duration Formula", "Document Date");
                                else
                                  "Valid Until" := 0D;
                              end;
                              //+MM1.29 [313542]
                            end;

                            //-MM1.29 [313542]
                            if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::NA) then
                              "Valid Until" := 0D;
                            //+MM1.29 [313542]

                          end;
                        end;
                        ActivationDate := "Document Date";
                    end;
                }
            }
            group(Card)
            {
                Visible = ShowNewCardSection;
                field("External Card No.";"External Card No.")
                {
                    ShowMandatory = ExternalCardNoMandatory;
                }
                field("Pin Code";"Pin Code")
                {
                    Importance = Additional;
                }
                field("Valid Until";"Valid Until")
                {
                    Editable = CardValidUntilMandatory;
                    Importance = Additional;
                    ShowMandatory = CardValidUntilMandatory;
                }
                field("Member Card Type";"Member Card Type")
                {
                    Editable = EditMemberCardType;
                    Importance = Additional;
                }
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
    }

    actions
    {
        area(processing)
        {
            action("Import Members")
            {
                Caption = 'Import Members';
                Image = ImportCodes;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowImportMemberAction;

                trigger OnAction()
                begin
                    ImportMembers ();
                end;
            }
            action("Take Picture ")
            {
                Caption = 'Take Picture';
                Image = Camera;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MCSWebcamAPI: Codeunit "MCS Webcam API";
                    MemberCameraHook: Codeunit "MM Member Camera Hook";
                begin
                     MCSWebcamAPI.CallCaptureStartByMMMemberInfoCapture(Rec,true);
                    // MemberCameraHook.OpenCameraMMMemberInfoCapture (Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-MM1.15
        Clear(xRec.Picture);
        //+MM1.15
    end;

    trigger OnAfterGetRecord()
    begin

        if (ActivationDateEditable) then
          Validate ("Document Date", ActivationDate);

        if (ShowAddToMembershipSection) then
          SetExternalMembershipNo (ExternalMembershipNo);

        SetDefaultValues ();

        SetMandatoryVisualQue ();

        //+MM1.40 [360242]
        GetMasterDataAttributeValue ();
        //-MM1.40 [360242]

        CurrPage.Update (false);
    end;

    trigger OnInit()
    begin

        ShowNewMemberSection := true;
        ShowNewCardSection := true;
    end;

    trigger OnOpenPage()
    begin
        SetDefaultValues ();

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

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RequiredFields: Boolean;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin
        if (CloseAction = ACTION::LookupOK) then begin
          if (Rec."Receipt No." <> '') then begin
            Modify ();
            MemberInfoCapture.SetFilter ("Receipt No.", '=%1', "Receipt No.");
            MemberInfoCapture.SetFilter ("Line No.", '=%1', "Line No.");
            RequiredFields := true;
            if (MemberInfoCapture.FindSet ()) then begin
              repeat
                RequiredFields := HaveRequiredFields (MemberInfoCapture);
              until (MemberInfoCapture.Next () = 0) or (not RequiredFields);
            end;
            exit (RequiredFields);
          end else
            exit (HaveRequiredFields (Rec));
        end;
    end;

    var
        EMAIL_EXISTS: Label '%1 is already in use by member [%2] %3.\\If you are certain that the existing member should be blocked from the existing membership and re-registered with the new membership, press Yes.';
        MISSING_REQUIRED_FIELDS: Label 'All required fields do not have values.\\ The following fields must be set: %1';
        EMAIL_INVALID_CONFIRM: Label 'The %1 seems invalid, do you want to correct it?';
        EmailMandatory: Boolean;
        PhoneNoMandatory: Boolean;
        SSNMandatory: Boolean;
        INVALID_VALUE: Label 'The %1 is invalid.';
        ExternalCardNoMandatory: Boolean;
        ShowImportMemberAction: Boolean;
        ActivationDateEditable: Boolean;
        ActivationDateMandatory: Boolean;
        INVALID_ACTIVATION_DATE: Label 'The activation date %1 is not valid. The resulting membership must have remaining time when applying the membership duration formula to activation date.';
        ActivationDate: Date;
        ExternalMembershipNo: Code[20];
        ExternalMemberNo: Code[20];
        ShowMemberOverviewSection: Boolean;
        ShowNewMemberSection: Boolean;
        ShowNewCardSection: Boolean;
        ShowAddToMembershipSection: Boolean;
        ShowAddMemberCardSection: Boolean;
        ShowReplaceCardSection: Boolean;
        ShowCardholderSection: Boolean;
        ShowQuantityField: Boolean;
        EditMemberCardType: Boolean;
        ExtraInfo: Text;
        ShowAutoRenew: Boolean;
        ExternalMembershipNoEditable: Boolean;
        AutoRenewPaymentMethodMandatory: Boolean;
        SetGuardianMode: Boolean;
        CardValidUntilMandatory: Boolean;
        INVALID_SETUP: Label 'The combination %1 %2 and %3 %4 is not supported.';
        GDPRMandatory: Boolean;
        GDPRSelected: Boolean;
        NAMEFIELD_TO_LONG: Label 'The maximum length for "%1", "%2" and "%3" when combined is %4. Current total length is %5.';
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
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

    local procedure CheckEmail()
    var
        MembershipSetup: Record "MM Membership Setup";
        MembershipCommunity: Record "MM Member Community";
        Member: Record "MM Member";
        MembershipManagement: Codeunit "MM Membership Management";
        ValidEmail: Boolean;
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberCommunity: Record "MM Member Community";
    begin
        if ("E-Mail Address" = '') then
          exit;

        ValidEmail := (StrPos ("E-Mail Address", '@') > 1);
        if (ValidEmail) then
          ValidEmail := (StrPos (CopyStr ("E-Mail Address", StrPos ("E-Mail Address", '@')), '.') > 1);

        if (not ValidEmail) then
          if (Confirm (EMAIL_INVALID_CONFIRM, true, FieldCaption("E-Mail Address"))) then
            Error (INVALID_VALUE, FieldCaption ("E-Mail Address"));

        if ("Item No." <> '') then begin
          MembershipSalesSetup.SetFilter (Type, '=%1', MembershipSalesSetup.Type::ITEM);
          MembershipSalesSetup.SetFilter ("No.", '=%1', "Item No.");
          if (MembershipSalesSetup.FindFirst ()) then begin
            MembershipSetup.Get (MembershipSalesSetup."Membership Code");
            MemberCommunity.Get (MembershipSetup."Community Code");

            if (MemberCommunity."Member Unique Identity" =  MemberCommunity."Member Unique Identity"::EMAIL) then begin

              Member.SetFilter ("E-Mail Address", '=%1', LowerCase ("E-Mail Address"));
              Member.SetFilter (Blocked, '=%1', false);
              if (Member.FindFirst ()) then begin
                if (Confirm (EMAIL_EXISTS, false, Member."E-Mail Address", Member."External Member No.", Member."Display Name")) then begin
                  MembershipManagement.BlockMember (MembershipManagement.GetMembershipFromExtMemberNo (Member."External Member No."), Member."Entry No.", true);
                end else begin
                  Error (INVALID_VALUE, FieldCaption ("E-Mail Address"));
                end;
              end;

            end;
          end;
        end;
    end;

    local procedure HaveRequiredFields(MemberInfoCapture: Record "MM Member Info Capture"): Boolean
    var
        MissingInformation: Boolean;
        MissingFields: Text;
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberCommunity: Record "MM Member Community";
        MembershipSetup: Record "MM Membership Setup";
        NameTotalLength: Integer;
        Customer: Record Customer;
        Member: Record "MM Member";
    begin

        MissingInformation := false;
        MissingFields := '';

        if ("Item No." <> '') then begin
          MembershipSalesSetup.SetFilter (Type, '=%1', MembershipSalesSetup.Type::ITEM);
          MembershipSalesSetup.SetFilter ("No.", '=%1', "Item No.");
          if (MembershipSalesSetup.FindFirst ()) then begin

            //-MM1.33 [325198]
            // MembershipSetup.GET (MembershipSalesSetup."Membership Code");
            // MemberCommunity.GET (MembershipSetup."Community Code");
            if (MembershipSetup.Get (MembershipSalesSetup."Membership Code")) then
              MemberCommunity.Get (MembershipSetup."Community Code");
            //+MM1.33 [325198]

            if (ShowNewMemberSection) then begin
              case MemberCommunity."Member Unique Identity" of
                MemberCommunity."Member Unique Identity"::NONE :     MissingInformation := false;
                MemberCommunity."Member Unique Identity"::EMAIL :    SetMissingInfo (MissingInformation, MissingFields, FieldCaption("E-Mail Address"), (MemberInfoCapture."E-Mail Address" = ''));
                MemberCommunity."Member Unique Identity"::PHONENO :  SetMissingInfo (MissingInformation, MissingFields, FieldCaption("Phone No."), (MemberInfoCapture."Phone No." = ''));
                MemberCommunity."Member Unique Identity"::SSN :      SetMissingInfo (MissingInformation, MissingFields, FieldCaption("Social Security No."), (MemberInfoCapture."Social Security No." = ''));
              end;

              if (ActivationDateEditable) and (MemberInfoCapture."Document Date" = 0D) then
                SetMissingInfo (MissingInformation, MissingFields, FieldCaption("Document Date"), ("Document Date" = 0D));
            end;

            if (ShowNewCardSection) then begin
              if (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::EXTERNAL) then begin
                SetMissingInfo (MissingInformation, MissingFields, FieldCaption("External Card No."), (MemberInfoCapture."External Card No." = ''));
                //-MM1.29 [313542]
                //SetMissingInfo (MissingInformation, MissingFields, FIELDCAPTION("Valid Until"), (MemberInfoCapture."Valid Until" = 0D));
                if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then
                  SetMissingInfo (MissingInformation, MissingFields, FieldCaption("Valid Until"), (MemberInfoCapture."Valid Until" = 0D));
                //+MM1.29 [313542]
              end;
            end;

            if (ShowAddToMembershipSection) or (ShowAddMemberCardSection) or (ShowReplaceCardSection) then begin
              SetMissingInfo (MissingInformation, MissingFields, FieldCaption("External Membership No."), (MemberInfoCapture."External Membership No." = ''));
            end;

            if (ShowAddMemberCardSection) or (ShowReplaceCardSection) then begin
              SetMissingInfo (MissingInformation, MissingFields, FieldCaption("External Member No"), (MemberInfoCapture."External Member No" = ''));
            end;

            if ("Enable Auto-Renew") then
              SetMissingInfo (MissingInformation, MissingFields, FieldCaption ("Auto-Renew Payment Method Code"), ("Auto-Renew Payment Method Code" = ''));

            //-MM1.29 [313795]
            case MembershipSetup."GDPR Mode" of
              MembershipSetup."GDPR Mode"::REQUIRED : SetMissingInfo (MissingInformation, MissingFields, Rec.FieldCaption ("GDPR Approval"), (Rec."GDPR Approval" <> Rec."GDPR Approval"::ACCEPTED));
              MembershipSetup."GDPR Mode"::CONSENT : SetMissingInfo (MissingInformation, MissingFields, Rec.FieldCaption ("GDPR Approval"), (Rec."GDPR Approval" = Rec."GDPR Approval"::NA));
            end;
            //+MM1.29 [313795]

            //-MM1.34 [327614]
            if (MemberCommunity."Membership to Cust. Rel.") then begin
              NameTotalLength := StrLen (MemberInfoCapture."First Name") + StrLen (MemberInfoCapture."Middle Name") + StrLen (MemberInfoCapture."Last Name") + 2;
              if ((NameTotalLength > MaxStrLen (Customer.Name)) and not (MissingInformation)) then begin
                Message (NAMEFIELD_TO_LONG, MemberInfoCapture.FieldCaption ("First Name"), MemberInfoCapture.FieldCaption ("Middle Name"), MemberInfoCapture.FieldCaption ("Last Name"),
                       MaxStrLen (Customer.Name), NameTotalLength);
                exit (false);
              end;
            end;

            if (not MemberCommunity."Membership to Cust. Rel.") then begin
              NameTotalLength := StrLen (MemberInfoCapture."First Name") + StrLen (MemberInfoCapture."Last Name") + 1;
              if ((NameTotalLength > MaxStrLen (Member."Display Name")) and not (MissingInformation)) then begin
                Message (NAMEFIELD_TO_LONG, MemberInfoCapture.FieldCaption ("First Name"), MemberInfoCapture.FieldCaption ("Middle Name"), MemberInfoCapture.FieldCaption ("Last Name"),
                       MaxStrLen (Member."Display Name"), NameTotalLength);
                exit (false);
              end;
            end;
            //+MM1.34 [327614]

          end;
        end else begin
          SetMissingInfo (MissingInformation, MissingFields, FieldCaption("E-Mail Address"), (MemberInfoCapture."E-Mail Address" = ''));

          if (SetGuardianMode) then begin
            MissingInformation := false;
            SetMissingInfo (MissingInformation, MissingFields, FieldCaption("Guardian External Member No."), (MemberInfoCapture."Guardian External Member No." = ''));
          end;

        end;

        if (MissingInformation) then
          Message (MISSING_REQUIRED_FIELDS, MissingFields);

        exit (not MissingInformation);
    end;

    local procedure SetMandatoryVisualQue()
    var
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberCommunity: Record "MM Member Community";
        MembershipSetup: Record "MM Membership Setup";
    begin
        if ("Item No." <> '') then begin
          MembershipSalesSetup.SetFilter (Type, '=%1', MembershipSalesSetup.Type::ITEM);
          MembershipSalesSetup.SetFilter ("No.", '=%1', "Item No.");
          if (MembershipSalesSetup.FindFirst ()) then begin

            //-MM1.33 [325198]
            // MembershipSetup.GET (MembershipSalesSetup."Membership Code");
            // MemberCommunity.GET (MembershipSetup."Community Code");
            if (MembershipSetup.Get (MembershipSalesSetup."Membership Code")) then
              MemberCommunity.Get (MembershipSetup."Community Code");
            //+MM1.33 [325198]


            case MemberCommunity."Member Unique Identity" of
              MemberCommunity."Member Unique Identity"::NONE : ;
              MemberCommunity."Member Unique Identity"::EMAIL :   EmailMandatory := true;
              MemberCommunity."Member Unique Identity"::PHONENO : PhoneNoMandatory := true;
              MemberCommunity."Member Unique Identity"::SSN :     SSNMandatory := true;
            end;

            ExternalCardNoMandatory := (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::EXTERNAL);

            //-MM1.29 [313542]
            CardValidUntilMandatory := not (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::NA);
            //+MM1.29 [313542]

            case MembershipSalesSetup."Valid From Base" of
              MembershipSalesSetup."Valid From Base"::FIRST_USE : ActivationDateMandatory := false;
              else
                ActivationDateMandatory := true;
            end;

            AutoRenewPaymentMethodMandatory := "Enable Auto-Renew";

          end;
        end else begin
          EmailMandatory := true;
          PhoneNoMandatory := false;
          SSNMandatory := false;
        end;
    end;

    local procedure SetDefaultValues()
    var
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberCommunity: Record "MM Member Community";
        MembershipSetup: Record "MM Membership Setup";
        ValidUntilBaseDate: Date;
    begin

        ShowMemberOverviewSection := (Rec.Count > 1);
        ShowNewMemberSection := true;

        ShowAddToMembershipSection := false;
        ShowCardholderSection := false;
        ShowAddMemberCardSection := false;
        ShowReplaceCardSection := false;
        ShowNewCardSection := false;
        ShowAutoRenew := false;
        ShowQuantityField := false;
        EditMemberCardType := false;

        Rec.Quantity := 1;

        ExternalMembershipNoEditable := ("External Membership No." = '');

        if (SetGuardianMode) then begin
          ShowAddToMembershipSection := false;
          ShowReplaceCardSection := false;
          ShowNewMemberSection := false;
          ShowCardholderSection := false;
          ShowNewCardSection := false;
          ShowQuantityField := false;
        end;

        if ("Item No." <> '') then begin
          MembershipSalesSetup.SetFilter (Type, '=%1', MembershipSalesSetup.Type::ITEM);
          MembershipSalesSetup.SetFilter ("No.", '=%1', "Item No.");
          if (MembershipSalesSetup.FindFirst ()) then begin

            //-MM1.33 [325198]
            // MembershipSetup.GET (MembershipSalesSetup."Membership Code");
            // MemberCommunity.GET (MembershipSetup."Community Code");
            if (MembershipSetup.Get (MembershipSalesSetup."Membership Code")) then
              MemberCommunity.Get (MembershipSetup."Community Code");
            //+MM1.33 [325198]

            ShowNewCardSection := (MembershipSetup."Loyalty Card" = MembershipSetup."Loyalty Card"::YES);

            //-MM1.32 [318132]
            EditMemberCardType := (MembershipSalesSetup."Member Card Type Selection" = MembershipSalesSetup."Member Card Type Selection"::USER_SELECT);
            "Member Card Type" := MembershipSalesSetup."Member Card Type";
            //+MM1.32 [318132]

            ShowAutoRenew := MemberCommunity."Membership to Cust. Rel.";

            case MembershipSalesSetup."Business Flow Type" of
              MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER : ShowAddToMembershipSection := true;

              MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER :
                begin
                  ShowAddToMembershipSection := true;
                  ShowReplaceCardSection := false;
                  ShowNewMemberSection := false;
                  ShowCardholderSection := false;
                  ShowNewCardSection := false;
                  ShowQuantityField := true;
                end;

              MembershipSalesSetup."Business Flow Type"::ADD_CARD :
                begin
                  ShowAddMemberCardSection := true;
                  ShowNewMemberSection := false;
                  ShowCardholderSection := true;
                end;

              MembershipSalesSetup."Business Flow Type"::REPLACE_CARD :
                begin
                  ShowReplaceCardSection := true;
                  ShowNewMemberSection := false;
                  ShowCardholderSection := true;
                end;
            end;

            //-MM1.29 [313542]
            //    IF (FORMAT (MembershipSetup."Card Number Valid Until") <> '') THEN
            //      IF ("Document Date" <> 0D) THEN
            //        "Valid Until" := CALCDATE (MembershipSetup."Card Number Valid Until", "Document Date")
            //      ELSE
            //        "Valid Until" := CALCDATE (MembershipSetup."Card Number Valid Until", TODAY);
            //+MM1.29 [313542]

            ActivationDateEditable := false;
            case MembershipSalesSetup."Valid From Base" of
              MembershipSalesSetup."Valid From Base"::SALESDATE :   "Document Date" := WorkDate;
              MembershipSalesSetup."Valid From Base"::DATEFORMULA :
                begin
                  "Document Date" := CalcDate (MembershipSalesSetup."Valid From Date Calculation", WorkDate);
                  ActivationDateEditable := true;
                end;
              MembershipSalesSetup."Valid From Base"::PROMPT :      ActivationDateEditable := true;
              MembershipSalesSetup."Valid From Base"::FIRST_USE :   "Document Date" := 0D;
            end;

            //-MM1.29 [313542]
            ValidUntilBaseDate := "Document Date";
            if (ValidUntilBaseDate = 0D) then
              ValidUntilBaseDate := WorkDate;

            //-MM1.33 [325198]
            if (MembershipSalesSetup."Membership Code" = '') then
              MembershipSetup."Card Number Valid Until" := MembershipSalesSetup."Duration Formula";
            //+MM1.33 [325198]

            case MembershipSetup."Card Expire Date Calculation" of
              MembershipSetup."Card Expire Date Calculation"::DATEFORMULA  : "Valid Until" := CalcDate (MembershipSetup."Card Number Valid Until", ValidUntilBaseDate);
              MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED : "Valid Until" := CalcDate (MembershipSalesSetup."Duration Formula", ValidUntilBaseDate);
              else "Valid Until" := 0D;
            end;
            //+MM1.29 [313542]

            //-MM1.29 [313795]
            GDPRMandatory := false;
            GDPRSelected := true;
            case MembershipSetup."GDPR Mode" of
              MembershipSetup."GDPR Mode"::NA : "GDPR Approval" := Rec."GDPR Approval"::NA;
              MembershipSetup."GDPR Mode"::IMPLIED : "GDPR Approval" := Rec."GDPR Approval"::ACCEPTED;
              MembershipSetup."GDPR Mode"::REQUIRED :
                begin
                  "GDPR Approval" := Rec."GDPR Approval"::NA;
                  GDPRMandatory := true;
                  GDPRSelected := false;
                end;
              MembershipSetup."GDPR Mode"::CONSENT :
                begin
                  "GDPR Approval" := Rec."GDPR Approval"::PENDING;
                  GDPRMandatory := true;
                  GDPRSelected := false;
                end;
            end;
            //+MM1.29 [313795]

          end;
        end;
    end;

    local procedure ImportMembers()
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        ImportMembers: Codeunit "MM Import Members";
    begin

        CurrPage.SetSelectionFilter (MemberInfoCapture);
        if (MemberInfoCapture.FindSet ()) then begin
          repeat
            ImportMembers.insertMember (MemberInfoCapture."Entry No.");
          until (MemberInfoCapture.Next () = 0);
        end;
    end;

    procedure SetShowImportAction()
    begin
        ShowImportMemberAction := true;
    end;

    local procedure SetMissingInfo(var InfoIsMissing: Boolean;var AllInvalidFieldNames: Text;CurrentFieldName: Text;CurrentCondition: Boolean)
    begin

        InfoIsMissing := InfoIsMissing or CurrentCondition;
        if (CurrentCondition) then begin
          if (AllInvalidFieldNames) <> '' then
            AllInvalidFieldNames += ', ';
          AllInvalidFieldNames += CurrentFieldName;
        end;
    end;

    local procedure SetExternalMembershipNo(pExternalMembershipNo: Code[20])
    var
        Membership: Record "MM Membership";
        MemberCard: Record "MM Member Card";
        MembershipRole: Record "MM Membership Role";
        GuardianMember: Record "MM Member";
    begin

        if (pExternalMembershipNo = '') then
          exit;

        Membership.SetFilter ("External Membership No.", '=%1', pExternalMembershipNo);
        if (not Membership.FindFirst ()) then begin
          MemberCard.SetFilter ("External Card No.", '=%1', pExternalMembershipNo);
          MemberCard.SetFilter (Blocked, '=%1', false);
          if (not MemberCard.FindLast ()) then
            Membership.FindFirst ();

          Membership.Get (MemberCard."Membership Entry No.");
        end;

        "Membership Entry No." := Membership."Entry No.";
        "External Membership No." := Membership."External Membership No.";

        ExternalMembershipNo := Membership."External Membership No.";

        //-MM1.33 [324065]
        // Set guardian
        if (ShowAddToMembershipSection) then begin
          MembershipRole.SetFilter ("Membership Entry No.", '=%1', "Membership Entry No.");
          MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
          MembershipRole.SetFilter (Blocked, '=%1', false);
          if (MembershipRole.FindFirst ()) then begin
            GuardianMember.Get (MembershipRole."Member Entry No.");
            "Guardian External Member No." := GuardianMember."External Member No.";
            "E-Mail Address" := GuardianMember."E-Mail Address";
          end;
        end;
        //+MM1.33 [324065]
    end;

    local procedure SetExternalMemberNo(pExternalMemberNo: Code[20])
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MemberCard: Record "MM Member Card";
        MembershipManagement: Codeunit "MM Membership Management";
    begin

        if (pExternalMemberNo = '') then begin
          exit;
        end;

        Member.SetFilter ("External Member No.", '=%1', pExternalMemberNo);
        if (not Member.FindFirst ()) then begin
          MemberCard.SetFilter ("External Card No.", '=%1', pExternalMemberNo);
          MemberCard.SetFilter (Blocked, '=%1', false);
          if (not MemberCard.FindLast ()) then
            Member.FindFirst ();

          Member.Get (MemberCard."Member Entry No.");
          pExternalMemberNo := Member."External Member No.";
        end;

        "Member Entry No" := Member."Entry No.";
        "External Member No" := Member."External Member No.";
        ExternalMemberNo := Member."External Member No.";

        Member.CalcFields (Picture);
        if (Member.Picture.HasValue()) then begin
          Picture := Member.Picture;
        end else begin
          Clear(Picture);
        end;

        "First Name" := Member."First Name";
        "Middle Name" := Member."Middle Name";
        "Last Name" := Member."Last Name";
        "E-Mail Address" := Member."E-Mail Address";

        Membership.Get (MembershipManagement.GetMembershipFromExtMemberNo (pExternalMemberNo));
        SetExternalMembershipNo (Membership."External Membership No.");
    end;

    local procedure MembershipLookup()
    var
        MembersListPage: Page "MM Members";
        Member: Record "MM Member";
        MemberRole: Record "MM Membership Role";
        Membership: Record "MM Membership";
        PageAction: Action;
    begin

        MembersListPage.LookupMode (true);
        PageAction := MembersListPage.RunModal();
        if (PageAction <> ACTION::LookupOK) then
          exit;

        MembersListPage.GetRecord (Member);

        if (ShowAddMemberCardSection) then
          SetExternalMemberNo (Member."External Member No.");

        MemberRole.SetFilter ("Member Entry No.", '=%1', Member."Entry No.");
        MemberRole.SetFilter (Blocked, '=%1', false);
        if (MemberRole.FindFirst ()) then begin
          Membership.Get (MemberRole."Membership Entry No.");
          SetExternalMembershipNo (Membership."External Membership No.");

        end;
    end;

    local procedure MembershipMemberLookup()
    var
        MembersListPage: Page "MM Members";
        Member: Record "MM Member";
        MemberRole: Record "MM Membership Role";
        Membership: Record "MM Membership";
        PageAction: Action;
    begin

        MembersListPage.LookupMode (true);
        PageAction := MembersListPage.RunModal();
        if (PageAction <> ACTION::LookupOK) then
          exit;

        MembersListPage.GetRecord (Member);

        MemberRole.SetFilter ("Member Entry No.", '=%1', Member."Entry No.");
        MemberRole.SetFilter (Blocked, '=%1', false);
        if (MemberRole.FindFirst ()) then begin
          Membership.Get (MemberRole."Membership Entry No.");
          SetExternalMembershipNo (Membership."External Membership No.");

          if (ShowAddMemberCardSection) then
            SetExternalMemberNo (Member."External Member No.");

          if (ShowReplaceCardSection) then begin
            SetExternalMemberNo (Member."External Member No.");
            MemberCardLookup (Member."Entry No.", false);
          end;

          if (SetGuardianMode) then
            "Guardian External Member No." := Member."External Member No.";

        end;
    end;

    local procedure MemberCardLookup(MemberEntryNo: Integer;WithDialog: Boolean)
    var
        MemberCardList: Page "MM Member Card List";
        MemberList: Page "MM Members";
        MemberCard: Record "MM Member Card";
        Member: Record "MM Member";
        MemberRole: Record "MM Membership Role";
        PageAction: Action;
        PageId: Integer;
        TmpMember: Record "MM Member" temporary;
    begin

        if (MemberEntryNo = 0) then
          exit;

        MemberCard.SetFilter ("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.SetFilter (Blocked, '=%1', false);
        if (not MemberCard.FindSet()) then
          exit;

        if ((MemberCard.Count > 1) and (not WithDialog)) then
          exit;

        if (WithDialog) then begin
          MemberCardList.SetTableView (MemberCard);
          MemberCardList.LookupMode (true);
          PageAction := MemberCardList.RunModal();
          if (PageAction <> ACTION::LookupOK) then
            exit;

          MemberCardList.GetRecord (MemberCard);
        end;

        "Replace External Card No." := MemberCard."External Card No.";
    end;

    procedure SetAddMembershipGuardianMode()
    begin
        SetGuardianMode := true;
    end;

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
        exit (DATABASE::"MM Member Info Capture");
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

