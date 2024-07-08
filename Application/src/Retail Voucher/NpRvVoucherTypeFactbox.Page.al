page 6151489 "NPR NpRv Voucher Type Factbox"
{
    Caption = 'NpRv Voucher Type Factbox';
    PageType = ListPart;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    Editable = true;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Description; Rec.Name)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    var
                    begin
                        DrilldownCalculatedField();
                    end;
                }
            }
        }
    }

# pragma warning disable AA0139
    internal procedure InitData(VoucherType: Record "NPR NpRv Voucher Type"; Params: Dictionary of [Text, Text])
    begin
        Rec.DeleteAll();
        _VoucherType := VoucherType;
        if Params.ContainsKey(Format(VoucherType.FieldNo("Voucher Qty. (Open)"))) then
            InsertRec(1, VoucherType.FieldCaption("Voucher Qty. (Open)"), LoadingTxt);
        if Params.ContainsKey(Format(VoucherType.FieldNo("Voucher Qty. (Closed)"))) then
            InsertRec(2, VoucherType.FieldCaption("Voucher Qty. (Closed)"), LoadingTxt);
        if Params.ContainsKey(Format(VoucherType.FieldNo("Arch. Voucher Qty."))) then
            InsertRec(3, VoucherType.FieldCaption("Arch. Voucher Qty."), LoadingTxt);
        CurrPage.Update(false);
    end;

    internal procedure FinishFillData(Results: Dictionary of [Text, Text])
    begin
        ModifyRec(1, GetFieldValueFromBackgroundTaskResultSet(Results, Format(_VoucherType.FieldNo("Voucher Qty. (Open)"))));
        ModifyRec(2, GetFieldValueFromBackgroundTaskResultSet(Results, Format(_VoucherType.FieldNo("Voucher Qty. (Closed)"))));
        ModifyRec(3, GetFieldValueFromBackgroundTaskResultSet(Results, Format(_VoucherType.FieldNo("Arch. Voucher Qty."))));
    end;
#pragma warning restore

    local procedure InsertRec(pId: integer; pName: Text[250]; pValue: Text[250])
    begin
        Rec.Init();
        Rec.ID := pId;
        Rec.Name := pName;
        Rec.Value := pValue;
        Rec.Insert();
    end;

    local procedure ModifyRec(pId: integer; pValue: Text[250])
    var
    begin
        if Rec.Get(pId) then begin
            Rec.Value := pValue;
            Rec.Modify();
        end;
    end;

    local procedure GetFieldValueFromBackgroundTaskResultSet(var BackgroundTaskResults: Dictionary of [Text, Text]; FieldNo: Text) Result: Text
    begin
        if not BackgroundTaskResults.ContainsKey(FieldNo) then
            exit('0');
        Result := BackgroundTaskResults.Get(FieldNo);
        if Result = '' then
            Result := '0';
    end;

    local procedure DrilldownCalculatedField()
    var
    begin
        Case Rec.ID of
            1:
                _VoucherType.DrilldownCalculatedFields(_VoucherType.FieldNo("Voucher Qty. (Open)"));
            2:
                _VoucherType.DrilldownCalculatedFields(_VoucherType.FieldNo("Voucher Qty. (Closed)"));
            3:
                _VoucherType.DrilldownCalculatedFields(_VoucherType.FieldNo("Arch. Voucher Qty."));
        End;
    end;

    var
        _VoucherType: Record "NPR NpRv Voucher Type";
        LoadingTxt: Label 'Loading...', Locked = true;


}
