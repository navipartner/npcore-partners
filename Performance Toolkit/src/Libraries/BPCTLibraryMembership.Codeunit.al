codeunit 88013 "NPR BPCT Library - Membership"
{
    procedure SetupCommunity_Simple(): Code[20]
    var
        MemberCommunity: Record "NPR MM Member Community";
        Language: Record "NPR MM Language";
    begin

        Language.LanguageCode := 'DAN';
        if (Language.Insert()) then;

        Language.LanguageCode := 'ENU';
        if (Language.Insert()) then;

        exit(CreateCommunitySetup(GetNextNoFromSeries('C20'),
            MemberCommunity."External No. Search Order"::CARDNO,
            MemberCommunity."Member Unique Identity"::EMAIL,
            MemberCommunity."Create Member UI Violation"::ERROR,
            MemberCommunity."Member Logon Credentials"::MEMBER_UNIQUE_ID,
            false,
            true,
            '', // Description is not important
            'MS-DEMO01',
            'MM-DEMO01'));
    end;

    local procedure CreateCommunitySetup(CommunityCode: Code[20]; SearchOrder: Option; UniqueIdentity: Enum "NPR MM Member Unique Identity"; UIViolation: Option;
                                                                                                       LogonCredentials: Option;
                                                                                                       CreateContacts: Boolean;
                                                                                                       CreateRenewNotification: Boolean;
                                                                                                       Description: Text;
                                                                                                       MembershipNoSeries: Code[20];
                                                                                                       MemberNoSeries: Code[20]): Code[20];
    var
        MemberCommunity: Record "NPR MM Member Community";
    begin
        if (not MemberCommunity.Get(CommunityCode)) then begin
            MemberCommunity.Code := CommunityCode;
            MemberCommunity.Insert();
        end;

        MemberCommunity.Init();
        MemberCommunity.Description := Description;
        MemberCommunity.VALIDATE("External Membership No. Series", MembershipNoSeries);
        MemberCommunity.VALIDATE("External Member No. Series", MemberNoSeries);

        MemberCommunity."External No. Search Order" := SearchOrder;
        MemberCommunity."Member Unique Identity" := UniqueIdentity;
        MemberCommunity."Create Member UI Violation" := UIViolation;
        MemberCommunity."Member Logon Credentials" := LogonCredentials;
        MemberCommunity."Membership to Cust. Rel." := CreateContacts;
        MemberCommunity."Create Renewal Notifications" := CreateRenewNotification;

        MemberCommunity.Modify();

        exit(MemberCommunity.Code);
    end;

    procedure CreateAlterationAutoRenewSetup(FromMembershipCode: Code[20]; SalesItemNo: Code[20]; Description: Text; ToMembershipCode: Code[20]; ActivationFromDateFormula: Text[30]; MembershipDuration: Text[30]; PriceCalculation: Option; AutoRenewTo: Code[20])
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        if (not AlterationSetup.Get(AlterationSetup."Alteration Type"::AUTORENEW, FromMembershipCode, SalesItemNo)) then begin
            AlterationSetup."Alteration Type" := AlterationSetup."Alteration Type"::AUTORENEW;
            AlterationSetup."From Membership Code" := FromMembershipCode;
            AlterationSetup."Sales Item No." := SalesItemNo;
            AlterationSetup.Insert();
        end;

        AlterationSetup.Init();
        AlterationSetup.Description := Description;
        AlterationSetup."To Membership Code" := ToMembershipCode;
        Evaluate(AlterationSetup."Alteration Date Formula", ActivationFromDateFormula);
        Evaluate(AlterationSetup."Membership Duration", MembershipDuration);
        AlterationSetup."Price Calculation" := PriceCalculation;
        AlterationSetup."Auto-Renew To" := AutoRenewTo;
        AlterationSetup."Card Expired Action" := AlterationSetup."Card Expired Action"::UPDATE;
        AlterationSetup.Modify(true);
    end;


    local procedure CreateNoSerie(NoSerieCode: Code[20]; StartNumber: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if (not NoSeries.Get(NoSerieCode)) then begin
            NoSeries.Code := NoSerieCode;
            NoSeries.Insert();
        end;

        NoSeries.Description := 'Ticket Automated Test Framework';
        NoSeries."Default Nos." := true;
        NoSeries.Modify();

        if (not NoSeriesLine.Get(NoSerieCode, 10000)) then begin
            NoSeriesLine."Series Code" := NoSerieCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := DMY2Date(1, 1, 2020);
            NoSeriesLine."Starting No." := StartNumber;
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;
    end;

    local procedure GetNextNoFromSeries(FromSeries: Code[20]): Code[20]
    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
    begin
        case FromSeries OF
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            'MM-DEMO01':
                exit(NoSeriesManagement.GetNextNo('MM-DEMO01', Today(), false));
            'MS-DEMO01':
                exit(NoSeriesManagement.GetNextNo('MS-DEMO01', Today(), false));
            'MC-DEMO01':
                exit(NoSeriesManagement.GetNextNo('MC-DEMO01', Today(), false));

            'C10':
                exit(NoSeriesManagement.GetNextNo('MM-PK10', Today(), false));
            'C20':
                exit(NoSeriesManagement.GetNextNo('MM-PK20', Today(), false));

            'SAFE10':
                exit(NoSeriesManagement.GetNextNo('MM-SPK10', Today(), false));
            'SAFE20':
                exit(NoSeriesManagement.GetNextNo('MM-SPK20', Today(), false));
#ELSE
            'MM-DEMO01':
                exit(NoSeriesManagement.GetNextNo('MM-DEMO01', Today(), true));
            'MS-DEMO01':
                exit(NoSeriesManagement.GetNextNo('MS-DEMO01', Today(), true));
            'MC-DEMO01':
                exit(NoSeriesManagement.GetNextNo('MC-DEMO01', Today(), true));

            'C10':
                exit(NoSeriesManagement.GetNextNo('MM-PK10', Today(), true));
            'C20':
                exit(NoSeriesManagement.GetNextNo('MM-PK20', Today(), true));

            'SAFE10':
                exit(NoSeriesManagement.GetNextNo('MM-SPK10', Today(), true));
            'SAFE20':
                exit(NoSeriesManagement.GetNextNo('MM-SPK20', Today(), true));
#ENDIF
            else
                ERROR('Get Next No %1 from number series is not configured.', FromSeries);
        end;
    end;

    local procedure SetPaymentMethodAsDefault(var MemberPaymentMethod: Record "NPR MM Member Payment Method"; var Membership: Record "NPR MM Membership")
    var
        Member: Record "NPR MM Member";
        UserAccount: Record "NPR UserAccount";
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not MembershipMgt.GetUserAccountFromMember(Member, UserAccount)) then
            MembershipMgt.CreateUserAccountFromMember(Member, UserAccount);
        PaymentMethodMgt.SetMemberPaymentMethodAsDefault(Membership, MemberPaymentMethod);
    end;


    procedure SetRandomMemberInfoData(var InfoCapture: Record "NPR MM Member Info Capture")
    var
        NPRBPCTLibraryRandom: Codeunit "NPR BPCT Library - Random";
    begin
        Clear(InfoCapture);
        InfoCapture."First Name" := NPRBPCTLibraryRandom.RandText(15);
        InfoCapture."Middle Name" := NPRBPCTLibraryRandom.RandText(8);
        InfoCapture."Last Name" := NPRBPCTLibraryRandom.RandText(20);
        InfoCapture."Social Security No." := NPRBPCTLibraryRandom.RandText(MaxStrLen(InfoCapture."Social Security No."));
        InfoCapture.Address := NPRBPCTLibraryRandom.RandText(MaxStrLen(InfoCapture.Address));
        InfoCapture.City := NPRBPCTLibraryRandom.RandText(MaxStrLen(InfoCapture.City));
        InfoCapture.Country := NPRBPCTLibraryRandom.RandText(MaxStrLen(InfoCapture.Country));
        InfoCapture."Company Name" := NPRBPCTLibraryRandom.RandText(MaxStrLen(InfoCapture."Company Name"));
        InfoCapture."E-Mail Address" := NPRBPCTLibraryRandom.RandText(50);
        InfoCapture."E-Mail Address"[3 + Random(10)] := '@';
        InfoCapture."E-Mail Address"[Strlen(InfoCapture."E-Mail Address") - 3] := '.';
        InfoCapture."Country Code" := '';
        InfoCapture.Gender := InfoCapture.Gender::OTHER;
        InfoCapture.Birthday := CalcDate('<-50Y+7D>', Today());
        InfoCapture."News Letter" := InfoCapture."News Letter"::YES;
        InfoCapture."Notification Method" := InfoCapture."Notification Method"::EMAIL;
        InfoCapture.PreferredLanguageCode := 'ENU';
        InfoCapture."Enable Auto-Renew" := true;
        InfoCapture."Auto-Renew Payment Method Code" := 'TEST';
    end;

    procedure CreateNoSeries()
    begin
        CreateNoSerie('MM-PK20', 'MM & 2000000000');
    end;

    procedure CreateRecurringPaymentSetup(var RecurPaymSetup: Record "NPR MM Recur. Paym. Setup")
    var
        SourceCode: Record "Source Code";
        GLAccount: Record "G/L Account";
    begin
        if not RecurPaymSetup.Get('TEST') then begin
            RecurPaymSetup.Init();
            RecurPaymSetup.Code := 'TEST';
            RecurPaymSetup.Insert();
        end;

        RecurPaymSetup."Max. Pay. Process Try Count" := 3;
        RecurPaymSetup."Subscr. Auto-Renewal On" := RecurPaymSetup."Subscr. Auto-Renewal On"::"Expiry Date";
        if SourceCode.Get('ITEMJNL') then
            RecurPaymSetup."Source Code" := SourceCode.Code;
        RecurPaymSetup."Revenue Account" := CreateGLAccountNoWithDirectPosting();
        RecurPaymSetup."Document No. Series" := 'ASSIGNMENT';
        RecurPaymSetup."Gen. Journal Template Name" := 'PAYMENT';
        RecurPaymSetup.Modify();
    end;

    procedure CreateMemberPaymentMethod(MembershipEntryNo: Integer)
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
    begin
        Membership.Get(MembershipEntryNo);
        MemberPaymentMethod.Init();
        MemberPaymentMethod."Table No." := Database::"NPR MM Membership";
        MemberPaymentMethod."BC Record ID" := Membership.RecordId;
        MemberPaymentMethod.Status := MemberPaymentMethod.Status::Active;
        MemberPaymentMethod.PSP := MemberPaymentMethod.PSP::Adyen;
        MemberPaymentMethod."Payment Token" := 'test-subs';
        MemberPaymentMethod.Insert();

        SetPaymentMethodAsDefault(MemberPaymentMethod, Membership);
    end;

    procedure CreateSubsPaymentGateway()
    var
        SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
        if not SubsPaymentGateway.Get('AdyenMock') then begin
            SubsPaymentGateway.Init();
            SubsPaymentGateway.Code := 'AdyenMock';
            SubsPaymentGateway.Insert();
        end;
        SubsPaymentGateway."Integration Type" := SubsPaymentGateway."Integration Type"::Adyen;
        SubsPaymentGateway.Status := SubsPaymentGateway.Status::Enabled;
        SubsPaymentGateway.Modify();

        If not SubsAdyenPGSetup.Get(SubsPaymentGateway.Code) then begin
            SubsAdyenPGSetup.Init();
            SubsAdyenPGSetup.Code := SubsPaymentGateway.Code;
            SubsAdyenPGSetup.Insert();
        end;
        SubsAdyenPGSetup.SetAPIKey('test');
        SubsAdyenPGSetup."Payment Account Type" := SubsAdyenPGSetup."Payment Account Type"::"G/L Account";
        SubsAdyenPGSetup."Payment Account No." := CreateGLAccountNoWithDirectPosting();
        SubsAdyenPGSetup."Merchant Name" := 'Test';
        SubsAdyenPGSetup.Modify();
    end;

    procedure CreateGLAccountNoWithDirectPosting(): Code[20]

    var
        LibraryRandom: Codeunit "NPR BPCT Library - Random";
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Init();
        GLAccount.Validate("No.", LibraryRandom.RandText(MaxStrLen(GLAccount."No.")));
        GLAccount.Validate(Name, GLAccount."No.");
        GLAccount.Insert(true);
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Modify();
        exit(GLAccount."No.");
    end;

    procedure CreateNPPaySetup()
    var
        NPPaySetup: Record "NPR Adyen Setup";
    begin
        if not NPPaySetup.Get() then begin
            NPPaySetup.Init();
            NPPaySetup."Max Sub Req Process Try Count" := 3;
            NPPaySetup.Insert();
        end;
    end;
}