codeunit 85119 "NPR POS Act.CreateMember Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        InfoCapture: Record "NPR MM Member Info Capture";


    [Test]
    [HandlerFunctions('PageHandler_MemberInfoCapture')]

    procedure CreateMember()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        MembershipSalesSetupItemNumber: Code[20];
        POSActCreateMemberB: Codeunit "NPR POS Action Create Member B";
        SalePOS: Record "NPR POS Sale";
    begin
        //[GIVEN] given
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateSetup();
        //[WHEN] when
        POSActCreateMemberB.CreateMembershipWrapper(POSSale, MembershipSalesSetupItemNumber);
        POSSale.GetCurrentSale(SalePOS);
        //[THEN] then
        Assert.IsTrue(SalePOS.Name = InfoCapture."First Name" + ' ' + InfoCapture."Middle Name" + ' ' + InfoCapture."Last Name", 'Name inserted');
        Assert.IsTrue(SalePOS.Address = InfoCapture.Address, 'Address inserted');
        Assert.IsTrue(SalePOS."Post Code" = InfoCapture."Post Code Code", 'Post Code inserted.');
    end;

    [ModalPageHandler]
    procedure PageHandler_SelectMM(var SelectMembershipPage: Page "NPR MM Create Membership"; var ActionResponse: Action)
    var
        MMSalesSetup: Record "NPR MM Members. Sales Setup";
    begin
        MMSalesSetup.Get(MMSalesSetup.Type::ITEM, '320100');
        SelectMembershipPage.SetRecord(MMSalesSetup);
        ActionResponse := Action::LookupOK;
    end;

    [ModalPageHandler]
    procedure PageHandler_MemberInfoCapture(var MemberInfoCapturePage: Page "NPR MM Member Info Capture"; var ActionResponse: Action)
    var
        LibraryMemberModule: Codeunit "NPR Library - Member Module";
    begin
        LibraryMemberModule.SetRandomMemberInfoData(InfoCapture);
        InfoCapture.Validate("Phone No.", '012');
        MemberInfoCapturePage.SetRecord(InfoCapture);
        ActionResponse := Action::LookupOK;
    end;

    local procedure SelectSmokeTestScenario() ItemNo: Code[20]
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
    begin
        ItemNo := MemberLibrary.CreateScenario_SmokeTest()
    end;

    procedure CreateSetup()
    var
        Item: Record Item;
        MembershipSetup: Record "NPR MM Membership Setup";
        CreateDemoData: Codeunit "NPR MM Member Create Demo Data";
        MemberCommunity: Record "NPR MM Member Community";
        LoyaltyProgramCode: Code[20];
        Customer: Record Customer;
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);

        CreateNoSerie('MM-DEMO01', 'MM-DEMO-00001');
        CreateNoSerie('MS-DEMO01', 'MS-DEMO-00001');
        CreateNoSerie('MC-DEMO01', 'MC-DEMO-00001');

        MemberCommunity.Get(SetupCommunity_Demo('RIVERLAND', 'Riverland Sportsclub'));
        MemberCommunity."Activate Loyalty Program" := true;
        MemberCommunity.Modify();

        LoyaltyProgramCode := CreateLoyaltySetup('RLP', 'Riverland Loyalty Program', 1.0, 0.015);

        MembershipSetup.Get(CreateDemoData.SetupMembership_Demo(MemberCommunity.Code, 'GOLD', LoyaltyProgramCode, 'Gold Membership'));
        MembershipSetup."Customer Config. Template Code" := CreateDemoCustomerTemplate('MM-GOLD');
        MembershipSetup.Modify();
        AddConfigTemplateLine(MembershipSetup."Customer Config. Template Code", 0, Customer.FIELDNO("Customer Disc. Group"), CreateDiscountGroup('CDG-GOLD', 'GOLD Discount Grp.'));

        Item.Get(CreateItem('320100', '', 'GOLD Membership', 157));
        CreateDemoData.SetupSimpleMembershipSalesItem(Item."No.", 'GOLD');

        MemberCommunity."Membership to Cust. Rel." := true;
        MemberCommunity.Modify();
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

    local procedure CreateDemoCustomerTemplate(TemplateCode: Code[10]): Code[10];
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
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

        exit(ConfigTemplateHeader.Code);
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

    local procedure SetupCommunity_Demo(CommunityCode: Code[20]; NewDescription: Text[50]): Code[20]
    var
        MemberCommunity: Record "NPR MM Member Community";
    begin
        exit(CreateCommunitySetup(CommunityCode,
                MemberCommunity."External No. Search Order"::CARDNO,
                MemberCommunity."Member Unique Identity"::EMAIL,
                MemberCommunity."Create Member UI Violation"::ERROR,
                MemberCommunity."Member Logon Credentials"::MEMBER_UNIQUE_ID,
                false,
                true,
                NewDescription,
                'MS-DEMO01',
                'MM-DEMO01'));
    end;

    local procedure CreateItem(No: Code[20]; VariantCode: Code[10]; Description: Text[50]; UnitPrice: Decimal): Code[20]
    var
        TicketItem: Record "Item";
        ItemVariant: Record "Item Variant";
    begin
        TicketItem.INIT();
        if (not (TicketItem.Get(No))) then begin
            TicketItem."No." := No;
            TicketItem.Insert();
        end;

        TicketItem.Description := Description;
        TicketItem."Unit Price" := UnitPrice;
        TicketItem.Blocked := false;
        TicketItem."NPR Group sale" := false;

        TicketItem.Modify();

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

    local procedure CreateCommunitySetup(CommunityCode: Code[20]; SearchOrder: Option; UniqueIdentity: Enum "NPR MM Member Unique Identity"; UIViolation: Option; LogonCredentials: Option; CreateContacts: Boolean; CreateRenewNotification: Boolean; Description: Text[50]; MembershipNoSeries: Code[20]; MemberNoSeries: Code[20]): Code[20];
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

}