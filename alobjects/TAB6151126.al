table 6151126 "NpIa Item AddOn Line"
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn
    // NPR5.48/MHA /20181109  CASE 334922 Extended type with Quantity and Select

    Caption = 'Item AddOn Line';

    fields
    {
        field(1;"AddOn No.";Code[20])
        {
            Caption = 'AddOn No.';
            NotBlank = true;
            TableRelation = "NpIa Item AddOn";
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            Description = 'NPR5.48';
            OptionCaption = 'Quantity,Select';
            OptionMembers = Quantity,Select;

            trigger OnValidate()
            begin
                //-NPR5.48 [334922]
                if Type = Type::Select then begin
                  "Item No." := '';
                  "Variant Code" := '';
                end;
                //+NPR5.48 [334922]
            end;
        }
        field(15;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            Description = 'NPR5.48';
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                //-NPR5.48 [334922]
                // CASE Type OF
                //  Type::Item:
                //    BEGIN
                //      IF "Item No." <> '' THEN
                //        Item.GET("Item No.");
                //
                //      "Unit Price" := Item."Unit Price";
                //      Description := Item.Description;
                //      VALIDATE("Variant Code");
                //    END;
                // END;
                if "Item No." = '' then
                  exit;

                Item.Get("Item No.");

                "Unit Price" := Item."Unit Price";
                Description := Item.Description;
                Validate("Variant Code");
                //+NPR5.48 [334922]
            end;
        }
        field(20;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                //-NPR5.48 [334922]
                // IF "Variant Code" <> '' THEN
                //  ItemVariant.GET("Item No.","Variant Code");
                if "Variant Code" = '' then
                  exit;

                ItemVariant.Get("Item No.","Variant Code");
                //+NPR5.48 [334922]
                "Description 2" := ItemVariant.Description;
            end;
        }
        field(25;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(30;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
        field(50;"Unit Price";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
        }
        field(55;"Discount %";Decimal)
        {
            BlankZero = true;
            Caption = 'Discount %';
            DecimalPlaces = 0:1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(60;"Comment Enabled";Boolean)
        {
            Caption = 'Comment Enabled';

            trigger OnValidate()
            var
                NpIaItemAddOn: Record "NpIa Item AddOn";
            begin
                NpIaItemAddOn.Get("AddOn No.");
                NpIaItemAddOn.TestField("Comment POS Info Code");
            end;
        }
        field(100;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(200;"Before Insert Codeunit ID";Integer)
        {
            BlankZero = true;
            Caption = 'Before Insert Codeunit ID';
            Description = 'NPR5.48';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.48 [334922]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpIa Item AddOn Mgt.");
                EventSubscription.SetRange("Published Function",'OnSetupGenericParentTable');
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Before Insert Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Before Insert Function" := EventSubscription."Subscriber Function";
                //+NPR5.48 [334922]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.48 [334922]
                if "Before Insert Codeunit ID" = 0 then begin
                  "Before Insert Function" := '';
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpIa Item AddOn Mgt.");
                EventSubscription.SetRange("Published Function",'OnSetupGenericParentTable');
                EventSubscription.SetRange("Subscriber Codeunit ID","Before Insert Codeunit ID");
                if "Before Insert Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Before Insert Function");
                EventSubscription.FindFirst;
                //+NPR5.48 [334922]
            end;
        }
        field(205;"Before Insert Codeunit Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Before Insert Codeunit ID")));
            Caption = 'Before Insert Codeunit Name';
            Description = 'NPR5.48';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210;"Before Insert Function";Text[250])
        {
            Caption = 'Before Insert Function';
            Description = 'NPR5.48';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.48 [334922]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpIa Item AddOn Mgt.");
                EventSubscription.SetRange("Published Function",'BeforeInsertPOSAddOnLine');
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Before Insert Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Before Insert Function" := EventSubscription."Subscriber Function";
                //+NPR5.48 [334922]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.48 [334922]
                if "Before Insert Function" = '' then begin
                  "Before Insert Codeunit ID" := 0;
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpIa Item AddOn Mgt.");
                EventSubscription.SetRange("Published Function",'BeforeInsertPOSAddOnLine');
                EventSubscription.SetRange("Subscriber Function","Before Insert Function");
                EventSubscription.SetRange("Subscriber Codeunit ID","Before Insert Codeunit ID");
                if not EventSubscription.FindFirst then
                  EventSubscription.SetRange("Subscriber Codeunit ID");

                EventSubscription.FindFirst;
                "Before Insert Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                //+NPR5.48 [334922]
            end;
        }
    }

    keys
    {
        key(Key1;"AddOn No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpIaItemAddOnLineOption: Record "NpIa Item AddOn Line Option";
    begin
        //-NPR5.48 [334922]
        NpIaItemAddOnLineOption.SetRange("AddOn No.","AddOn No.");
        NpIaItemAddOnLineOption.SetRange("AddOn Line No.","Line No.");
        if NpIaItemAddOnLineOption.FindFirst then
          NpIaItemAddOnLineOption.DeleteAll;
        //+NPR5.48 [334922]
    end;

    trigger OnInsert()
    begin
        //-NPR5.48 [334922]
        //TESTFIELD("Item No.");
        if Type = Quantity then
          TestField("Item No.");
        //+NPR5.48 [334922]
    end;

    trigger OnModify()
    begin
        //+NPR5.48 [334922]
        //TESTFIELD("Item No.");
        if Type = Quantity then
          TestField("Item No.");
        //+NPR5.48 [334922]
    end;
}

