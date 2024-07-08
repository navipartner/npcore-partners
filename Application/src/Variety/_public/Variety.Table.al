table 6059971 "NPR Variety"
{
    // NPR4.16/JDH/20151022 CASE 225661 Changed NotBlank to yes, to avoid blank primary key value
    // VRT1.11/JDH /20160602 CASE 242940 Captions added

    Caption = 'Variety';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Variety";
    LookupPageID = "NPR Variety";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            trigger OnValidate()
            begin
                CheckForSpecialCharacters();
            end;
        }
        field(10; Description; Text[30])
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

            trigger OnValidate()
            var
                VrtTable: Record "NPR Variety Table";
            begin
                //-VRT1.11
                if "Pre tag In Variant Description" <> xRec."Pre tag In Variant Description" then
                    if Confirm(Text001) then begin
                        VrtTable.SetRange(Type, Code);
                        VrtTable.ModifyAll("Pre tag In Variant Description", "Pre tag In Variant Description");
                    end;
                //+VRT1.11
            end;
        }
        field(22; "Use Description field"; Boolean)
        {
            Caption = 'Use Description Field';
            DataClassification = CustomerContent;
        }

        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key3; SystemRowVersion)
        {
        }
#ENDIF
    }

    fieldgroups
    {
    }
    trigger OnInsert()
    begin
        TestField(Description);
    end;

    trigger OnModify()
    begin
        TestField(Description);
    end;

    trigger OnDelete()
    var
        VRTTable: Record "NPR Variety Table";
    begin
        VRTTable.SetRange(Type, Code);
        VRTTable.DeleteAll(true);
    end;

    local procedure CheckForSpecialCharacters()
    var
        Reg: Codeunit "NPR RegEx";
        SpecialCharsErr: Label 'Only A-Z 0-9 and _ are allowed';
    begin
        if "Code" = '' then
            exit;
        if not Reg.IsMatch("Code", '^[a-zA-Z0-9 _]*$') then //only allowed letters, numbers and underscore
            Error(SpecialCharsErr);
    end;

    var
        Text001: Label 'Do you wish to update all related Variety Table Values?';
}

