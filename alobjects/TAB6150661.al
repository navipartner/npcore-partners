table 6150661 "NPRE Waiter Pad Line"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.35/JDH /20170828 CASE 288314 Changed field Unit of Measure code from Text10 to Code10
    // NPR5.41/JDH /20180427 CASE 313106 Removed unused Vars

    Caption = 'Waiter Pad Line';

    fields
    {
        field(1;"Waiter Pad No.";Code[20])
        {
            Caption = 'Waiter Pad No.';
            Description = 'Key';
            TableRelation = "NPRE Waiter Pad"."No.";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
            Description = 'Key';
        }
        field(5;"Sent To. Kitchen Print";Boolean)
        {
            Caption = 'Sent To. Kitchen Print';
        }
        field(6;"Print Category";Code[10])
        {
            Caption = 'Print Category';
            TableRelation = "NPRE Print Category".Code;
        }
        field(11;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
        }
        field(14;"Start Date";Date)
        {
            Caption = 'Start Date';
        }
        field(15;"Start Time";Time)
        {
            Caption = 'Start Time';
        }
        field(20;"Marked Qty";Decimal)
        {
            Caption = 'Qty. to ticket';
            DecimalPlaces = 0:5;
            Description = 'Only used in temp mode';
            MaxValue = 99.999;
        }
        field(29;"Amount Excl. VAT";Decimal)
        {
            Caption = 'Amount Excl. VAT';
        }
        field(30;"Amount Incl. VAT";Decimal)
        {
            Caption = 'Amount Incl. VAT';
        }
        field(40;"Meal Flow";Code[10])
        {
            Caption = 'Meal Flow';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=CONST(WaiterPadLineMealFlow));
        }
        field(41;"Meal Flow Description";Text[50])
        {
            CalcFormula = Lookup("NPRE Flow Status".Description WHERE (Code=FIELD("Meal Flow")));
            Caption = 'Meal Flow Description';
            FieldClass = FlowField;
        }
        field(42;"Meal Flow Order";Integer)
        {
            CalcFormula = Lookup("NPRE Flow Status"."Flow Order" WHERE (Code=FIELD("Meal Flow")));
            Caption = 'Meal Flow Order';
            FieldClass = FlowField;
        }
        field(45;"Line Status";Code[10])
        {
            Caption = 'Line Status';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=CONST(WaiterPadLineStatus));
        }
        field(46;"Line Status Description";Text[50])
        {
            CalcFormula = Lookup("NPRE Flow Status".Description WHERE (Code=FIELD("Line Status")));
            Caption = 'Line Status Description';
            FieldClass = FlowField;
        }
        field(50;Type;Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Item Group,Repair,,Payment,Open/Close,Inventory,Customer,Comment';
            OptionMembers = "G/L Entry",Item,"Item Group",Repair,,Payment,"Open/Close","BOM List",Customer,Comment;
        }
        field(51;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST("G/L Entry")) "G/L Account"."No."
                            ELSE IF (Type=CONST("Item Group")) "Item Group"."No."
                            ELSE IF (Type=CONST(Repair)) "Customer Repair"."No."
                            ELSE IF (Type=CONST(Payment)) "Payment Type POS"."No." WHERE (Status=CONST(Active),
                                                                                          "Via Terminal"=CONST(false))
                                                                                          ELSE IF (Type=CONST(Customer)) Customer."No."
                                                                                          ELSE IF (Type=CONST(Item)) Item."No.";
            ValidateTableRelation = false;
        }
        field(52;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(53;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
            MaxValue = 99.999;
        }
        field(54;Marked;Boolean)
        {
            Caption = 'Marked';
            Description = 'Only used in temp mode';
        }
        field(55;"Sale Type";Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(56;"Description 2";Text[50])
        {
            Caption = 'Description 2';
            Description = 'NPR5.23';
        }
        field(57;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("No."));
        }
        field(58;"Order No. from Web";Code[20])
        {
            Caption = 'Order No. from Web';
        }
        field(59;"Order Line No. from Web";Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No. from Web';
        }
        field(60;"Unit Price";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DecimalPlaces = 2:2;
            Editable = true;
            MaxValue = 9.999.999;
        }
        field(61;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            Description = 'NPR5.30';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }
        field(62;"Discount Code";Code[20])
        {
            Caption = 'Discount Code';
        }
        field(63;"Allow Invoice Discount";Boolean)
        {
            Caption = 'Allow Invoice Discount';
            InitValue = true;
        }
        field(64;"Allow Line Discount";Boolean)
        {
            Caption = 'Allow Line Discount';
            InitValue = true;
        }
        field(65;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0:1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(66;"Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Discount';
            MinValue = 0;
        }
        field(67;"Invoice Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
        }
        field(68;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(69;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No."=FIELD("No."));
        }
    }

    keys
    {
        key(Key1;"Waiter Pad No.","Line No.")
        {
        }
        key(Key2;"Waiter Pad No.","Print Category","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        BongLine: Record "NPRE Waiter Pad Line";
    begin

        BongLine.Reset;
        BongLine.SetRange("Waiter Pad No.", Rec."Waiter Pad No.");
        if BongLine.IsEmpty then begin
          "Line No." := 10000;
        end else begin
          BongLine.FindLast;
          "Line No." := BongLine."Line No." + 10000;
        end;
    end;
}

