table 6014506 "Accessory/Spare Part"
{
    // NPR5.40/MHA /20180214  CASE 288039 Added field 85 "Unfold in Worksheet"

    Caption = 'Accessory/Spare Part';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            TableRelation = Item;
        }
        field(2;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                CalcFields(Description);
            end;
        }
        field(3;Description;Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4;Vendor;Code[20])
        {
            CalcFormula = Lookup(Item."Vendor No." WHERE ("No."=FIELD("Item No.")));
            Caption = 'Buy-from Vendor';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;"Buy-from Vendor Name";Text[50])
        {
            CalcFormula = Lookup(Vendor.Name WHERE ("No."=FIELD(Vendor)));
            Caption = 'Buy-from Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(9;Inventory;Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE ("Item No."=FIELD("Item No."),
                                                                  "Posting Date"=FIELD("Date Filter"),
                                                                  "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter"),
                                                                  "Location Code"=FIELD(Lokationsfilter)));
            Caption = 'Inventory';
            FieldClass = FlowField;
        }
        field(10;"Unit Price";Decimal)
        {
            CalcFormula = Lookup(Item."Unit Price" WHERE ("No."=FIELD("Item No.")));
            Caption = 'Unit Price';
            FieldClass = FlowField;
        }
        field(12;"Last Date Modified";Date)
        {
            Caption = 'Last Date Modified';
        }
        field(13;"Show Discount";Boolean)
        {
            Caption = 'Show Discount';
        }
        field(63;"Per unit";Boolean)
        {
            Caption = 'Per unit';
            InitValue = true;
        }
        field(64;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(65;"Global Dimension 1 Filter";Code[20])
        {
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(66;"Global Dimension 2 Filter";Code[20])
        {
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(67;Lokationsfilter;Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(68;Standard;Boolean)
        {
            Caption = 'Standard';
        }
        field(69;"Add Extra Line Automatically";Boolean)
        {
            Caption = 'Add Extra Line Automatically';
            InitValue = false;
        }
        field(70;"Use Alt. Price";Boolean)
        {
            Caption = 'Use Alt. Price';
            InitValue = false;
        }
        field(71;"Alt. Price";Decimal)
        {
            Caption = 'Alt. Price';
        }
        field(80;"Quantity in Dialogue";Boolean)
        {
            Caption = 'Quantity in Dialogue';
        }
        field(85;"Unfold in Worksheet";Boolean)
        {
            Caption = 'Unfold in Worksheet';
            Description = 'NPR5.40';

            trigger OnValidate()
            var
                AccessoryUnfoldMgt: Codeunit "Accessory Unfold Mgt.";
            begin
                //-NPR5.40 [288039]
                if "Unfold in Worksheet" then
                  AccessoryUnfoldMgt.TestVatSetup(Code,"Item No.");
                //+NPR5.40 [288039]
            end;
        }
        field(1000;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Accessory,Spare Part,Match';
            OptionMembers = Accessory,"Spare Part",Match;
        }
        field(5000;Auto;Boolean)
        {
            Caption = 'Auto';
            InitValue = true;
        }
    }

    keys
    {
        key(Key1;Type,"Code","Item No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        recRef.GetTable(Rec);
        syncCU.OnDelete(recRef);
    end;

    trigger OnInsert()
    begin
        if Quantity = 0 then
          Quantity := 1;

        "Add Extra Line Automatically":=true;

        recRef.GetTable(Rec);
        syncCU.OnInsert(recRef);
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
        recRef.GetTable(Rec);
        syncCU.OnModify(recRef);
    end;

    var
        "//-SyncProfiles": Integer;
        syncCU: Codeunit CompanySyncManagement;
        recRef: RecordRef;
        "//+SyncProfiles": Integer;
}

