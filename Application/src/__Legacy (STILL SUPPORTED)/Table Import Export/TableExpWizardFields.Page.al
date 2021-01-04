page 6014457 "NPR Table Exp. Wizard Fields"
{
    // NPR5.23/THRO/20160404 CASE 234161 Remove all filters before deleting all records in Clearall + Add ClearData for deleting single table records

    Caption = 'Table Export Wizard Fields';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "Field";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6150619)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Field": Record "Field";
                        "Fields": Page "Fields Lookup";
                        TableNo: Integer;
                    begin
                        TableNo := GetRangeMin(TableNo);
                        Field.SetRange(TableNo, TableNo);

                        if "No." > 0 then
                            if Field.Get(TableNo, "No.") then;

                        Fields.SetTableView(Field);
                        Fields.SetRecord(Field);
                        Fields.LookupMode(true);

                        if Fields.RunModal = ACTION::LookupOK then begin
                            Fields.GetRecord(Field);
                            TransferFields(Field);
                            Insert;
                        end;
                    end;
                }
                field(FieldName; FieldName)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the FieldName field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Len; Len)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Len field';
                }
                field(Class; Class)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Class field';
                }
            }
        }
    }

    actions
    {
    }

    procedure AddField(TableNoIn: Integer; FieldNoIn: Integer)
    var
        "Field": Record "Field";
    begin
        Field.Get(TableNoIn, FieldNoIn);
        TransferFields(Field);
        if Insert then CurrPage.Update(false);
    end;

    procedure ClearAllData()
    begin
        //-NPR5.23
        FilterGroup(4);
        SetRange(TableNo);
        FilterGroup(0);
        //+NPR5.23
        DeleteAll;
        CurrPage.Update(false);
    end;

    procedure ClearData()
    begin
        //-NPR5.23
        DeleteAll;
        CurrPage.Update(false);
        //+NPR5.23
    end;

    procedure GetFields(var TempFields: Record "Field")
    var
        TableID: Integer;
    begin
        Clear(Rec);

        if FindSet then
            repeat
                TempFields.TransferFields(Rec);
                TempFields.Insert;
            until Next = 0;
        CurrPage.Update(false);
    end;
}

