codeunit 85107 "NPR MM Loyalty Test"
{
    Subtype = Test;

    var
        _LastMembership: Record "NPR MM Membership";
        _LastMember: Record "NPR MM Member";
        _LastMemberCard: Record "NPR MM Member Card";
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _LoyaltySetup: Record "NPR MM Loyalty Setup";
        _POSSession: Codeunit "NPR POS Session";
        _POSSale: Codeunit "NPR POS Sale";
        _Assert: Codeunit "Assert";
        _IsMembershipInitialized: Boolean;
        _isSalesInitialized: Boolean;



    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SuccessfulTest()
    var
    begin

    end;

    local procedure InitializeSales()
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        LibraryPOSMock.InitializeData(_isSalesInitialized, _POSUnit, _POSStore, _POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _POSSale);
    end;

    local procedure InitializeFixedMembershipSetup()
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        ItemLoyalty: Record "NPR MM Loy. Item Point Setup";
    begin

        if (_IsMembershipInitialized) then begin
            ItemLoyalty.SetFilter(Code, '=%1', _LoyaltySetup.Code);
            ItemLoyalty.DeleteAll();
            exit;
        end;

        _LoyaltySetup.Get(LibraryLoyalty.CreateScenario_AsYouGoLoyalty());
        _IsMembershipInitialized := true;
    end;

    local procedure CreateMembership(ItemNo: Code[20])
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";

        ResponseMessage: Text;
        MembershipEntryNo: Integer;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberEntryNo: Integer;
    begin

        // Start loyalty test scenario with a BRONZE membership
        if (not MemberApiLibrary.CreateMembership(ItemNo, MembershipEntryNo, ResponseMessage)) then
            Error(ResponseMessage);

        _LastMembership.Reset();
        _LastMembership.Get(MembershipEntryNo);
        _LastMembership.SetRecFilter();
        _LastMembership.SetAutoCalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Remaining Points", "Redeemed Points (Deposit)", "Redeemed Points (Withdrawl)", "Expired Points");
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        if (not MemberApiLibrary.AddMembershipMember(_LastMembership, MemberInfoCapture, MemberEntryNo, ResponseMessage)) then
            Error(ResponseMessage);

        _LastMember.Reset();
        _LastMember.Get(MemberEntryNo);
        _LastMember.SetRecFilter();

        _LastMemberCard.Reset();
        _LastMemberCard.SetFilter("Membership Entry No.", '=%1', _LastMembership."Entry No.");
        _LastMemberCard.SetFilter("Member Entry No.", '=%1', _LastMember."Entry No.");
        _LastMemberCard.FindFirst();
        _LastMemberCard.SetRecFilter();

    end;

    local procedure CreateItem(var Item: Record Item; UnitPrice: Decimal): Code[20]
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := UnitPrice;
        Item."Price Includes VAT" := true;
        Item.Modify();

        exit(Item."No.");
    end;

    [Normal]
    local procedure CalculateEarnPointsFromAmount(Amount: Decimal; Factor: Decimal; Quantity: Integer) Points: Integer
    var
        AwardAmount: Decimal;
    begin
        if (not _IsMembershipInitialized) then
            Error('Membership not initialized.');
        AwardAmount := Amount * Factor;
        AwardAmount *= Quantity;

        if (_LoyaltySetup."Rounding on Earning" = _LoyaltySetup."Rounding on Earning"::NEAREST) then
            Points := Round(AwardAmount, 1, '=');
        if (_LoyaltySetup."Rounding on Earning" = _LoyaltySetup."Rounding on Earning"::UP) then
            Points := Round(AwardAmount, 1, '>');
        if (_LoyaltySetup."Rounding on Earning" = _LoyaltySetup."Rounding on Earning"::DOWN) then
            Points := Round(AwardAmount, 1, '<');
    end;



    [Normal]
    local procedure SetPointsToEarn(PointsToEarn: Integer; var TempSaleLines: Record "NPR MM Reg. Sales Buffer" temporary): Integer
    begin
        TempSaleLines.FindFirst();
        TempSaleLines."Total Points" := PointsToEarn;
        TempSaleLines.Modify();
        exit(PointsToEarn);
    end;

    [Normal]
    local procedure SetScenario_100(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) LoyaltyCode: Code[20]
    var
        MembershipLibrary: Codeunit "NPR Library - Member Module";
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipSalesItem: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";

        Qty: Decimal;
        Amount: Decimal;
        Points: Integer;
        ItemNo: Code[20];
    begin
        ItemNo := LibraryLoyalty.CreateScenario_Loyalty100(TmpTransactionAuthorization, TmpRegisterSaleLines, TmpRegisterPaymentLines);


        MembershipSalesItem.Get(MembershipSalesItem.Type::ITEM, ItemNo);
        MembershipSetup.Get(MembershipSalesItem."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        CreateMembership(ItemNo);

        TmpTransactionAuthorization."Reference Number" := GenerateSafeCode20();
        TmpTransactionAuthorization."Card Number" := _LastMemberCard."External Card No.";
        TmpTransactionAuthorization.Modify();

        LibraryLoyalty.GenerateQtyAmtPointsBurn(LoyaltySetup.Code, Qty, Amount, Points);
        LibraryLoyalty.CreateSaleLine(GenerateSafeCode20(), GenerateSafeCode10(), Qty, Amount, Points, TmpRegisterSaleLines);
        LibraryLoyalty.CreatePaymentLine(Amount, 0, '', TmpRegisterPaymentLines);

        exit(LoyaltySetup.Code);
    end;


    [Normal]
    local procedure GenerateSafeCode10(): Code[10]
    var
        MembershipLibrary: Codeunit "NPR Library - Member Module";
    begin
        exit(MembershipLibrary.GenerateSafeCode10());
    end;

    [Normal]
    local procedure GenerateSafeCode20(): Code[20]
    var
        MembershipLibrary: Codeunit "NPR Library - Member Module";
    begin
        exit(MembershipLibrary.GenerateSafeCode20());
    end;



    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure IgnoreMessageHandler(Message: Text[1024])
    begin
    end;

}