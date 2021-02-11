table 6014416 "NPR Alternative No."
{
    // NPR3.0r, NPK, DL, 21-04-08, Changed minor error in the replication code
    // NPR5.23/MMV /20160610 CASE 242522 Added field 12 - Discontinue : Boolean
    //                                   Removed deprecated field 11.
    // NPR5.48/TS  /20181128 CASE 337806 Increase length of Variant Description to 50

    Caption = 'Alternative No.';
    LookupPageID = "NPR Alternative Number";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST(Customer)) Customer."No."
            ELSE
            IF (Type = CONST(SalesPerson)) "Salesperson/Purchaser".Code;
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }
        field(2; "Alt. No."; Code[20])
        {
            Caption = 'Alternative No.';
            NotBlank = true;
            TableRelation = IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Register)) "NPR Register"
            ELSE
            IF (Type = CONST(SalesPerson)) "Salesperson/Purchaser"
            ELSE
            IF (Type = CONST("CRM Customer")) Contact;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(3; "Created the"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Customer,CRM Customer,Register drawer,Salesperson';
            OptionMembers = Item,Customer,"CRM Customer",Register,SalesPerson;
            DataClassification = CustomerContent;
        }
        field(5; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD(Code));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                "Item Variant": Record "Item Variant";
            begin
                "Variant Description" := '';
                if Type = Type::Item then
                    if "Item Variant".Get(Code, "Variant Code") then
                        "Variant Description" := "Item Variant".Description;
            end;
        }
        field(7; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD(Code));
            DataClassification = CustomerContent;
        }
        field(8; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD(Code));
            DataClassification = CustomerContent;
        }
        field(9; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD(Code));
            DataClassification = CustomerContent;
        }
        field(10; "Blocked Reason Code"; Code[10])
        {
            Caption = 'Blocked Reason';
            TableRelation = "Reason Code".Code;
            DataClassification = CustomerContent;
        }
        field(12; Discontinue; Boolean)
        {
            Caption = 'Discontinue Bar Code';
            DataClassification = CustomerContent;
        }
        field(5000; Auto; Boolean)
        {
            Caption = 'Auto';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(6014400; "Variant Description"; Text[100])
        {
            Caption = 'Variant Description';
            Description = 'NPR5.48';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "Code", "Alt. No.")
        {
        }
        key(Key2; "Alt. No.", Type)
        {
        }
        key(Key3; "Code")
        {
        }
        key(Key4; "Variant Code")
        {
        }
        key(Key5; "Last Date Modified")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if Type = Type::Item then begin
            recRef.GetTable(Rec);
            syncCU.OnDelete(recRef);
        end;
    end;

    trigger OnInsert()
    begin
        "Created the" := Today;
        "Last Date Modified" := Today;

        if Type = Type::Item then begin
            recRef.GetTable(Rec);
            syncCU.OnInsert(recRef);
        end;
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;

        if Type = Type::Item then begin
            recRef.GetTable(Rec);
            syncCU.OnModify(recRef);
        end;
    end;

    trigger OnRename()
    begin
        if Type = Type::Item then begin
            recRef.GetTable(xRec);
            syncCU.OnDelete(recRef);
            recRef.GetTable(Rec);
            syncCU.OnInsert(recRef);
        end;
    end;

    var
        Item: Record Item;
        "//-SyncProfiles": Integer;
        syncCU: Codeunit "NPR CompanySyncManagement";
        recRef: RecordRef;
        "//+SyncProfiles": Integer;

    procedure GetItem()
    begin
        TestField("Alt. No.");
        if "Alt. No." <> Item."No." then
            Item.Get("Alt. No.");
    end;
}

