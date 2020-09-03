table 6151105 "NPR NpRi Party"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Party';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRi Parties";
    LookupPageID = "NPR NpRi Parties";

    fields
    {
        field(1; "Party Type"; Code[20])
        {
            Caption = 'Party Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRi Party Type";

            trigger OnValidate()
            var
                NpRiPartyType: Record "NPR NpRi Party Type";
            begin
                if "Party Type" = '' then
                    exit;

                NpRiPartyType.Get("Party Type");
                "Reimburse every" := NpRiPartyType."Reimburse every";
                "Next Posting Date Calculation" := NpRiPartyType."Next Posting Date Calculation";
            end;
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnLookup()
            var
                TableMetadata: Record "Table Metadata";
                RecRef: RecordRef;
                KeyRef: KeyRef;
                FieldRef: FieldRef;
                RecRefVariant: Variant;
            begin
                CalcFields("Table No.");
                if "Table No." <= 0 then
                    exit;
                if not TableMetadata.Get("Table No.") then
                    exit;
                if TableMetadata.LookupPageID <= 0 then
                    exit;

                RecRef.Open("Table No.");
                KeyRef := RecRef.KeyIndex(1);
                FieldRef := KeyRef.FieldIndex(1);

                if "No." <> '' then begin
                    FieldRef.SetFilter('%1', "No.");
                    if RecRef.FindFirst then;
                    FieldRef.SetRange();
                end;

                RecRefVariant := RecRef;
                if PAGE.RunModal(TableMetadata.LookupPageID, RecRefVariant) <> ACTION::LookupOK then
                    exit;

                Validate("No.", Format(FieldRef.Value));
            end;

            trigger OnValidate()
            var
                TableMetadata: Record "Table Metadata";
                DataTypeMgt: Codeunit "Data Type Management";
                RecRef: RecordRef;
                KeyRef: KeyRef;
                FieldRef: FieldRef;
            begin
                CalcFields("Table No.");
                if "Table No." <= 0 then
                    exit;
                if not TableMetadata.Get("Table No.") then
                    exit;
                if TableMetadata.LookupPageID <= 0 then
                    exit;

                RecRef.Open("Table No.");
                KeyRef := RecRef.KeyIndex(1);
                FieldRef := KeyRef.FieldIndex(1);

                if "No." <> '' then begin
                    FieldRef.SetFilter('%1', "No.");
                    if RecRef.FindFirst then;
                    FieldRef.SetRange();
                end;

                Name := '';
                if DataTypeMgt.FindFieldByName(RecRef, FieldRef, FieldName(Name)) then
                    Name := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(Name));
            end;
        }
        field(10; "Table No."; Integer)
        {
            BlankZero = true;
            CalcFormula = Lookup ("NPR NpRi Party Type"."Table No." WHERE(Code = FIELD("Party Type")));
            Caption = 'Table No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
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
        key(Key1; "Party Type", "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpRiReimbursement: Record "NPR NpRi Reimbursement";
        NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
    begin
        NpRiReimbursement.SetRange("Party Type", "Party Type");
        NpRiReimbursement.SetRange("Party No.", "No.");
        NpRiReimbursementEntry.SetCurrentKey("Party Type", "Party No.", "Template Code", "Entry Type", Open, "Posting Date");
        NpRiReimbursementEntry.SetRange("Party Type", "Party Type");
        NpRiReimbursementEntry.SetRange("Party No.", "No.");
        if NpRiReimbursement.FindFirst or NpRiReimbursementEntry.FindFirst then begin
            if not Confirm(Text000, false) then
                Error(Text001);

            NpRiReimbursementEntry.DeleteAll;
            NpRiReimbursement.DeleteAll;
        end;
    end;

    var
        Text000: Label 'Are you sure you want to delete this Party including all Reimbursements?';
        Text001: Label 'Delete aborted';
}

