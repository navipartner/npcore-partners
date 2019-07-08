table 6151058 "Distribution Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Lines';

    fields
    {
        field(1;"Distribution Id";Integer)
        {
            Caption = 'Distribution Id';
        }
        field(2;"Distribution Line";Integer)
        {
            Caption = 'Distribution Line';
        }
        field(5;"Distribution Group Member";Code[20])
        {
            Caption = 'Distribution Group Member';
        }
        field(6;Location;Code[10])
        {
            Caption = 'Location';
            TableRelation = Location;
        }
        field(7;"Distribution Item";Code[20])
        {
            Caption = 'Distribution Item';
            TableRelation = Item;
        }
        field(8;"Item Hiearachy";Code[20])
        {
            Caption = 'Item Hiearachy';
            TableRelation = "Item Hierarchy";
        }
        field(9;"Item Hiearachy Level";Integer)
        {
            Caption = 'Item Hiearachy Level';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(11;"Item Variant";Code[20])
        {
            Caption = 'Item Variant';
            TableRelation = "Item Variant";
        }
        field(20;"Distribution Quantity";Decimal)
        {
            Caption = 'Distribution Quantity';
        }
        field(21;"Org. Distribution Quantity";Decimal)
        {
            Caption = 'Org. Distribution Quantity';
        }
        field(30;"Distribution Cost Value (LCY)";Decimal)
        {
            Caption = 'Distribution Cost Value (LCY)';
        }
        field(40;"Avaliable Quantity";Decimal)
        {
            Caption = 'Avaliable Quantity';
        }
        field(50;"Demanded Quantity";Decimal)
        {
            Caption = 'Demanded Quantity';
        }
        field(100;"Date Created";Date)
        {
            Caption = 'Date Created';
        }
        field(101;"Date Required";Date)
        {
            Caption = 'Date Required';
        }
        field(200;"Action Required";Option)
        {
            Caption = 'Action Required';
            OptionCaption = 'Skip,Purchase,Transfer,Completed,Done';
            OptionMembers = Skip,Purchase,Transfer,Completed,Done;
        }
        field(300;"Purchase Order No.";Code[20])
        {
            Caption = 'Purchase Order No.';
            TableRelation = "Purchase Header" WHERE ("Document Type"=CONST(Order),
                                                     "No."=FIELD("Purchase Order No."));
        }
        field(301;"Purchase Order Line";Integer)
        {
            Caption = 'Purchase Order Line';
            TableRelation = "Purchase Line" WHERE ("Document Type"=CONST(Order),
                                                   "Document No."=FIELD("Purchase Order No."),
                                                   "Line No."=FIELD("Purchase Order Line"));
        }
        field(302;"Qty On PO";Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Outstanding Quantity" WHERE ("Document Type"=CONST(Order),
                                                                            "Retail Replenisment No."=FIELD("Distribution Id"),
                                                                            Type=CONST(Item),
                                                                            "No."=FIELD("Distribution Item"),
                                                                            "Location Code"=FIELD(Location)));
            Caption = 'Qty On PO';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310;"Transfer Order No.";Code[20])
        {
            Caption = 'Transfer Order No.';
        }
        field(311;"Transfer Order Line";Integer)
        {
            Caption = 'Transfer Order Line';
        }
        field(312;"Qty On Transfer";Decimal)
        {
            CalcFormula = Sum("Transfer Line"."Outstanding Quantity" WHERE ("Retail Replenisment No."=FIELD("Distribution Id"),
                                                                            "Item No."=FIELD("Distribution Item"),
                                                                            "Transfer-to Code"=FIELD(Location)));
            Caption = 'Qty On Transfer';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Distribution Id","Distribution Line")
        {
        }
        key(Key2;Location,"Distribution Item")
        {
        }
    }

    fieldgroups
    {
    }
}

