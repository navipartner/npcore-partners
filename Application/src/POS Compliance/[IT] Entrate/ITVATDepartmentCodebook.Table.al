table 6150751 "NPR IT VAT Department Codebook"
{
    Access = Internal;
    Caption = 'IT VAT Department Codebook';
    DataClassification = CustomerContent;
    LookupPageId = "NPR IT VAT Department Codebook";
    DrillDownPageId = "NPR IT VAT Department Codebook";
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "POS Unit No."; Code[20])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(3; "IT Printer VAT Department"; Enum "NPR IT Printer Departments")
        {
            Caption = 'Printer VAT Department';
            DataClassification = CustomerContent;
        }
        field(4; "IT Printer VAT %"; Decimal)
        {
            Caption = 'Printer VAT %';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "POS Unit No.")
        { }
    }

    internal procedure InitVATDepartmentsForPOSUnit(var POSUnit: Record "NPR POS Unit")
    var
        ITVATDepartmentCodebook: Record "NPR IT VAT Department Codebook";
        CodebookEntryCount: Integer;
        i: Integer;
    begin
        ITVATDepartmentCodebook.SetRange("POS Unit No.", POSUnit."No.");
        if not ITVATDepartmentCodebook.IsEmpty() then
            ITVATDepartmentCodebook.DeleteAll();

        CodebookEntryCount := GetLastEntryNo();

        for i := 1 to 19 do begin
            ITVATDepartmentCodebook.Init();
            CodebookEntryCount += 1;
            ITVATDepartmentCodebook."Entry No." := CodebookEntryCount;
            ITVATDepartmentCodebook."POS Unit No." := POSUnit."No.";
            ITVATDepartmentCodebook."IT Printer VAT Department" := "NPR IT Printer Departments".FromInteger(i);
            if i in [10 .. 18] then
                ITVATDepartmentCodebook."IT Printer VAT %" := 0;
            ITVATDepartmentCodebook.Insert();
        end;
    end;

    internal procedure InitVATDepartmentForPOSUnit(var ITVATDepartmentCodebook: Record "NPR IT VAT Department Codebook"; ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; VATPercentage: Decimal; DepartmentNumber: Integer)
    var
        CodebookEntryCount: Integer;
    begin
        CodebookEntryCount := GetLastEntryNo();

        ITVATDepartmentCodebook.Init();
        CodebookEntryCount += 1;
        ITVATDepartmentCodebook."Entry No." := CodebookEntryCount;
        ITVATDepartmentCodebook."POS Unit No." := ITPOSUnitMapping."POS Unit No.";
        ITVATDepartmentCodebook."IT Printer VAT Department" := "NPR IT Printer Departments".FromInteger(DepartmentNumber);
        ITVATDepartmentCodebook."IT Printer VAT %" := VATPercentage;
    end;

    local procedure GetLastEntryNo(): Integer
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;
}