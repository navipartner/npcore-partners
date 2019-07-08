table 6060057 "Item Worksheet Variety Mapping"
{
    // NPR5.37/BR  /20170922  CASE 268786 Added Mapping option to import
    // NPR5.37/BR  /20171016  CASE 268786 Added Variety Value Description flowfield, fixed tablerelation Variety Value
    // NPR5.43/JKL /20180524 CASE 314287  Added new fields Item Wksh. Maping Field, Item Wksh. Maping Field Name, Item Wksh. Maping Fiels Value + added these to primary key
    // NPR5.46/JKL /20180927 CASE 314287  added custom lookup for Item Wksh. Maping Field Value "item group"
    // NPR5.49/BHR /20190218 CASE 341465 Increase size of Variety Tables from code 20 to code 40

    Caption = 'Item Worksheet Variety Mapping';

    fields
    {
        field(1;"Worksheet Template Name";Code[10])
        {
            Caption = 'Worksheet Template Name';
            TableRelation = "Item Worksheet Template";
        }
        field(2;"Worksheet Name";Code[10])
        {
            Caption = 'Worksheet Name';
            TableRelation = "Item Worksheet".Name WHERE ("Item Template Name"=FIELD("Worksheet Template Name"));
        }
        field(3;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10;Variety;Code[10])
        {
            Caption = 'Variety';
            TableRelation = Variety;
        }
        field(11;"Variety Table";Code[40])
        {
            Caption = 'Variety Table';
            TableRelation = "Variety Table".Code WHERE (Type=FIELD(Variety));
        }
        field(12;"Vendor Variety Value";Text[50])
        {
            Caption = 'Vendor Variey Value';
        }
        field(13;"Variety Value";Code[20])
        {
            Caption = 'Variety Value';
            TableRelation = "Variety Value".Value WHERE (Type=FIELD(Variety),
                                                         Table=FIELD("Variety Table"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(20;"Variety Value Description";Text[30])
        {
            CalcFormula = Lookup("Variety Value".Description WHERE (Type=FIELD(Variety),
                                                                    Table=FIELD("Variety Table"),
                                                                    Value=FIELD("Variety Value")));
            Caption = 'Variety Value Description';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30;"Item Wksh. Maping Field";Integer)
        {
            Caption = 'Item Worksheet Mapipng Field';
            Description = 'NPR5.43';
            TableRelation = "Item Worksheet Field Setup"."Field Number";
        }
        field(31;"Item Wksh. Maping Field Name";Text[80])
        {
            CalcFormula = Lookup("Item Worksheet Field Setup"."Field Caption" WHERE ("Field Number"=FIELD("Item Wksh. Maping Field")));
            Caption = 'Item Worksheet Mapping Field Name';
            Description = 'NPR5.43';
            Editable = false;
            FieldClass = FlowField;
        }
        field(32;"Item Wksh. Maping Field Value";Text[50])
        {
            Caption = 'Item Worksheet Mapping Field Value';
            Description = 'NPR5.43';

            trigger OnLookup()
            var
                RecRef: RecordRef;
                Fldref: FieldRef;
                Variant: Variant;
                ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
            begin
                //-NPR5.46 [314287]
                case "Item Wksh. Maping Field" of
                 6014400 :
                 begin
                   RecRef.Open(6014410);
                   Variant := RecRef;
                   if PAGE.RunModal(0,Variant) = ACTION::LookupOK then
                     RecRef := Variant;
                     Fldref:= RecRef.Field(1);
                     Evaluate("Item Wksh. Maping Field Value",Format(Fldref.Value));
                 end;
                end;
            end;
        }
    }

    keys
    {
        key(Key1;"Worksheet Template Name","Worksheet Name","Vendor No.",Variety,"Variety Table","Vendor Variety Value","Item Wksh. Maping Field","Item Wksh. Maping Field Value")
        {
        }
    }

    fieldgroups
    {
    }
}

