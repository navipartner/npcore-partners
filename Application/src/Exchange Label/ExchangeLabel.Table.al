table 6014498 "NPR Exchange Label"
{
    Caption = 'Exchange Label';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store ID"; Code[3])
        {
            Caption = 'Store ID';
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[7])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(3; Barcode; Code[13])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
        }
        field(4; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
            DataClassification = CustomerContent;
        }
        field(5; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(8; "Packaged Batch"; Boolean)
        {
            Caption = 'Packaged Batch';
            DataClassification = CustomerContent;
        }
        field(10; "Valid From"; Date)
        {
            Caption = 'Valid From';
            DataClassification = CustomerContent;
        }
        field(11; "Valid To"; Date)
        {
            Caption = 'Valid To';
            DataClassification = CustomerContent;
        }
        field(15; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(20; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "NPR POS Unit";
            DataClassification = CustomerContent;
        }
        field(21; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(22; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(23; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(24; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;
        }
        field(30; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(31; "Sales Price Incl. Vat"; Decimal)
        {
            Caption = 'Sales Price Incl. Vat';
            DataClassification = CustomerContent;
        }
        field(32; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(35; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DecimalPlaces = 2 : 2;
            Description = 'NPR5.49';
            DataClassification = CustomerContent;
        }
        field(41; "Sales Header Type"; Option)
        {
            BlankZero = true;
            Caption = 'Sales Header Type';
            OptionCaption = ',,Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = ,,Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(42; "Sales Header No."; Code[20])
        {
            Caption = 'Sales Header No.';
            DataClassification = CustomerContent;
        }
        field(50; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(60; "Printed Date"; DateTime)
        {
            Caption = 'Printed Date';
            DataClassification = CustomerContent;
        }
        field(70; "Retail Cross Reference No."; Code[50])
        {
            Caption = 'Retail Cross Reference No.';
            Description = 'NPR5.51';
            TableRelation = "NPR Retail Cross Reference"."Reference No.";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Store ID", "No.", "Batch No.")
        {
        }
        key(Key2; "Register No.", "Sales Ticket No.", "Sales Line No.")
        {
        }
        key(Key3; "Register No.", "Sales Ticket No.", "Batch No.")
        {
        }
        key(Key4; "No.")
        {
        }
        key(Key5; Barcode)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        ExchangeLabelMgt: Codeunit "NPR Exchange Label Mgt.";
    begin
        if "No." = '' then
            NoSeriesMgt.InitSeries(GetNoSeriesCode, xRec."No. Series", 0D, "No.", "No. Series");

        TestField("Store ID");

        Barcode := ExchangeLabelMgt.GetLabelBarcode(Rec);
        "Printed Date" := CurrentDateTime;
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;

    procedure GetNoSeriesCode(): Code[10]
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
    begin
        ExchangeLabelSetup.Get();
        exit(ExchangeLabelSetup."Exchange Label  No. Series");
    end;
}

