table 6059972 "NPR Variety Table"
{
    // NPR4.16/JDH/20151022 CASE 225661 Changed NotBlank to yes, to avoid blank primary key value
    // VRT1.10/JDH/20151202 CASE 201022 Added field Lock Table
    // VRT1.11/JDH /20160531 CASE 242940 Added functionality to setup new lines
    // VRT1.11/JDH /20160602 CASE 242940 Captions
    // NPR5.47/JDH /20180913 CASE 327541  Changed field length of Code to 40 characters

    Caption = 'Variety Table';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Variety Table";
    LookupPageID = "NPR Variety Table";

    fields
    {
        field(1; Type; Code[10])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Variety";
        }
        field(2; "Code"; Code[40])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            begin
                //-NPR5.47 [327541]
                TestLength();
                //+NPR5.47 [327541]
            end;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Use in Variant Description"; Boolean)
        {
            Caption = 'Use in Variant Description';
            DataClassification = CustomerContent;
        }
        field(21; "Pre tag In Variant Description"; Text[10])
        {
            Caption = 'Pre tag In Variant Description';
            DataClassification = CustomerContent;
        }
        field(22; "Use Description field"; Boolean)
        {
            Caption = 'Use Description field';
            DataClassification = CustomerContent;
        }
        field(30; "Is Copy"; Boolean)
        {
            Caption = 'Is Copy';
            DataClassification = CustomerContent;
        }
        field(31; "Copy from"; Code[40])
        {
            Caption = 'Copy from';
            DataClassification = CustomerContent;
        }
        field(40; "Lock Table"; Boolean)
        {
            Caption = 'Lock Table';
            DataClassification = CustomerContent;
        }
        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "Code")
        {
        }
        key(Key2; "Replication Counter")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        VRTValue: Record "NPR Variety Value";
    begin
        VRTValue.SetRange(Type, Type);
        VRTValue.SetRange(Table, Code);
        VRTValue.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        //-NPR5.47 [327541]
        TestLength();
        //+NPR5.47 [327541]
    end;

    trigger OnRename()
    begin
        //-NPR5.47 [327541]
        TestLength();
        //+NPR5.47 [327541]
    end;

    var
        Text001: Label 'The length of field %1 must not be more than 20 characters';

    internal procedure SetupNewLine()
    var
        VRT: Record "NPR Variety";
    begin
        //-VRT1.11
        VRT.Get(GetFilter(Type));
        "Use in Variant Description" := VRT."Use in Variant Description";
        "Use Description field" := VRT."Use Description field";
        "Pre tag In Variant Description" := VRT."Pre tag In Variant Description";
        Description := VRT.Description;
        //+VRT1.11
    end;

    local procedure TestLength()
    begin
        //-NPR5.47 [327541]
        if (StrLen(Code) > 20) and (not "Is Copy") then
            Error(Text001, FieldCaption(Code));
        //+NPR5.47 [327541]
    end;
}

