table 6014403 "Credit Card Transaction"
{
    // NPR5.20/BR/20160229   CASE 231481 Changed Fieldlength for text from 40 to 60, to support Pepper integration
    // NPR5.27/MMV/20161006  CASE 254376 Refactored & Renamed UdskrivBon().
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.30/TSA/20170207  CASE 263458 Added field 110 EFT Trans. Request Entry No.
    // NPR5.35/BR  /20170803 CASE 285804 Added Receipt No. so that a cut can be made between Merchant and Client tickets
    // NPR5.36/MMV /20170711 CASE 283791 Refactored function PrintTerminalReceipt();
    //                                   Deleted deprecated function BalanceRegRoutine()
    // NPR5.40/TS  /20180307 CASE 307425 Deleted Field 101
    // NPR5.43/JDH /20180702 CASE 321012 Reintroduces Field 101 (Sales Ticket amount) - some customers was using it
    // NPR5.46/MMV /20180920 CASE 290734 New EFT print flow

    Caption = 'Credit Card Transaction';
    LookupPageID = "Credit card transaction list";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            BlankZero = true;
            Caption = 'Entry No.';
        }
        field(2;Date;Date)
        {
            Caption = 'Date';
        }
        field(3;Type;Integer)
        {
            Caption = 'Type';
            MaxValue = 3;
            MinValue = 0;
        }
        field(4;"Transaction Time";Time)
        {
            Caption = 'Transaction Time';
        }
        field(5;Text;Text[60])
        {
            Caption = 'Text';
        }
        field(6;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
        }
        field(7;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(8;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(9;Telegramtype;Code[2])
        {
            Caption = 'Terminal Type';
        }
        field(10;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(100;"No. Printed";Integer)
        {
            Caption = 'No. Printed';
        }
        field(101;"Sales Ticket amount";Decimal)
        {
            CalcFormula = Sum("Audit Roll"."Amount Including VAT" WHERE ("Sale Type"=CONST(Payment),
                                                                         "Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                         "Register No."=FIELD("Register No.")));
            Caption = 'Sales Ticket amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"EFT Trans. Request Entry No.";Integer)
        {
            Caption = 'EFT Trans. Request Entry No.';
            TableRelation = "EFT Transaction Request";
        }
        field(120;"Receipt No.";Integer)
        {
            Caption = 'Receipt No.';
            Description = 'NPR5.35';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Entry No.")
        {
        }
        key(Key2;"Register No.","Sales Ticket No.",Type)
        {
        }
        key(Key3;"Register No.","Sales Ticket No.",Date)
        {
        }
        key(Key4;"Register No.","Sales Ticket No.",Date,Telegramtype)
        {
        }
        key(Key5;Date)
        {
        }
        key(Key6;"EFT Trans. Request Entry No.","Receipt No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure PrintTerminalReceipt()
    var
        RetailFormCode: Codeunit "Retail Form Code";
        RetailReportSelMgt: Codeunit "Retail Report Selection Mgt.";
        ReportSelectionRetail: Record "Report Selection Retail";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        //-NPR5.46 [290734]
        //RetailReportSelMgt.SetRequestWindow(VisAnfordring);
        //+NPR5.46 [290734]
        RetailReportSelMgt.SetRegisterNo(RetailFormCode.FetchRegisterNumber() );
        RetailReportSelMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Terminal Receipt");

        //-NPR5.46 [290734]
        // IF FINDSET(TRUE) THEN BEGIN
        //  REPEAT
        //    "No. Printed" += 1;
        //    MODIFY;
        //  UNTIL NEXT = 0;
        //  COMMIT;
        // END;
        //+NPR5.46 [290734]
    end;
}

