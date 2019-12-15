table 6150638 "POS Payment Bin Denomination"
{
    // NPR5.48/TSA /20190111 CASE 339571 Persistant storage for counted denominations

    Caption = 'POS Payment Bin Denomination';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
        }
        field(10;Denomination;Decimal)
        {
            Caption = 'Denomination';
        }
        field(20;Amount;Decimal)
        {
            Caption = 'Amount';
        }
        field(30;Quantity;Integer)
        {
            Caption = 'Quantity';
        }
        field(200;"Payment Type No.";Code[10])
        {
            Caption = 'Payment Type No.';
            TableRelation = "Payment Type POS"."No.";
        }
        field(220;"Payment Method No.";Code[10])
        {
            Caption = 'Payment Method No.';
        }
        field(245;"Bin Checkpoint Entry No.";Integer)
        {
            Caption = 'Bin Checkpoint Entry No.';
            TableRelation = "POS Payment Bin Checkpoint";
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
        key(Key2;"Bin Checkpoint Entry No.")
        {
        }
        key(Key3;"Workshift Checkpoint Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

