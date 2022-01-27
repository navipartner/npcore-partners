table 6151104 "NPR NpRi Party Type"
{
    Access = Internal;
    Caption = 'Reimbursement Party Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRi Party Types";
    LookupPageID = "NPR NpRi Party Types";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'Table No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempTableMetadata: Record "Table Metadata" temporary;
                TempAllObjWithCaption: Record AllObjWithCaption temporary;
                NpRiSetupMgt: Codeunit "NPR NpRi Setup Mgt.";
            begin
                NpRiSetupMgt.SetupPartyTypeTableNoLookup(TempTableMetadata);
                if not TempTableMetadata.FindSet() then
                    exit;

                repeat
                    TempAllObjWithCaption.Init();
                    TempAllObjWithCaption."Object Type" := TempAllObjWithCaption."Object Type"::Table;
                    TempAllObjWithCaption."Object ID" := TempTableMetadata.ID;
                    TempAllObjWithCaption."Object Name" := TempTableMetadata.Name;
                    TempAllObjWithCaption."Object Caption" := TempTableMetadata.Caption;
                    TempAllObjWithCaption.Insert();
                until TempTableMetadata.Next() = 0;

                if TempAllObjWithCaption.Get(TempAllObjWithCaption."Object Type"::Table, "Table No.") then;
                if PAGE.RunModal(PAGE::"Table Objects", TempAllObjWithCaption) <> ACTION::LookupOK then
                    exit;

                Validate("Table No.", TempAllObjWithCaption."Object ID");
            end;

            trigger OnValidate()
            var
                TempTableMetadata: Record "Table Metadata" temporary;
                NpRiSetupMgt: Codeunit "NPR NpRi Setup Mgt.";
            begin
                if "Table No." = 0 then
                    exit;

                NpRiSetupMgt.SetupPartyTypeTableNoLookup(TempTableMetadata);
                if not TempTableMetadata.Get("Table No.") then
                    Error(Text000);
            end;
        }
        field(15; "Table Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Reimburse every"; DateFormula)
        {
            Caption = 'Reimburse every';
            DataClassification = CustomerContent;
        }
        field(105; "Next Posting Date Calculation"; DateFormula)
        {
            Caption = 'Next Posting Date Calculation';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        NpRiParty: Record "NPR NpRi Party";
    begin
        NpRiParty.SetRange("Party Type", Code);
        if NpRiParty.FindFirst() then
            Error(Text001, NpRiParty."No.");
    end;

    var
        Text000: Label 'Invalid Party Table No.';
        Text001: Label 'Unable to delete as Reimbursement Party %1 is using this Party Type';
}

