﻿codeunit 85014 "NPR Library - Member Module"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Clone Data", 'CheckIfSkipCreateDefaultBarcode', '', true, true)]
    local procedure CheckIfSkipCreateDefaultBarcode(ItemNo: Code[20]; VariantCode: Code[10]; var SkipCreateDefaultBarcode: Boolean; var Handled: Boolean)
    begin
        // Variety number series vs data are messed-up in default dev container
        SkipCreateDefaultBarcode := true;
        Handled := true;
    end;

    procedure CreateScenario_SmokeTest() SalesItemNo: Code[20]
    var
        Customer: Record Customer;
        Item: Record Item;
        MemberCommunity: Record "NPR MM Member Community";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketType: Record "NPR TM Ticket Type";
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        LoyaltyProgramCode: Code[20];
    begin

        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        WorkDate(Today());

        // This scenario can be used for smoke testing

        Initialize();

        MemberCommunity.Get(SetupCommunity_Simple());
        MemberCommunity."Activate Loyalty Program" := true;
        MemberCommunity."Membership to Cust. Rel." := true;
        MemberCommunity.Modify();

        LoyaltyProgramCode := CreateLoyaltySetup(GenerateCode20(), 'Riverland Loyalty Program', 1.0, 0.015);

        MembershipSetup.Get(SetupMembership_Simple(MemberCommunity.Code, 'T-GOLD', LoyaltyProgramCode, 'Gold Membership'));
        MembershipSetup."Customer Config. Template Code" := CreateDemoCustomerTemplate(GenerateCode10());
        MembershipSetup.Modify();
        AddConfigTemplateLine(MembershipSetup."Customer Config. Template Code", 0, Customer.FieldNo("Customer Disc. Group"), CreateDiscountGroup(GenerateCode10(), 'GOLD Discount Grp.'));

        MembershipSetup.Get(SetupMembership_Simple(MemberCommunity.Code, 'T-SILVER', LoyaltyProgramCode, 'Silver Membership'));
        MembershipSetup."Customer Config. Template Code" := CreateDemoCustomerTemplate(GenerateCode10());
        MembershipSetup.Modify();
        AddConfigTemplateLine(MembershipSetup."Customer Config. Template Code", 0, Customer.FieldNo("Customer Disc. Group"), CreateDiscountGroup(GenerateCode10(), 'SILVER Discount Grp.'));

        MembershipSetup.Get(SetupMembership_Simple(MemberCommunity.Code, 'T-BRONZE', LoyaltyProgramCode, 'Bronze Membership'));
        MembershipSetup."Customer Config. Template Code" := CreateDemoCustomerTemplate(GenerateCode10());
        MembershipSetup.Modify();
        AddConfigTemplateLine(MembershipSetup."Customer Config. Template Code", 0, Customer.FieldNo("Customer Disc. Group"), CreateDiscountGroup(GenerateCode10(), 'BRONZE Discount Grp.'));

        Item.Get(CreateItem('T-320100-ADDMEMBER', '', 'Add Member to Membership', 0));
        Item.Get(CreateItem('T-320100-CARD', '', 'Additional Membership Card', 17));
        Item.Get(CreateItem('T-320100-REPLACCRD', '', 'Membership Replacement Card', 27));
        Item.Get(CreateItem('T-320100-REGRET', '', 'Regret Membership time frame', 0));
        Item.Get(CreateItem('T-320100', '', 'GOLD Membership', 157));
        SetupSimpleMembershipSalesItem(Item."No.", 'T-GOLD');
        SetupRenew_NoGraceNotStackable('T-GOLD', CreateItem('T-320100-RENEW', '', 'Renew GOLD Membership', 157), '', 'Renew GOLD Membership');
        SetupUpgrade('T-GOLD', CreateItem('T-320100-DOWNGRADE', '', 'Downgrade from GOLD to SILVER', 147), 'T-SILVER', '', 'Downgrade from GOLD to SILVER');
        SetupExtend('T-GOLD', CreateItem('T-320100-EXTEND', '', 'Extend GOLD Membership', 34), '', '+9M', 'Extend GOLD Membership');

        Item.Get(CreateItem('T-320101', '', 'SILVER Membership', 147));
        SetupSimpleMembershipSalesItem(Item."No.", 'T-SILVER');
        SetupRenew_NoGraceNotStackable('T-SILVER', CreateItem('T-320101-RENEW', '', 'Renew Silver Membership', 147), '', 'Renew Silver Membership');
        SetupUpgrade('T-SILVER', CreateItem('T-320101-UPGRADE', '', 'Upgrade from SILVER to GOLD', 157), 'T-GOLD', '', 'Upgrade from SILVER to GOLD');
        SetupUpgrade('T-SILVER', CreateItem('T-320101-DOWNGRADE', '', 'Downgrade from SILVER to BRONZE', 137), 'T-SILVER', '', 'Downgrade from SILVER to BRONZE');

        Item.Get(CreateItem('T-320102', '', 'BRONZE Membership', 137));
        SetupSimpleMembershipSalesItem(Item."No.", 'T-BRONZE');
        SetupUpgrade('T-BRONZE', CreateItem('T-320102-UPGRADE', '', 'Upgrade from BRONZE to SILVER', 147), 'T-SILVER', '', 'Upgrade from BRONZE to SILVER');

        CreateLoyaltyUpgradeThreshold(LoyaltyProgramCode, 'T-BRONZE', 'T-SILVER', 'T-320102-UPGRADE', true, 3000);
        CreateLoyaltyUpgradeThreshold(LoyaltyProgramCode, 'T-SILVER', 'T-GOLD', 'T-320101-UPGRADE', true, 5000);
        CreateLoyaltyUpgradeThreshold(LoyaltyProgramCode, 'T-GOLD', 'T-SILVER', 'T-320100-DOWNGRADE', false, 2000);
        CreateLoyaltyUpgradeThreshold(LoyaltyProgramCode, 'T-SILVER', 'T-BRONZE', 'T-320101-DOWNGRADE', false, 4000);

        SetupWelcomeNotification('T-WG', 'RIVERLAND', 'T-GOLD');
        SetupWelcomeNotification('T-WS', 'RIVERLAND', 'T-SILVER');
        SetupWelcomeNotification('T-WB', 'RIVERLAND', 'T-BRONZE');

        SetupWalletNotification('T-WC', 'RIVERLAND', '', 0);
        SetupWalletNotification('T-WU', 'RIVERLAND', '', 1);

        exit('T-320100');

    end;

    procedure CreateCancelSetup(FromMembershipCode: Code[20]; SalesItemNo: Code[20]; Description: Text; ActivateFrom: Option; ActivationFromDateFormula: Text[30]; UseGracePeriod: Boolean; GracePeriodRelatesTo: Option; GracePeriodBefore: Text[30]; GracePeriodAfter: Text[30]; PriceCalculation: Option);
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        if (not AlterationSetup.Get(AlterationSetup."Alteration Type"::CANCEL, FromMembershipCode, SalesItemNo)) then begin
            AlterationSetup."Alteration Type" := AlterationSetup."Alteration Type"::CANCEL;
            AlterationSetup."From Membership Code" := FromMembershipCode;
            AlterationSetup."Sales Item No." := SalesItemNo;
            AlterationSetup.Insert();
        end;

        AlterationSetup.Init();
        AlterationSetup.Description := Description;
        AlterationSetup."Alteration Activate From" := ActivateFrom;
        Evaluate(AlterationSetup."Alteration Date Formula", ActivationFromDateFormula);
        AlterationSetup."Activate Grace Period" := UseGracePeriod;
        AlterationSetup."Grace Period Relates To" := GracePeriodRelatesTo;
        Evaluate(AlterationSetup."Grace Period Before", GracePeriodBefore);
        Evaluate(AlterationSetup."Grace Period After", GracePeriodAfter);
        AlterationSetup."Price Calculation" := PriceCalculation;
        AlterationSetup.Modify(true);
    end;

    procedure CreateDemoMemberAttributes();
    var
        AttributeCode: Code[20];
        i: Integer;
    begin

        for i := 1 to 3 do begin
            AttributeCode := CreateAttribute('MM', i, 'Member');
            CreateAttributeTableLink(AttributeCode, DATABASE::"NPR MM Member", i);
            CreateAttributeTableLink(AttributeCode, DATABASE::"NPR MM Member Info Capture", i);
        end;

        for i := 4 to 6 do begin
            AttributeCode := CreateAttribute('MM', i, 'Membership');
            CreateAttributeTableLink(AttributeCode, DATABASE::"NPR MM Membership", i);
            CreateAttributeTableLink(AttributeCode, DATABASE::"NPR MM Member Info Capture", i);
        end;

        for i := 7 to 8 do begin
            AttributeCode := CreateAttribute('MM', i, 'Common');
            CreateAttributeTableLink(AttributeCode, DATABASE::"NPR MM Member", i);
            CreateAttributeTableLink(AttributeCode, DATABASE::"NPR MM Membership", i);
            CreateAttributeTableLink(AttributeCode, DATABASE::"NPR MM Member Info Capture", i);
        end;

        CreateAttributeTableLink(CreateAttribute('MM', 9, 'Member Only'), DATABASE::"NPR MM Member", 9);
        CreateAttributeTableLink(CreateAttribute('MM', 10, 'Membership Only'), DATABASE::"NPR MM Membership", 10);
    end;

    procedure CreateExtendSetup(FromMembershipCode: Code[20]; SalesItemNo: Code[20]; Description: Text; ToMembershipCode: Code[20]; ActivateFrom: Option; ActivationFromDateFormula: Text[30]; UseGracePeriod: Boolean; GracePeriodRelatesTo: Option; GracePeriodBefore: Text[30]; GracePeriodAfter: Text[30]; MembershipDuration: Text[30]; PriceCalculation: Option; AllowStacking: Boolean);
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        if (not AlterationSetup.Get(AlterationSetup."Alteration Type"::EXTEND, FromMembershipCode, SalesItemNo)) then begin
            AlterationSetup."Alteration Type" := AlterationSetup."Alteration Type"::EXTEND;
            AlterationSetup."From Membership Code" := FromMembershipCode;
            AlterationSetup."Sales Item No." := SalesItemNo;
            AlterationSetup.Insert();
        end;

        AlterationSetup.Init();
        AlterationSetup.Description := Description;
        AlterationSetup."To Membership Code" := ToMembershipCode;
        AlterationSetup."Alteration Activate From" := ActivateFrom;
        Evaluate(AlterationSetup."Alteration Date Formula", ActivationFromDateFormula);
        AlterationSetup."Activate Grace Period" := UseGracePeriod;
        AlterationSetup."Grace Period Relates To" := GracePeriodRelatesTo;
        Evaluate(AlterationSetup."Grace Period Before", GracePeriodBefore);
        Evaluate(AlterationSetup."Grace Period After", GracePeriodAfter);
        Evaluate(AlterationSetup."Membership Duration", MembershipDuration);
        AlterationSetup."Price Calculation" := PriceCalculation;
        AlterationSetup."Stacking Allowed" := AllowStacking;
        AlterationSetup.Modify(true);
    end;

    procedure CreateMembershipGuestAdmissionSetup(MembershipCode: Code[20]; AdmissionCode: Code[20]; TicketItemType: Option; TicketItemNo: Code[20]; MaxGuestCount: Integer; Description: Text[50]);
    var
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
    begin

        if (not MembershipAdmissionSetup.Get(MembershipCode, AdmissionCode, TicketItemType, TicketItemNo)) then begin
            MembershipAdmissionSetup.INIT();
            MembershipAdmissionSetup."Membership  Code" := MembershipCode;
            MembershipAdmissionSetup."Admission Code" := AdmissionCode;
            MembershipAdmissionSetup."Ticket No. Type" := TicketItemType;
            MembershipAdmissionSetup."Ticket No." := TicketItemNo;
            MembershipAdmissionSetup.Insert();
        end;

        MembershipAdmissionSetup."Cardinality Type" := MembershipAdmissionSetup."Cardinality Type"::UNLIMITED;
        MembershipAdmissionSetup."Max Cardinality" := 0;
        if (MaxGuestCount >= 0) then begin
            MembershipAdmissionSetup."Cardinality Type" := MembershipAdmissionSetup."Cardinality Type"::LIMITED;
            MembershipAdmissionSetup."Max Cardinality" := MaxGuestCount;
        end;

        MembershipAdmissionSetup.Description := Description;
        MembershipAdmissionSetup.Modify();

        exit;
    end;

    procedure CreateMembershipSalesItemSetup(ItemNo: Code[20]; MembershipCode: Code[20]; ValidFromType: Option; SalesCutoffDateformula: Text[30]; ValidFromDateFormula: Text[30]; ValidUntilType: Option; ValidUntilDateFormala: Text[30]);
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin

        if (not (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, ItemNo))) then begin
            MembershipSalesSetup.Type := MembershipSalesSetup.Type::ITEM;
            MembershipSalesSetup."No." := ItemNo;
            MembershipSalesSetup.Insert();
        end;

        MembershipSalesSetup.Init();

        MembershipSalesSetup."Business Flow Type" := MembershipSalesSetup."Business Flow Type"::MEMBERSHIP;

        MembershipSalesSetup."Valid From Base" := ValidFromType;
        Evaluate(MembershipSalesSetup."Sales Cut-Off Date Calculation", SalesCutoffDateformula);
        Evaluate(MembershipSalesSetup."Valid From Date Calculation", ValidFromDateFormula);
        MembershipSalesSetup."Valid Until Calculation" := ValidUntilType;
        Evaluate(MembershipSalesSetup."Duration Formula", ValidUntilDateFormala);

        MembershipSalesSetup."Membership Code" := MembershipCode;
        MembershipSalesSetup.Modify();
    end;

    procedure CreateRenewSetup(FromMembershipCode: Code[20]; SalesItemNo: Code[20]; Description: Text; ToMembershipCode: Code[20]; ActivateFrom: Option; ActivationFromDateFormula: Text[30]; UseGracePeriod: Boolean; GracePeriodRelatesTo: Option; GracePeriodBefore: Text[30]; GracePeriodAfter: Text[30]; MembershipDuration: Text[30]; PriceCalculation: Option; AllowStacking: Boolean);
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        if (not AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, FromMembershipCode, SalesItemNo)) then begin
            AlterationSetup."Alteration Type" := AlterationSetup."Alteration Type"::RENEW;
            AlterationSetup."From Membership Code" := FromMembershipCode;
            AlterationSetup."Sales Item No." := SalesItemNo;
            AlterationSetup.Insert();
        end;

        AlterationSetup.Init();
        AlterationSetup.Description := Description;
        AlterationSetup."To Membership Code" := ToMembershipCode;
        AlterationSetup."Alteration Activate From" := ActivateFrom;
        Evaluate(AlterationSetup."Alteration Date Formula", ActivationFromDateFormula);
        AlterationSetup."Activate Grace Period" := UseGracePeriod;
        AlterationSetup."Grace Period Relates To" := GracePeriodRelatesTo;
        Evaluate(AlterationSetup."Grace Period Before", GracePeriodBefore);
        Evaluate(AlterationSetup."Grace Period After", GracePeriodAfter);
        Evaluate(AlterationSetup."Membership Duration", MembershipDuration);
        AlterationSetup."Price Calculation" := PriceCalculation;
        AlterationSetup."Stacking Allowed" := AllowStacking;
        AlterationSetup.Modify(true);
    end;

    procedure CreateUpgradeSetup(FromMembershipCode: Code[20]; SalesItemNo: Code[20]; Description: Text; ToMembershipCode: Code[20]; ActivateFrom: Option; ActivationFromDateFormula: Text[30]; UseGracePeriod: Boolean; GracePeriodRelatesTo: Option; GracePeriodBefore: Text[30]; GracePeriodAfter: Text[30]; MembershipDuration: Text[30]; PriceCalculation: Option; AllowStacking: Boolean);
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        if (not AlterationSetup.Get(AlterationSetup."Alteration Type"::UPGRADE, FromMembershipCode, SalesItemNo)) then begin
            AlterationSetup."Alteration Type" := AlterationSetup."Alteration Type"::UPGRADE;
            AlterationSetup."From Membership Code" := FromMembershipCode;
            AlterationSetup."Sales Item No." := SalesItemNo;
            AlterationSetup.Insert();
        end;

        AlterationSetup.Init();
        AlterationSetup.Description := Description;
        AlterationSetup."To Membership Code" := ToMembershipCode;
        AlterationSetup."Alteration Activate From" := ActivateFrom;
        Evaluate(AlterationSetup."Alteration Date Formula", ActivationFromDateFormula);
        AlterationSetup."Activate Grace Period" := UseGracePeriod;
        AlterationSetup."Grace Period Relates To" := GracePeriodRelatesTo;
        Evaluate(AlterationSetup."Grace Period Before", GracePeriodBefore);
        Evaluate(AlterationSetup."Grace Period After", GracePeriodAfter);
        Evaluate(AlterationSetup."Membership Duration", MembershipDuration);
        AlterationSetup."Price Calculation" := PriceCalculation;
        AlterationSetup."Stacking Allowed" := AllowStacking;
        AlterationSetup."Upgrade With New Duration" := (MembershipDuration <> '');

        AlterationSetup.Modify(true);
    end;

    procedure SetupCancel_NoGrace(CurrentMembershipCode: Code[20]; SalesItemNo: Code[20]; NewMembershipCode: Code[20]; NEwDescription: Text);
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        CreateCancelSetup(CurrentMembershipCode, SalesItemNo,
            NEwDescription,
            AlterationSetup."Alteration Activate From"::ASAP,
            '',          // AlterationSetup."Alteration Date Formula"
            false,       // AlterationSetup."Activate Grace Period"
            AlterationSetup."Grace Period Relates To"::START_DATE,
            '',          // AlterationSetup."Grace Period Before",
            '',          // AlterationSetup."Grace Period After",
            AlterationSetup."Price Calculation"::UNIT_PRICE);
    end;

    procedure SetupExtend(CurrentMembershipCode: Code[20]; SalesItemNo: Code[20]; NewMembershipCode: Code[20]; NewDuration: Text[30]; NewDescription: Text);
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        CreateExtendSetup(CurrentMembershipCode, SalesItemNo,
            NewDescription,
            NewMembershipCode,
            AlterationSetup."Alteration Activate From"::ASAP,
            '',          // AlterationSetup."Alteration Date Formula"
            false,       // AlterationSetup."Activate Grace Period"
            AlterationSetup."Grace Period Relates To"::START_DATE,
            '',          // AlterationSetup."Grace Period Before",
            '',          // AlterationSetup."Grace Period After",
            NewDuration, // AlterationSetup."Membership Duration"
            AlterationSetup."Price Calculation"::UNIT_PRICE,
            false);      // AlterationSetup."Stacking Allowed"
    end;

    procedure SetupMembership_Simple(CommunityCode: Code[20]; MembershipCode: Code[20]; LoyaltyCode: Code[20]; NewDescription: Text): Code[20];
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        exit(CreateLoyaltyMembershipSetup(MembershipCode,
            NewDescription,
            CommunityCode,
            MembershipSetup."Membership Type"::GROUP,
            LoyaltyCode,
            MembershipSetup."Loyalty Card"::YES,
            MembershipSetup."Member Information"::NAMED,
            false, // Perpetual
            MembershipSetup."Member Role Assignment"::FIRST_IS_ADMIN,
            2,
            true,
            true,
            'MC-DEMO01'));
    end;

    procedure SetupRenew_NoGraceNotStackable(CurrentMembershipCode: Code[20]; SalesItemNo: Code[20]; NewMembershipCode: Code[20]; NewDescription: Text);
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        CreateRenewSetup(CurrentMembershipCode, SalesItemNo,
            NewDescription,
            NewMembershipCode,
            AlterationSetup."Alteration Activate From"::ASAP,
            '',          // AlterationSetup."Alteration Date Formula"
            false,       // AlterationSetup."Activate Grace Period"
            AlterationSetup."Grace Period Relates To"::START_DATE,
            '',          // AlterationSetup."Grace Period Before",
            '',          // AlterationSetup."Grace Period After",
            '<+1Y-1D>',  // AlterationSetup."Membership Duration"
            AlterationSetup."Price Calculation"::UNIT_PRICE,
            false);      // AlterationSetup."Stacking Allowed"
    end;

    procedure SetupSimpleMembershipSalesItem(ItemNo: Code[20]; MembershipCode: Code[20]): Code[20];
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin

        CreateMembershipSalesItemSetup(ItemNo,
          MembershipCode,
          MembershipSalesSetup."Valid From Base"::SALESDATE,
          '', // Sales Cut-off Date Formule
          '', // Valid from Date Formula
          MembershipSalesSetup."Valid Until Calculation"::DATEFORMULA,
          '<+1Y-1D>');

        exit(ItemNo);
    end;

    procedure SetupUpgrade(CurrentMembershipCode: Code[20]; SalesItemNo: Code[20]; NewMembershipCode: Code[20]; NewDuration: Text[30]; NewDescription: Text);
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        CreateUpgradeSetup(CurrentMembershipCode, SalesItemNo,
            NewDescription,
            NewMembershipCode,
            AlterationSetup."Alteration Activate From"::ASAP,
            '',          // AlterationSetup."Alteration Date Formula"
            false,       // AlterationSetup."Activate Grace Period"
            AlterationSetup."Grace Period Relates To"::START_DATE,
            '',          // AlterationSetup."Grace Period Before",
            '',          // AlterationSetup."Grace Period After",
            NewDuration, // AlterationSetup."Membership Duration"
            AlterationSetup."Price Calculation"::UNIT_PRICE,
            false);      // AlterationSetup."Stacking Allowed"
    end;

    procedure SetupWalletNotification(NotificationCode: Code[10]; CommunityCode: Code[20]; MembershipCode: Code[20]; TriggerType: option CREATE,UPDATE);
    var
        MemberNotificationSetup: Record "NPR MM Member Notific. Setup";
        MemberNotification: Codeunit "NPR MM Member Notification";
        outstr: OutStream;
    begin

        if (not MemberNotificationSetup.Get(NotificationCode)) then begin
            MemberNotificationSetup.Code := NotificationCode;
            MemberNotificationSetup.Insert();
        end;

        MemberNotificationSetup.Description := 'Wallet Update';
        if (TriggerType = TriggerType::UPDATE) then
            MemberNotificationSetup.Type := MemberNotificationSetup.Type::WALLET_UPDATE;

        if (TriggerType = TriggerType::CREATE) then
            MemberNotificationSetup.Type := MemberNotificationSetup.Type::WALLET_CREATE;

        MemberNotificationSetup."Days Before" := 0;
        MemberNotificationSetup."Days Past" := 0;
        MemberNotificationSetup."Community Code" := CommunityCode;
        MemberNotificationSetup."Membership Code" := MembershipCode;
        MemberNotificationSetup."Cancel Overdue Notif. (Days)" := 1;
        MemberNotificationSetup."Target Member Role" := MemberNotificationSetup."Target Member Role"::ALL_ADMINS;
        MemberNotificationSetup."Processing Method" := MemberNotificationSetup."Processing Method"::INLINE;
        MemberNotificationSetup."NP Pass Server Base URL" := 'https://passes.npecommerce.dk/api/v1';
        MemberNotificationSetup."Pass Notification Method" := MemberNotificationSetup."Pass Notification Method"::SYNCHRONOUS;
        MemberNotificationSetup."Passes API" := '/passes/%1/%2';
        MemberNotificationSetup."Pass Token" := 'eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MjIyNDQyNjEsIm5iZiI6MTUyMjI0NDI2MSwidWlkIjo2fQ.yWeKjD8hDGhDNn8KLf345v7tYBZ-bA20DzS07bgHRxo';
        MemberNotificationSetup."Pass Type Code" := 'npmembership';
        MemberNotificationSetup."Include NP Pass" := true;

        MemberNotificationSetup."PUT Passes Template".CREATEOUTSTREAM(outstr);
        outstr.WRITE(MemberNotification.GetDefaultWalletTemplate());

        MemberNotificationSetup.Modify
    end;

    procedure SetupWelcomeNotification(NotificationCode: Code[10]; CommunityCode: Code[20]; MembershipCode: Code[20]);
    var
        MemberNotificationSetup: Record "NPR MM Member Notific. Setup";
        MemberNotification: Codeunit "NPR MM Member Notification";
        outstr: OutStream;
    begin

        if (not MemberNotificationSetup.Get(NotificationCode)) then begin
            MemberNotificationSetup.Code := NotificationCode;
            MemberNotificationSetup.Insert();
        end;

        MemberNotificationSetup.Description := 'Welcome Notification';
        MemberNotificationSetup.Type := MemberNotificationSetup.Type::WELCOME;
        MemberNotificationSetup."Days Before" := 0;
        MemberNotificationSetup."Days Past" := 0;
        MemberNotificationSetup."Community Code" := CommunityCode;
        MemberNotificationSetup."Membership Code" := MembershipCode;
        MemberNotificationSetup."Cancel Overdue Notif. (Days)" := 1;
        MemberNotificationSetup."Target Member Role" := MemberNotificationSetup."Target Member Role"::ALL_ADMINS;
        MemberNotificationSetup."Processing Method" := MemberNotificationSetup."Processing Method"::INLINE;
        MemberNotificationSetup."NP Pass Server Base URL" := 'https://passes.npecommerce.dk/api/v1';
        MemberNotificationSetup."Pass Notification Method" := MemberNotificationSetup."Pass Notification Method"::SYNCHRONOUS;
        MemberNotificationSetup."Passes API" := '/passes/%1/%2';
        MemberNotificationSetup."Pass Token" := 'eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MjIyNDQyNjEsIm5iZiI6MTUyMjI0NDI2MSwidWlkIjo2fQ.yWeKjD8hDGhDNn8KLf345v7tYBZ-bA20DzS07bgHRxo';
        MemberNotificationSetup."Pass Type Code" := 'npmembership';
        MemberNotificationSetup."Include NP Pass" := true;

        MemberNotificationSetup."PUT Passes Template".CREATEOUTSTREAM(outstr);
        outstr.WRITE(MemberNotification.GetDefaultWalletTemplate());

        MemberNotificationSetup.Modify();
    end;

    local procedure AddConfigTemplateLine(TemplateCode: Code[10]; LineNo: Integer; FieldId: Integer; Value: Text[250]): Integer;
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
    begin

        ConfigTemplateHeader.Get(TemplateCode);

        if (LineNo = 0) then begin
            ConfigTemplateLine.SetFilter("Data Template Code", '=%1', TemplateCode);
            LineNo := 1000;
            if (ConfigTemplateLine.FindLast()) then
                LineNo += ConfigTemplateLine."Line No.";
        end;

        if (not ConfigTemplateLine.Get(TemplateCode, LineNo)) then begin
            ConfigTemplateLine.INIT();
            ConfigTemplateLine."Data Template Code" := TemplateCode;
            ConfigTemplateLine."Line No." := LineNo;
            ConfigTemplateLine.Insert(true);
        end;

        ConfigTemplateLine.Type := ConfigTemplateLine.Type::Field;
        ConfigTemplateLine."Skip Relation Check" := true; // Avoid COMMIT when validating default value

        ConfigTemplateLine.VALIDATE("Table ID", ConfigTemplateHeader."Table ID");
        ConfigTemplateLine.VALIDATE("Field ID", FieldId);
        ConfigTemplateLine.VALIDATE("Default Value", Value);
        ConfigTemplateLine.Modify(true);

        exit(LineNo);
    end;

    local procedure CreateAttribute(CodePrefix: Code[10]; AttributeNumber: Integer; BaseDescription: Text): Code[20];
    var
        NPRAttribute: Record "NPR Attribute";
    begin

        if (CodePrefix <> '') then
            NPRAttribute.Code := StrSubstNo('%1-%2', CodePrefix, AttributeNumber);
        if (NPRAttribute.Code = '') then
            NPRAttribute.Code := GenerateCode10();

        if (not NPRAttribute.Get(NPRAttribute.Code)) then
            NPRAttribute.Insert();

        NPRAttribute.Name := StrSubstNo('%1 %2', BaseDescription, AttributeNumber);
        NPRAttribute."Code Caption" := StrSubstNo('%1 %2 c', BaseDescription, AttributeNumber);
        NPRAttribute."Filter Caption" := StrSubstNo('%1 %2 f', BaseDescription, AttributeNumber);
        NPRAttribute.Description := StrSubstNo('%1 %2 d', BaseDescription, AttributeNumber);

        NPRAttribute."Value Datatype" := NPRAttribute."Value Datatype"::DT_TEXT;
        NPRAttribute."On Validate" := NPRAttribute."On Validate"::DATATYPE;
        NPRAttribute."On Format" := NPRAttribute."On Format"::NATIVE;
        NPRAttribute.Modify();

        exit(NPRAttribute.Code);
    end;

    local procedure CreateAttributeTableLink(AttributeCode: Code[20]; TableId: Integer; AttributeNumber: Integer);
    var
        NPRAttributeID: Record "NPR Attribute ID";
    begin

        NPRAttributeID.SetFilter("Table ID", '=%1', TableId);
        NPRAttributeID.SetFilter("Shortcut Attribute ID", '=%1', AttributeNumber);
        NPRAttributeID.DeleteALL();

        if (not NPRAttributeID.Get(TableId, AttributeNumber)) then begin
            NPRAttributeID."Table ID" := TableId;
            NPRAttributeID."Attribute Code" := AttributeCode;
            NPRAttributeID.Insert();
        end;

        NPRAttributeID.VALIDATE("Shortcut Attribute ID", AttributeNumber);
        NPRAttributeID.Modify();
    end;


    local procedure CreateCommunitySetup(CommunityCode: Code[20]; SearchOrder: Option; UniqueIdentity: Enum "NPR MM Member Unique Identity"; UIViolation: Option; LogonCredentials: Option; CreateContacts: Boolean; CreateRenewNotification: Boolean; Description: Text; MembershipNoSeries: Code[20]; MemberNoSeries: Code[20]): Code[20];
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

    local procedure CreateDemoCustomerTemplate(TemplateCode: Code[10]): Code[10]
    var
        Customer: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";

        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        Currency: Record "Currency";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
    begin
        if (not ConfigTemplateHeader.Get(TemplateCode)) then begin
            ConfigTemplateHeader.Init();
            ConfigTemplateHeader.Code := TemplateCode;
            ConfigTemplateHeader.Description := 'Customer created from membership';
            ConfigTemplateHeader.VALIDATE("Table ID", DATABASE::Customer);
            ConfigTemplateHeader.Insert(true);
        end;

        ConfigTemplateLine.SetFilter("Data Template Code", '=%1', ConfigTemplateHeader.Code);
        ConfigTemplateLine.DeleteALL();

        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        LibraryERM.FindCurrency(Currency);

        AddConfigTemplateLine(TemplateCode, 0, Customer.FieldNo("Currency Code"), Currency.Code);
        AddConfigTemplateLine(TemplateCode, 0, Customer.FieldNo("Gen. Bus. Posting Group"), GeneralPostingSetup."Gen. Bus. Posting Group");
        AddConfigTemplateLine(TemplateCode, 0, Customer.FieldNo("VAT Bus. Posting Group"), VATPostingSetup."VAT Bus. Posting Group");
        AddConfigTemplateLine(TemplateCode, 0, Customer.FieldNo("Customer Posting Group"), LibrarySales.FindCustomerPostingGroup());

        exit(ConfigTemplateHeader.Code);
    end;

    local procedure CreateDiscountGroup(DiscountGroupCode: Code[10]; Description: Text[100]): Code[10];
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin

        if (not CustomerDiscountGroup.Get(DiscountGroupCode)) then begin
            CustomerDiscountGroup.INIT();
            CustomerDiscountGroup.Code := DiscountGroupCode;
            CustomerDiscountGroup.Insert();
        end;

        CustomerDiscountGroup.Description := Description;
        CustomerDiscountGroup.Modify();

        exit(DiscountGroupCode);
    end;

    procedure CreateItem(No: Code[20]; VariantCode: Code[10]; Description: Text[50]; UnitPrice: Decimal): Code[20]
    var
        MemberItem: Record "Item";
        ItemVariant: Record "Item Variant";
        LibraryInventory: Codeunit "NPR Library - Inventory";
    begin
        MemberItem.INIT();
        if (not (MemberItem.Get(No))) then begin
            LibraryInventory.CreateItem(MemberItem);
            MemberItem."No." := No;
            MemberItem.Insert();
        end;

        MemberItem.Description := Description;
        MemberItem."Unit Price" := UnitPrice;
        MemberItem.Blocked := false;
        MemberItem."NPR Group sale" := false;

        MemberItem.Modify();

        if (VariantCode <> '') then begin
            ItemVariant.INIT();
            if (not ItemVariant.Get(No, VariantCode)) then begin
                ItemVariant."Item No." := No;
                ItemVariant.Code := VariantCode;
                ItemVariant.Insert();
            end;
            ItemVariant.Description := Description;
            ItemVariant.Modify();
        end;

        exit(No);
    end;

    local procedure CreateLoyaltyMembershipSetup(Code: Code[20]; Description: Text; CommunityCode: Code[20]; MembershipType: Option; LoyaltyCode: Code[20]; LoyaltyCard: Option; MemberInfo: Option; Perpetual: Boolean; RoleAssignment: Option; MemberCardinality: Integer; WelcomeNotification: Boolean; RenewNotification: Boolean; MemberCardNoSeries: Code[20]): Code[20];
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Community: Record "NPR MM Member Community";
    begin
        if (not MembershipSetup.Get(Code)) then begin
            MembershipSetup.Code := Code;
            MembershipSetup.Insert();
        end;

        MembershipSetup.Init();

        MembershipSetup.Description := Description;
        MembershipSetup."Customer Config. Template Code" := '';

        Community.Get(CommunityCode);
        if (Community."Membership to Cust. Rel.") then
            MembershipSetup."Customer Config. Template Code" := CreateSimpleCustomerTemplate();

        MembershipSetup."Community Code" := CommunityCode;
        MembershipSetup."Membership Type" := MembershipType;
        MembershipSetup."Loyalty Code" := LoyaltyCode;
        MembershipSetup."Loyalty Card" := LoyaltyCard;
        MembershipSetup."Member Information" := MemberInfo;
        MembershipSetup.Perpetual := Perpetual;
        MembershipSetup."Member Role Assignment" := RoleAssignment;
        MembershipSetup."Membership Member Cardinality" := MemberCardinality;
        MembershipSetup."Create Welcome Notification" := WelcomeNotification;
        MembershipSetup."Create Renewal Notifications" := RenewNotification;

        SetMembershipCardDetails(MembershipSetup, MemberCardNoSeries);
        SetMembershipTicketDetails();

        MembershipSetup.Modify();
        exit(MembershipSetup.Code);
    end;

    local procedure CreateLoyaltySetup(Code: Code[20]; Description: Text[50]; AmountFactor: Decimal; PointRate: Decimal): Code[20];
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
    begin

        if (not LoyaltySetup.Get(Code)) then begin
            LoyaltySetup.INIT();
            LoyaltySetup.Code := Code;
            LoyaltySetup.Insert();
        end;

        LoyaltySetup.Description := Description;
        LoyaltySetup."Collection Period" := LoyaltySetup."Collection Period"::AS_YOU_GO;
        LoyaltySetup."Point Base" := LoyaltySetup."Point Base"::AMOUNT;
        LoyaltySetup."Points On Discounted Sales" := true;
        LoyaltySetup."Amount Base" := LoyaltySetup."Amount Base"::INCL_VAT;
        LoyaltySetup."Amount Factor" := AmountFactor;
        LoyaltySetup."Point Rate" := PointRate;

        LoyaltySetup."Auto Upgrade Point Source" := LoyaltySetup."Auto Upgrade Point Source"::UNCOLLECTED;

        LoyaltySetup.Modify();

        exit(Code);
    end;

    local procedure CreateLoyaltyUpgradeThreshold(LocaltyCode: Code[20]; FromMembershipCode: Code[20]; ToMembershipCode: Code[20]; AlterationItem: Code[20]; Upgrade: Boolean; Threshold: Integer);
    var
        LoyaltyAlterMembership: Record "NPR MM Loyalty Alter Members.";
        ChangeDirection: Option;
    begin
        ChangeDirection := LoyaltyAlterMembership."Change Direction"::DOWNGRADE;
        if (Upgrade) then
            ChangeDirection := LoyaltyAlterMembership."Change Direction"::UPGRADE;

        if (not LoyaltyAlterMembership.Get(LocaltyCode, FromMembershipCode, ToMembershipCode, ChangeDirection)) then begin
            LoyaltyAlterMembership.INIT();
            LoyaltyAlterMembership."Loyalty Code" := LocaltyCode;
            LoyaltyAlterMembership."From Membership Code" := FromMembershipCode;
            LoyaltyAlterMembership."To Membership Code" := ToMembershipCode;
            LoyaltyAlterMembership."Change Direction" := ChangeDirection;
            LoyaltyAlterMembership.Insert();
        end;

        LoyaltyAlterMembership."Sales Item No." := AlterationItem;

        if (Upgrade) then
            LoyaltyAlterMembership.Description := StrSubstNo('Upgrade from %1 to %2', FromMembershipCode, ToMembershipCode);

        if (not Upgrade) then
            LoyaltyAlterMembership.Description := StrSubstNo('Downgrade from %1 to %2', FromMembershipCode, ToMembershipCode);

        LoyaltyAlterMembership."Points Threshold" := Threshold;
        LoyaltyAlterMembership.Modify();
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


    local procedure CreateSimpleCustomerTemplate(): Code[10];
    begin
        exit(CreateDemoCustomerTemplate(GenerateCode10()));
    end;

    procedure Initialize();
    var
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        WorkDate(Today());

        CreateNoSerie('MM-DEMO01', 'MM-DEMO-00001');
        CreateNoSerie('MS-DEMO01', 'MS-DEMO-00001');
        CreateNoSerie('MC-DEMO01', 'MC-DEMO-00001');

        CreateNoSerie('MM-ATF001', 'MMATF0000001');
        CreateNoSerie('MM-PK10', 'MM & 10000');         // Code 10 number series
        CreateNoSerie('MM-PK20', 'MM & 2000000000');    // Code 20 number series

        CreateNoSerie('MM-SPK10', 'MM010000');         // Code 10 number series
        CreateNoSerie('MM-SPK20', 'MM02000000000');    // Code 20 number series
    end;

    procedure GenerateCode10(): Code[20]
    begin
        exit(GetNextNoFromSeries('C10'));
    end;

    procedure GenerateCode20(): Code[20]
    begin
        exit(GetNextNoFromSeries('C20'));
    end;

    procedure GenerateSafeCode10(): Code[20]
    begin
        exit(GetNextNoFromSeries('SAFE10'));
    end;

    procedure GenerateSafeCode20(): Code[20]
    begin
        exit(GetNextNoFromSeries('SAFE20'));
    end;

    local procedure GetNextNoFromSeries(FromSeries: Code[20]): Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        case FromSeries OF
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
            else
                ERROR('Get Next No %1 from number series is not configured.', FromSeries);
        end;
    end;

    local procedure SetMembershipCardDetails(var MembershipSetup: Record "NPR MM Membership Setup"; NoSeriesCode: Code[20]);
    begin

        MembershipSetup."Card Number Scheme" := MembershipSetup."Card Number Scheme"::GENERATED;
        MembershipSetup."Card Expire Date Calculation" := MembershipSetup."Card Expire Date Calculation"::DATEFORMULA;
        MembershipSetup."Card Number Prefix" := '4552';
        MembershipSetup."Card Number Length" := 25;
        MembershipSetup."Card Number Validation" := MembershipSetup."Card Number Validation"::NONE;
        MembershipSetup.VALIDATE("Card Number No. Series", NoSeriesCode);
        Evaluate(MembershipSetup."Card Number Valid Until", '<+1Y-1D>');
        MembershipSetup."Card Number Pattern" := '[S][N]';
    end;

    local procedure SetMembershipTicketDetails();
    begin
    end;

    procedure SetupCommunity_Simple(): Code[20]
    var
        MemberCommunity: Record "NPR MM Member Community";

    begin

        exit(CreateCommunitySetup(GenerateCode20(),
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


    procedure GenerateText(var Txt: Text; MaxLength: Integer)
    var
        Plain: Text;
    begin

        Plain := StrSubstNo('%1%2', Txt, UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));

        if (MaxLength <= StrLen(Plain)) then
            Txt := CopyStr(Plain, 1, MaxLength)
        else begin
            while (StrLen(Txt) + StrLen(Plain) <= MaxLength) do
                Txt += Plain;
            Txt := CopyStr(Txt + Plain, 1, MaxLength)
        end;
    end;

    procedure GenerateCode(var Cde: Code[250]; MaxLength: Integer)
        RandomText: Text[250];
    begin
        GenerateText(RandomText, MaxLength);
        Cde := UpperCase(RandomText);
    end;

    procedure GeneratePhoneNumber(var Txt: Text)
    var
        Plain: Label '+1 (212) 555-12.34', Locked = true, comment = 'ITU E.164 limits phone numbers to 15 digits. The set [+ (-.] are legal characters';
    begin
        Txt := Plain;
    end;

    procedure SetRandomMemberInfoData(VAR InfoCapture: Record "NPR MM Member Info Capture")
    begin
        Clear(InfoCapture);
        // fields are concatenated, so max length does not work when applied on the individual fields
        GenerateText(InfoCapture."First Name", 15);
        GenerateText(InfoCapture."Middle Name", 8);
        GenerateText(InfoCapture."Last Name", 20);
        GeneratePhoneNumber(InfoCapture."Phone No.");
        GenerateText(InfoCapture."Social Security No.", MaxStrLen(InfoCapture."Social Security No."));
        GenerateText(InfoCapture.Address, MaxStrLen(InfoCapture.Address));
        GenerateText(InfoCapture.City, MaxStrLen(InfoCapture.City));
        GenerateText(InfoCapture.Country, MaxStrLen(InfoCapture.Country));
        GenerateText(InfoCapture."Company Name", MaxStrLen(InfoCapture."Company Name"));
        GenerateText(InfoCapture."E-Mail Address", 50);
        InfoCapture."E-Mail Address"[3 + Random(10)] := '@';
        InfoCapture."E-Mail Address"[Strlen(InfoCapture."E-Mail Address") - 3] := '.';

        GenerateCode(InfoCapture."Post Code Code", MaxStrLen(InfoCapture."Post Code Code"));
        //GenerateCode (InfoCapture."Country Code", MaxStrLen (InfoCapture."Country Code"));
        InfoCapture."Country Code" := '';

        GenerateCode(InfoCapture."User Logon ID", MaxStrLen(InfoCapture."User Logon ID"));
        GenerateText(InfoCapture."Password SHA1", MaxStrLen(InfoCapture."Password SHA1"));

        InfoCapture.Gender := InfoCapture.Gender::OTHER;
        InfoCapture.Birthday := CalcDate('<-50Y+7D>', Today());
        InfoCapture."News Letter" := InfoCapture."News Letter"::YES;
        InfoCapture."Notification Method" := InfoCapture."Notification Method"::EMAIL;
    end;

}