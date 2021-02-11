table 6014412 "NPR Mixed Discount Line"
{
    // NPR70.00.01.01/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR5.26/BHR /20160712  CASE 246594 Field 210
    // NPR5.26/JC  /20160818  CASE 248286 Remove fields 9, 15, 50,51 100, 200 & applied code guidelines, restored field 200 Item group as used in Item Group table
    // NPR5.31/MHA /20170110  CASE 262904 Changed primary key to included "Disc. Grouping Type" from: Code,"Item No.","Variant Code"
    //                                    Renamed field 2 from "Item No."
    //                                    Added Option to field 21 "Disc. Grouping Type": Mix Discount
    //                                    Renamed variables to English and deleted unused
    //                                    Added DecimalPlaces 0:5 to all Quantity fields
    // NPR5.38/MHA /20171106  CASE 295330 Renamed Option "Balanced" to "Closed" for field 8 "Status"
    // NPR5.39/BHR /20180109  CASE 299276 Add fields "Vendor No" and "Vendor Item No".
    // NPR5.40/MMV /20180213  CASE 294655 Performance optimization, new fields, new key, field 8 changed from flow to real field.
    // NPR5.48/TS  /20181128  CASE 337806 Made Global Variable Mixed Discount as Local Variable
    // NPR5.55/ALST.20200608  CASE 407796 added possibility to find item by cross reference

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
                            //-NPR5.31 [262904]
                            //QuantityDiscountLine.SETRANGE("Item No.", "No.");
                            //IF QuantityDiscountLine.FINDFIRST THEN
                            //  IF NOT CONFIRM(STRSUBSTNO(MsgBoth,"No.")) THEN
                            //    ERROR(ErrCreate);
                            //+NPR5.31 [262904]

                            Item.Get("No.");
                            Description := Item.Description;
                            "Description 2" := Item."Description 2";
                            CalcFields("Unit cost");
                            CalcFields("Unit price");
                            //-NPR5.40 [294655]
                            //CALCFIELDS(Status);
                            //+NPR5.40 [294655]
                            //-NPR5.31 [262904]
                            if ("Variant Code" <> '') and ItemVariant.Get("No.", "Variant Code") then
                                "Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen("Description 2"));
                            "Vendor No." := Item."Vendor No.";
                            "Vendor Item No." := Item."Vendor Item No.";
                            //-NPR5.39 [299276]
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
                    //-NPR5.31 [262904]
                    "Disc. Grouping Type"::"Mix Discount":
                        begin
                            MixedDiscount.Get("No.");
                            Description := MixedDiscount.Description;
                        end;
                //+NPR5.31 [262904]
                end;
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(4; "Unit cost"; Decimal)
        {
            CalcFormula = Lookup (Item."Unit Cost" WHERE("No." = FIELD("No.")));
            Caption = 'Unit Cost';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Unit price"; Decimal)
        {
            CalcFormula = Lookup (Item."Unit Price" WHERE("No." = FIELD("No.")));
            Caption = 'Unit Price';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            begin
                //-NPR5.31 [262904]
                //IF "Unit price" <= 0 THEN
                //  ERROR(ErrSalesPrice);
                //+NPR5.31 [262904]
            end;
        }
        field(7; "Unit price incl. VAT"; Boolean)
        {
            CalcFormula = Lookup (Item."Price Includes VAT" WHERE("No." = FIELD("No.")));
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

            trigger OnValidate()
            begin
                //-NPR5.31 [262904]
                //IF NOT (Quantity > 0) THEN
                //  ERROR(MsgNotNeg);
                //-NPR5.31 [262904]
            end;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Description = 'NPR5.31';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.31 [262904]
                Validate("No.");
                //+NPR5.31 [262904]
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
        field(210; "Cross-Reference No."; Code[20])
        {
            Caption = 'Cross-Reference No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                BarcodeLibrary: Codeunit "NPR Barcode Library";
            begin
                //-NPR5.26 [246594]
                BarcodeLibrary.CallCrossRefNoLookupMixDiscount(Rec);
                //+NPR5.26 [246594]
            end;

            trigger OnValidate()
            var
                ItemCrossReference: Record "Item Cross Reference";
            begin
                //-NPR5.55 [407796]
                if "Disc. Grouping Type" <> "Disc. Grouping Type"::Item then
                    Validate("Disc. Grouping Type", "Disc. Grouping Type"::Item);

                if "No." = '' then begin
                    ItemCrossReference.SetRange("Cross-Reference No.", "Cross-Reference No.");
                    if ItemCrossReference.Count > 1 then begin
                        ItemCrossReference.SetFilter("Cross-Reference Type", '%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
                        ItemCrossReference.SetFilter("Cross-Reference Type No.", '%1', '');

                        if PAGE.RunModal(PAGE::"Cross Reference List", ItemCrossReference) <> ACTION::LookupOK then
                            exit;
                    end else
                        ItemCrossReference.FindFirst;

                    "No." := ItemCrossReference."Item No.";
                    "Variant Code" := ItemCrossReference."Variant Code";
                end;
                //+NPR5.55 [407796]
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

        //-NPR5.40 [294655]
        UpdateLine();
        //+NPR5.40 [294655]
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

        //-NPR5.40 [294655]
        UpdateLine();
        //+NPR5.40 [294655]
    end;

    trigger OnRename()
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        MixedDiscount.Get(Code);
        MixedDiscount."Last Date Modified" := Today;

        //-NPR5.40 [294655]
        UpdateLine();
        //+NPR5.40 [294655]
    end;

    var
        "//-SyncProfiles": Integer;
        syncCU: Codeunit "NPR CompanySyncManagement";
        RecRef: RecordRef;
        "//+SyncProfiles": Integer;

    local procedure UpdateLine()
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        //-NPR5.40 [294655]
        if MixedDiscount.Get(Code) then begin
            "Starting Date" := MixedDiscount."Starting date";
            "Ending Date" := MixedDiscount."Ending date";
            Status := MixedDiscount.Status;
            "Starting Time" := MixedDiscount."Starting time";
            "Ending Time" := MixedDiscount."Ending time";
        end;
        //+NPR5.40 [294655]
    end;
}

