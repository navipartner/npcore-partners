table 6059850 "NPR HL MultiChoice Fld Option"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    Caption = 'HL Multi-Choice Field Option';
    DataClassification = CustomerContent;
    LookupPageId = "NPR HL MultiChoice Fld Options";
    DrillDownPageId = "NPR HL MultiChoice Fld Options";

    fields
    {
        field(1; "Field Code"; Code[20])
        {
            Caption = 'Field Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR HL MultiChoice Field".Code;
            NotBlank = true;
        }
        field(2; "Option ID"; Integer)
        {
            Caption = 'Option ID';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Magento Description"; Text[100])
        {
            Caption = 'Magento Description';
            DataClassification = CustomerContent;
        }
        field(30; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
    keys
    {
        key(PK; "Field Code", "Option ID")
        {
            Clustered = true;
        }
        key(DisplaySorting; "Field Code", "Sort Order") { }
        key(Magento; "Magento Description") { }
    }

    trigger OnInsert()
    begin
        TestField("Field Code");
        if "Option ID" = 0 then
            "Option ID" := GetNextOptionID();
        if "Sort Order" = 0 then
            GetNextSortSequenceNo();
    end;

    local procedure GetNextOptionID(): Integer
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
    begin
        HLMultiChoiceFldOption.SetRange("Field Code", "Field Code");
        if HLMultiChoiceFldOption.FindLast() then
            exit(HLMultiChoiceFldOption."Option ID" + 1);
        exit(1);
    end;

    internal procedure GetNextSortSequenceNo()
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
    begin
        if "Field Code" = '' then
            "Field Code" := GetFieldCodeFilter();
        if "Field Code" = '' then
            exit;
        HLMultiChoiceFldOption.SetCurrentKey("Field Code", "Sort Order");
        HLMultiChoiceFldOption.SetRange("Field Code", "Field Code");
        if HLMultiChoiceFldOption.IsEmpty() then
            "Sort Order" := 10
        else begin
            HLMultiChoiceFldOption.FindLast();
            "Sort Order" := HLMultiChoiceFldOption."Sort Order" div 10 * 10 + 10;
        end;
    end;

    internal procedure GetFieldCodeFilter() FieldCode: Code[20]
    begin
        FieldCode := GetFilterFieldCode();
        if FieldCode = '' then begin
            FilterGroup(2);
            FieldCode := GetFilterFieldCode();
            if FieldCode = '' then
                FieldCode := GetFilterFieldCodByApplyingFilter();
            FilterGroup(0);
        end;
    end;

    local procedure GetFilterFieldCode(): Code[20]
    var
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if GetFilter("Field Code") <> '' then begin
            if TryGetFilterFieldCodeRange(MinValue, MaxValue) then
                if MinValue = MaxValue then
                    exit(MaxValue);
        end;
    end;

    [TryFunction]
    local procedure TryGetFilterFieldCodeRange(var MinValue: Code[20]; var MaxValue: Code[20])
    begin
        MinValue := GetRangeMin("Field Code");
        MaxValue := GetRangeMax("Field Code");
    end;

    local procedure GetFilterFieldCodByApplyingFilter(): Code[20]
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if GetFilter("Field Code") = '' then
            exit('');
        HLMultiChoiceFldOption.CopyFilters(Rec);
        if HLMultiChoiceFldOption.FindFirst() then
            MinValue := HLMultiChoiceFldOption."Field Code";
        if HLMultiChoiceFldOption.FindLast() then
            MaxValue := HLMultiChoiceFldOption."Field Code";
        if MinValue = MaxValue then
            exit(MaxValue);
    end;
}
