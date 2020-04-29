table 6151394 "CS Item Reclass. Handling"
{
    // NPR5.50/CLVA/20190527  CASE 355694 Object created

    Caption = 'CS Warehouse Shipment Handling';

    fields
    {
        field(1;Id;Code[10])
        {
            Caption = 'Id';
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(3;"Unit of Measure";Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(10;Barcode;Text[30])
        {
            Caption = 'Barcode';
        }
        field(11;Qty;Decimal)
        {
            Caption = 'Qty';
            InitValue = 1;
        }
        field(12;"Journal Template Name";Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Item Journal Template";
        }
        field(13;"Journal Batch Name";Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Item Journal Batch".Name WHERE ("Journal Template Name"=FIELD("Journal Template Name"));
        }
        field(14;"Zone Code";Code[10])
        {
            Caption = 'Zone Code';
            TableRelation = Zone.Code WHERE ("Location Code"=FIELD("Location Code"));
        }
        field(21;"No.";Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(22;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(23;"Shelf No.";Code[10])
        {
            Caption = 'Shelf No.';
        }
        field(26;"Bin Code";Code[20])
        {
            Caption = 'Bin Code';

            trigger OnLookup()
            var
                BinCode: Code[20];
            begin
            end;

            trigger OnValidate()
            var
                BinContent: Record "Bin Content";
                BinType: Record "Bin Type";
                QtyAvail: Decimal;
                QtyOutstanding: Decimal;
                AvailableQty: Decimal;
                UOMCode: Code[10];
                NewBinCode: Code[20];
            begin
            end;
        }
        field(27;"Assignment Date";Date)
        {
            Caption = 'Assignment Date';
            Editable = false;
        }
        field(28;"New Bin Code";Code[20])
        {
            Caption = 'New Bin Code';

            trigger OnLookup()
            var
                BinCode: Code[20];
            begin
            end;

            trigger OnValidate()
            var
                BinContent: Record "Bin Content";
                BinType: Record "Bin Type";
                QtyAvail: Decimal;
                QtyOutstanding: Decimal;
                AvailableQty: Decimal;
                UOMCode: Code[10];
                NewBinCode: Code[20];
            begin
            end;
        }
        field(50;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code", '');
            end;
        }
        field(51;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(52;"Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(53;"Variant Description";Text[50])
        {
            CalcFormula = Lookup("Item Variant".Description WHERE (Code=FIELD("Variant Code"),
                                                                   "Item No."=FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(54;"Source Doc. No.";Code[20])
        {
            Caption = 'Source Doc. No.';
        }
        field(100;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(101;"Record Id";RecordID)
        {
            Caption = 'Record Id';
        }
        field(102;Handled;Boolean)
        {
            Caption = 'Handled';
        }
        field(103;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(104;"Created By";Code[20])
        {
            Caption = 'Created By';
        }
        field(105;"Transferred to Worksheet";Boolean)
        {
            Caption = 'Transferred to Worksheet';
        }
    }

    keys
    {
        key(Key1;Id,"Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Created := CurrentDateTime;
        "Created By" := UserId;
    end;
}

