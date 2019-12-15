table 6151002 "POS Quote Entry"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added Customer fields 25, 30, 35, 40, 45, 50
    // NPR5.48/MHA /20181130  CASE 338208 Added 200 "POS Sales Data"
    // NPR5.51/MMV /20190820  CASE 364694 Added field 1010

    Caption = 'POS Quote Entry';
    DrillDownPageID = "POS Quotes";
    LookupPageID = "POS Quotes";

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Created at";DateTime)
        {
            Caption = 'Created at';
        }
        field(10;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
        }
        field(15;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            NotBlank = true;
        }
        field(20;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(25;"Customer Type";Option)
        {
            Caption = 'Customer Type';
            Description = 'NPR5.48';
            OptionCaption = 'Customer,Contact';
            OptionMembers = Customer,Contact;
        }
        field(30;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            Description = 'NPR5.48';
            TableRelation = IF ("Customer Type"=CONST(Customer)) Customer."No."
                            ELSE IF ("Customer Type"=CONST(Contact)) Contact."No.";
        }
        field(35;"Customer Price Group";Code[10])
        {
            Caption = 'Customer Price Group';
            Description = 'NPR5.48';
            TableRelation = "Customer Price Group";
        }
        field(40;"Customer Disc. Group";Code[20])
        {
            Caption = 'Customer Disc. Group';
            Description = 'NPR5.48';
            TableRelation = "Customer Discount Group";
        }
        field(45;Attention;Text[30])
        {
            Caption = 'Attention';
            Description = 'NPR5.48';
        }
        field(50;Reference;Text[30])
        {
            Caption = 'Reference';
            Description = 'NPR5.48';
        }
        field(200;"POS Sales Data";BLOB)
        {
            Caption = 'POS Sales Data';
            Description = 'NPR5.48';
        }
        field(1000;Amount;Decimal)
        {
            CalcFormula = Sum("POS Quote Line".Amount WHERE ("Quote Entry No."=FIELD("Entry No.")));
            Caption = 'Amount';
            DecimalPlaces = 2:2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005;"Amount Including VAT";Decimal)
        {
            CalcFormula = Sum("POS Quote Line"."Amount Including VAT" WHERE ("Quote Entry No."=FIELD("Entry No.")));
            Caption = 'Amount Including VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010;"Contains EFT Approval";Boolean)
        {
            CalcFormula = Exist("POS Quote Line" WHERE ("Quote Entry No."=FIELD("Entry No."),
                                                        "EFT Approved"=CONST(true)));
            Caption = 'Contains EFT Approval';
            FieldClass = FlowField;
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

    trigger OnDelete()
    var
        POSQuoteLine: Record "POS Quote Line";
    begin
        POSQuoteLine.SetRange("Quote Entry No.","Entry No.");
        //-NPR5.51 [364694]
        POSQuoteLine.DeleteAll(not SkipLineDeleteTriggerValue);
        //+NPR5.51 [364694]
    end;

    var
        SkipLineDeleteTriggerValue: Boolean;

    procedure SkipLineDeleteTrigger(Value: Boolean)
    begin
        //-NPR5.51 [364694]
        SkipLineDeleteTriggerValue := Value;
        //+NPR5.51 [364694]
    end;
}

