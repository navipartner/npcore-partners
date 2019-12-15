table 6059778 "Sync Profile Setup"
{
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 4

    Caption = 'Sync Profile Setup';
    DataPerCompany = false;

    fields
    {
        field(1;"Synchronisation Profile";Code[20])
        {
            Caption = 'Synchronisation Profile';
            TableRelation = "Company Sync Profiles"."Synchronisation Profile";
        }
        field(2;"Table No.";Integer)
        {
            Caption = 'Table No.';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(3;"Record Synchronisation Type";Option)
        {
            Caption = 'Record Synchronisation Type';
            OptionCaption = 'All,Create,Modify,Delete';
            OptionMembers = All,Create,Modify,Delete;
        }
        field(4;"Field Synchronisation Type";Option)
        {
            Caption = 'Field Synchronisation Type';
            OptionCaption = 'Full,Partial';
            OptionMembers = Full,Partial;
        }
        field(5;"Synchronisation Type";Option)
        {
            Caption = 'Synchronisation Type';
            OptionCaption = 'Navision';
            OptionMembers = Navision;
        }
        field(6;Description;Text[100])
        {
            Caption = 'Description';
        }
        field(7;Enabled;Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
        }
    }

    keys
    {
        key(Key1;"Synchronisation Profile","Table No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        addTableDescription;
    end;

    trigger OnRename()
    begin
        addTableDescription;
    end;

    var
        objectRecord: Record "Object";
        AllObj: Record AllObj;

    procedure addTableDescription()
    begin
        //-NPR5.46 [322752]
        // CLEAR(objectRecord);
        // objectRecord.INIT;
        // objectRecord.SETRANGE(Type, objectRecord.Type::Table);
        // objectRecord.SETRANGE(ID, "Table No.");
        // IF objectRecord.FIND('-') THEN
        //  Description := objectRecord.Name;

         Clear(AllObj);
         AllObj.Init;
         AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
         AllObj.SetRange("Object ID", "Table No.");
         if AllObj.Find('-') then
          Description := AllObj."Object Name";
        //+NPR5.46 [322752]
    end;
}

