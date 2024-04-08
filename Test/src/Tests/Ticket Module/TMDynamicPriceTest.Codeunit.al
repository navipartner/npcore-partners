codeunit 85047 "NPR TM Dynamic Price Test"
{
    Subtype = Test;

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
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, Today(), 0T, Rule)) then
            Error('1 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(30, Rule.LineNo, '1 - Rule selection is biased for highest line number for equivilent rules.');

        // --
        SetBookingDate(PriceProfileCode, 40, '<-10D>', '<+21D>');

        // Test 2
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, Today(), 0T, Rule)) then
            Error('2 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(30, Rule.LineNo, '2 - Rule selection is biased for highest line number for equivilent rules.');


        // --
        SetBookingDate(PriceProfileCode, 25, '<-10D>', '<+19D>');

        // Test 3
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, Today(), 0T, Rule)) then
            Error('3 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(25, Rule.LineNo, '3 - Rule selection is biased for smallest date range.');

        // Test 4
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, CalcDate('<-11D>'), 0T, Rule)) then
            Error('4 - No rule should be found on this date.');

        // Test 5
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, CalcDate('<+22D>'), 0T, Rule)) then
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

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, DateRecord."Period Start", 0T, Rule);

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

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, DateRecord."Period Start", 0T, Rule);

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

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, DateRecord."Period Start", 0T, Rule);

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

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, DateRecord."Period Start", 0T, Rule);

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

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, DateRecord."Period Start", 0T, Rule);

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
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, Today(), 0T, Rule)) then
            Error('1 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(30, Rule.LineNo, '1 - Rule selection is biased for highest line number for equivilent rules.');

        // --
        SetEventDate(PriceProfileCode, 40, '<-10D>', '<+21D>');

        // Test 2
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, Today(), 0T, Rule)) then
            Error('2 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(30, Rule.LineNo, '2 - Rule selection is biased for highest line number for equivilent rules.');


        // --
        SetEventDate(PriceProfileCode, 25, '<-10D>', '<+19D>');

        // Test 3
        if (not TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, Today(), 0T, Rule)) then
            Error('3 - TicketPrice.SelectPriceRule() failed finding a valid price rule - incorrect.');

        Assert.AreEqual(25, Rule.LineNo, '3 - Rule selection is biased for smallest date range.');

        // Test 4 
        TmpAdmScheduleEntryResponseOut."Admission Start Date" := CalcDate('<-11D>');
        TmpAdmScheduleEntryResponseOut."Admission End Date" := CalcDate('<-11D>');
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, Today(), 0T, Rule)) then
            Error('4 - No rule should be found on this date.');

        // Test 5
        TmpAdmScheduleEntryResponseOut."Admission Start Date" := CalcDate('<+22D>');
        TmpAdmScheduleEntryResponseOut."Admission End Date" := CalcDate('<+22D>');
        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, Today(), 0T, Rule)) then
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

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, DateNotRelevant, 0T, Rule);

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

            PriceRuleFound := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponseOut, DateRecord."Period Start", 0T, Rule);
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