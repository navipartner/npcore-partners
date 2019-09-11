table 6014498 "Exchange Label"
{
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR4.10/MMV/20150527  CASE 213523 Added missing danish captions
    //                                   Added blank option value to field "Sales Header Type" IN FRONT!
    // NPR5.26/MMV /20160810 CASE 248262 Removed fields 25 & 26.
    // NPR5.26/MMV /20160802 CASE 246998 Added field 30 - Quantity.
    //                                   Added field 32 - Unit of Measure.
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.30/MMV /20170307 CASE 248985 Renamed field 8 from "Print In Label Group Batch" to "Packaged Batch".
    //                                   Renamed field 4 from "Label Group Batch" to "Batch No."
    //                                   Renamed field 3 from "Label Barcode" to "Barcode".
    //                                   Renamed field 2 from "Label No." to "No."
    // NPR5.48/JDH /20181109 CASE 334163 Added caption to missing fields
    // NPR5.49/MHA /20190211 CASE 345209 Added field 35 "Unit Price"
    // NPR5.51/ALST/20190624 CASE 337539 Added field "Retail Cross Reference No."

    Caption = 'Exchange Label';

    fields
    {
        field(1;"Store ID";Code[3])
        {
            Caption = 'Store ID';
        }
        field(2;"No.";Code[7])
        {
            Caption = 'No.';
        }
        field(3;Barcode;Code[13])
        {
            Caption = 'Barcode';
        }
        field(4;"Batch No.";Integer)
        {
            Caption = 'Batch No.';
        }
        field(5;"No. Series";Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(8;"Packaged Batch";Boolean)
        {
            Caption = 'Packaged Batch';
        }
        field(10;"Valid From";Date)
        {
            Caption = 'Valid From';
        }
        field(11;"Valid To";Date)
        {
            Caption = 'Valid To';
        }
        field(15;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(20;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = Register;
        }
        field(21;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(22;"Sales Line No.";Integer)
        {
            Caption = 'Sales Line No.';
        }
        field(23;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(24;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(30;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(31;"Sales Price Incl. Vat";Decimal)
        {
            Caption = 'Sales Price Incl. Vat';
        }
        field(32;"Unit of Measure";Code[10])
        {
            Caption = 'Unit of Measure';
        }
        field(35;"Unit Price";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DecimalPlaces = 2:2;
            Description = 'NPR5.49';
        }
        field(41;"Sales Header Type";Option)
        {
            BlankZero = true;
            Caption = 'Sales Header Type';
            OptionCaption = ',,Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = ,,Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(42;"Sales Header No.";Code[20])
        {
            Caption = 'Sales Header No.';
        }
        field(50;"Company Name";Text[50])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(60;"Printed Date";DateTime)
        {
            Caption = 'Printed Date';
        }
        field(70;"Retail Cross Reference No.";Code[50])
        {
            Caption = 'Retail Cross Reference No.';
            Description = 'NPR5.51';
            TableRelation = "Retail Cross Reference"."Reference No.";
        }
    }

    keys
    {
        key(Key1;"Store ID","No.","Batch No.")
        {
        }
        key(Key2;"Register No.","Sales Ticket No.","Sales Line No.")
        {
        }
        key(Key3;"Register No.","Sales Ticket No.","Batch No.")
        {
        }
        key(Key4;"No.")
        {
        }
        key(Key5;Barcode)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        ExchangeLabelMgt: Codeunit "Exchange Label Management";
    begin
        if "No." = '' then
          NoSeriesMgt.InitSeries(GetNoSeriesCode,xRec."No. Series",0D,"No.","No. Series");

        TestField("Store ID");

        Barcode := ExchangeLabelMgt.GetLabelBarcode(Rec);
        "Printed Date"  := CurrentDateTime;
    end;

    var
        RetailConfiguration: Record "Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    procedure GetNoSeriesCode(): Code[10]
    begin
        RetailConfiguration.Get;
        exit(RetailConfiguration."Exchange Label  No. Series");
    end;
}

