﻿codeunit 6151240 "NPR NP Retail Headline Mgt."
{
    Access = Internal;

    trigger OnRun()
    begin
        DrillDownSalesThisMonthLastYear();
    end;

    var
        TimeOfDay: Option Morning,LateMorning,Noon,Afternoon,Evening;
        AfternoonGreetingTxt: Label 'Good afternoon, %1!', Comment = '%1 is the user name.  This is displayed between 14:00 and 18:59.';
        EveningGreetingTxt: Label 'Good evening, %1!', Comment = '%1 is the user name.  This is displayed between 19:00 and 23:59.';
        LateMorningGreetingTxt: Label 'Hi, %1!', Comment = '%1 is the user name.  This is displayed between 11:00 and 11:59.';
        MorningGreetingTxt: Label 'Good morning, %1!', Comment = '%1 is the user name. This is displayed between 00:00 and 10:59.';
        NoonGreetingTxt: Label 'Hi, %1!', Comment = '%1 is the user name.  This is displayed between 12:00 and 13:59.';
        SimpleAfternoonGreetingTxt: Label 'Good afternoon!', Comment = ' This is displayed between 14:00 and 18:59.';
        SimpleEveningGreetingTxt: Label 'Good evening!', Comment = ' This is displayed between 19:00 and 23:59.';
        SimpleLateMorningGreetingTxt: Label 'Hi!', Comment = ' This is displayed between 11:00 and 11:59.';
        SimpleMorningGreetingTxt: Label 'Good morning!', Comment = ' This is displayed between 00:00 and 10:59.';
        SimpleNoonGreetingTxt: Label 'Hi!', Comment = ' This is displayed between 12:00 and 13:59.';

    procedure Truncate(TextToTruncate: Text; MaxLength: Integer): Text
    begin
        if StrLen(TextToTruncate) <= MaxLength then
            exit(TextToTruncate);

        if MaxLength <= 0 then
            exit('');

        if MaxLength <= 3 then
            exit(CopyStr(TextToTruncate, 1, MaxLength));

        exit(CopyStr(TextToTruncate, 1, MaxLength - 3) + '...');
    end;

    procedure Emphasize(TextToEmphasize: Text): Text
    var
        EmphasizeLbl: Label '<emphasize>%1</emphasize>', locked = true;
    begin
        if TextToEmphasize <> '' then
            exit(StrSubstNo(EmphasizeLbl, TextToEmphasize));
    end;

    procedure GetHeadlineText(Qualifier: Text; Payload: Text; var ResultText: Text[250]): Boolean
    var
        NpRegEx: Codeunit "NPR RegEx";
        PayloadTagsLength: Integer;
        QualifierTagsLength: Integer;
        PayloadWithoutEmphasize: Text;
    begin
        QualifierTagsLength := 23;
        PayloadTagsLength := 19;

        if StrLen(Qualifier) + StrLen(Payload) > 250 - QualifierTagsLength - PayloadTagsLength then
            exit(false); // this won't fit

        if Payload = '' then
            exit(false); // payload should not be empty

        if StrLen(Qualifier) > GetMaxQualifierLength() then
            exit(false); // qualifier is too long to be a qualifier

        PayloadWithoutEmphasize := NpRegEx.Replace(Payload, '<emphasize>|</emphasize>', '');
        if StrLen(PayloadWithoutEmphasize) > GetMaxPayloadLength() then
            exit(false); // payload is too long for being a headline

        ResultText := CopyStr(GetQualifierText(Qualifier) + GetPayloadText(Payload), 1, MaxStrLen(ResultText));
        exit(true);
    end;

    local procedure GetPayloadText(PayloadText: Text): Text
    var
        PayloadLbl: Label '<payload>%1</payload>', locked = true;
    begin
        if PayloadText <> '' then
            exit(StrSubstNo(PayloadLbl, PayloadText));
    end;

    local procedure GetQualifierText(QualifierText: Text): Text
    var
        QualifierLbl: Label '<qualifier>%1</qualifier>', locked = true;
    begin
        if QualifierText <> '' then
            exit(StrSubstNo(QualifierLbl, QualifierText));
    end;

    procedure GetUserGreetingText(var GreetingText: Text)
    var
        User: Record User;
    begin
        if User.Get(UserSecurityId()) then;
        GetUserGreetingTextInternal(User."Full Name", GetTimeOfDay(), GreetingText);
    end;

    procedure GetUserGreetingTextInternal(UserName: Text[80]; CurrentTimeOfDay: Option; var GreetingText: Text)
    var
        NpRegEx: Codeunit "NPR RegEx";
        UserNameFound: Boolean;
        CleanUserName: Text;
    begin
        if UserName <> '' then begin
            CleanUserName := NpRegEx.Replace(UserName, '\s', '');
            UserNameFound := CleanUserName <> '';
        end;

        case CurrentTimeOfDay of
            TimeOfDay::Morning:
                if UserNameFound then
                    GreetingText := StrSubstNo(MorningGreetingTxt, UserName)
                else
                    GreetingText := SimpleMorningGreetingTxt;
            TimeOfDay::LateMorning:
                if UserNameFound then
                    GreetingText := StrSubstNo(LateMorningGreetingTxt, UserName)
                else
                    GreetingText := SimpleLateMorningGreetingTxt;
            TimeOfDay::Noon:
                if UserNameFound then
                    GreetingText := StrSubstNo(NoonGreetingTxt, UserName)
                else
                    GreetingText := SimpleNoonGreetingTxt;
            TimeOfDay::Afternoon:
                if UserNameFound then
                    GreetingText := StrSubstNo(AfternoonGreetingTxt, UserName)
                else
                    GreetingText := SimpleAfternoonGreetingTxt;
            TimeOfDay::Evening:
                if UserNameFound then
                    GreetingText := StrSubstNo(EveningGreetingTxt, UserName)
                else
                    GreetingText := SimpleEveningGreetingTxt;
        end
    end;

    local procedure GetTimeOfDay(): Integer
    var
        TypeHelper: Codeunit "Type Helper";
        TimezoneOffset: Duration;
        Hour: Integer;
    begin
        if not TypeHelper.GetUserTimezoneOffset(TimezoneOffset) then
            TimezoneOffset := 0;

        Evaluate(Hour, TypeHelper.FormatUtcDateTime(TypeHelper.GetCurrUTCDateTime(), 'HH', ''));
        Hour += TimezoneOffset div (60 * 60 * 1000);

        case Hour of
            0 .. 10:
                exit(TimeOfDay::Morning);
            11:
                exit(TimeOfDay::LateMorning);
            12 .. 13:
                exit(TimeOfDay::Noon);
            14 .. 18:
                exit(TimeOfDay::Afternoon);
            19 .. 23:
                exit(TimeOfDay::Evening);
        end;
    end;

    procedure ShouldUserGreetingBeVisible(): Boolean
    var
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        LimitDateTime: DateTime;
    begin
        LimitDateTime := CreateDateTime(Today, Time - (1 * 60 * 1000)); // greet if login is in the last 10 minutes, then stop greeting
        exit(UserLoginTimeTracker.UserLoggedInSinceDateTime(LimitDateTime));
    end;

    procedure GetMaxQualifierLength(): Integer
    begin
        exit(50);
    end;

    procedure GetMaxPayloadLength(): Integer
    begin
        exit(75);
    end;

    procedure ScheduleTask(CodeunitId: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecordId: RecordId;
    begin
        OnBeforeScheduleTask(CodeunitId);
        if not TaskScheduler.CanCreateTask() then
            exit;
        if not JobQueueEntry.WritePermission then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.ScheduleJobQueueEntry(CodeunitId, DummyRecordId);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleTask(CodeunitId: Integer)
    begin
    end;

    procedure GetTopSalesToday(var HigestTodaySales: Text)
    var
        POSEntry: Record "NPR POS Entry";
        SalesAmt: Decimal;
    begin
        POSEntry.Reset();
        POSEntry.SetFilter("Entry Date", '=%1', Today);
        if POSEntry.FindSet() then begin
            SalesAmt := POSEntry."Item Sales (LCY)";
            repeat
                if SalesAmt < POSEntry."Item Sales (LCY)" then
                    SalesAmt := POSEntry."Item Sales (LCY)";
            until POSEntry.Next() = 0;
            HigestTodaySales := Format(SalesAmt);
        end;
    end;

    procedure GetTopSalesPersonToday(var TopSalesPerson: Text[50])
    var
        SalesPerson: Record "Salesperson/Purchaser";
        SalesAmt: Decimal;
        SalesLCY: Decimal;
    begin
        SalesAmt := 0;
        SalesPerson.Reset();
        if SalesPerson.FindSet() then begin
            SalesPerson.NPRGetVESalesLCY(SalesLCY);
            SalesAmt := SalesLCY;
            TopSalesPerson := SalesPerson.Name;
            repeat
                SalesPerson.NPRGetVESalesLCY(SalesLCY);
                if SalesAmt < SalesLCY then begin
                    SalesAmt := SalesLCY;
                    TopSalesPerson := SalesPerson.Name;
                end;
            until SalesPerson.Next() = 0;
        end;
    end;

    procedure GetMyPickToday(var MyPickText: Text[250])
    var
        WarehouseActivityHdr: Record "Warehouse Activity Header";
    begin
        WarehouseActivityHdr.Reset();
        WarehouseActivityHdr.SetRange(Type, WarehouseActivityHdr.Type::Pick);
        MyPickText := Format(WarehouseActivityHdr.Count());
    end;

    procedure GetMyPutAwayToday(var AwayPickText: Text)
    var
        WarehouseActivityHdr: Record "Warehouse Activity Header";
    begin
        WarehouseActivityHdr.Reset();
        WarehouseActivityHdr.SetRange(Type, WarehouseActivityHdr.Type::"Put-away");
        AwayPickText := Format(WarehouseActivityHdr.Count())
    end;

    procedure GetHighestPOSSalesText(var highestPOSSales: Text)
    var
        POSEntry: Record "NPR POS Entry";
        SalesAmt: Decimal;
    begin
        POSEntry.Reset();
        POSEntry.SetFilter("Entry Type", '%1', POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetFilter("Entry Date", '%1', TODAY);
        if POSEntry.FindSet() then begin
            SalesAmt := POSEntry."Amount Excl. Tax";
            repeat
                if SalesAmt < POSEntry."Amount Excl. Tax" then
                    SalesAmt := POSEntry."Amount Excl. Tax";
            until POSEntry.Next() = 0;
            highestPOSSales := Format(SalesAmt);
        end else
            highestPOSSales := '0.00';
    end;

    procedure GetHighestSalesInvText(var highestSalesInv: Text)
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SalesAmt: Decimal;
    begin
        SalesInvHdr.Reset();
        SalesInvHdr.SetFilter(SalesInvHdr."Posting Date", '=%1', TODAY);
        if SalesInvHdr.FindSet() then begin
            SalesInvHdr.CalcFields(Amount);
            SalesAmt := SalesInvHdr.Amount;
            repeat
                SalesInvHdr.CalcFields(Amount);
                if SalesAmt < SalesInvHdr."Amount" then
                    SalesAmt := SalesInvHdr."Amount";
            until SalesInvHdr.Next() = 0;
            highestSalesInv := Format(SalesAmt);
        end else
            highestSalesInv := '0.00';
    end;

    procedure GetTopSalesPersonText(var TopSalesPersonText: Text)
    var
        SalesPerson: Record "Salesperson/Purchaser";
        ValueEntry: Record "Value Entry";
        HighestSalesAmt: Decimal;
        SalesAmt: Decimal;
    begin
        SalesAmt := 0;
        HighestSalesAmt := 0;
        SalesPerson.Reset();
        if SalesPerson.FindSet() then begin
            repeat
                ValueEntry.Reset();
                ValueEntry.SetRange("Posting Date", Today);
                ValueEntry.SetRange("Salespers./Purch. Code", SalesPerson.Code);
                if ValueEntry.FindSet() then begin
                    repeat
                        SalesAmt += ValueEntry."Sales Amount (Actual)";
                    until ValueEntry.Next() = 0;
                    if SalesAmt > HighestSalesAmt then begin
                        HighestSalesAmt := SalesAmt;
                        TopSalesPersonText := SalesPerson.Name;
                    end;
                end;
            until SalesPerson.Next() = 0;
        end;
    end;

    procedure GetAverageBasket(var AvgBasket: Decimal)
    var
        PosEntry: Record "NPR POS Entry";
        TotalRoundingAmt: Decimal;
        TotalSum: Decimal;
        NoOfLines: Integer;
    begin
        PosEntry.Reset();
        PosEntry.SetRange("Entry Date", Today);
        PosEntry.SetRange("Post Item Entry Status", PosEntry."Post Item Entry Status"::Posted);
        NoOfLines := PosEntry.Count();

        if PosEntry.FindSet() then begin
            repeat
                TotalSum += PosEntry."Amount Excl. Tax";
                TotalRoundingAmt += PosEntry."Rounding Amount (LCY)";
            until PosEntry.Next() = 0;
        end;

        if NoOfLines > 0 then
            AvgBasket := (TotalSum + TotalRoundingAmt) / NoOfLines
        else
            AvgBasket := 0;
    end;

    procedure GetIssuedTicketToday(var AvgIssued: Text[250])
    var
        Ticket: Record "NPR TM Ticket";
        TicketCountLabel: Label 'Tickets issued today: %1';
    begin
        Ticket.Reset();
        Ticket.SetCurrentKey("Document Date");
        Ticket.SetFilter("Document Date", '=%1', Today());
        AvgIssued := StrSubstNo(TicketCountLabel, Format(Ticket.Count()));
    end;

    procedure GetMembersCreatedToday(var AvgMember: Text[250])
    var
        Membership: Record "NPR MM Membership";
        MemberCountLabel: Label 'Memberships activated today: %1';
    begin
        Membership.Reset();
        Membership.SetCurrentKey("Issued Date");
        Membership.SetFilter("Issued Date", '=%1', Today());
        AvgMember := StrSubstNo(MemberCountLabel, Format(Membership.Count()));
    end;

    procedure DrillDownSalesThisMonthLastYear()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetFilter("Document Type", '%1|%2',
          ItemLedgerEntry."Document Type"::"Sales Invoice", ItemLedgerEntry."Document Type"::"Sales Credit Memo");
        ItemLedgerEntry.SetRange("Posting Date", CalcDate('<-CY>', Today), Today);
        Page.Run(Page::"Item Ledger Entries", ItemLedgerEntry);
    end;

    procedure CalcSalesThisMonthAmountLastYear(CalledFromWebService: Boolean) Amount: Decimal
    var
        RetailHeadlineSales: Query "NPR Retail Headline Sales";
    begin
        SetFilterForCalcSalesThisMonthAmountLastYear(RetailHeadlineSales, CalledFromWebService);

        RetailHeadlineSales.Open();
        while RetailHeadlineSales.Read() do
            Amount += RetailHeadlineSales.SalesAmountActual;
        RetailHeadlineSales.Close();
    end;

    procedure SetFilterForCalcSalesThisMonthAmountLastYear(var RetailHeadlineSales: Query "NPR Retail Headline Sales"; CalledFromWebService: Boolean)
    var
        ItemLedgerDocumentType: Enum "Item Ledger Document Type";
    begin
        RetailHeadlineSales.SetFilter(DocumentType, '%1|%2', ItemLedgerDocumentType::"Sales Invoice", ItemLedgerDocumentType::"Sales Credit Memo");
        RetailHeadlineSales.SetRange(PostingDate, CalcDate('<-CY>', Today()), Today());
    end;
}