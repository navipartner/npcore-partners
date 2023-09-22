page 6060134 "NPR MM Member Info Capture"
{
    UsageCategory = None;
    Caption = 'Member Information';
    DataCaptionExpression = Rec."External Member No";
    InsertAllowed = false;
    SourceTable = "NPR MM Member Info Capture";
    PageType = Card;

    layout
    {
        area(content)
        {
            group(MembershipLookupGroup)
            {
                Caption = 'Membership Lookup';
                Visible = _ShowAddToMembershipSection;
                field("External Membership No."; Rec."External Membership No.")
                {

                    Caption = 'Add Member to Membership';
                    Editable = ExternalMembershipNoEditable;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Add Member to Membership field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnDrillDown()
                    var
                        MemberInfoCapture: Record "NPR MM Member Info Capture";
                        Membership: Record "NPR MM Membership";
                        TempMembership: Record "NPR MM Membership" temporary;
                    begin
                        if (Rec."Receipt No." <> '') then begin
                            MemberInfoCapture.SetFilter("Receipt No.", '=%1', Rec."Receipt No.");
                            MemberInfoCapture.SetFilter("Line No.", '<>%1', Rec."Line No.");
                            if (MemberInfoCapture.FindSet()) then begin
                                repeat
                                    if (Membership.Get(MemberInfoCapture."Membership Entry No.")) then begin
                                        TempMembership.TransferFields(Membership, true);
                                        TempMembership.Insert();
                                    end;
                                until (MemberInfoCapture.Next() = 0);
                            end;

                            if (PAGE.RunModal(6060127, TempMembership) = ACTION::LookupOK) then begin
                                SetMembershipDetails(TempMembership."External Membership No.");
                                CurrPage.Update(true);
                            end;
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        MembershipLookup();
                    end;

                    trigger OnValidate()
                    begin

                        SetMembershipDetails(Rec."External Membership No.");
                    end;
                }
                field(Quantity; Rec.Quantity)
                {

                    Caption = 'Member Count';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Count field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(AddMemberCard)
            {
                Caption = 'Add Member Card';
                Visible = _ShowAddMemberCardSection;
                field("External Member No"; Rec."External Member No")
                {

                    Caption = 'Add Card for Member';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Add Card for Member field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnDrillDown()
                    var
                        MemberInfoCapture: Record "NPR MM Member Info Capture";
                        Member: Record "NPR MM Member";
                        TempMember: Record "NPR MM Member" temporary;
                    begin

                        if (Rec."Receipt No." <> '') then begin
                            MemberInfoCapture.SetFilter("Receipt No.", '=%1', Rec."Receipt No.");
                            MemberInfoCapture.SetFilter("Line No.", '<>%1', Rec."Line No.");
                            if (MemberInfoCapture.FindSet()) then begin
                                repeat
                                    if (Member.Get(MemberInfoCapture."Member Entry No")) then begin
                                        TempMember.TransferFields(Member, true);
                                        TempMember.Insert();
                                    end;
                                until (MemberInfoCapture.Next() = 0);
                            end;

                            if (PAGE.RunModal(Page::"NPR MM Members", TempMember) = ACTION::LookupOK) then begin
                                Rec."First Name" := TempMember."First Name";
                                Rec."Last Name" := TempMember."Last Name";
                                Rec."E-Mail Address" := TempMember."E-Mail Address";
                                Rec."Phone No." := TempMember."Phone No.";

                                SetMemberDetails(TempMember."External Member No.");
                                SetDefaultValues();
                                CurrPage.Update(true);
                            end;
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MembershipMemberLookup();
                        SetDefaultValues();
                    end;

                    trigger OnValidate()
                    begin
                        SetMemberDetails(Rec."External Member No");
                        SetDefaultValues();
                    end;
                }
            }
            group(AddGuardian)
            {
                Caption = 'Set Membership Guardian';
                Visible = SetAddGuardianMode;
                field(AddGuardianToExistingMembership; Rec."Guardian External Member No.")
                {

                    ShowMandatory = GuardianMandatory;
                    ToolTip = 'Specifies the value of the Guardian External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MembershipMemberLookup();
                    end;
                }
                field(GuardianGDPRApproval; Rec."GDPR Approval")
                {

                    OptionCaption = 'Not Selected,Pending,Accepted,Rejected';
                    ShowMandatory = GDPRMandatory;
                    Style = Attention;
                    StyleExpr = NOT GDPRSelected;
                    ToolTip = 'Specifies the value of the GDPR Approval field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(ReplaceMemberCard)
            {
                Caption = 'Replace Member Card';
                Visible = _ShowReplaceCardSection;
                field(ReplaceMemberNoCard; Rec."External Member No")
                {

                    Caption = 'Replace Card for Member';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Replace Card for Member field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec."Replace External Card No." := '';
                        OnValidateReplaceExternalCardNumber();

                        MembershipMemberLookup();
                        OnValidateReplaceExternalCardNumber();
                    end;

                    trigger OnValidate()
                    begin
                        SetMemberDetails(Rec."External Member No");
                        OnValidateReplaceExternalCardNumber();
                    end;
                }
                field("Replace External Card No."; Rec."Replace External Card No.")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Replace External Card No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MemberCardLookup(Rec."Member Entry No", true);
                        OnValidateReplaceExternalCardNumber();
                    end;

                    trigger OnValidate()
                    begin
                        OnValidateReplaceExternalCardNumber();
                    end;
                }

                field(MembershipCode; Rec."Membership Code")
                {
                    Editable = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Shows the membership code associated with the card bing replaced.';
                    Caption = 'Membership Code';
                }

                field(ValidUntil; _MembershipValidUntilDate)
                {
                    Editable = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Show when the membership expires.';
                    Caption = 'Membership Valid Until';
                }
            }
            group(Cardholder)
            {
                Caption = 'Cardholder';
                Visible = _ShowCardholderSection;

                field(FirstName2; Rec."First Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(LastName2; Rec."Last Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(EmailAddress2; Rec."E-Mail Address")
                {

                    Editable = false;
                    ShowMandatory = _EmailMandatory;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    begin
                        CheckEmail();
                    end;
                }
            }
            group(General)
            {
                Visible = _ShowNewMemberSection;
                field("Company Name"; Rec."Company Name")
                {
                    Editable = not _PreSelectedCustomerContact;
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("First Name"; Rec."First Name")
                {
                    Editable = not _PreSelectedCustomerContact;
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    Editable = not _PreSelectedCustomerContact;
                    ToolTip = 'Specifies the value of the Middle Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Last Name"; Rec."Last Name")
                {
                    Editable = not _PreSelectedCustomerContact;
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    Editable = not _PreSelectedCustomerContact;
                    ShowMandatory = _PhoneNoMandatory;
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Social Security No."; Rec."Social Security No.")
                {

                    Importance = Additional;
                    ShowMandatory = _SSNMandatory;
                    ToolTip = 'Specifies the value of the Social Security No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Address; Rec.Address)
                {
                    Editable = not _PreSelectedCustomerContact;
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    Editable = not _PreSelectedCustomerContact;
                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(City; Rec.City)
                {
                    Editable = not _PreSelectedCustomerContact;
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Country Code"; Rec."Country Code")
                {
                    Editable = not _PreSelectedCustomerContact;
                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Enable Auto-Renew"; Rec."Enable Auto-Renew")
                {
                    Editable = _ShowAutoRenew;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Enable Auto-Renew field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    begin
                        if (not Rec."Enable Auto-Renew") then
                            Rec."Auto-Renew Payment Method Code" := '';

                        SetMandatoryVisualQue();
                    end;
                }
                field("Auto-Renew Payment Method Code"; Rec."Auto-Renew Payment Method Code")
                {
                    Importance = Additional;
                    ShowMandatory = AutoRenewPaymentMethodMandatory;
                    ToolTip = 'Specifies the value of the Auto-Renew Payment Method Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    begin
                        if (Rec."Auto-Renew Payment Method Code" <> '') then
                            Rec."Enable Auto-Renew" := true;

                        SetMandatoryVisualQue();
                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    Importance = Additional;
                    ToolTip = 'Links membership with a pre-existing customer number.';
                    Visible = true; // if membership -> customer relationship is enabled.
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    var
                        Customer: Record "Customer";
                        ContactNumber: Code[20];
                    begin
                        Rec."Contact No." := '';
                        if (Rec."Customer No." <> '') then begin
                            Customer.Get(Rec."Customer No.");
                            ApplyCustomer(Customer."No.", Rec);
                            if (SelectContact(Customer."No.", ContactNumber)) then
                                ApplyContact(ContactNumber, Rec);
                            CurrPage.Update(true);
                        end;
                        _PreSelectedCustomerContact := (Rec."Customer No." <> '');
                    end;

                    trigger OnDrillDown()
                    var
                        CustomerNumber: Code[20];
                        ContactNumber: Code[20];
                    begin
                        Rec."Customer No." := '';
                        Rec."Contact No." := '';
                        if (SelectCustomer(CustomerNumber)) then begin
                            ApplyCustomer(CustomerNumber, Rec);
                            if (SelectContact(CustomerNumber, ContactNumber)) then
                                ApplyContact(ContactNumber, Rec);
                        end;
                        CurrPage.Update(true);
                        _PreSelectedCustomerContact := (Rec."Customer No." <> '');
                    end;
                }

            }
            group(CRM)
            {
                Visible = _ShowNewMemberSection;

                field(Gender; Rec.Gender)
                {

                    ToolTip = 'Specifies the value of the Gender field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Birthday; Rec.Birthday)
                {

                    Importance = Additional;
                    ShowMandatory = _BirthDateMandatory;
                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    var
                        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
                        MembershipSetup: Record "NPR MM Membership Setup";
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        ReasonText: Text;
                        ReasonLbl: Label ' {%5 must be %4 %3 => (%1 + %2)}';
                        ReasonDateLbl: Label '<+%1Y>', Locked = true;
                    begin
                        if (_BirthDateMandatory) then begin

                            if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, Rec."Item No.")) then begin
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
                                          StrSubstNo(ReasonLbl, Rec.Birthday,
                                            MembershipSalesSetup."Age Constraint (Years)",
                                            CalcDate(StrSubstNo(ReasonDateLbl, MembershipSalesSetup."Age Constraint (Years)"), Rec.Birthday),
                                            Format(MembershipSalesSetup."Age Constraint Type"),
                                            MembershipManagement.GetMembershipAgeConstraintDate(MembershipSalesSetup, Rec));
                                        Error(ReasonText);
                                    end;
                            end;
                        end;
                    end;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    Editable = (not _PreSelectedCustomerContact) or (_EmailMandatory and (Rec."E-Mail Address" = ''));
                    ShowMandatory = _EmailMandatory;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    begin
                        CheckEmail();
                    end;
                }
                field("Store Code"; Rec."Store Code")
                {

                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Guardian External Member No."; Rec."Guardian External Member No.")
                {

                    ShowMandatory = GuardianMandatory;
                    ToolTip = 'Specifies the value of the Guardian External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnDrillDown()
                    begin
                        SetGuardian();
                    end;

                    trigger OnValidate()
                    var
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        Member: Record "NPR MM Member";
                        ReasonText: Text;
                    begin
                        if (Rec."Guardian External Member No." = '') then begin
                            Rec."E-Mail Address" := '';
                            CurrPage.Update(true);
                            exit;
                        end;

                        if (Member.Get(MembershipManagement.GetMemberFromExtCardNo(Rec."Guardian External Member No.", Today, ReasonText))) then begin
                            Rec."Guardian External Member No." := Member."External Member No.";
                            Rec."E-Mail Address" := Member."E-Mail Address";
                            CurrPage.Update(true);
                            exit;
                        end;

                        Member.SetFilter("External Member No.", '=%1', Rec."Guardian External Member No.");
                        Member.SetFilter(Blocked, '=%1', false);
                        Member.FindFirst();
                        Rec."Guardian External Member No." := Member."External Member No.";
                        Rec."E-Mail Address" := Member."E-Mail Address";
                        CurrPage.Update(true);
                    end;
                }
                field("News Letter"; Rec."News Letter")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the News Letter field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Approval"; Rec."GDPR Approval")
                {

                    Editable = gdprmandatory;
                    OptionCaption = 'Not Selected,Pending,Accepted,Rejected';
                    ShowMandatory = GDPRMandatory;
                    Style = Attention;
                    StyleExpr = NOT GDPRSelected;
                    ToolTip = 'Specifies the value of the GDPR Approval field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Method"; Rec."Notification Method")
                {

                    ToolTip = 'Specifies the value of the Notification Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("User Logon ID"; Rec."User Logon ID")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the User Logon ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Password SHA1"; Rec."Password SHA1")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Password field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document Date"; Rec."Document Date")
                {

                    Caption = 'Activation Date';
                    Editable = ActivationDateEditable;
                    Importance = Additional;
                    ShowMandatory = ActivationDateMandatory;
                    ToolTip = 'Specifies the value of the Activation Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    var
                        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
                        MembershipSetup: Record "NPR MM Membership Setup";
                    begin
                        if (Rec."Item No." <> '') then begin
                            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
                            MembershipSalesSetup.SetFilter("No.", '=%1', Rec."Item No.");
                            if (MembershipSalesSetup.FindFirst()) then begin
                                MembershipSetup.Get(MembershipSalesSetup."Membership Code");

                                if (Rec."Document Date" > 0D) then begin
                                    if (CalcDate(MembershipSalesSetup."Duration Formula", Rec."Document Date") < WorkDate()) then
                                        Error(INVALID_ACTIVATION_DATE, Rec."Document Date");

                                    case MembershipSetup."Card Expire Date Calculation" of
                                        MembershipSetup."Card Expire Date Calculation"::DATEFORMULA:
                                            Rec."Valid Until" := CalcDate(MembershipSetup."Card Number Valid Until", Rec."Document Date");
                                        MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED:
                                            Rec."Valid Until" := CalcDate(MembershipSalesSetup."Duration Formula", Rec."Document Date");
                                        else
                                            Rec."Valid Until" := 0D;
                                    end;

                                end;

                                if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::NA) then
                                    Rec."Valid Until" := 0D;

                            end;
                        end;
                        ActivationDate := Rec."Document Date";
                    end;
                }
            }
            group(Card)
            {
                Visible = _ShowNewCardSection;
                field("External Card No."; Rec."External Card No.")
                {

                    ShowMandatory = ExternalCardNoMandatory;
                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pin Code"; Rec."Pin Code")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Pin Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until"; Rec."Valid Until")
                {

                    Editable = CardValidUntilMandatory;
                    Importance = Additional;
                    ShowMandatory = CardValidUntilMandatory;
                    ToolTip = 'Specifies the value of the Valid Until field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Card Type"; Rec."Member Card Type")
                {

                    Editable = EditMemberCardType;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Member Card Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(Attributes)
            {
                Caption = 'Attributes';
                Visible = _ShowAttributesSection;
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {

                    CaptionClass = GetAttributeCaptionClass(1);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

                    CaptionClass = GetAttributeCaptionClass(2);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        OnAttributeLookup(2);
                    end;

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

                    CaptionClass = GetAttributeCaptionClass(4);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

                    CaptionClass = GetAttributeCaptionClass(5);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

                    CaptionClass = GetAttributeCaptionClass(6);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

                    CaptionClass = GetAttributeCaptionClass(7);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

                    CaptionClass = GetAttributeCaptionClass(8);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

                    CaptionClass = GetAttributeCaptionClass(9);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

                    CaptionClass = GetAttributeCaptionClass(10);
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
            group(AzureMemberRegistration)
            {
                Caption = 'Sign-Up with External Application';
                Visible = _ShowAzureSection;
                field(FirstName3; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(PhoneNo3; Rec."Phone No.")
                {
                    ShowMandatory = _ShowAzureSection;
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    begin
                        if ((StrLen(Rec."Phone No.") >= 1) and (CopyStr(Rec."Phone No.", 1, 1) <> '+')) then
                            Error('Phone number must be in international format (starting with a +) for the SMS Service to work correctly.');
                    end;

                    trigger OnDrillDown()
                    begin
                        SetGuardian();
                    end;
                }
            }
        }

        area(factboxes)
        {
            part(MMMemberInfoCapturePicture; "NPR MM Member Info Picture")
            {
                Caption = 'Picture';
                SubPageLink = "Entry No." = field("Entry No.");
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Take Picture ")
            {
                Caption = 'Take Picture';
                Image = Camera;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Take Picture action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                begin
                    MembershipManagement.TakeMemberInfoPicture(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(xRec.Image);
    end;

    trigger OnAfterGetRecord()
    begin
        if (ActivationDateEditable) then
            Rec.Validate("Document Date", ActivationDate);

        if (_ShowAddToMembershipSection) then
            SetMembershipDetails(ExternalMembershipNo);

        SetDefaultValues();
        SetMandatoryVisualQue();
        GetMasterDataAttributeValue();

        CurrPage.Update(false);
    end;

    trigger OnInit()
    begin

        _ShowNewMemberSection := true;
        _ShowNewCardSection := true;
    end;

    trigger OnOpenPage()
    begin
        SetDefaultValues();

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
        NPRAttrEditable := CurrPage.Editable();

    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RequiredFields: Boolean;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        if (CloseAction = ACTION::LookupOK) then begin
            if (Rec."Receipt No." <> '') then begin
                Rec.Modify();
                MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
                MemberInfoCapture.SetFilter("Receipt No.", '=%1', Rec."Receipt No.");
                MemberInfoCapture.SetFilter("Line No.", '=%1', Rec."Line No.");
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
        MISSING_REQUIRED_FIELDS: Label 'All fields do not have valid values.\\ The following fields needs attention: %1';
        EMAIL_INVALID_CONFIRM: Label 'The %1 seems invalid, do you want to correct it?';
        _EmailMandatory: Boolean;
        _PhoneNoMandatory: Boolean;
        _SSNMandatory: Boolean;
        INVALID_VALUE: Label 'The %1 is invalid.';
        _BirthDateMandatory: Boolean;
        ExternalCardNoMandatory: Boolean;
        GuardianMandatory: Boolean;

        ActivationDateEditable: Boolean;
        ActivationDateMandatory: Boolean;
        INVALID_ACTIVATION_DATE: Label 'The activation date %1 is not valid. The resulting membership must have remaining time when applying the membership duration formula to activation date.';
        ActivationDate: Date;
        ExternalMembershipNo: Code[20];
        _ShowNewMemberSection: Boolean;
        _ShowNewCardSection: Boolean;
        _ShowAddToMembershipSection: Boolean;
        _ShowAddMemberCardSection: Boolean;
        _ShowReplaceCardSection: Boolean;
        _ShowCardholderSection: Boolean;
        _ShowAttributesSection: Boolean;
        EditMemberCardType: Boolean;
        _ShowAutoRenew: Boolean;
        _ShowAzureSection: Boolean;
        ExternalMembershipNoEditable: Boolean;
        AutoRenewPaymentMethodMandatory: Boolean;
        SetAddGuardianMode: Boolean;
        CardValidUntilMandatory: Boolean;
        GDPRMandatory: Boolean;
        GDPRSelected: Boolean;
        NAMEFIELD_TO_LONG: Label 'The maximum length for "%1", "%2" and "%3" when combined is %4. Current total length is %5.';
        NPRAttrTextArray: array[40] of Text;
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
        _PreSelectedCustomerContact: Boolean;
        _PosUnitNo: Code[10];
        _MembershipValidUntilDate: Date;

    local procedure CheckEmail()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ValidEmail: Boolean;
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberCommunity: Record "NPR MM Member Community";
    begin
        if (Rec."E-Mail Address" = '') then
            exit;

        ValidEmail := IsValidEmail(Rec."E-Mail Address");

        if (not ValidEmail) then
            if (Confirm(EMAIL_INVALID_CONFIRM, true, Rec.FieldCaption("E-Mail Address"))) then
                Error(INVALID_VALUE, Rec.FieldCaption("E-Mail Address"));

        if (Rec."Item No." <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', Rec."Item No.");
            if (MembershipSalesSetup.FindFirst()) then begin
                MembershipSetup.Get(MembershipSalesSetup."Membership Code");
                MemberCommunity.Get(MembershipSetup."Community Code");

                if (MemberCommunity."Member Unique Identity" = MemberCommunity."Member Unique Identity"::EMAIL) then begin

                    Member.SetFilter("E-Mail Address", '=%1', LowerCase(Rec."E-Mail Address"));
                    Member.SetFilter(Blocked, '=%1', false);
                    if (Member.FindFirst()) then begin
                        if (Confirm(EMAIL_EXISTS, false, Member."E-Mail Address", Member."External Member No.", Member."Display Name")) then begin
                            MembershipManagement.BlockMember(MembershipManagement.GetMembershipFromExtMemberNo(Member."External Member No."), Member."Entry No.", true);
                        end else begin
                            Error(INVALID_VALUE, Rec.FieldCaption("E-Mail Address"));
                        end;
                    end;

                end;
            end;
        end;
    end;

    local procedure IsValidEmail(EMail: Text) ValidEmail: Boolean
    var
        Name: Text;
        Domain: Text;
    begin
        if (StrLen(EMail) = 0) then
            exit(false);

        // Contains 1 @
        ValidEmail := StrLen(DelChr(EMail, '<=>', '@')) = StrLen(EMail) - 1;

        // A least 1 dot to the right of @
        if (ValidEmail) then
            ValidEmail := (StrPos(CopyStr(EMail, StrPos(EMail, '@')), '.') > 1);

        // strict check is 0-9, a-z, A-Z, and ~!$%^&*_=+}{'?-.
        if (ValidEmail) then begin
            Name := CopyStr(EMail, 1, StrPos(EMail, '@'));
            if (StrLen(Name) = 1) then
                exit(false);

            Name := DelChr(Name, '<=>', '0123456789');
            Name := DelChr(Name, '<=>', 'abcdefghijklmnopqrstuvwqyz');
            Name := DelChr(Name, '<=>', 'ABCDEFGHIJKLMNOPQRSTUVWQYZ');
            Name := DelChr(Name, '<=>', '~!$%^&*_=+}{?-.@');
            ValidEmail := StrLen(Name) = 0;
        end;

        // strict check is 0-9, a-z, A-Z, and -.
        if (ValidEmail) then begin
            Domain := CopyStr(EMail, StrPos(EMail, '@'));
            if (StrPos(Domain, '.') <= 2) then
                exit(false);

            if (Domain[StrLen(Domain)]) in ['-', '.', '@'] then
                exit(false);

            Domain := DelChr(Domain, '<=>', '0123456789');
            Domain := DelChr(Domain, '<=>', 'abcdefghijklmnopqrstuvwqyz');
            Domain := DelChr(Domain, '<=>', 'ABCDEFGHIJKLMNOPQRSTUVWQYZ');
            Domain := DelChr(Domain, '<=>', '-.@');
            ValidEmail := StrLen(Domain) = 0;
        end;

        exit(ValidEmail);
    end;

    internal procedure HaveRequiredFields(MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
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
        ValidEmail: Boolean;
    begin

        MissingInformation := false;
        MissingFields := '';

        if (MemberInfoCapture."Item No." <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', MemberInfoCapture."Item No.");
            if (MembershipSalesSetup.FindFirst()) then begin
                if (MembershipSetup.Get(MembershipSalesSetup."Membership Code")) then
                    MemberCommunity.Get(MembershipSetup."Community Code");

                if (_ShowNewMemberSection) then begin
                    case MemberCommunity."Member Unique Identity" of
                        MemberCommunity."Member Unique Identity"::NONE:
                            MissingInformation := false;
                        MemberCommunity."Member Unique Identity"::EMAIL:
                            SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("E-Mail Address"), (MemberInfoCapture."E-Mail Address" = ''));
                        MemberCommunity."Member Unique Identity"::PHONENO:
                            SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("Phone No."), (MemberInfoCapture."Phone No." = ''));
                        MemberCommunity."Member Unique Identity"::SSN:
                            SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("Social Security No."), (MemberInfoCapture."Social Security No." = ''));
                    end;

                    if (ActivationDateEditable) and (MemberInfoCapture."Document Date" = 0D) then
                        SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("Document Date"), (MemberInfoCapture."Document Date" = 0D));

                    if (_BirthDateMandatory) then begin
                        SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption(Birthday), (MemberInfoCapture.Birthday = 0D));
                        if (MemberInfoCapture.Birthday <> 0D) then
                            if (not MembershipManagement.CheckAgeConstraint(
                                MembershipManagement.GetMembershipAgeConstraintDate(MembershipSalesSetup, MemberInfoCapture),
                                MemberInfoCapture.Birthday,
                                MembershipSetup."Validate Age Against",
                                MembershipSalesSetup."Age Constraint Type",
                                MembershipSalesSetup."Age Constraint (Years)")) then begin
                                SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption(Birthday), true);
                                Message(AGE_VERIFICATION, MemberInfoCapture."First Name", MembershipSalesSetup."Age Constraint (Years)");
                            end;
                    end;

                    if (MemberInfoCapture."E-Mail Address" <> '') then begin
                        ValidEmail := IsValidEmail(MemberInfoCapture."E-Mail Address");
                        SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("E-Mail Address"), not ValidEmail);
                    end;

                end;

                if (_ShowNewCardSection) then begin
                    if (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::EXTERNAL) then begin
                        SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("External Card No."), (MemberInfoCapture."External Card No." = ''));

                        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then
                            SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("Valid Until"), (MemberInfoCapture."Valid Until" = 0D));

                    end;
                end;

                if (_ShowAddToMembershipSection) or (_ShowAddMemberCardSection) or (_ShowReplaceCardSection) then begin
                    SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("External Membership No."), (MemberInfoCapture."External Membership No." = ''));
                end;

                if (_ShowAddMemberCardSection) or (_ShowReplaceCardSection) then begin
                    SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("External Member No"), (MemberInfoCapture."External Member No" = ''));
                end;

                if (MemberInfoCapture."Enable Auto-Renew") then
                    SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("Auto-Renew Payment Method Code"), (MemberInfoCapture."Auto-Renew Payment Method Code" = ''));

                case MembershipSetup."GDPR Mode" of
                    MembershipSetup."GDPR Mode"::REQUIRED:
                        SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("GDPR Approval"), (MemberInfoCapture."GDPR Approval" <> MemberInfoCapture."GDPR Approval"::ACCEPTED));
                    MembershipSetup."GDPR Mode"::CONSENT:
                        SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("GDPR Approval"), (MemberInfoCapture."GDPR Approval" = MemberInfoCapture."GDPR Approval"::NA));
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
            SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("E-Mail Address"), (MemberInfoCapture."E-Mail Address" = ''));
            if (MemberInfoCapture."E-Mail Address" <> '') then begin
                ValidEmail := IsValidEmail(MemberInfoCapture."E-Mail Address");
                SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("E-Mail Address"), not ValidEmail);
            end;

            if (SetAddGuardianMode) then begin
                MissingInformation := false;
                SetMissingInfo(MissingInformation, MissingFields, MemberInfoCapture.FieldCaption("Guardian External Member No."), (MemberInfoCapture."Guardian External Member No." = ''));
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
        if (Rec."Item No." <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', Rec."Item No.");
            if (MembershipSalesSetup.FindFirst()) then begin
                if (MembershipSetup.Get(MembershipSalesSetup."Membership Code")) then
                    MemberCommunity.Get(MembershipSetup."Community Code");

                case MemberCommunity."Member Unique Identity" of
                    MemberCommunity."Member Unique Identity"::NONE:
                        ;
                    MemberCommunity."Member Unique Identity"::EMAIL:
                        _EmailMandatory := true;
                    MemberCommunity."Member Unique Identity"::PHONENO:
                        _PhoneNoMandatory := true;
                    MemberCommunity."Member Unique Identity"::SSN:
                        _SSNMandatory := true;
                end;

                ExternalCardNoMandatory := (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::EXTERNAL);
                CardValidUntilMandatory := ((MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::EXTERNAL) and
                                            not (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::NA));

                case MembershipSalesSetup."Valid From Base" of
                    MembershipSalesSetup."Valid From Base"::FIRST_USE:
                        ActivationDateMandatory := false;
                    else
                        ActivationDateMandatory := true;
                end;

                AutoRenewPaymentMethodMandatory := Rec."Enable Auto-Renew";

                _BirthDateMandatory := MembershipSetup."Enable Age Verification";

            end;
        end else begin
            _EmailMandatory := true;
            _PhoneNoMandatory := false;
            _SSNMandatory := false;

            _BirthDateMandatory := false;

        end;
    end;

    local procedure SetDefaultValues()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipEntry: Record "NPR MM Membership Entry";
        ValidUntilBaseDate: Date;
    begin

        _PreSelectedCustomerContact := ((Rec."Contact No." <> '') or (Rec."Customer No." <> '')) and not Rec."Originates From File Import";
        _ShowNewMemberSection := true;

        _ShowAddToMembershipSection := false;
        _ShowCardholderSection := false;
        _ShowAddMemberCardSection := false;
        _ShowReplaceCardSection := false;
        _ShowNewCardSection := false;
        _ShowAutoRenew := false;
        EditMemberCardType := false;

        _ShowAttributesSection := true;
        GuardianMandatory := false;

        Rec.Quantity := 1;

        ExternalMembershipNoEditable := (Rec."External Membership No." = '');

        if (SetAddGuardianMode) then begin
            _ShowAddToMembershipSection := false;
            _ShowReplaceCardSection := false;
            _ShowNewMemberSection := false;
            _ShowCardholderSection := false;
            _ShowNewCardSection := false;

            _ShowAttributesSection := false;
            GuardianMandatory := true;
        end;

        if (Rec."Store Code" = '') and (_PosUnitNo <> '') then
            Rec."Store Code" := Rec.GetCsStoreCode(_PosUnitNo);

        if (Rec."Item No." <> '') then begin
            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', Rec."Item No.");
            if (MembershipSalesSetup.FindFirst()) then begin

                if (MembershipSetup.Get(MembershipSalesSetup."Membership Code")) then
                    MemberCommunity.Get(MembershipSetup."Community Code");

                if (Rec."Country Code" = '') then
                    Rec."Country Code" := MemberCommunity.MemberDefaultCountryCode;

                _ShowNewCardSection := (MembershipSetup."Loyalty Card" = MembershipSetup."Loyalty Card"::YES);

                EditMemberCardType := (MembershipSalesSetup."Member Card Type Selection" = MembershipSalesSetup."Member Card Type Selection"::USER_SELECT);
                Rec."Member Card Type" := MembershipSalesSetup."Member Card Type";

                _ShowAutoRenew := MemberCommunity."Membership to Cust. Rel.";

                case MembershipSalesSetup."Business Flow Type" of
                    MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                        begin
                            if (MembershipSalesSetup.AzureMemberRegSetupCode <> '') then begin
                                _ShowAddToMembershipSection := false;
                                _ShowReplaceCardSection := false;
                                _ShowNewMemberSection := false;
                                _ShowCardholderSection := false;
                                _ShowNewCardSection := false;
                                _ShowAddMemberCardSection := false;
                                _ShowAttributesSection := false;
                                _ShowAutoRenew := false;
                                _ShowNewMemberSection := false;
                                _ShowAzureSection := true;
                            end;
                        end;
                    MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER:
                        _ShowAddToMembershipSection := true;

                    MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER:
                        begin
                            _ShowAddToMembershipSection := true;
                            _ShowReplaceCardSection := false;
                            _ShowNewMemberSection := false;
                            _ShowCardholderSection := false;
                            _ShowNewCardSection := false;
                        end;

                    MembershipSalesSetup."Business Flow Type"::ADD_CARD:
                        begin
                            _ShowAddMemberCardSection := true;
                            _ShowNewMemberSection := false;
                            _ShowCardholderSection := true;
                        end;

                    MembershipSalesSetup."Business Flow Type"::REPLACE_CARD:
                        begin
                            _ShowReplaceCardSection := true;
                            _ShowNewMemberSection := false;
                            _ShowCardholderSection := true;
                        end;
                end;



                ActivationDateEditable := false;
                case MembershipSalesSetup."Valid From Base" of
                    MembershipSalesSetup."Valid From Base"::SALESDATE:
                        Rec."Document Date" := WorkDate();
                    MembershipSalesSetup."Valid From Base"::DATEFORMULA:
                        begin
                            Rec."Document Date" := CalcDate(MembershipSalesSetup."Valid From Date Calculation", WorkDate());
                            ActivationDateEditable := true;
                        end;
                    MembershipSalesSetup."Valid From Base"::PROMPT:
                        ActivationDateEditable := true;
                    MembershipSalesSetup."Valid From Base"::FIRST_USE:
                        Rec."Document Date" := 0D;
                end;

                ValidUntilBaseDate := Rec."Document Date";
                if (ValidUntilBaseDate = 0D) then
                    ValidUntilBaseDate := WorkDate();

                if (MembershipSalesSetup."Membership Code" = '') then
                    MembershipSetup."Card Number Valid Until" := MembershipSalesSetup."Duration Formula";

                if (not _ShowReplaceCardSection) then begin
                    case MembershipSetup."Card Expire Date Calculation" of
                        MembershipSetup."Card Expire Date Calculation"::DATEFORMULA:
                            Rec."Valid Until" := CalcDate(MembershipSetup."Card Number Valid Until", ValidUntilBaseDate);
                        MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED:
                            begin
                                MembershipEntry.SetFilter("Membership Entry No.", '=%1', Rec."Membership Entry No.");
                                MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
                                MembershipEntry.SetFilter(Blocked, '=%1', false);
                                if (MembershipEntry.FindLast()) then
                                    if (not MembershipEntry."Activate On First Use") then
                                        Rec."Valid Until" := MembershipEntry."Valid Until Date";
                            end;
                        else
                            Rec."Valid Until" := 0D;
                    end;
                end;

                GDPRMandatory := false;
                GDPRSelected := true;
                case MembershipSetup."GDPR Mode" of
                    MembershipSetup."GDPR Mode"::NA:
                        Rec."GDPR Approval" := Rec."GDPR Approval"::NA;
                    MembershipSetup."GDPR Mode"::IMPLIED:
                        Rec."GDPR Approval" := Rec."GDPR Approval"::ACCEPTED;
                    MembershipSetup."GDPR Mode"::REQUIRED:
                        begin
                            Rec."GDPR Approval" := Rec."GDPR Approval"::NA;
                            GDPRMandatory := true;
                            GDPRSelected := false;
                        end;
                    MembershipSetup."GDPR Mode"::CONSENT:
                        begin
                            Rec."GDPR Approval" := Rec."GDPR Approval"::PENDING;
                            GDPRMandatory := true;
                            GDPRSelected := false;
                        end;
                end;

                GuardianMandatory := (MembershipSalesSetup."Requires Guardian");

            end;
        end;
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

    local procedure SetMembershipDetails(pExternalMembershipNo: Code[20])
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

        Rec."Membership Entry No." := Membership."Entry No.";
        Rec."External Membership No." := Membership."External Membership No.";

        ExternalMembershipNo := Membership."External Membership No.";

        // Set guardian
        if (_ShowAddToMembershipSection) then begin
            MembershipRole.SetFilter("Membership Entry No.", '=%1', Rec."Membership Entry No.");
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
            MembershipRole.SetFilter(Blocked, '=%1', false);
            if (MembershipRole.FindFirst()) then begin
                GuardianMember.Get(MembershipRole."Member Entry No.");
                Rec."Guardian External Member No." := GuardianMember."External Member No.";
                Rec."E-Mail Address" := GuardianMember."E-Mail Address";
                Rec."Phone No." := GuardianMember."Phone No.";
            end;
        end;

    end;

    local procedure SetGuardian()
    var
        TempMember: Record "NPR MM Member" temporary;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Member: Record "NPR MM Member";
    begin
        if (Rec."Receipt No." <> '') then begin
            MemberInfoCapture.SetFilter("Receipt No.", '=%1', Rec."Receipt No.");
            MemberInfoCapture.SetFilter("Line No.", '<>%1', Rec."Line No.");
            MemberInfoCapture.SetFilter("Guardian External Member No.", '=%1', '');
            if (MemberInfoCapture.FindSet()) then begin
                repeat
                    if (Member.Get(MemberInfoCapture."Member Entry No")) then begin
                        TempMember.TransferFields(Member, true);
                        TempMember.Insert();
                    end;
                until (MemberInfoCapture.Next() = 0);
            end;

            if (PAGE.RunModal(Page::"NPR MM Members", TempMember) = ACTION::LookupOK) then begin
                Rec."Guardian External Member No." := TempMember."External Member No.";
                Rec."E-Mail Address" := TempMember."E-Mail Address";
                Rec."Phone No." := TempMember."Phone No.";
                CurrPage.Update(true);
            end;
        end else begin
            if (PAGE.RunModal(Page::"NPR MM Members", Member) = ACTION::LookupOK) then begin
                Rec."Guardian External Member No." := Member."External Member No.";
                Rec."E-Mail Address" := Member."E-Mail Address";
                Rec."Phone No." := Member."Phone No.";
                CurrPage.Update(true);
            end;
        end;
    end;

    local procedure SetMemberDetails(pExternalMemberNo: Code[20])
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
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

        Rec."Member Entry No" := Member."Entry No.";
        Rec."External Member No" := Member."External Member No.";

        if (Member.Image.HasValue()) then begin
            TempBlob.CreateOutStream(OutStr);
            Member.Image.ExportStream(OutStr);
            TempBlob.CreateInStream(InStr);
            Rec.Image.ImportStream(InStr, Rec.FieldName(Image));
        end else
            Clear(Rec.Image);

        if (not _ShowAzureSection) then begin
            Rec."First Name" := Member."First Name";
            Rec."Middle Name" := Member."Middle Name";
            Rec."Last Name" := Member."Last Name";
        end;
        Rec."E-Mail Address" := Member."E-Mail Address";
        Rec."Phone No." := Member."Phone No.";
        Rec."Valid Until" := 0D;

        Membership.Get(MembershipManagement.GetMembershipFromExtMemberNo(pExternalMemberNo));
        SetMembershipDetails(Membership."External Membership No.");
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

        if (_ShowAddMemberCardSection) then
            SetMemberDetails(Member."External Member No.");

        MemberRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MemberRole.SetFilter(Blocked, '=%1', false);
        if (MemberRole.FindFirst()) then begin
            Membership.Get(MemberRole."Membership Entry No.");
            SetMembershipDetails(Membership."External Membership No.");

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
            SetMembershipDetails(Membership."External Membership No.");

            if (_ShowAddMemberCardSection) then
                SetMemberDetails(Member."External Member No.");

            if (_ShowReplaceCardSection) then begin
                SetMemberDetails(Member."External Member No.");
                MemberCardLookup(Member."Entry No.", false);
            end;

            if (_ShowAzureSection) then;

            if (SetAddGuardianMode) then
                Rec."Guardian External Member No." := Member."External Member No.";

        end;
    end;

    local procedure MemberCardLookup(MemberEntryNo: Integer; WithDialog: Boolean)
    var
        MemberCardList: Page "NPR MM Member Card List";
        MemberCard: Record "NPR MM Member Card";
        PageAction: Action;
    begin

        if (MemberEntryNo = 0) then
            exit;

        MemberCard.SetCurrentKey("Member Entry No.");
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.SetFilter(Blocked, '=%1', false);
        if (not MemberCard.FindSet()) then
            exit;

        if ((MemberCard.Count() > 1) and (not WithDialog)) then
            exit;

        if (WithDialog) then begin
            MemberCardList.SetTableView(MemberCard);
            MemberCardList.LookupMode(true);
            PageAction := MemberCardList.RunModal();
            if (PageAction <> ACTION::LookupOK) then
                exit;

            MemberCardList.GetRecord(MemberCard);
        end;

        Rec."Replace External Card No." := MemberCard."External Card No.";
    end;

    internal procedure SetAddMembershipGuardianMode()
    begin
        SetAddGuardianMode := true;
    end;

    local procedure SelectCustomer(var CustomerNumber: Code[20]): Boolean
    var
        Customers: Page "Customer List";
        Customer: Record "Customer";
    begin
        CustomerNumber := '';

        Customer.SetFilter(Blocked, '=%1', "Customer Blocked"::" ");
        Customers.SetTableView(Customer);
        Customers.LookupMode(true);
        if (Action::LookupOK = Customers.RunModal()) then begin
            Customers.GetRecord(Customer);
            CustomerNumber := Customer."No.";
        end;

        exit(CustomerNumber <> '');
    end;

    local procedure SelectContact(CustomerNumber: Code[20]; var ContactNumber: Code[20]): Boolean
    var
        Contact: Record "Contact";
        ContactRelation: Record "Contact Business Relation";
        Contacts: Page "Contact List";
    begin
        ContactNumber := '';

        ContactRelation.SetFilter("Link to Table", '=%1', "Contact Business Relation Link To Table"::"Customer");
        ContactRelation.SetFilter("No.", '=%1', CustomerNumber);
        if (not ContactRelation.FindFirst()) then
            exit;

        Contact.SetFilter("Company No.", '=%1', ContactRelation."Contact No.");
        Contacts.SetTableView(Contact);
        Contacts.LookupMode(true);
        if (Action::LookupOK = Contacts.RunModal()) then begin
            Contacts.GetRecord(Contact);
            ContactNumber := Contact."No.";
        end;

        exit(ContactNumber <> '');
    end;

    local procedure ApplyCustomer(CustomerNumber: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Customer: Record "Customer";
        Membership: Record "NPR MM Membership";
        CustomerLinkedToMembership: Label 'Customer number %2 is already linked to membership %1.';
    begin
        Customer.Get(CustomerNumber);

        Membership.SetFilter("Customer No.", '=%1', CustomerNumber);
        Membership.SetFilter(Blocked, '=%1', false);
        if (Membership.FindFirst()) then
            Error(CustomerLinkedToMembership, Membership."External Membership No.", CustomerNumber);

        MemberInfoCapture."Company Name" := CopyStr(Customer.Name, 1, MaxStrLen(MemberInfoCapture."Company Name"));
        MemberInfoCapture."First Name" := CopyStr(Customer.Name, 1, MaxStrLen(MemberInfoCapture."First Name"));
        MemberInfoCapture."Middle Name" := '';
        MemberInfoCapture."Last Name" := '';
        MemberInfoCapture.Address := Customer.Address;
        MemberInfoCapture."Post Code Code" := Customer."Post Code";
        MemberInfoCapture.City := Customer.City;
        MemberInfoCapture."Country Code" := Customer."Country/Region Code";
        MemberInfoCapture."E-Mail Address" := Customer."E-Mail";
        MemberInfoCapture."Phone No." := Customer."Phone No.";
        MemberInfoCapture."Customer No." := CustomerNumber;
    end;

    local procedure ApplyContact(ContactNumber: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Contact: Record "Contact";
        MembershipRole: Record "NPR MM Membership Role";
        ContactLinkedToMember: Label 'Contact %1 is assigned to member %2 %3 on membership %4';
    begin
        Contact.Get(ContactNumber);

        MembershipRole.SetFilter("Contact No.", '=%1', ContactNumber);
        MembershipRole.CalcFields("External Member No.", "External Membership No.", "Member Display Name");
        if (MembershipRole.FindFirst()) then
            Error(ContactLinkedToMember, ContactNumber, MembershipRole."External Member No.", MembershipRole."Member Display Name", MembershipRole."External Membership No.");

        MemberInfoCapture."First Name" := Contact."First Name";
        MemberInfoCapture."Middle Name" := Contact."Middle Name";
        MemberInfoCapture."Last Name" := Contact.Surname;
        MemberInfoCapture.Address := Contact.Address;
        MemberInfoCapture."Post Code Code" := Contact."Post Code";
        MemberInfoCapture.City := Contact.City;
        MemberInfoCapture."Country Code" := Contact."Country/Region Code";
        MemberInfoCapture."E-Mail Address" := Contact."E-Mail";
        MemberInfoCapture."Phone No." := Contact."Phone No.";
        MemberInfoCapture."Contact No." := Contact."No.";
    end;

    local procedure OnValidateReplaceExternalCardNumber()
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberCard: Record "NPR MM Member Card";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
    begin
        if (rec."Replace External Card No." = '') then begin
            Clear(Rec."Valid Until");
            Clear(Rec."Membership Code");
            Clear(_MembershipValidUntilDate);
            exit;
        end;

        MemberCard.SetFilter("External Card No.", '=%1', rec."Replace External Card No.");
        MemberCard.FindFirst();
        Member.Get(MemberCard."Member Entry No.");
        Membership.Get(MemberCard."Membership Entry No.");

        SetMemberDetails(Member."External Member No.");
        MembershipManagement.GetMembershipMaxValidUntilDate(Membership."Entry No.", _MembershipValidUntilDate);
        Rec.Validate("Membership Code", Membership."Membership Code");
        Rec.Validate("External Member No", Member."External Member No.");
        Rec.Validate("Valid Until", MemberCard."Valid Until");

        CurrPage.Update(true);
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

        exit(DATABASE::"NPR MM Member Info Capture");

    end;

    local procedure GetAttributeCaptionClass(AttributeNumber: Integer): Text[50]
    var
        PlaceHolderLbl: Label '6014555,%1,%2,2', Locked = true;
    begin
        exit(StrSubstNo(PlaceHolderLbl, GetAttributeTableId(), AttributeNumber));

    end;

    local procedure OnAttributeLookup(AttributeNumber: Integer)
    begin
        NPRAttrManagement.OnPageLookUp(GetAttributeTableId(), AttributeNumber, Format(Rec."Entry No.", 0, '<integer>'), NPRAttrTextArray[AttributeNumber]);
    end;

    procedure SetPOSUnit(PosUnitNoIn: Code[10])
    begin
        _PosUnitNo := PosUnitNoIn;
    end;
}
