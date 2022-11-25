﻿table 6151126 "NPR NpIa Item AddOn Line"
{
    Caption = 'Item AddOn Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "AddOn No."; Code[20])
        {
            Caption = 'AddOn No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpIa Item AddOn";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Quantity,Select';
            OptionMembers = Quantity,Select;

            trigger OnValidate()
            begin
                if Type = Type::Select then
                    validate("Item No.", '');
            end;
        }
        field(15; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
                xItemAddonLine: Record "NPR NpIa Item AddOn Line";
            begin
                if "Item No." = '' then begin
                    xItemAddonLine := Rec;
                    Init();
                    Type := xItemAddonLine.Type;
                    exit;
                end;
                TestField(Type, Type::Quantity);
                Item.Get("Item No.");

                "Unit Price" := Item."Unit Price";
                Description := Item.Description;
                Validate("Variant Code");
            end;
        }
        field(20; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                if "Variant Code" <> '' then begin
                    TestField("Item No.");
                    ItemVariant.Get("Item No.", "Variant Code")
                end else
                    Clear(ItemVariant);
                "Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen("Description 2"));
            end;
        }
        field(25; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(49; "Use Unit Price"; Option)
        {
            Caption = 'Use Unit Price';
            DataClassification = CustomerContent;
            OptionCaption = 'Non-Zero,Always';
            OptionMembers = "Non-Zero",Always;
        }
        field(50; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(55; "Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(60; "Comment Enabled"; Boolean)
        {
            Caption = 'Comment Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NpIaItemAddOn: Record "NPR NpIa Item AddOn";
            begin
                NpIaItemAddOn.Get("AddOn No.");
                NpIaItemAddOn.TestField("Comment POS Info Code");
            end;
        }
        field(100; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if Quantity = 0 then begin
                    "Fixed Quantity" := false;
                    Mandatory := false;
                end else
                    TestField("Item No.");
            end;
        }
        field(110; "Fixed Quantity"; Boolean)
        {
            Caption = 'Fixed Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Fixed Quantity" then
                    TestField(Quantity);
            end;
        }
        field(120; "Per Unit"; Boolean)
        {
            Caption = 'Per unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Per Unit" then
                    TestField(Quantity);
            end;
        }
        field(130; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Mandatory then
                    TestField(Quantity);
            end;
        }
        field(200; "Before Insert Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Before Insert Codeunit ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpIa Item AddOn Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericParentTable');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Before Insert Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Before Insert Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Before Insert Codeunit ID" = 0 then begin
                    "Before Insert Function" := '';
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpIa Item AddOn Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericParentTable');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Before Insert Codeunit ID");
                if "Before Insert Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Before Insert Function");
                EventSubscription.FindFirst();
            end;
        }
        field(205; "Before Insert Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Before Insert Codeunit ID")));
            Caption = 'Before Insert Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210; "Before Insert Function"; Text[250])
        {
            Caption = 'Before Insert Function';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpIa Item AddOn Mgt.");
                EventSubscription.SetRange("Published Function", 'BeforeInsertPOSAddOnLine');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Before Insert Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Before Insert Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Before Insert Function" = '' then begin
                    "Before Insert Codeunit ID" := 0;
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpIa Item AddOn Mgt.");
                EventSubscription.SetRange("Published Function", 'BeforeInsertPOSAddOnLine');
                EventSubscription.SetRange("Subscriber Function", "Before Insert Function");
                EventSubscription.SetRange("Subscriber Codeunit ID", "Before Insert Codeunit ID");
                if not EventSubscription.FindFirst() then
                    EventSubscription.SetRange("Subscriber Codeunit ID");

                EventSubscription.FindFirst();
                "Before Insert Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
            end;
        }
        field(220; "Copy Serial No."; Boolean)
        {
            Caption = 'Copy Serial No.';
            DataClassification = CustomerContent;
        }
        field(230; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "AddOn No.", "Line No.") { }
    }

    trigger OnDelete()
    var
        NpIaItemAddOnLineOption: Record "NPR NpIa ItemAddOn Line Opt.";
    begin
        NpIaItemAddOnLineOption.SetRange("AddOn No.", "AddOn No.");
        NpIaItemAddOnLineOption.SetRange("AddOn Line No.", "Line No.");
        if NpIaItemAddOnLineOption.FindFirst() then
            NpIaItemAddOnLineOption.DeleteAll();
    end;

    trigger OnInsert()
    begin
        if Type = Quantity then
            TestField("Item No.");
    end;

    trigger OnModify()
    begin
        if Type = Quantity then
            TestField("Item No.");
    end;
}
