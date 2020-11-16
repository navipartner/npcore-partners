page 6014569 "NPR Exp. Wizard Filters"
{
    // NPR5.23/THRO/20160404 CASE 234161 Filters in Export Wizard

    AutoSplitKey = true;
    Caption = 'Export Wizard Filters';
    MultipleNewLines = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "Table Filter";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Number"; "Field Number")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Field": Record "Field";
                        FieldsLookup: Page "Fields Lookup";
                    begin
                        Field.SetRange(TableNo, "Table Number");
                        FieldsLookup.SetTableView(Field);
                        FieldsLookup.LookupMode(true);
                        if FieldsLookup.RunModal = ACTION::LookupOK then begin
                            FieldsLookup.GetRecord(Field);
                            if Field."No." = "Field Number" then
                                exit;
                            CheckDuplicateField(Field);
                            FillSourceRecord(Field);
                            CurrPage.Update(true);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        "Field": Record "Field";
                    begin
                        if Field.Get("Table Number", "Field Number") then
                            FillSourceRecord(Field);
                    end;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Field Filter"; "Field Filter")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckFieldFilter;
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    local procedure FillSourceRecord("Field": Record "Field")
    begin
        SetRange("Field Number");
        Init;

        "Table Number" := Field.TableNo;
        "Table Name" := Field.TableName;
        "Field Number" := Field."No.";
        "Field Name" := Field.FieldName;
        "Field Caption" := Field."Field Caption";
    end;

    procedure AddData(var TempTableFilter: Record "Table Filter")
    var
        "Field": Record "Field";
    begin
        if TempTableFilter.FindSet then
            repeat
                TransferFields(TempTableFilter);
                if Field.Get("Table Number", "Field Number") then begin
                    "Field Name" := Field.FieldName;
                    "Field Caption" := Field."Field Caption";
                end;
                if Insert then;
            until TempTableFilter.Next = 0;
    end;

    procedure GetData(var TempTableFilter: Record "Table Filter")
    var
        TableID: Integer;
    begin
        Clear(Rec);

        if FindSet then
            repeat
                TempTableFilter.TransferFields(Rec);
                TempTableFilter.Insert;
            until Next = 0;
        CurrPage.Update(false);
    end;

    procedure ClearAllData()
    begin
        FilterGroup(4);
        SetRange("Table Number");
        FilterGroup(0);
        DeleteAll;
        CurrPage.Update(false);
    end;

    procedure ClearData()
    begin
        DeleteAll;
        CurrPage.Update(false);
    end;

    local procedure CheckFieldFilter()
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.Open("Table Number");
        FieldRef := RecordRef.Field("Field Number");
        FieldRef.SetFilter("Field Filter");
        "Field Filter" := FieldRef.GetFilter;
        RecordRef.Close;
    end;
}

