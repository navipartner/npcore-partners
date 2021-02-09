table 6014412 "NPR Mixed Discount Line"
{
    Caption = 'Mixed Discount Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = "NPR Mixed Discount".Code;
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            Description = 'NPR5.31';
            NotBlank = true;
            TableRelation = IF ("Disc. Grouping Type" = CONST(Item)) Item
            ELSE
            IF ("Disc. Grouping Type" = CONST("Item Group")) "NPR Item Group"
            ELSE
            IF ("Disc. Grouping Type" = CONST("Item Disc. Group")) "Item Discount Group"
            ELSE
            IF ("Disc. Grouping Type" = CONST("Mix Discount")) "NPR Mixed Discount" WHERE("Mix Type" = CONST("Combination Part"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
                ItemVariant: Record "Item Variant";
                ItemDiscountGroup: Record "Item Discount Group";
                ItemGroup: Record "NPR Item Group";
                MixedDiscount: Record "NPR Mixed Discount";
            begin
                case "Disc. Grouping Type" of
                    "Disc. Grouping Type"::Item:
                        begin
                            Item.Get("No.");
                            Description := Item.Description;
                            "Description 2" := Item."Description 2";
                            CalcFields("Unit cost");
                            CalcFields("Unit price");

                            if ("Variant Code" <> '') and ItemVariant.Get("No.", "Variant Code") then
                                "Description 2" := ItemVariant.Description;
                            "Vendor No." := Item."Vendor No.";
                            "Vendor Item No." := Item."Vendor Item No.";
                        end;
                    "Disc. Grouping Type"::"Item Group":
                        begin
                            ItemGroup.Get("No.");
                            Description := ItemGroup.Description;
                        end;
                    "Disc. Grouping Type"::"Item Disc. Group":
                        begin
                            ItemDiscountGroup.Get("No.");
                            Description := ItemDiscountGroup.Description;
                        end;
                    "Disc. Grouping Type"::"Mix Discount":
                        begin
                            MixedDiscount.Get("No.");
                            Description := MixedDiscount.Description;
                        end;
                end;
            end;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(4; "Unit cost"; Decimal)
        {
            CalcFormula = Lookup(Item."Unit Cost" WHERE("No." = FIELD("No.")));
            Caption = 'Unit Cost';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Unit price"; Decimal)
        {
            CalcFormula = Lookup(Item."Unit Price" WHERE("No." = FIELD("No.")));
            Caption = 'Unit Price';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Unit price incl. VAT"; Boolean)
        {
            CalcFormula = Lookup(Item."Price Includes VAT" WHERE("No." = FIELD("No.")));
            Caption = 'Price Includes VAT';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; Status; Option)
        {
            Caption = 'Status';
            Description = 'NPR5.38';
            Editable = false;
            OptionCaption = 'Pending,Active,Closed';
            OptionMembers = Pending,Active,Closed;
            DataClassification = CustomerContent;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
            InitValue = 1;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Description = 'NPR5.31';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("No.");
            end;
        }
        field(12; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(13; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(21; "Disc. Grouping Type"; Enum "NPR Disc. Grouping Type")
        {
            Caption = 'Disc. Grouping Type';
            DataClassification = CustomerContent;
        }
        field(30; Priority; Integer)
        {
            Caption = 'Priority';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(40; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(41; "Vendor Item No."; Code[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
        }
        field(200; "Item Group"; Boolean)
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
        }
        field(210; "Cross-Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                BarcodeLibrary: Codeunit "NPR Barcode Library";
            begin
                BarcodeLibrary.CallItemRefNoLookupMixDiscount(Rec);
            end;

            trigger OnValidate()
            var
                ItemReference: Record "Item Reference";
            begin
                if "Disc. Grouping Type" <> "Disc. Grouping Type"::Item then
                    Validate("Disc. Grouping Type", "Disc. Grouping Type"::Item);

                if "No." = '' then begin
                    ItemReference.SetRange("Reference No.", "Cross-Reference No.");
                    if ItemReference.Count() > 1 then begin
                        ItemReference.SetFilter("Reference Type", '%1', ItemReference."Reference Type"::"Bar Code");
                        ItemReference.SetFilter("Reference Type No.", '%1', '');

                        if PAGE.RunModal(PAGE::"Item Reference List", ItemReference) <> ACTION::LookupOK then
                            exit;
                    end else
                        ItemReference.FindFirst();

                    "No." := ItemReference."Item No.";
                    "Variant Code" := ItemReference."Variant Code";
                end;
            end;
        }
        field(300; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(301; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(302; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(303; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", "Disc. Grouping Type", "No.", "Variant Code")
        {
            SumIndexFields = Quantity;
        }
        key(Key2; "No.")
        {
        }
        key(Key3; "Last Date Modified")
        {
        }
        key(Key4; Priority)
        {
        }
        key(Key5; "Disc. Grouping Type", "No.", "Variant Code", "Starting Date", "Ending Date", "Starting Time", "Ending Time", Status)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        MixedDiscount.Get(Code);
        MixedDiscount."Last Date Modified" := Today;
    end;

    trigger OnInsert()
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        MixedDiscount.Get(Code);
        MixedDiscount."Last Date Modified" := Today;

        RecRef.GetTable(Rec);
        syncCU.OnInsert(RecRef);

        UpdateLine();
    end;

    trigger OnModify()
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        MixedDiscount.Get(Code);
        MixedDiscount."Last Date Modified" := Today;
        "Last Date Modified" := Today;

        RecRef.GetTable(Rec);
        syncCU.OnModify(RecRef);

        UpdateLine();
    end;

    trigger OnRename()
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        MixedDiscount.Get(Code);
        MixedDiscount."Last Date Modified" := Today;

        UpdateLine();
    end;

    var
        syncCU: Codeunit "NPR CompanySyncManagement";
        RecRef: RecordRef;

    local procedure UpdateLine()
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        if MixedDiscount.Get(Code) then begin
            "Starting Date" := MixedDiscount."Starting date";
            "Ending Date" := MixedDiscount."Ending date";
            Status := MixedDiscount.Status;
            "Starting Time" := MixedDiscount."Starting time";
            "Ending Time" := MixedDiscount."Ending time";
        end;
    end;
}

