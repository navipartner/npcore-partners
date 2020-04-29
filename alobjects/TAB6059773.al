table 6059773 "Member Card Transaction Log"
{
    // NPR70.00.01.00/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR4.11/JDH/20150622  CASE 216974 Added Captions

    Caption = 'Point Card - Transaction Log';
    DrillDownPageID = "Member Card Transaction Logs";
    LookupPageID = "Member Card Transaction Logs";

    fields
    {
        field(1;"Transaction No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Transaction No.';
        }
        field(2;"Card Code";Code[20])
        {
            Caption = 'Card Code';
            TableRelation = "Member Card Issued Cards";
        }
        field(3;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(4;Points;Decimal)
        {
            Caption = 'Points';
        }
        field(5;"Remaining Points";Decimal)
        {
            Caption = 'Remaining points';
        }
        field(7;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(10;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(15;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'For debit trace puposes';
        }
        field(16;"Balancing Sales Ticket";Code[20])
        {
            Caption = 'Balancing Sales Ticket';
        }
        field(20;"Value Entry No.";Integer)
        {
            Caption = 'Value Entry No.';
        }
        field(25;Posted;Boolean)
        {
            Caption = 'Posted';
        }
        field(50;Company;Text[50])
        {
            Caption = 'Company';
        }
        field(6059800;"Sent To Web";Boolean)
        {
            Caption = 'Sent To Web';
        }
    }

    keys
    {
        key(Key1;"Transaction No.")
        {
        }
        key(Key2;"Card Code","Posting Date")
        {
            SumIndexFields = Points,"Remaining Points";
        }
        key(Key3;"Card Code","Posting Date","Remaining Points")
        {
        }
        key(Key4;"Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        PointCardIssuedCards: Record "Member Card Issued Cards";
    begin
        if "Posting Date" = 0D then
          Validate("Posting Date", WorkDate);
    end;

    trigger OnModify()
    begin
        //-NPR70.00.01.00
        //RecRef.GETTABLE(Rec);
        //xRecRef.GETTABLE(xRec);
        //Changelog.OnModify(RecRef,xRecRef);
        //+NPR70.00.01.00
    end;

    var
        TxtIllegalBalance: Label 'Balance for card %1 becomes negative. Aborting.';
}

