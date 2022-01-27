table 6150628 "NPR POS Payment Bin Checkp."
{
    Caption = 'POS Payment Bin Checkpoint';
    DataClassification = CustomerContent;
    DataCaptionFields = "Payment Bin No.", "Payment Type No.", Description;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,X-Report,Z-Report,Transfer';
            OptionMembers = NA,XREPORT,ZREPORT,TRANSFER;
        }
        field(10; "Float Amount"; Decimal)
        {
            Caption = 'Float Amount';
            DataClassification = CustomerContent;
        }
        field(20; "Counted Amount Incl. Float"; Decimal)
        {
            Caption = 'Counted Amount Incl. Float';
            DataClassification = CustomerContent;
        }
        field(25; "Counted Quantity"; Decimal)
        {
            Caption = 'Counted Quantity';
            DataClassification = CustomerContent;
        }
        field(30; "Calculated Amount Incl. Float"; Decimal)
        {
            Caption = 'Calculated Amount Incl. Float';
            DataClassification = CustomerContent;
        }
        field(35; "Calculated Quantity"; Decimal)
        {
            Caption = 'Calculated Quantity';
            DataClassification = CustomerContent;
        }
        field(40; "Bank Deposit Amount"; Decimal)
        {
            Caption = 'Bank Deposit Amount';
            DataClassification = CustomerContent;
        }
        field(41; "Bank Deposit Reference"; Text[50])
        {
            Caption = 'Bank Deposit Reference';
            DataClassification = CustomerContent;
        }
        field(42; "Bank Deposit Bin Code"; Code[10])
        {
            Caption = 'Bank Deposit Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin" WHERE("Bin Type" = CONST(BANK));
        }
        field(50; "Move to Bin Amount"; Decimal)
        {
            Caption = 'Move to Bin Amount';
            DataClassification = CustomerContent;
        }
        field(51; "Move to Bin Reference"; Text[50])
        {
            Caption = 'Move to Bin Trans. ID';
            DataClassification = CustomerContent;
        }
        field(52; "Move to Bin Code"; Code[10])
        {
            Caption = 'Move to Bin No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin" WHERE("Bin Type" = FILTER(<> BANK & <> VIRTUAL));
        }
        field(60; "New Float Amount"; Decimal)
        {
            Caption = 'New Float Amount';
            DataClassification = CustomerContent;
        }
        field(65; "Transfer In Amount"; Decimal)
        {
            Caption = 'Transfer In Amount';
            DataClassification = CustomerContent;
        }
        field(66; "Transfer Out Amount"; Decimal)
        {
            Caption = 'Transfer Out Amount';
            DataClassification = CustomerContent;
        }
        field(70; Comment; Text[50])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(71; "Created On"; DateTime)
        {
            Caption = 'Created On';
            DataClassification = CustomerContent;
        }
        field(72; "Checkpoint Date"; Date)
        {
            Caption = 'Checkpoint Date';
            DataClassification = CustomerContent;
        }
        field(73; "Checkpoint Time"; Time)
        {
            Caption = 'Checkpoint Time';
            DataClassification = CustomerContent;
        }
        field(75; "Checkpoint Bin Entry No."; Integer)
        {
            Caption = 'Checkpoint Bin Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Bin Entry";
        }
        field(90; "Include In Counting"; Option)
        {
            Caption = 'Include In Counting';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes,Yes - Blind,Virtual';
            OptionMembers = NO,YES,BLIND,VIRTUAL;
        }
        field(100; "Payment Bin Entry Amount"; Decimal)
        {
            CalcFormula = Sum("NPR POS Bin Entry"."Transaction Amount" WHERE("Entry No." = FIELD(UPPERLIMIT("Payment Bin Entry No. Filter")),
                                                                          "Payment Bin No." = FIELD("Payment Bin No."),
                                                                          "Payment Type Code" = FIELD("Payment Type No."),
                                                                          "POS Unit No." = FIELD("POS Unit No. Filter")));
            Caption = 'Payment Bin Entry Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Payment Bin Entry Amount (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Bin Entry"."Transaction Amount (LCY)" WHERE("Entry No." = FIELD(UPPERLIMIT("Payment Bin Entry No. Filter")),
                                                                                "Payment Bin No." = FIELD("Payment Bin No."),
                                                                                "Payment Type Code" = FIELD("Payment Type No."),
                                                                                "POS Unit No." = FIELD("POS Unit No. Filter")));
            Caption = 'Payment Bin Entry Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Payment Bin Entry No. Filter"; Integer)
        {
            Caption = 'Payment Bin Filter';
            FieldClass = FlowFilter;
        }
        field(130; "POS Unit No. Filter"; Code[10])
        {
            Caption = 'POS Unit No. Filter';
            FieldClass = FlowFilter;
        }
        field(200; "Payment Type No."; Code[10])
        {
            Caption = 'Payment Type No.';
            DataClassification = CustomerContent;
        }
        field(210; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(220; "Payment Method No."; Code[10])
        {
            Caption = 'Payment Method No.';
            DataClassification = CustomerContent;
        }
        field(225; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(230; "Payment Bin No."; Code[10])
        {
            Caption = 'Payment Bin No.';
            DataClassification = CustomerContent;
        }
        field(240; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Work In Progress,Ready to Transfer,Transfered';
            OptionMembers = WIP,READY,TRANSFERED;
        }
        field(250; "Workshift Checkpoint Entry No."; Integer)
        {
            Caption = 'Workshift Checkpoint Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Workshift Checkpoint";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Workshift Checkpoint Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

