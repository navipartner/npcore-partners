table 6014670 "NPR TM Dynamic Price Rule"
{
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; ProfileCode; Code[10])
        {
            Caption = 'Profile Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Dynamic Price Profile".ProfileCode;
        }
        field(2; LineNo; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; BookingDateFrom; Date)
        {
            Caption = 'Booking Date From';
            DataClassification = CustomerContent;
        }
        field(11; BookingDateUntil; Date)
        {
            Caption = 'Booking Date Until';
            DataClassification = CustomerContent;
        }
        field(13; RelativeBookingDateFormula; DateFormula)
        {
            Caption = 'Relative Booking Date Formula';
            DataClassification = CustomerContent;
        }
        field(20; EventDateFrom; Date)
        {
            Caption = 'Event Date From';
            DataClassification = CustomerContent;
        }
        field(21; EventDateUntil; Date)
        {
            Caption = 'Event Date Until';
            DataClassification = CustomerContent;
        }
        field(23; RelativeEventDateFormula; DateFormula)
        {
            Caption = 'Relative Event Date Formula';
            DataClassification = CustomerContent;
        }
        field(30; RelativeUntilEventDate; DateFormula)
        {
            Caption = 'Relative Until Event Date';
            DataClassification = CustomerContent;
        }
        field(40; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(45; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(80; PricingOption; Option)
        {
            Caption = 'Pricing Option';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Fixed Amount,Relative Amount,Percentage';
            OptionMembers = NA,"FIXED",RELATIVE,PERCENT;
        }
        field(82; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(83; Percentage; Decimal)
        {
            Caption = 'Percentage';
            DataClassification = CustomerContent;
            MinValue = -100;
        }
        field(85; AmountIncludesVAT; Boolean)
        {
            Caption = 'Amount Includes VAT';
            DataClassification = CustomerContent;
        }
        field(86; VatPercentage; Decimal)
        {
            Caption = 'VAT Percentage';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
        field(90; RoundingPrecision; Decimal)
        {
            Caption = 'Rounding Precision';
            DataClassification = CustomerContent;
            InitValue = 0.01;
        }
        field(91; RoundingDirection; Option)
        {
            Caption = 'Rounding Direction';
            DataClassification = CustomerContent;
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }

    }
    keys
    {
        key(Key1; ProfileCode, LineNo)
        {
            Clustered = true;
        }
        key(BookingFrom; ProfileCode, BookingDateFrom, BookingDateUntil)
        {
            Unique = false;
        }
    }

    trigger OnInsert()
    var
        DynamicPriceRule: Record "NPR TM Dynamic Price Rule";
    begin
        if (LineNo = 0) then begin
            LineNo := 10000;
            DynamicPriceRule.SetCurrentKey(ProfileCode, LineNo);
            DynamicPriceRule.SetFilter(ProfileCode, '=%1', Rec.ProfileCode);
            if (DynamicPriceRule.FindLast()) then
                LineNo := DynamicPriceRule.LineNo + 10000;
        end;
    end;

    internal procedure RuleRangeSize() Length: Integer
    begin
        // The bigger the number, the wider is the date ranges and thus rule is less precise
        Length := CalcDateRangeLength(Rec.BookingDateFrom, Rec.BookingDateUntil) + CalcDateRangeLength(Rec.EventDateFrom, Rec.EventDateUntil);
    end;

    local procedure CalcDateRangeLength(DateFrom: Date; DateUntil: Date): Integer
    var
        DateRangeLabel: Label 'Error in date range, until date must be greater than from date.';
        DateMin, DateMax : Date;
    begin

        DateMin := DMY2Date(01, 01, 2000);
        DateMax := DMY2Date(31, 12, 2999);

        if ((DateUntil = 0D) or (DateUntil > DateMax)) then
            DateUntil := DateMax;

        if (DateUntil < DateMin) then
            DateUntil := DateMin;

        if ((DateFrom = 0D) or (DateMin < DateMin)) then
            DateFrom := DateMin;

        if (DateFrom > DateMax) then
            DateFrom := DateMax;

        if (DateFrom > DateUntil) then
            Error(DateRangeLabel);

        exit(DateUntil - DateFrom);
    end;

}