table 6060057 "NPR Item Worksh. Vrty Mapping"
{
    Caption = 'Item Worksheet Variety Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Worksheet Template Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Worksh. Template";
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Worksheet".Name WHERE("Item Template Name" = FIELD("Worksheet Template Name"));
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = false;
        }
        field(10; Variety; Code[10])
        {
            Caption = 'Variety';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(11; "Variety Table"; Code[40])
        {
            Caption = 'Variety Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD(Variety));
        }
        field(12; "Vendor Variety Value"; Text[50])
        {
            Caption = 'Vendor Variey Value';
            DataClassification = CustomerContent;
        }
        field(13; "Variety Value"; Code[20])
        {
            Caption = 'Variety Value';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD(Variety),
                                                         Table = FIELD("Variety Table"));
            ValidateTableRelation = false;
        }
        field(20; "Variety Value Description"; Text[30])
        {
            CalcFormula = Lookup("NPR Variety Value".Description WHERE(Type = FIELD(Variety),
                                                                    Table = FIELD("Variety Table"),
                                                                    Value = FIELD("Variety Value")));
            Caption = 'Variety Value Description';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Item Wksh. Maping Field"; Integer)
        {
            Caption = 'Item Worksheet Mapping Field';
            DataClassification = CustomerContent;
            Description = 'NPR5.43';
            TableRelation = "NPR Item Worksh. Field Setup"."Field Number";
        }
        field(31; "Item Wksh. Maping Field Name"; Text[80])
        {
            CalcFormula = Lookup("NPR Item Worksh. Field Setup"."Field Caption" WHERE("Field Number" = FIELD("Item Wksh. Maping Field")));
            Caption = 'Item Worksheet Mapping Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Item Wksh. Maping Field Value"; Text[50])
        {
            Caption = 'Item Worksheet Mapping Field Value';
            DataClassification = CustomerContent;
            Description = 'NPR5.43';

            trigger OnLookup()
            var
                ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
                RecRef: RecordRef;
                Fldref: FieldRef;
                Variant: Variant;
            begin
                case "Item Wksh. Maping Field" of
                    6014400:
                        begin
                            RecRef.Open(6014410);
                            Variant := RecRef;
                            if PAGE.RunModal(0, Variant) = ACTION::LookupOK then
                                RecRef := Variant;
                            Fldref := RecRef.Field(1);
                            Evaluate("Item Wksh. Maping Field Value", Format(Fldref.Value));
                        end;
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", "Worksheet Name", "Vendor No.", Variety, "Variety Table", "Vendor Variety Value", "Item Wksh. Maping Field", "Item Wksh. Maping Field Value")
        {
        }
    }

}

