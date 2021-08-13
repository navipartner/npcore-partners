codeunit 6151240 "NPR NP Retail Headline Mgt."
{

    trigger OnRun()
    begin
        DrillDownSalesThisMonthLastYear();
    end;

    var
        MorningGreetingTxt: Label 'Good morning, %1!', Comment = '%1 is the user name. This is displayed between 00:00 and 10:59.';
        LateMorningGreetingTxt: Label 'Hi, %1!', Comment = '%1 is the user name.  This is displayed between 11:00 and 11:59.';
        NoonGreetingTxt: Label 'Hi, %1!', Comment = '%1 is the user name.  This is displayed between 12:00 and 13:59.';
        AfternoonGreetingTxt: Label 'Good afternoon, %1!', Comment = '%1 is the user name.  This is displayed between 14:00 and 18:59.';
        EveningGreetingTxt: Label 'Good evening, %1!', Comment = '%1 is the user name.  This is displayed between 19:00 and 23:59.';
        TimeOfDay: Option Morning,LateMorning,Noon,Afternoon,Evening;
        SimpleMorningGreetingTxt: Label 'Good morning!', Comment = ' This is displayed between 00:00 and 10:59.';
        SimpleLateMorningGreetingTxt: Label 'Hi!', Comment = ' This is displayed between 11:00 and 11:59.';
        SimpleNoonGreetingTxt: Label 'Hi!', Comment = ' This is displayed between 12:00 and 13:59.';
        SimpleAfternoonGreetingTxt: Label 'Good afternoon!', Comment = ' This is displayed between 14:00 and 18:59.';
        SimpleEveningGreetingTxt: Label 'Good evening!', Comment = ' This is displayed between 19:00 and 23:59.';

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
        PayloadWithoutEmphasize: Text[158];
        PayloadTagsLength: Integer;
        QualifierTagsLength: Integer;
        NpRegEx: Codeunit "NPR RegEx";
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

    procedure GetUserGreetingText(var GreetingText: Text[250])
    var
        User: Record User;
    begin
        if User.Get(UserSecurityId()) then;
        GetUserGreetingTextInternal(User."Full Name", GetTimeOfDay(), GreetingText);
    end;

    procedure GetUserGreetingTextInternal(UserName: Text[80]; CurrentTimeOfDay: Option; var GreetingText: Text[250])
    var
        UserNameFound: Boolean;
        CleanUserName: Text;
        NpRegEx: Codeunit "NPR RegEx";
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
        LimitDateTime := CreateDateTime(Today, Time - (10 * 60 * 1000)); // greet if login is in the last 10 minutes, then stop greeting
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
        DummyRecordId: RecordID;
    begin
        OnBeforeScheduleTask(CodeunitId);
        if not TaskScheduler.CanCreateTask() then
            exit;
        if not JobQueueEntry.WritePermission then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.IsEmpty then
            exit;

        JobQueueEntry.ScheduleJobQueueEntry(CodeunitId, DummyRecordId);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleTask(CodeunitId: Integer)
    begin
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Settings", 'OnBeforeLanguageChange', '', true, true)]
    local procedure OnBeforeUpdateLanguage(OldLanguageId: Integer; NewLanguageId: Integer)
    begin
        OnInvalidateHeadlines();
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Settings", 'OnBeforeWorkdateChange', '', true, true)]
    local procedure OnBeforeUpdateWorkdate(OldWorkdate: Date; NewWorkdate: Date)
    begin
        OnInvalidateHeadlines();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvalidateHeadlines()
    begin
    end;

    procedure GetTopSalesToday(var HigestTodaySales: Text[250])
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
    begin
        SalesAmt := 0;
        SalesPerson.Reset();
        if SalesPerson.FindSet() then begin
            SalesPerson.CalcFields("NPR Sales (LCY)");
            SalesAmt := SalesPerson."NPR Sales (LCY)";
            TopSalesPerson := SalesPerson.Name;
            repeat
                SalesPerson.CalcFields("NPR Sales (LCY)");
                if SalesAmt < SalesPerson."NPR Sales (LCY)" then begin
                    SalesAmt := SalesPerson."NPR Sales (LCY)";
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

    procedure GetMyPutAwayToday(var AwayPickText: Text[50])
    var
        WarehouseActivityHdr: Record "Warehouse Activity Header";
    begin
        WarehouseActivityHdr.Reset();
        WarehouseActivityHdr.SetRange(Type, WarehouseActivityHdr.Type::"Put-away");
        AwayPickText := Format(WarehouseActivityHdr.Count)
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
        SalesAmt: Decimal;
        HighestSalesAmt: Decimal;
        ValueEntry: Record "Value Entry";
    begin
        SalesAmt := 0;
        HighestSalesAmt := 0;
        SalesPerson.Reset();
        if SalesPerson.FindSet() then begin
            repeat
                ValueEntry.Reset();
                ValueEntry.SetRange("Posting Date", Today);
                ValueEntry.SetRange("Salespers./Purch. Code", SalesPerson.Code);
                IF ValueEntry.FindSet() then begin
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

    procedure GetAverageBasket(var AvgBasket: decimal)
    var
        PosEntry: Record "NPR POS Entry";
        TotalSum: Decimal;
        TotalRoundingAmt: Decimal;
        NoOfLines: Integer;
    begin
        PosEntry.Reset();
        PosEntry.SetRange("Entry Date", Today);
        PosEntry.SetRange("Post Item Entry Status", PosEntry."Post Item Entry Status"::Posted);
        NoOfLines := PosEntry.Count();

        IF PosEntry.FindSet() THEN begin
            repeat
                TotalSum += PosEntry."Amount Excl. Tax";
                TotalRoundingAmt += PosEntry."Rounding Amount (LCY)";
            until PosEntry.Next() = 0;
        END;

        IF NoOfLines > 0 THEN
            AvgBasket := (TotalSum + TotalRoundingAmt) / NoOfLines
        ELSE
            AvgBasket := 0;
    end;

    procedure GetissuedTicketToday(var AvgIssued: Text[250])
    var
        TMTicketType: Record "NPR TM Ticket";
    begin
        TMTicketType.Reset();
        TMTicketType.SetRange("Document Date", Today);
        AvgIssued := 'Ticket issued for today is ' + FORMAT(TMTicketType.Count());

    end;

    procedure GetTicketAdmissionToday(var AvgAdmission: Text[250])
    var
        TMAdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";

    begin
        TMAdmissionScheduleLines.Reset();
        AvgAdmission := 'Ticket admission for day is ' + FORMAT(TMAdmissionScheduleLines.Count());

    end;

    procedure GetMembersCreatedToday(var AvgMember: Text[250])
    var
        MMMember: Record "NPR MM Membership";
    begin

        MMMember.Reset();
        MMMember.SetRange("Issued Date", Today);
        AvgMember := 'No of new member for today is ' + FORMAT(MMMember.Count());
    end;

    procedure DrillDownSalesThisMonthLastYear()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetFilter("Document Type", '%1|%2',
          ItemLedgerEntry."Document Type"::"Sales Invoice", ItemLedgerEntry."Document Type"::"Sales Credit Memo");
        ItemLedgerEntry.SetRange("Posting Date", CalcDate('<-CY>', Today), Today);
        PAGE.Run(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;

    procedure CalcSalesThisMonthAmountLastYear(CalledFromWebService: Boolean) Amount: Decimal
    var
        ILE: Record "Item Ledger Entry";
    begin
        SetFilterForCalcSalesThisMonthAmountLastYear(ILE, CalledFromWebService);
        ILE.CalcSums("Sales Amount (Actual)");
        Amount := ILE."Sales Amount (Actual)";
    end;

    procedure SetFilterForCalcSalesThisMonthAmountLastYear(var ILE: Record "Item Ledger Entry"; CalledFromWebService: Boolean)
    begin
        ILE.SetFilter("Document Type", '%1|%2',
          ILE."Document Type"::"Sales Invoice", ILE."Document Type"::"Sales Credit Memo");

        ILE.SetRange("Posting Date", CalcDate('<-CY>', Today), Today)
    end;
}