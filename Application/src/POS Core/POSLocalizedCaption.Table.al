table 6150702 "NPR POS Localized Caption"
{
    Caption = 'Localized Caption';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Clear("Caption ID");
            end;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Clear("Caption ID");
            end;
        }
        field(3; "Caption ID"; Text[50])
        {
            Caption = 'Caption Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Clear("Record ID");
                Clear("Field No.");
            end;
        }
        field(4; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language.Code;
        }
        field(11; Caption; Text[250])
        {
            Caption = 'Caption';
            DataClassification = CustomerContent;
        }
        field(12; "Extended Caption"; BLOB)
        {
            Caption = 'Extended Caption';
            DataClassification = CustomerContent;
        }
        field(98; "Screen Sort Order"; Integer)
        {
            Caption = 'Screen Sort Order';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
            Editable = false;
        }
        field(99; "From Original Table"; Boolean)
        {
            Caption = 'From Original Table';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Record ID", "Field No.", "Caption ID", "Language Code")
        {
        }
        key(Key2; "Language Code", "Caption ID") { }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        EnforceRecordIDCaptionCodeRule();
    end;

    trigger OnRename()
    begin
        EnforceRecordIDCaptionCodeRule();
    end;

    var
        Language: Record "Windows Language";

    local procedure EnforceRecordIDCaptionCodeRule()
    var
        BlankRecordID: RecordID;
    begin
        if Format("Record ID") <> '' then
            TestField("Caption ID", '');

        if "Caption ID" <> '' then begin
            TestField("Record ID", BlankRecordID);
            TestField("Field No.", 0);
        end;
    end;

    procedure GetLocalization(CaptionRecordID: RecordID; CaptionFieldNo: Integer): Boolean
    begin
        //-290485 [290485]
        if Language."Language ID" = 0 then
            Language.Get(GlobalLanguage);
        exit(Get(CaptionRecordID, CaptionFieldNo, '', Language."Abbreviated Name") and (Caption <> ''));
        //+290485 [290485]
    end;
}

