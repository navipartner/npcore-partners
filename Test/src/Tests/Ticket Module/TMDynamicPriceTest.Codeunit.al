codeunit 85047 "NPR TM Dynamic Price Test"
{
    Subtype = Test;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PriceProfileSelection()
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        AdmScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ItemPriceProfileSetup: Record "NPR TM DynamicPriceItemList";
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
    begin

        ItemNo := SelectDynamicPriceScenario();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetBookingDate(PriceProfileCode, 13, '<-10D>', '<+20D>');
        SetBookingDate(PriceProfileCode, 15, '<-10D>', '<+20D>');
        SetBookingDate(PriceProfileCode, 17, '<-10D>', '<+20D>');

        TicketApiLibrary.AdmissionCapacityCheck(GetAdmissionCode(ItemNo), Today, ItemNo, TmpAdmScheduleEntryResponseOut);
        TmpAdmScheduleEntryResponseOut.FindFirst();
        TmpAdmScheduleEntryResponseOut.TestField("Dynamic Price Profile Code", PriceProfileCode);

        // Unrelated garbage in the Item Price Profile setup table. None should be found.
        ItemPriceProfileSetup.Init();
        ItemPriceProfileSetup.ItemNo := 'FOO_BAR';
        ItemPriceProfileSetup.VariantCode := '';
        ItemPriceProfileSetup.AdmissionCode := TmpAdmScheduleEntryResponseOut."Admission Code";
        ItemPriceProfileSetup.ScheduleCode := TmpAdmScheduleEntryResponseOut."Schedule Code";
        ItemPriceProfileSetup.ItemPriceCode := 'FOO_BAR';
        ItemPriceProfileSetup.Insert();

        // Test 1
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('1 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(17, Rule.LineNo, '1 - Rule selection is biased for highest line number for equivalent rules.');


        AdmScheduleEntry.Get(TmpAdmScheduleEntryResponseOut."Entry No.");
        AdmScheduleEntry."Dynamic Price Profile Code" := '';
        AdmScheduleEntry.Modify();
        TicketApiLibrary.AdmissionCapacityCheck(GetAdmissionCode(ItemNo), Today, ItemNo, TmpAdmScheduleEntryResponseOut);

        // Test 2 - remove the price profile code from the admission schedule entry 
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('2 - TicketPrice.SelectPriceRule() found a valid price rule when none was defined - incorrect. Rule:[%1, %2]', Rule.ProfileCode, Rule.LineNo);

        // Add a price profile code item specific price profile. One should be found.
        ItemPriceProfileSetup.Init();
        ItemPriceProfileSetup.ItemNo := ItemNo;
        ItemPriceProfileSetup.VariantCode := '';
        ItemPriceProfileSetup.AdmissionCode := TmpAdmScheduleEntryResponseOut."Admission Code";
        ItemPriceProfileSetup.ScheduleCode := TmpAdmScheduleEntryResponseOut."Schedule Code";
        ItemPriceProfileSetup.ItemPriceCode := PriceProfileCode;
        ItemPriceProfileSetup.Insert();

        // Test 3
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('3 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(17, Rule.LineNo, '3 - Rule selection is biased for highest line number for equivalent rules.');

        AdmScheduleEntry.Get(TmpAdmScheduleEntryResponseOut."Entry No.");
        AdmScheduleEntry."Dynamic Price Profile Code" := 'FOO_BAR';
        AdmScheduleEntry.Modify();
        TicketApiLibrary.AdmissionCapacityCheck(GetAdmissionCode(ItemNo), Today, ItemNo, TmpAdmScheduleEntryResponseOut);

        // Test 4
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('4 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(17, Rule.LineNo, '4 - Rule selection is biased for highest line number for equivalent rules.');


        ItemPriceProfileSetup.Delete();
        // Test 5 - remove the price profile code item specific price profile, garbage in the admission schedule entry. None should be found.
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('5 - TicketPrice.SelectPriceRule() found a valid price rule when none was defined - incorrect. Rule:[%1, %2]', Rule.ProfileCode, Rule.LineNo);

    end;


    #region BookingDate
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BookingDatePriority()
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
    begin
        ItemNo := SelectDynamicPriceScenario();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetBookingDate(PriceProfileCode, 10, '<-10D>', '<+20D>');
        SetBookingDate(PriceProfileCode, 20, '<-10D>', '<+20D>');
        SetBookingDate(PriceProfileCode, 30, '<-10D>', '<+20D>');

        TicketApiLibrary.AdmissionCapacityCheck(GetAdmissionCode(ItemNo), Today, ItemNo, TmpAdmScheduleEntryResponseOut);
        TmpAdmScheduleEntryResponseOut.FindFirst();
        TmpAdmScheduleEntryResponseOut.TestField("Dynamic Price Profile Code", PriceProfileCode);

        // Test 1
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('1 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(30, Rule.LineNo, '1 - Rule selection is biased for highest line number for equivalent rules.');

        // --
        SetBookingDate(PriceProfileCode, 40, '<-10D>', '<+21D>');

        // Test 2
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('2 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(30, Rule.LineNo, '2 - Rule selection is biased for highest line number for equivalent rules.');


        // --
        SetBookingDate(PriceProfileCode, 25, '<-10D>', '<+19D>');

        // Test 3
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('3 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(25, Rule.LineNo, '3 - Rule selection is biased for smallest date range.');

        // Test 4
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', CalcDate('<-11D>'), 0T, Rule)) then
            Error('4 - No rule should be found on this date.');

        // Test 5
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', CalcDate('<+22D>'), 0T, Rule)) then
            Error('5 - No rule should be found on this date.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelativeBookingDate_D()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        DateRecord: Record Date;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
        PriceRuleFound: Boolean;
        DateNotRelevant: Date;
    begin
        ItemNo := SelectDynamicPriceScenario();
        DateNotRelevant := Today();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetRelativeBookingDate(PriceProfileCode, 1, '<D1>');
        SetRelativeBookingDate(PriceProfileCode, 15, '<D15>');
        SetRelativeBookingDate(PriceProfileCode, 28, '<D28>');
        SetRelativeBookingDate(PriceProfileCode, 29, '<D29>');
        SetRelativeBookingDate(PriceProfileCode, 31, '<D31>');

        DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
        DateRecord.SetFilter("Period Start", '%1..%2', DMY2Date(1, 1, 2024), DMY2Date(31, 12, 2024));
        DateRecord.FindSet();
        repeat
            TmpAdmScheduleEntryResponseOut."Admission Start Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Admission End Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := PriceProfileCode;

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', DateRecord."Period Start", 0T, Rule);

            case Date2DMY(DateRecord."Period Start", 1) of
                1, 15, 28, 29, 31:
                    begin
                        Assert.IsTrue(PriceRuleFound, StrSubstNo('Price rule should be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
                        Assert.AreEqual(Rule.LineNo, Date2DMY(DateRecord."Period Start", 1), 'The incorrect rule was selected.');
                    end;
                else
                    Assert.IsFalse(PriceRuleFound, StrSubstNo('Price rule should NOT be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
            end
        until (DateRecord.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelativeBookingDate_WD()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        DateRecord: Record Date;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
        PriceRuleFound: Boolean;
        DateNotRelevant: Date;
    begin
        ItemNo := SelectDynamicPriceScenario();
        DateNotRelevant := Today();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetRelativeBookingDate(PriceProfileCode, 1, '<WD1>');
        SetRelativeBookingDate(PriceProfileCode, 3, '<WD3>');
        SetRelativeBookingDate(PriceProfileCode, 5, '<WD5>');
        SetRelativeBookingDate(PriceProfileCode, 7, '<WD7>');

        DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
        DateRecord.SetFilter("Period Start", '%1..%2', DMY2Date(1, 12, 2023), DMY2Date(31, 1, 2025));
        DateRecord.FindSet();
        repeat
            TmpAdmScheduleEntryResponseOut."Admission Start Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Admission End Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := PriceProfileCode;

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', DateRecord."Period Start", 0T, Rule);

            case (DateRecord."Period No.") of
                1, 3, 5, 7:
                    begin
                        Assert.IsTrue(PriceRuleFound, StrSubstNo('Price rule should be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
                        Assert.AreEqual(Rule.LineNo, DateRecord."Period No.", 'The incorrect rule was selected.');
                    end;
                else
                    Assert.IsFalse(PriceRuleFound, StrSubstNo('Price rule should NOT be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
            end
        until (DateRecord.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelativeBookingDate_M()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        DateRecord: Record Date;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
        PriceRuleFound: Boolean;
        DateNotRelevant: Date;
    begin
        ItemNo := SelectDynamicPriceScenario();
        DateNotRelevant := Today();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetRelativeBookingDate(PriceProfileCode, 2, '<M2>'); // All of Feb
        SetRelativeBookingDate(PriceProfileCode, 5, '<M5>'); // All of May
        SetRelativeBookingDate(PriceProfileCode, 12, '<M12>'); // All of Dec

        DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
        DateRecord.SetFilter("Period Start", '%1..%2', DMY2Date(1, 12, 2023), DMY2Date(31, 1, 2025));
        DateRecord.FindSet();
        repeat
            TmpAdmScheduleEntryResponseOut."Admission Start Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Admission End Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := PriceProfileCode;

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', DateRecord."Period Start", 0T, Rule);

            case Date2DMY(DateRecord."Period Start", 2) of
                2, 5, 12:
                    Assert.IsTrue(PriceRuleFound, StrSubstNo('Price rule should be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
                else
                    Assert.IsFalse(PriceRuleFound, StrSubstNo('Price rule should NOT be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
            end
        until (DateRecord.Next() = 0);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelativeBookingDate_Q()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        DateRecord: Record Date;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
        PriceRuleFound: Boolean;
        DateNotRelevant: Date;
    begin
        ItemNo := SelectDynamicPriceScenario();
        DateNotRelevant := Today();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetRelativeBookingDate(PriceProfileCode, 3, '<Q3>');

        DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
        DateRecord.SetFilter("Period Start", '%1..%2', DMY2Date(1, 12, 2023), DMY2Date(31, 1, 2025));
        DateRecord.FindSet();
        repeat
            TmpAdmScheduleEntryResponseOut."Admission Start Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Admission End Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := PriceProfileCode;

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', DateRecord."Period Start", 0T, Rule);

            case Date2DMY(DateRecord."Period Start", 2) of
                7, 8, 9:
                    Assert.IsTrue(PriceRuleFound, StrSubstNo('Price rule should be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
                else
                    Assert.IsFalse(PriceRuleFound, StrSubstNo('Price rule should NOT be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
            end
        until (DateRecord.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelativeBookingDate_W()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        DateRecord: Record Date;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
        PriceRuleFound: Boolean;
        DateNotRelevant: Date;
    begin
        ItemNo := SelectDynamicPriceScenario();
        DateNotRelevant := Today();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetRelativeBookingDate(PriceProfileCode, 17, '<W17>');
        SetRelativeBookingDate(PriceProfileCode, 21, '<W21>');
        SetRelativeBookingDate(PriceProfileCode, 25, '<W25>');

        DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Week);
        DateRecord.SetFilter("Period Start", '%1..%2', DMY2Date(1, 12, 2023), DMY2Date(31, 1, 2025));
        DateRecord.FindSet();
        repeat
            TmpAdmScheduleEntryResponseOut."Admission Start Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Admission End Date" := DateNotRelevant;
            TmpAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := PriceProfileCode;

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', DateRecord."Period Start", 0T, Rule);

            case DateRecord."Period No." of
                17, 21, 25:
                    Assert.IsTrue(PriceRuleFound, StrSubstNo('Price rule should be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
                else
                    Assert.IsFalse(PriceRuleFound, StrSubstNo('Price rule should NOT be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
            end
        until (DateRecord.Next() = 0);
    end;
    #endregion BookingDate

    #region EventDate

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EventDatePriority()
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
    begin

        // NOTE these rules have no booking date range so they are valid for any booking date.
        // The Today() date on SelectPriceRule will have no affect on outcome.

        ItemNo := SelectDynamicPriceScenario();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetEventDate(PriceProfileCode, 10, '<-10D>', '<+20D>');
        SetEventDate(PriceProfileCode, 20, '<-10D>', '<+20D>');
        SetEventDate(PriceProfileCode, 30, '<-10D>', '<+20D>');

        TicketApiLibrary.AdmissionCapacityCheck(GetAdmissionCode(ItemNo), Today(), ItemNo, TmpAdmScheduleEntryResponseOut);
        TmpAdmScheduleEntryResponseOut.FindFirst();
        TmpAdmScheduleEntryResponseOut.TestField("Dynamic Price Profile Code", PriceProfileCode);

        // Test 1
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('1 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(30, Rule.LineNo, '1 - Rule selection is biased for highest line number for equivilent rules.');

        // --
        SetEventDate(PriceProfileCode, 40, '<-10D>', '<+21D>');

        // Test 2
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('2 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(30, Rule.LineNo, '2 - Rule selection is biased for highest line number for equivilent rules.');


        // --
        SetEventDate(PriceProfileCode, 25, '<-10D>', '<+19D>');

        // Test 3
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('3 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(25, Rule.LineNo, '3 - Rule selection is biased for smallest date range.');

        // Test 4 
        TmpAdmScheduleEntryResponseOut."Admission Start Date" := CalcDate('<-11D>');
        TmpAdmScheduleEntryResponseOut."Admission End Date" := CalcDate('<-11D>');
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('4 - No rule should be found on this date.');

        // Test 5
        TmpAdmScheduleEntryResponseOut."Admission Start Date" := CalcDate('<+22D>');
        TmpAdmScheduleEntryResponseOut."Admission End Date" := CalcDate('<+22D>');
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', Today(), 0T, Rule)) then
            Error('5 - No rule should be found on this date.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelativeEventDate_D()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        DateRecord: Record Date;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
        PriceRuleFound: Boolean;
        DateNotRelevant: Date;
    begin
        ItemNo := SelectDynamicPriceScenario();
        DateNotRelevant := Today();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetRelativeEventDate(PriceProfileCode, 1, '<D1>');
        SetRelativeEventDate(PriceProfileCode, 15, '<D15>');
        SetRelativeEventDate(PriceProfileCode, 28, '<D28>');
        SetRelativeEventDate(PriceProfileCode, 29, '<D29>');
        SetRelativeEventDate(PriceProfileCode, 31, '<D31>');

        DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
        DateRecord.SetFilter("Period Start", '%1..%2', DMY2Date(1, 1, 2024), DMY2Date(31, 12, 2024));
        DateRecord.FindSet();
        repeat
            TmpAdmScheduleEntryResponseOut."Admission Start Date" := DateRecord."Period Start";
            TmpAdmScheduleEntryResponseOut."Admission End Date" := DateRecord."Period Start";
            TmpAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := PriceProfileCode;

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', DateNotRelevant, 0T, Rule);

            case Date2DMY(DateRecord."Period Start", 1) of
                1, 15, 28, 29, 31:
                    begin
                        Assert.IsTrue(PriceRuleFound, StrSubstNo('Price rule should be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
                        Assert.AreEqual(Rule.LineNo, Date2DMY(DateRecord."Period Start", 1), 'The incorrect rule was selected.');
                    end;
                else
                    Assert.IsFalse(PriceRuleFound, StrSubstNo('Price rule should NOT be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));
            end
        until (DateRecord.Next() = 0);
    end;

    #endregion

    #region RelativeUntil

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelativeUntilEventDate()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        DateRecord: Record Date;
        TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;
        ItemNo: Code[20];
        PriceProfileCode: Code[10];
        PriceRuleFound: Boolean;
        Distance: Integer;
    begin

        ItemNo := SelectDynamicPriceScenario();

        PriceProfileCode := GetPriceProfileCode(ItemNo);
        SetRelativeUntilEventDate(PriceProfileCode, 7, '<+1W>');
        SetRelativeUntilEventDate(PriceProfileCode, 14, '<+2W>');
        SetRelativeUntilEventDate(PriceProfileCode, 21, '<+3W>');
        SetRelativeUntilEventDate(PriceProfileCode, 28, '<+4W>');
        SetRelativeUntilEventDate(PriceProfileCode, 1, '<+1D>');
        SetRelativeUntilEventDate(PriceProfileCode, 5, '<+5D>');

        DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
        DateRecord.SetFilter("Period Start", '%1..%2', CalcDate('<-5W>'), Today());
        DateRecord.FindSet();
        repeat
            TmpAdmScheduleEntryResponseOut."Admission Start Date" := Today();
            TmpAdmScheduleEntryResponseOut."Admission End Date" := Today();
            TmpAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := PriceProfileCode;

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, ItemNo, '', DateRecord."Period Start", 0T, Rule);
            Distance := Today() - DateRecord."Period Start";
            if (Distance < 29) then
                Assert.IsTrue(PriceRuleFound, StrSubstNo('Price rule should be found for this day %1.', Format(DateRecord."Period Start", 0, 9)));

            case (Distance) of
                0 .. 1:
                    Assert.AreEqual(Rule.LineNo, 1, 'The incorrect rule was selected (0..1).');
                2 .. 5:
                    Assert.AreEqual(Rule.LineNo, 5, 'The incorrect rule was selected (2..5).');
                6 .. 7:
                    Assert.AreEqual(Rule.LineNo, 7, 'The incorrect rule was selected (6..7).');
                8 .. 14:
                    Assert.AreEqual(Rule.LineNo, 14, 'The incorrect rule was selected (8..14).');
                15 .. 21:
                    Assert.AreEqual(Rule.LineNo, 21, 'The incorrect rule was selected (15..21).');
                22 .. 28:
                    Assert.AreEqual(Rule.LineNo, 28, 'The incorrect rule was selected (22..28).');
                else
                    Assert.IsFalse(PriceRuleFound, StrSubstNo('Price rule should NOT be found for this day %1. Found rule number %2. ', Format(DateRecord."Period Start", 0, 9), Rule.LineNo));
            end
        until (DateRecord.Next() = 0);
    end;

    #endregion RelativeUntil

    #region RuleArithmetic

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EvaluateRule_Percent()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        BasePrice: Decimal;
        AddonPrice: Decimal;
    begin
        // Given: a PERCENT rule with -13% adjustment, default-carrier evaluation, no VAT
        Rule.Init();
        Rule.PricingOption := Rule.PricingOption::PERCENT;
        Rule.Percentage := -13;
        Rule.AmountIncludesVAT := false;
        Rule.VatPercentage := 0;
        Rule.RoundingPrecision := 0.01;

        // When: evaluating against UnitPrice 9.11 with IsDefaultBasePrice = true
        TicketPrice.EvaluatePriceRule(Rule, 9.11, false, 0, true, BasePrice, AddonPrice);

        // Then: BasePrice carries the unit price; AddonPrice = 9.11 * -13/100 = -1.1843 -> rounds to -1.18
        Assert.AreEqual(9.11, BasePrice, 'PERCENT default-carrier: BasePrice should equal the input UnitPrice');
        Assert.AreEqual(-1.18, AddonPrice, 'PERCENT default-carrier: AddonPrice should equal UnitPrice * Percentage / 100, rounded to 0.01');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EvaluateRule_Relative()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        BasePrice: Decimal;
        AddonPrice: Decimal;
    begin
        // Given: a RELATIVE rule adding +7.29, default-carrier evaluation, no VAT
        Rule.Init();
        Rule.PricingOption := Rule.PricingOption::RELATIVE;
        Rule.Amount := 7.29;
        Rule.AmountIncludesVAT := false;
        Rule.VatPercentage := 0;
        Rule.RoundingPrecision := 0.01;

        // When: evaluating against UnitPrice 9.11 with IsDefaultBasePrice = true
        TicketPrice.EvaluatePriceRule(Rule, 9.11, false, 0, true, BasePrice, AddonPrice);

        // Then: BasePrice carries the unit price; AddonPrice = Rule.Amount = 7.29
        Assert.AreEqual(9.11, BasePrice, 'RELATIVE default-carrier: BasePrice should equal the input UnitPrice');
        Assert.AreEqual(7.29, AddonPrice, 'RELATIVE default-carrier: AddonPrice should equal Rule.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EvaluateRule_Fixed()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        BasePrice: Decimal;
        AddonPrice: Decimal;
    begin
        // Given: a FIXED rule overriding base to 47.13, default-carrier evaluation, no VAT
        Rule.Init();
        Rule.PricingOption := Rule.PricingOption::FIXED;
        Rule.Amount := 47.13;
        Rule.AmountIncludesVAT := false;
        Rule.VatPercentage := 0;
        Rule.RoundingPrecision := 0.01;

        // When: evaluating against UnitPrice 9.11 with IsDefaultBasePrice = true
        TicketPrice.EvaluatePriceRule(Rule, 9.11, false, 0, true, BasePrice, AddonPrice);

        // Then: BasePrice is overridden to Rule.Amount; AddonPrice stays 0 (FIXED replaces the base, no delta)
        Assert.AreEqual(47.13, BasePrice, 'FIXED: BasePrice should be overridden to Rule.Amount');
        Assert.AreEqual(0, AddonPrice, 'FIXED: AddonPrice should be 0 (rule replaces base)');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EvaluateRule_RelativeVatInclusive()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        Rule: Record "NPR TM Dynamic Price Rule";
        BasePrice: Decimal;
        AddonPrice: Decimal;
    begin
        // Given: RELATIVE rule with Amount 7.29 ex-VAT; UnitPrice 11.39 inc-VAT @ 25%
        //   (RELATIVE is the right rule type to exercise VAT here -- for PERCENT, the inc/ex factor
        //    cancels out and the test wouldn't catch a missing VAT round-trip.)
        Rule.Init();
        Rule.PricingOption := Rule.PricingOption::RELATIVE;
        Rule.Amount := 7.29;
        Rule.AmountIncludesVAT := false;
        Rule.VatPercentage := 0;
        Rule.RoundingPrecision := 0.01;

        // When: UnitPriceIncludesVAT = true, VAT% = 25, IsDefaultBasePrice = true
        TicketPrice.EvaluatePriceRule(Rule, 11.39, true, 25, true, BasePrice, AddonPrice);

        // Then: outputs are VAT-inclusive.
        //   BasePrice path: UnitPrice 11.39 inc -> ex 9.112 -> AddVat back -> 11.39
        //   AddonPrice path: Rule.Amount 7.29 ex -> AddVat -> 9.1125 -> rounds to 9.11 (nearest)
        Assert.AreEqual(11.39, BasePrice, 'RELATIVE VAT-inc: BasePrice should equal the inc-VAT UnitPrice (round-trip)');
        Assert.AreEqual(9.11, AddonPrice, 'RELATIVE VAT-inc: AddonPrice should equal Rule.Amount * (1 + VAT%) = 9.1125, rounded to 9.11');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CalculateScheduleEntryPrice_DefaultVsNonDefaultRequired()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Assert: Codeunit "Assert";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Rule: Record "NPR TM Dynamic Price Rule";
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        PriceProfileCode: Code[10];
        ExternalEntryNo: Integer;
        DefaultBasePrice: Decimal;
        DefaultAddonPrice: Decimal;
        NonDefaultBasePrice: Decimal;
        NonDefaultAddonPrice: Decimal;
    begin
        // Given: a clean scenario with no rules applying (clear any seeded rules so we test the no-rule fall-through path)
        ItemNo := SelectDynamicPriceScenario();
        AdmissionCode := GetAdmissionCode(ItemNo);
        PriceProfileCode := GetPriceProfileCode(ItemNo);

        Rule.SetFilter(ProfileCode, '=%1', PriceProfileCode);
        Rule.DeleteAll();

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.FindFirst();
        ExternalEntryNo := AdmissionScheduleEntry."External Schedule Entry No.";

        // Ensure the BOM is set as default carrier + REQUIRED (the standard "main ticket" config)
        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom.Default := true;
        TicketBom."Admission Inclusion" := TicketBom."Admission Inclusion"::REQUIRED;
        TicketBom.Modify();

        // When: CalculateScheduleEntryPrice for default-carrier BOM, UnitPrice = 9.11, no rule active
        TicketPrice.CalculateScheduleEntryPrice(ItemNo, '', AdmissionCode, ExternalEntryNo, 9.11, false, 0, Today(), 0T, DefaultBasePrice, DefaultAddonPrice);

        // Then: BasePrice falls through to the input UnitPrice; no addon
        Assert.AreEqual(9.11, DefaultBasePrice, 'Default carrier, no rule: BasePrice should equal the input UnitPrice (fall-through)');
        Assert.AreEqual(0, DefaultAddonPrice, 'Default carrier, no rule: AddonPrice should be 0');

        // Given: flip the BOM to non-default REQUIRED (the "secondary admission" config)
        TicketBom.Default := false;
        TicketBom.Modify();

        // When: same call, same inputs, just the Default flag flipped
        TicketPrice.CalculateScheduleEntryPrice(ItemNo, '', AdmissionCode, ExternalEntryNo, 9.11, false, 0, Today(), 0T, NonDefaultBasePrice, NonDefaultAddonPrice);

        // Then: non-default REQUIRED zeroes out BasePrice (TMDynamicPrice.al:543-544 logic);
        //       this is the load-bearing rule that lets a package carrier hold the base while other required admissions contribute 0 + their own delta
        Assert.AreEqual(0, NonDefaultBasePrice, 'Non-default REQUIRED: BasePrice should be zeroed out by the carrier-only logic');
        Assert.AreEqual(0, NonDefaultAddonPrice, 'Non-default REQUIRED, no rule: AddonPrice should be 0');
    end;

    #endregion RuleArithmetic

    [Normal]
    local procedure SetBookingDate(PriceProfileCode: Code[10]; LineNo: Integer; DateFromFormula: Text; DateUntilFormula: Text)
    var
        Rule: Record "NPR TM Dynamic Price Rule";
    begin
        if (not Rule.Get(PriceProfileCode, LineNo)) then begin
            Rule.Init();
            Rule.ProfileCode := PriceProfileCode;
            Rule.LineNo := LineNo;
            Rule.Insert();
        end;

        Rule.BookingDateFrom := EvaluateDateFormula(DateFromFormula);
        Rule.BookingDateUntil := EvaluateDateFormula(DateUntilFormula);
        Rule.Modify();
    end;

    [Normal]
    local procedure SetRelativeBookingDate(PriceProfileCode: Code[10]; LineNo: Integer; RelativeDateFormula: Text)
    var
        Rule: Record "NPR TM Dynamic Price Rule";
    begin
        if (not Rule.Get(PriceProfileCode, LineNo)) then begin
            Rule.Init();
            Rule.ProfileCode := PriceProfileCode;
            Rule.LineNo := LineNo;
            Rule.Insert();
        end;

        Evaluate(Rule.RelativeBookingDateFormula, RelativeDateFormula);
        Rule.Modify();
    end;

    [Normal]
    local procedure SetRelativeEventDate(PriceProfileCode: Code[10]; LineNo: Integer; RelativeDateFormula: Text)
    var
        Rule: Record "NPR TM Dynamic Price Rule";
    begin
        if (not Rule.Get(PriceProfileCode, LineNo)) then begin
            Rule.Init();
            Rule.ProfileCode := PriceProfileCode;
            Rule.LineNo := LineNo;
            Rule.Insert();
        end;

        Evaluate(Rule.RelativeEventDateFormula, RelativeDateFormula);
        Rule.Modify();
    end;

    [Normal]
    local procedure SetRelativeUntilEventDate(PriceProfileCode: Code[10]; LineNo: Integer; RelativeDateFormula: Text)
    var
        Rule: Record "NPR TM Dynamic Price Rule";
    begin
        if (not Rule.Get(PriceProfileCode, LineNo)) then begin
            Rule.Init();
            Rule.ProfileCode := PriceProfileCode;
            Rule.LineNo := LineNo;
            Rule.Insert();
        end;

        Evaluate(Rule.RelativeUntilEventDate, RelativeDateFormula);
        Rule.Modify();
    end;

    [Normal]
    local procedure SetEventDate(PriceProfileCode: Code[10]; LineNo: Integer; DateFromFormula: Text; DateUntilFormula: Text)
    var
        Rule: Record "NPR TM Dynamic Price Rule";
    begin
        if (not Rule.Get(PriceProfileCode, LineNo)) then begin
            Rule.Init();
            Rule.ProfileCode := PriceProfileCode;
            Rule.LineNo := LineNo;
            Rule.Insert();
        end;

        Rule.EventDateFrom := EvaluateDateFormula(DateFromFormula);
        Rule.EventDateUntil := EvaluateDateFormula(DateUntilFormula);
        Rule.Modify();
    end;

    [Normal]
    local procedure EvaluateDateFormula(Formula: Text): Date
    begin
        exit(EvaluateDateFormula(Formula, Today()));
    end;

    [Normal]

    local procedure EvaluateDateFormula(Formula: Text; ReferenceDate: Date): Date
    var
        DF: DateFormula;
    begin
        Evaluate(DF, Formula);
        exit(CalcDate(DF, ReferenceDate));
    end;

    local procedure GetAdmissionCode(ItemNo: Code[20]): Code[20]
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();
        exit(TicketBom."Admission Code");
    end;

    [Normal]
    local procedure GetPriceProfileCode(ItemNo: Code[20]): Code[10]
    var
        AdmSchLine: Record "NPR TM Admis. Schedule Lines";
    begin
        AdmSchLine.SetFilter("Admission Code", '=%1', GetAdmissionCode(ItemNo));
        AdmSchLine.FindFirst();
        exit(AdmSchLine."Dynamic Price Profile Code");
    end;

    [Normal]
    local procedure SelectDynamicPriceScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_DynamicPrice();
    end;

}