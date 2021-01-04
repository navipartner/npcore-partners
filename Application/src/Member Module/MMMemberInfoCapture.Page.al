page 6060134 "NPR MM Member Info Capture"
{

    Caption = 'Member Information';
    DataCaptionExpression = "External Member No";
    InsertAllowed = false;
    SourceTable = "NPR MM Member Info Capture";

    layout
    {
        area(content)
        {
            group(Membership)
            {
                Caption = 'Membership Lookup';
                Visible = ShowAddToMembershipSection;
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    Caption = 'Add Member to Membership';
                    Editable = ExternalMembershipNoEditable;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Add Member to Membership field';

                    trigger OnDrillDown()
                    var
                        MemberInfoCapture: Record "NPR MM Member Info Capture";
                        Membership: Record "NPR MM Membership";
                        TmpMembership: Record "NPR MM Membership" temporary;
                    begin

                        if ("Receipt No." <> '') then begin
                            MemberInfoCapture.SetFilter("Receipt No.", '=%1', "Receipt No.");
                            MemberInfoCapture.SetFilter("Line No.", '<>%1', "Line No.");
                            if (MemberInfoCapture.FindSet()) then begin
                                repeat
                                    if (Membership.Get(MemberInfoCapture."Membership Entry No.")) then begin
                                        TmpMembership.TransferFields(Membership, true);
                                        TmpMembership.Insert();
                                    end;
                                until (MemberInfoCapture.Next() = 0);
                            end;

                            if (PAGE.RunModal(6060127, TmpMembership) = ACTION::LookupOK) then begin
                                SetExternalMembershipNo(TmpMembership."External Membership No.");
                                CurrPage.Update(true);
                            end;
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipLookup();
                    end;

                    trigger OnValidate()
                    var
                        Membership: Record "NPR MM Membership";
                    begin

                        SetExternalMembershipNo("External Membership No.");
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Member Count';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Count field';
                }
            }
            group(AddMemberCard)
            {
                Caption = 'Add Member Card';
                Visible = ShowAddMemberCardSection;
                field("External Member No"; "External Member No")
                {
                    ApplicationArea = All;
                    Caption = 'Add Card for Member';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Add Card for Member field';

                    trigger OnDrillDown()
                    var
                        MemberInfoCapture: Record "NPR MM Member Info Capture";
                        Member: Record "NPR MM Member";
                        TmpMember: Record "NPR MM Member" temporary;
                    begin

                        if ("Receipt No." <> '') then begin
                            MemberInfoCapture.SetFilter("Receipt No.", '=%1', "Receipt No.");
                            MemberInfoCapture.SetFilter("Line No.", '<>%1', "Line No.");
                            if (MemberInfoCapture.FindSet()) then begin
                                repeat
                                    if (Member.Get(MemberInfoCapture."Member Entry No")) then begin
                                        TmpMember.TransferFields(Member, true);
                                        TmpMember.Insert();
                                    end;
                                until (MemberInfoCapture.Next() = 0);
                            end;

                            if (PAGE.RunModal(6060126, TmpMember) = ACTION::LookupOK) then begin
                                "First Name" := TmpMember."First Name";
                                "Last Name" := TmpMember."Last Name";
                                "E-Mail Address" := TmpMember."E-Mail Address";
                                "Phone No." := TmpMember."Phone No.";

                                SetExternalMemberNo(TmpMember."External Member No.");

                                CurrPage.Update(true);
                            end;
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipMemberLookup();
                    end;

                    trigger OnValidate()
                    begin

                        SetExternalMemberNo("External Member No");
                    end;
                }
            }
            group(AddGuardian)
            {
                Caption = 'Set Membership Guardian';
                Visible = SetAddGuardianMode;
                field(AddGuardianToExistingMembership; "Guardian External Member No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = GuardianMandatory;
                    ToolTip = 'Specifies the value of the Guardian External Member No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipMemberLookup();
                    end;
                }
                field(GuardianGDPRApproval; "GDPR Approval")
                {
                    ApplicationArea = All;
                    OptionCaption = 'Not Selected,Pending,Accepted,Rejected';
                    ShowMandatory = GDPRMandatory;
                    Style = Attention;
                    StyleExpr = NOT GDPRSelected;
                    ToolTip = 'Specifies the value of the GDPR Approval field';
                }
            }
            group(ReplaceMemberCard)
            {
                Caption = 'Replace Member Card';
                Visible = ShowReplaceCardSection;
                field(ReplaceMemberNoCard; "External Member No")
                {
                    ApplicationArea = All;
                    Caption = 'Replace Card for Member';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Replace Card for Member field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipMemberLookup();
                    end;

                    trigger OnValidate()
                    begin

                        SetExternalMemberNo("External Member No");
                    end;
                }
                field("Replace External Card No."; "Replace External Card No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Replace External Card No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MemberCardLookup("Member Entry No", true);
                    end;

                    trigger OnValidate()
                    var
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        Member: Record "NPR MM Member";
                        ReasonText: Text;
                    begin

                        if (not Member.Get(MembershipManagement.GetMemberFromExtCardNo("Replace External Card No.", Today, ReasonText))) then
                            Error(ReasonText);

                        Validate("External Member No", Member."External Member No.");
                        CurrPage.Update(true);

                        SetExternalMemberNo(Member."External Member No.");
                        CurrPage.Update(true);
                    end;
                }
            }
            group(Cardholder)
            {
                Caption = 'Cardholder';
                Visible = ShowCardholderSection;
                field(Picture2; Picture)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Picture field';

                    trigger OnValidate()
                    begin

                        Commit();

                    end;
                }
                field(FirstName2; "First Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field(LastName2; "Last Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field(EmailAddress2; "E-Mail Address")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowMandatory = EmailMandatory;
                    ToolTip = 'Specifies the value of the E-Mail Address field';

                    trigger OnValidate()
                    begin

                        CheckEmail();
                    end;
                }
            }
            repeater(Overview)
            {
                Visible = ShowMemberOverviewSection;
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("R_PhoneNo"; "Phone No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = phonenomandatory;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("R_FirstName"; "First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("R_LastName"; "Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field("R_Email"; "E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Address field';

                    trigger OnValidate()
                    begin
                        CheckEmail();
                    end;
                }
                field("R_ExternalCardNo"; "External Card No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = ExternalCardNoMandatory;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
            }
            group(General)
            {
                Visible = ShowNewMemberSection;
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
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
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = phonenomandatory;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Social Security No."; "Social Security No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ShowMandatory = SSNMandatory;
                    ToolTip = 'Specifies the value of the Social Security No. field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code Code"; "Post Code Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Country Code"; "Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field';
                }
                field("Enable Auto-Renew"; "Enable Auto-Renew")
                {
                    ApplicationArea = All;
                    Editable = ShowAutoRenew;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Enable Auto-Renew field';

                    trigger OnValidate()
                    begin
                        if (not "Enable Auto-Renew") then
                            "Auto-Renew Payment Method Code" := '';

                        SetMandatoryVisualQue();
                    end;
                }
                field("Auto-Renew Payment Method Code"; "Auto-Renew Payment Method Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ShowMandatory = AutoRenewPaymentMethodMandatory;
                    ToolTip = 'Specifies the value of the Auto-Renew Payment Method Code field';

                    trigger OnValidate()
                    begin

                        if ("Auto-Renew Payment Method Code" <> '') then
                            "Enable Auto-Renew" := true;

                        SetMandatoryVisualQue();
                    end;
                }
            }
            group(CRM)
            {
                Visible = ShowNewMemberSection;
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';

                    trigger OnValidate()
                    begin

                        Commit();

                    end;
                }
                field(Gender; Gender)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gender field';
                }
                field(Birthday; Birthday)
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ShowMandatory = BirthDateMandatory;
                    ToolTip = 'Specifies the value of the Birthday field';

                    trigger OnValidate()
                    var
                        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
                        MembershipSetup: Record "NPR MM Membership Setup";
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        ReasonText: Text;
                    begin

                        if (BirthDateMandatory) then begin

                            if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, "Item No.")) then begin
                                MembershipSetup.Get(MembershipSalesSetup."Membership Code");

                                if (Rec.Birthday <> 0D) then
                                    if (not MembershipManagement.CheckAgeConstraint(
                                        MembershipManagement.GetMembershipAgeConstraintDate(MembershipSalesSetup, Rec),
                                        Rec.Birthday,
                                        MembershipSetup."Validate Age Against",
                                        MembershipSalesSetup."Age Constraint Type",
                                        MembershipSalesSetup."Age Constraint (Years)")) then begin
                                        ReasonText :=
                                          StrSubstNo(AGE_VERIFICATION, Rec."First Name", MembershipSalesSetup."Age Constraint (Years)") +
                                          StrSubstNo(' {%5 must be %4 %3 => (%1 + %2)}', Rec.Birthday,
                                            MembershipSalesSetup."Age Constraint (Years)",
                                            CalcDate(StrSubstNo('<+%1Y>', MembershipSalesSetup."Age Constraint (Years)"), Rec.Birthday),
                                            Format(MembershipSalesSetup."Age Constraint Type"),
                                            MembershipManagement.GetMembershipAgeConstraintDate(MembershipSalesSetup, Rec));
                                        Error(ReasonText);
                                    end;
                            end;
                        end;

                    end;
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                    ShowMandatory = EmailMandatory;
                    ToolTip = 'Specifies the value of the E-Mail Address field';

                    trigger OnValidate()
                    begin

                        CheckEmail();
                    end;
                }
                field("Guardian External Member No."; "Guardian External Member No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = GuardianMandatory;
                    ToolTip = 'Specifies the value of the Guardian External Member No. field';

                    trigger OnDrillDown()
                    var
                        TmpMember: Record "NPR MM Member" temporary;
                        MemberInfoCapture: Record "NPR MM Member Info Capture";
                        Member: Record "NPR MM Member";
                        MembersPage: Page "NPR MM Members";
                        PageAction: Action;
                    begin
                        if ("Receipt No." <> '') then begin
                            MemberInfoCapture.SetFilter("Receipt No.", '=%1', "Receipt No.");
                            MemberInfoCapture.SetFilter("Line No.", '<>%1', "Line No.");
                            MemberInfoCapture.SetFilter("Guardian External Member No.", '=%1', '');
                            if (MemberInfoCapture.FindSet()) then begin
                                repeat
                                    if (Member.Get(MemberInfoCapture."Member Entry No")) then begin
                                        TmpMember.TransferFields(Member, true);
                                        TmpMember.Insert();
                                    end;
                                until (MemberInfoCapture.Next() = 0);
                            end;

                            if (PAGE.RunModal(6060126, TmpMember) = ACTION::LookupOK) then begin
                                "Guardian External Member No." := TmpMember."External Member No.";
                                "E-Mail Address" := TmpMember."E-Mail Address";
                                CurrPage.Update(true);
                            end;
                        end else begin

                            if (PAGE.RunModal(6060126, Member) = ACTION::LookupOK) then begin
                                "Guardian External Member No." := Member."External Member No.";
                                "E-Mail Address" := Member."E-Mail Address";
                                CurrPage.Update(true);
                            end;

                        end;
                    end;

                    trigger OnValidate()
                    var
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        Member: Record "NPR MM Member";
                        ReasonText: Text;
                    begin

                        if ("Guardian External Member No." = '') then begin
                            "E-Mail Address" := '';
                            CurrPage.Update(true);
                            exit;
                        end;

                        if (Member.Get(MembershipManagement.GetMemberFromExtCardNo("Guardian External Member No.", Today, ReasonText))) then begin
                            "Guardian External Member No." := Member."External Member No.";
                            "E-Mail Address" := Member."E-Mail Address";
                            CurrPage.Update(true);
                            exit;
                        end;

                        Member.SetFilter("External Member No.", '=%1', "Guardian External Member No.");
                        Member.SetFilter(Blocked, '=%1', false);
                        Member.FindFirst();
                        "Guardian External Member No." := Member."External Member No.";
                        "E-Mail Address" := Member."E-Mail Address";
                        CurrPage.Update(true);
                    end;
                }
                field("News Letter"; "News Letter")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the News Letter field';
                }
                field("GDPR Approval"; "GDPR Approval")
                {
                    ApplicationArea = All;
                    Editable = gdprmandatory;
                    OptionCaption = 'Not Selected,Pending,Accepted,Rejected';
                    ShowMandatory = GDPRMandatory;
                    Style = Attention;
                    StyleExpr = NOT GDPRSelected;
                    ToolTip = 'Specifies the value of the GDPR Approval field';
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("User Logon ID"; "User Logon ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the User Logon ID field';
                }
                field("Password SHA1"; "Password SHA1")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Password field';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'Activation Date';
                    Editable = ActivationDateEditable;
                    Importance = Additional;
                    ShowMandatory = ActivationDateMandatory;
                    ToolTip = 'Specifies the value of the Activation Date field';

                    trigger OnValidate()
                    var
                        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
                        MembershipSetup: Record "NPR MM Membership Setup";
                    begin

                        if ("Item No." <> '') then begin
                            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
                            MembershipSalesSetup.SetFilter("No.", '=%1', "Item No.");
                            if (MembershipSalesSetup.FindFirst()) then begin
                                MembershipSetup.Get(MembershipSalesSetup."Membership Code");

                                if ("Document Date" > 0D) then begin
                                    if (CalcDate(MembershipSalesSetup."Duration Formula", "Document Date") < WorkDate) then
                                        Error(INVALID_ACTIVATION_DATE, "Document Date");

                                    //IF (FORMAT (MembershipSetup."Card Number Valid Until") <> '') THEN
                                    //  "Valid Until" := CALCDATE (MembershipSetup."Card Number Valid Until", "Document Date");
                                    case MembershipSetup."Card Expire Date Calculation" of
                                        MembershipSetup."Card Expire Date Calculation"::DATEFORMULA:
                                            "Valid Until" := CalcDate(MembershipSetup."Card Number Valid Until", "Document Date");
                                        MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED:
                                            "Valid Until" := CalcDate(MembershipSalesSetup."Duration Formula", "Document Date");
                                        else
                                            "Valid Until" := 0D;
                                    end;

                                end;

                                if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::NA) then
                                    "Valid Until" := 0D;

                            end;
                        end;
                        ActivationDate := "Document Date";
                    end;
                }
            }
            group(Card)
            {
                Visible = ShowNewCardSection;
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = ExternalCardNoMandatory;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("Pin Code"; "Pin Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Pin Code field';
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                    Editable = CardValidUntilMandatory;
                    Importance = Additional;
                    ShowMandatory = CardValidUntilMandatory;
                    ToolTip = 'Specifies the value of the Valid Until field';
                }
                field("Member Card Type"; "Member Card Type")
                {
                    ApplicationArea = All;
                    Editable = EditMemberCardType;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Member Card Type field';
                }
            }
            group(Attributes)
            {
                Caption = 'Attributes';
                Visible = ShowAttributesSection;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Import Members action';

                trigger OnAction()
                begin
                    ImportMembers();
                end;
            }
            action("Take Picture ")
            {
                Caption = 'Take Picture';
                Image = Camera;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Take Picture action';

                trigger OnAction()
                var
                    MCSWebcamAPI: Codeunit "NPR MCS Webcam API";
                    MemberCameraHook: Codeunit "NPR MM Member Camera Hook";
                begin
                    MCSWebcamAPI.CallCaptureStartByMMMemberInfoCapture(Rec, true);
                    // MemberCameraHook.OpenCameraMMMemberInfoCapture (Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin

        Clear(xRec.Picture);

    end;

    trigger OnAfterGetRecord()
    begin

        if (ActivationDateEditable) then
            Validate("Document Date", ActivationDate);

        if (ShowAddToMembershipSection) then
            SetExternalMembershipNo(ExternalMembershipNo);

        SetDefaultValues();

        SetMandatoryVisualQue();

        GetMasterDataAttributeValue();

        CurrPage.Update(false);
    end;

    trigger OnInit()
    begin

        ShowNewMemberSection := true;
        ShowNewCardSection := true;
    end;

    trigger OnOpenPage()
    begin
        SetDefaultValues();

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

    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RequiredFields: Boolean;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        if (CloseAction = ACTION::LookupOK) then begin
            if (Rec."Receipt No." <> '') then begin
                Modify();
                MemberInfoCapture.SetFilter("Receipt No.", '=%1', "Receipt No.");
                MemberInfoCapture.SetFilter("Line No.", '=%1', "Line No.");
                RequiredFields := true;
                if (MemberInfoCapture.FindSet()) then begin
                    repeat
                        RequiredFields := HaveRequiredFields(MemberInfoCapture);
                    until (MemberInfoCapture.Next() = 0) or (not RequiredFields);
                end;
                exit(RequiredFields);
            end else
                exit(HaveRequiredFields(Rec));
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
        BirthDateMandatory: Boolean;
        ExternalCardNoMandatory: Boolean;
        GuardianMandatory: Boolean;
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
        ShowAttributesSection: Boolean;
        EditMemberCardType: Boolean;
        ExtraInfo: Text;
        ShowAutoRenew: Boolean;
        ExternalMembershipNoEditable: Boolean;
        AutoRenewPaymentMethodMandatory: Boolean;
        SetAddGuardianMode: Boolean;
        CardValidUntilMandatory: Boolean;
        INVALID_SETUP: Label 'The combination %1 %2 and %3 %4 is not supported.';
        GDPRMandatory: Boolean;
        GDPRSelected: Boolean;
        NAMEFIELD_TO_LONG: Label 'The maximum length for "%1", "%2" and "%3" when combined is %4. Current total length is %5.';
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
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
        AGE_VERIFICATION: Label 'Member %1 does not meet the age constraint of %2 years set on this product.';

    local procedure CheckEmail()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipCommunity: Record "NPR MM Member Community";
        Member: Record "NPR MM Member";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ValidEmail: Boolean;
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberCommunity: Record "NPR MM Member Community";
    begin
        if ("E-Mail Address" = '') then
            exit;

        ValidEmail := (StrPos("E-Mail Address", '@') > 1);
        if (ValidEmail) then
            ValidEmail := (StrPos(CopyStr("E-Mail Address", StrPos("E-Mail Address", '@')), '.') > 1);

        if (not ValidEmail) then
            if (Confirm(EMAIL_INVALID_CONFIRM, true, FieldCaption("E-Mail Address"))) then
                Error(INVALID_VALUE, FieldCaption("E-Mail Address"));

        if ("Item No." <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', "Item No.");
            if (MembershipSalesSetup.FindFirst()) then begin
                MembershipSetup.Get(MembershipSalesSetup."Membership Code");
                MemberCommunity.Get(MembershipSetup."Community Code");

                if (MemberCommunity."Member Unique Identity" = MemberCommunity."Member Unique Identity"::EMAIL) then begin

                    Member.SetFilter("E-Mail Address", '=%1', LowerCase("E-Mail Address"));
                    Member.SetFilter(Blocked, '=%1', false);
                    if (Member.FindFirst()) then begin
                        if (Confirm(EMAIL_EXISTS, false, Member."E-Mail Address", Member."External Member No.", Member."Display Name")) then begin
                            MembershipManagement.BlockMember(MembershipManagement.GetMembershipFromExtMemberNo(Member."External Member No."), Member."Entry No.", true);
                        end else begin
                            Error(INVALID_VALUE, FieldCaption("E-Mail Address"));
                        end;
                    end;

                end;
            end;
        end;
    end;

    local procedure HaveRequiredFields(MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        MissingInformation: Boolean;
        MissingFields: Text;
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        NameTotalLength: Integer;
        Customer: Record Customer;
        Member: Record "NPR MM Member";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        MissingInformation := false;
        MissingFields := '';

        if ("Item No." <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', "Item No.");
            if (MembershipSalesSetup.FindFirst()) then begin

                // MembershipSetup.GET (MembershipSalesSetup."Membership Code");
                // MemberCommunity.GET (MembershipSetup."Community Code");
                if (MembershipSetup.Get(MembershipSalesSetup."Membership Code")) then
                    MemberCommunity.Get(MembershipSetup."Community Code");

                if (ShowNewMemberSection) then begin
                    case MemberCommunity."Member Unique Identity" of
                        MemberCommunity."Member Unique Identity"::NONE:
                            MissingInformation := false;
                        MemberCommunity."Member Unique Identity"::EMAIL:
                            SetMissingInfo(MissingInformation, MissingFields, FieldCaption("E-Mail Address"), (MemberInfoCapture."E-Mail Address" = ''));
                        MemberCommunity."Member Unique Identity"::PHONENO:
                            SetMissingInfo(MissingInformation, MissingFields, FieldCaption("Phone No."), (MemberInfoCapture."Phone No." = ''));
                        MemberCommunity."Member Unique Identity"::SSN:
                            SetMissingInfo(MissingInformation, MissingFields, FieldCaption("Social Security No."), (MemberInfoCapture."Social Security No." = ''));
                    end;

                    if (ActivationDateEditable) and (MemberInfoCapture."Document Date" = 0D) then
                        SetMissingInfo(MissingInformation, MissingFields, FieldCaption("Document Date"), ("Document Date" = 0D));

                    if (BirthDateMandatory) then begin
                        SetMissingInfo(MissingInformation, MissingFields, FieldCaption(Birthday), (MemberInfoCapture.Birthday = 0D));
                        if (MemberInfoCapture.Birthday <> 0D) then
                            if (not MembershipManagement.CheckAgeConstraint(
                                MembershipManagement.GetMembershipAgeConstraintDate(MembershipSalesSetup, MemberInfoCapture),
                                MemberInfoCapture.Birthday,
                                MembershipSetup."Validate Age Against",
                                MembershipSalesSetup."Age Constraint Type",
                                MembershipSalesSetup."Age Constraint (Years)")) then begin
                                SetMissingInfo(MissingInformation, MissingFields, FieldCaption(Birthday), true);
                                Message(AGE_VERIFICATION, MemberInfoCapture."First Name", MembershipSalesSetup."Age Constraint (Years)");
                            end;
                    end;

                end;

                if (ShowNewCardSection) then begin
                    if (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::EXTERNAL) then begin
                        SetMissingInfo(MissingInformation, MissingFields, FieldCaption("External Card No."), (MemberInfoCapture."External Card No." = ''));

                        //SetMissingInfo (MissingInformation, MissingFields, FIELDCAPTION("Valid Until"), (MemberInfoCapture."Valid Until" = 0D));
                        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then
                            SetMissingInfo(MissingInformation, MissingFields, FieldCaption("Valid Until"), (MemberInfoCapture."Valid Until" = 0D));

                    end;
                end;

                if (ShowAddToMembershipSection) or (ShowAddMemberCardSection) or (ShowReplaceCardSection) then begin
                    SetMissingInfo(MissingInformation, MissingFields, FieldCaption("External Membership No."), (MemberInfoCapture."External Membership No." = ''));
                end;

                if (ShowAddMemberCardSection) or (ShowReplaceCardSection) then begin
                    SetMissingInfo(MissingInformation, MissingFields, FieldCaption("External Member No"), (MemberInfoCapture."External Member No" = ''));
                end;

                if ("Enable Auto-Renew") then
                    SetMissingInfo(MissingInformation, MissingFields, FieldCaption("Auto-Renew Payment Method Code"), ("Auto-Renew Payment Method Code" = ''));

                case MembershipSetup."GDPR Mode" of
                    MembershipSetup."GDPR Mode"::REQUIRED:
                        SetMissingInfo(MissingInformation, MissingFields, Rec.FieldCaption("GDPR Approval"), (Rec."GDPR Approval" <> Rec."GDPR Approval"::ACCEPTED));
                    MembershipSetup."GDPR Mode"::CONSENT:
                        SetMissingInfo(MissingInformation, MissingFields, Rec.FieldCaption("GDPR Approval"), (Rec."GDPR Approval" = Rec."GDPR Approval"::NA));
                end;

                if (MemberCommunity."Membership to Cust. Rel.") then begin
                    NameTotalLength := StrLen(MemberInfoCapture."First Name") + StrLen(MemberInfoCapture."Middle Name") + StrLen(MemberInfoCapture."Last Name") + 2;
                    if ((NameTotalLength > MaxStrLen(Customer.Name)) and not (MissingInformation)) then begin
                        Message(NAMEFIELD_TO_LONG, MemberInfoCapture.FieldCaption("First Name"), MemberInfoCapture.FieldCaption("Middle Name"), MemberInfoCapture.FieldCaption("Last Name"),
                               MaxStrLen(Customer.Name), NameTotalLength);
                        exit(false);
                    end;
                end;

                if (not MemberCommunity."Membership to Cust. Rel.") then begin
                    NameTotalLength := StrLen(MemberInfoCapture."First Name") + StrLen(MemberInfoCapture."Last Name") + 1;
                    if ((NameTotalLength > MaxStrLen(Member."Display Name")) and not (MissingInformation)) then begin
                        Message(NAMEFIELD_TO_LONG, MemberInfoCapture.FieldCaption("First Name"), MemberInfoCapture.FieldCaption("Middle Name"), MemberInfoCapture.FieldCaption("Last Name"),
                               MaxStrLen(Member."Display Name"), NameTotalLength);
                        exit(false);
                    end;
                end;

            end;
        end else begin
            SetMissingInfo(MissingInformation, MissingFields, FieldCaption("E-Mail Address"), (MemberInfoCapture."E-Mail Address" = ''));

            if (SetAddGuardianMode) then begin
                MissingInformation := false;
                SetMissingInfo(MissingInformation, MissingFields, FieldCaption("Guardian External Member No."), (MemberInfoCapture."Guardian External Member No." = ''));
            end;

        end;

        if (MissingInformation) then
            Message(MISSING_REQUIRED_FIELDS, MissingFields);

        exit(not MissingInformation);
    end;

    local procedure SetMandatoryVisualQue()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        if ("Item No." <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', "Item No.");
            if (MembershipSalesSetup.FindFirst()) then begin

                // MembershipSetup.GET (MembershipSalesSetup."Membership Code");
                // MemberCommunity.GET (MembershipSetup."Community Code");
                if (MembershipSetup.Get(MembershipSalesSetup."Membership Code")) then
                    MemberCommunity.Get(MembershipSetup."Community Code");

                case MemberCommunity."Member Unique Identity" of
                    MemberCommunity."Member Unique Identity"::NONE:
                        ;
                    MemberCommunity."Member Unique Identity"::EMAIL:
                        EmailMandatory := true;
                    MemberCommunity."Member Unique Identity"::PHONENO:
                        PhoneNoMandatory := true;
                    MemberCommunity."Member Unique Identity"::SSN:
                        SSNMandatory := true;
                end;

                ExternalCardNoMandatory := (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::EXTERNAL);

                CardValidUntilMandatory := not (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::NA);

                case MembershipSalesSetup."Valid From Base" of
                    MembershipSalesSetup."Valid From Base"::FIRST_USE:
                        ActivationDateMandatory := false;
                    else
                        ActivationDateMandatory := true;
                end;

                AutoRenewPaymentMethodMandatory := "Enable Auto-Renew";

                //BirthDateMandatory := NOT (MembershipSetup."Validate Age Against" = MembershipSetup."Validate Age Against"::SALESDATE_Y)
                BirthDateMandatory := MembershipSetup."Enable Age Verification";

            end;
        end else begin
            EmailMandatory := true;
            PhoneNoMandatory := false;
            SSNMandatory := false;

            BirthDateMandatory := false;

        end;
    end;

    local procedure SetDefaultValues()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
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

        ShowAttributesSection := true;
        GuardianMandatory := false;

        Rec.Quantity := 1;

        ExternalMembershipNoEditable := ("External Membership No." = '');

        if (SetAddGuardianMode) then begin
            ShowAddToMembershipSection := false;
            ShowReplaceCardSection := false;
            ShowNewMemberSection := false;
            ShowCardholderSection := false;
            ShowNewCardSection := false;
            ShowQuantityField := false;

            ShowAttributesSection := false;
            GuardianMandatory := true;

        end;

        if ("Item No." <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', "Item No.");
            if (MembershipSalesSetup.FindFirst()) then begin

                // MembershipSetup.GET (MembershipSalesSetup."Membership Code");
                // MemberCommunity.GET (MembershipSetup."Community Code");
                if (MembershipSetup.Get(MembershipSalesSetup."Membership Code")) then
                    MemberCommunity.Get(MembershipSetup."Community Code");

                ShowNewCardSection := (MembershipSetup."Loyalty Card" = MembershipSetup."Loyalty Card"::YES);

                EditMemberCardType := (MembershipSalesSetup."Member Card Type Selection" = MembershipSalesSetup."Member Card Type Selection"::USER_SELECT);
                "Member Card Type" := MembershipSalesSetup."Member Card Type";

                ShowAutoRenew := MemberCommunity."Membership to Cust. Rel.";

                case MembershipSalesSetup."Business Flow Type" of
                    MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER:
                        ShowAddToMembershipSection := true;

                    MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER:
                        begin
                            ShowAddToMembershipSection := true;
                            ShowReplaceCardSection := false;
                            ShowNewMemberSection := false;
                            ShowCardholderSection := false;
                            ShowNewCardSection := false;
                            ShowQuantityField := true;
                        end;

                    MembershipSalesSetup."Business Flow Type"::ADD_CARD:
                        begin
                            ShowAddMemberCardSection := true;
                            ShowNewMemberSection := false;
                            ShowCardholderSection := true;
                        end;

                    MembershipSalesSetup."Business Flow Type"::REPLACE_CARD:
                        begin
                            ShowReplaceCardSection := true;
                            ShowNewMemberSection := false;
                            ShowCardholderSection := true;
                        end;
                end;

                //    IF (FORMAT (MembershipSetup."Card Number Valid Until") <> '') THEN
                //      IF ("Document Date" <> 0D) THEN
                //        "Valid Until" := CALCDATE (MembershipSetup."Card Number Valid Until", "Document Date")
                //      ELSE
                //        "Valid Until" := CALCDATE (MembershipSetup."Card Number Valid Until", TODAY);

                ActivationDateEditable := false;
                case MembershipSalesSetup."Valid From Base" of
                    MembershipSalesSetup."Valid From Base"::SALESDATE:
                        "Document Date" := WorkDate;
                    MembershipSalesSetup."Valid From Base"::DATEFORMULA:
                        begin
                            "Document Date" := CalcDate(MembershipSalesSetup."Valid From Date Calculation", WorkDate);
                            ActivationDateEditable := true;
                        end;
                    MembershipSalesSetup."Valid From Base"::PROMPT:
                        ActivationDateEditable := true;
                    MembershipSalesSetup."Valid From Base"::FIRST_USE:
                        "Document Date" := 0D;
                end;

                ValidUntilBaseDate := "Document Date";
                if (ValidUntilBaseDate = 0D) then
                    ValidUntilBaseDate := WorkDate;

                if (MembershipSalesSetup."Membership Code" = '') then
                    MembershipSetup."Card Number Valid Until" := MembershipSalesSetup."Duration Formula";

                case MembershipSetup."Card Expire Date Calculation" of
                    MembershipSetup."Card Expire Date Calculation"::DATEFORMULA:
                        "Valid Until" := CalcDate(MembershipSetup."Card Number Valid Until", ValidUntilBaseDate);
                    MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED:
                        "Valid Until" := CalcDate(MembershipSalesSetup."Duration Formula", ValidUntilBaseDate);
                    else
                        "Valid Until" := 0D;
                end;

                GDPRMandatory := false;
                GDPRSelected := true;
                case MembershipSetup."GDPR Mode" of
                    MembershipSetup."GDPR Mode"::NA:
                        "GDPR Approval" := Rec."GDPR Approval"::NA;
                    MembershipSetup."GDPR Mode"::IMPLIED:
                        "GDPR Approval" := Rec."GDPR Approval"::ACCEPTED;
                    MembershipSetup."GDPR Mode"::REQUIRED:
                        begin
                            "GDPR Approval" := Rec."GDPR Approval"::NA;
                            GDPRMandatory := true;
                            GDPRSelected := false;
                        end;
                    MembershipSetup."GDPR Mode"::CONSENT:
                        begin
                            "GDPR Approval" := Rec."GDPR Approval"::PENDING;
                            GDPRMandatory := true;
                            GDPRSelected := false;
                        end;
                end;

                GuardianMandatory := (MembershipSalesSetup."Requires Guardian");

            end;
        end;
    end;

    local procedure ImportMembers()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ImportMembers: Codeunit "NPR MM Import Members";
    begin

        CurrPage.SetSelectionFilter(MemberInfoCapture);
        if (MemberInfoCapture.FindSet()) then begin
            repeat
                ImportMembers.insertMember(MemberInfoCapture."Entry No.");
            until (MemberInfoCapture.Next() = 0);
        end;
    end;

    procedure SetShowImportAction()
    begin
        ShowImportMemberAction := true;
    end;

    local procedure SetMissingInfo(var InfoIsMissing: Boolean; var AllInvalidFieldNames: Text; CurrentFieldName: Text; CurrentCondition: Boolean)
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
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        MembershipRole: Record "NPR MM Membership Role";
        GuardianMember: Record "NPR MM Member";
    begin

        if (pExternalMembershipNo = '') then
            exit;

        Membership.SetFilter("External Membership No.", '=%1', pExternalMembershipNo);
        if (not Membership.FindFirst()) then begin
            MemberCard.SetFilter("External Card No.", '=%1', pExternalMembershipNo);
            MemberCard.SetFilter(Blocked, '=%1', false);
            if (not MemberCard.FindLast()) then
                Membership.FindFirst();

            Membership.Get(MemberCard."Membership Entry No.");
        end;

        "Membership Entry No." := Membership."Entry No.";
        "External Membership No." := Membership."External Membership No.";

        ExternalMembershipNo := Membership."External Membership No.";

        // Set guardian
        if (ShowAddToMembershipSection) then begin
            MembershipRole.SetFilter("Membership Entry No.", '=%1', "Membership Entry No.");
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
            MembershipRole.SetFilter(Blocked, '=%1', false);
            if (MembershipRole.FindFirst()) then begin
                GuardianMember.Get(MembershipRole."Member Entry No.");
                "Guardian External Member No." := GuardianMember."External Member No.";
                "E-Mail Address" := GuardianMember."E-Mail Address";
            end;
        end;

    end;

    local procedure SetExternalMemberNo(pExternalMemberNo: Code[20])
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        if (pExternalMemberNo = '') then begin
            exit;
        end;

        Member.SetFilter("External Member No.", '=%1', pExternalMemberNo);
        if (not Member.FindFirst()) then begin
            MemberCard.SetFilter("External Card No.", '=%1', pExternalMemberNo);
            MemberCard.SetFilter(Blocked, '=%1', false);
            if (not MemberCard.FindLast()) then
                Member.FindFirst();

            Member.Get(MemberCard."Member Entry No.");
            pExternalMemberNo := Member."External Member No.";
        end;

        "Member Entry No" := Member."Entry No.";
        "External Member No" := Member."External Member No.";
        ExternalMemberNo := Member."External Member No.";

        Member.CalcFields(Picture);
        if (Member.Picture.HasValue()) then begin
            Picture := Member.Picture;
        end else begin
            Clear(Picture);
        end;

        "First Name" := Member."First Name";
        "Middle Name" := Member."Middle Name";
        "Last Name" := Member."Last Name";
        "E-Mail Address" := Member."E-Mail Address";

        Membership.Get(MembershipManagement.GetMembershipFromExtMemberNo(pExternalMemberNo));
        SetExternalMembershipNo(Membership."External Membership No.");
    end;

    local procedure MembershipLookup()
    var
        MembersListPage: Page "NPR MM Members";
        Member: Record "NPR MM Member";
        MemberRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        PageAction: Action;
    begin

        MembersListPage.LookupMode(true);
        PageAction := MembersListPage.RunModal();
        if (PageAction <> ACTION::LookupOK) then
            exit;

        MembersListPage.GetRecord(Member);

        if (ShowAddMemberCardSection) then
            SetExternalMemberNo(Member."External Member No.");

        MemberRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MemberRole.SetFilter(Blocked, '=%1', false);
        if (MemberRole.FindFirst()) then begin
            Membership.Get(MemberRole."Membership Entry No.");
            SetExternalMembershipNo(Membership."External Membership No.");

        end;
    end;

    local procedure MembershipMemberLookup()
    var
        MembersListPage: Page "NPR MM Members";
        Member: Record "NPR MM Member";
        MemberRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        PageAction: Action;
    begin

        MembersListPage.LookupMode(true);
        PageAction := MembersListPage.RunModal();
        if (PageAction <> ACTION::LookupOK) then
            exit;

        MembersListPage.GetRecord(Member);

        MemberRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MemberRole.SetFilter(Blocked, '=%1', false);
        if (MemberRole.FindFirst()) then begin
            Membership.Get(MemberRole."Membership Entry No.");
            SetExternalMembershipNo(Membership."External Membership No.");

            if (ShowAddMemberCardSection) then
                SetExternalMemberNo(Member."External Member No.");

            if (ShowReplaceCardSection) then begin
                SetExternalMemberNo(Member."External Member No.");
                MemberCardLookup(Member."Entry No.", false);
            end;

            if (SetAddGuardianMode) then
                "Guardian External Member No." := Member."External Member No.";

        end;
    end;

    local procedure MemberCardLookup(MemberEntryNo: Integer; WithDialog: Boolean)
    var
        MemberCardList: Page "NPR MM Member Card List";
        MemberList: Page "NPR MM Members";
        MemberCard: Record "NPR MM Member Card";
        Member: Record "NPR MM Member";
        MemberRole: Record "NPR MM Membership Role";
        PageAction: Action;
        PageId: Integer;
        TmpMember: Record "NPR MM Member" temporary;
    begin

        if (MemberEntryNo = 0) then
            exit;

        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.SetFilter(Blocked, '=%1', false);
        if (not MemberCard.FindSet()) then
            exit;

        if ((MemberCard.Count > 1) and (not WithDialog)) then
            exit;

        if (WithDialog) then begin
            MemberCardList.SetTableView(MemberCard);
            MemberCardList.LookupMode(true);
            PageAction := MemberCardList.RunModal();
            if (PageAction <> ACTION::LookupOK) then
                exit;

            MemberCardList.GetRecord(MemberCard);
        end;

        "Replace External Card No." := MemberCard."External Card No.";
    end;

    procedure SetAddMembershipGuardianMode()
    begin
        SetAddGuardianMode := true;
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

        exit(DATABASE::"NPR MM Member Info Capture");

    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    begin

        exit(StrSubstNo('6014555,%1,%2,2', GetAttributeTableId(), AttributeNumber));

    end;

    local procedure OnAttributeLookup(AttributeNumber: Integer)
    begin

        NPRAttrManagement.OnPageLookUp(GetAttributeTableId, AttributeNumber, Format(AttributeNumber, 0, '<integer>'), NPRAttrTextArray[AttributeNumber]);

    end;
}

