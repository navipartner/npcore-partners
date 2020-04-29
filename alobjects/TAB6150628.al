table 6150628 "POS Payment Bin Checkpoint"
{
    // NPR5.36/NPKNAV/20171003  CASE 282251 Transport NPR5.36 - 3 October 2017
    // NPR5.43/TSA /20180605 CASE 311964 Added Type, "Transfer In Amount", "Transfer Out Amount"
    // NPR5.45/TSA /20180726 CASE 322769 Added field "Include In Counting"Option
    // NPR5.46/TSA /20181002 CASE 322769 Added open Auto to field "Include In Counting"
    // NPR5.47/TSA /20181018 CASE 322769 Added lookup filters to "Bank Deposit Bin Code", "Move to Bin Code"
    // NPR5.49/TSA /20190315 CASE 348458 Added "POS Unit No. Filter" to be used in the "Payment Bin Entry Amount" "Payment Bin Entry Amount (LCY)" flowfields

    Caption = 'POS Payment Bin Checkpoint';
    DataCaptionFields = "Payment Bin No.","Payment Type No.",Description;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,X-Report,Z-Report,Transfer';
            OptionMembers = NA,XREPORT,ZREPORT,TRANSFER;
        }
        field(10;"Float Amount";Decimal)
        {
            Caption = 'Float Amount';
        }
        field(20;"Counted Amount Incl. Float";Decimal)
        {
            Caption = 'Counted Amount Incl. Float';
        }
        field(25;"Counted Quantity";Decimal)
        {
            Caption = 'Counted Quantity';
        }
        field(30;"Calculated Amount Incl. Float";Decimal)
        {
            Caption = 'Calculated Amount Incl. Float';
        }
        field(35;"Calculated Quantity";Decimal)
        {
            Caption = 'Calculated Quantity';
        }
        field(40;"Bank Deposit Amount";Decimal)
        {
            Caption = 'Bank Deposit Amount';
        }
        field(41;"Bank Deposit Reference";Text[50])
        {
            Caption = 'Bank Deposit Reference';
        }
        field(42;"Bank Deposit Bin Code";Code[10])
        {
            Caption = 'Bank Deposit Bin Code';
            TableRelation = "POS Payment Bin" WHERE ("Bin Type"=CONST(BANK));
        }
        field(50;"Move to Bin Amount";Decimal)
        {
            Caption = 'Move to Bin Amount';
        }
        field(51;"Move to Bin Reference";Text[50])
        {
            Caption = 'Move to Bin Trans. ID';
        }
        field(52;"Move to Bin Code";Code[10])
        {
            Caption = 'Move to Bin No.';
            TableRelation = "POS Payment Bin" WHERE ("Bin Type"=FILTER(<>BANK&<>VIRTUAL));
        }
        field(60;"New Float Amount";Decimal)
        {
            Caption = 'New Float Amount';
        }
        field(65;"Transfer In Amount";Decimal)
        {
            Caption = 'Transfer In Amount';
        }
        field(66;"Transfer Out Amount";Decimal)
        {
            Caption = 'Transfer Out Amount';
        }
        field(70;Comment;Text[50])
        {
            Caption = 'Comment';
        }
        field(71;"Created On";DateTime)
        {
            Caption = 'Created On';
        }
        field(72;"Checkpoint Date";Date)
        {
            Caption = 'Checkpoint Date';
        }
        field(73;"Checkpoint Time";Time)
        {
            Caption = 'Checkpoint Time';
        }
        field(75;"Checkpoint Bin Entry No.";Integer)
        {
            Caption = 'Checkpoint Bin Entry No.';
            TableRelation = "POS Bin Entry";
        }
        field(90;"Include In Counting";Option)
        {
            Caption = 'Include In Counting';
            OptionCaption = 'No,Yes,Yes - Blind,Virtual';
            OptionMembers = NO,YES,BLIND,VIRTUAL;
        }
        field(100;"Payment Bin Entry Amount";Decimal)
        {
            CalcFormula = Sum("POS Bin Entry"."Transaction Amount" WHERE ("Entry No."=FIELD(UPPERLIMIT("Payment Bin Entry No. Filter")),
                                                                          "Payment Bin No."=FIELD("Payment Bin No."),
                                                                          "Payment Type Code"=FIELD("Payment Type No."),
                                                                          "POS Unit No."=FIELD("POS Unit No. Filter")));
            Caption = 'Payment Bin Entry Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101;"Payment Bin Entry Amount (LCY)";Decimal)
        {
            CalcFormula = Sum("POS Bin Entry"."Transaction Amount (LCY)" WHERE ("Entry No."=FIELD(UPPERLIMIT("Payment Bin Entry No. Filter")),
                                                                                "Payment Bin No."=FIELD("Payment Bin No."),
                                                                                "Payment Type Code"=FIELD("Payment Type No."),
                                                                                "POS Unit No."=FIELD("POS Unit No. Filter")));
            Caption = 'Payment Bin Entry Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120;"Payment Bin Entry No. Filter";Integer)
        {
            Caption = 'Payment Bin Filter';
            FieldClass = FlowFilter;
        }
        field(130;"POS Unit No. Filter";Code[10])
        {
            Caption = 'POS Unit No. Filter';
            FieldClass = FlowFilter;
        }
        field(200;"Payment Type No.";Code[10])
        {
            Caption = 'Payment Type No.';
        }
        field(210;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(220;"Payment Method No.";Code[10])
        {
            Caption = 'Payment Method No.';
        }
        field(225;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
        }
        field(230;"Payment Bin No.";Code[10])
        {
            Caption = 'Payment Bin No.';
        }
        field(240;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Work In Progress,Ready to Transfer,Transfered';
            OptionMembers = WIP,READY,TRANSFERED;
        }
        field(250;"Workshift Checkpoint Entry No.";Integer)
        {
            Caption = 'Workshift Checkpoint Entry No.';
            TableRelation = "POS Workshift Checkpoint";
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

