table 6151127 "NpIa Sale Line POS AddOn"
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn
    // NPR5.44/JDH /20180726  CASE 323366 Added table caption
    // NPR5.48/MHA /20181109  CASE 334922 Added field 32 "AddOn No."
    // NPR5.52/ALPO/20190912  CASE 354309 Possibility to fix the quantity so user would not be able to change it on sale line
    //                                    Set whether specified quantity is per unit of main item
    // NPR5.54/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization
    // NPR5.55/ALPO/20200424 CASE 401611 Remove dummy fields needed for 5.54 upgrade performace optimization

    Caption = 'Sale Line POS AddOn';

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = Register;
        }
        field(5;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(10;"Sale Type";Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(15;"Sale Date";Date)
        {
            Caption = 'Sale Date';
        }
        field(20;"Sale Line No.";Integer)
        {
            Caption = 'Sale Line No.';
        }
        field(25;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(30;"Applies-to Line No.";Integer)
        {
            Caption = 'Applies-to Line No.';
        }
        field(32;"AddOn No.";Code[20])
        {
            Caption = 'AddOn No.';
            Description = 'NPR5.48';
            TableRelation = "NpIa Item AddOn";
        }
        field(35;"AddOn Line No.";Integer)
        {
            Caption = 'AddOn Line No.';
        }
        field(40;"Fixed Quantity";Boolean)
        {
            Caption = 'Fixed Quantity';
            Description = 'NPR5.52';
        }
        field(50;"Per Unit";Boolean)
        {
            Caption = 'Per unit';
            Description = 'NPR5.52';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Type","Sale Date","Sale Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

