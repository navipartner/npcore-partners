#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150924 "NPR Ecom Voucher Sub"
{
    Caption = 'Vouchers';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR NpRv Voucher";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the voucher number.';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the voucher reference number presented to the customer.';
                }
                field("Voucher Type"; Rec."Voucher Type")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the voucher type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the voucher description. Archived vouchers are prefixed with [Archived].';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies when the voucher became valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies when the voucher expires.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenVoucher)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected voucher (live or archived) to see full details, amounts and entries.';

                trigger OnAction()
                var
                    EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
                begin
                    EcomCreateVchrImpl.OpenVoucherCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        if EcomCreateVchrImpl.IsArchivedTempDescription(Rec.Description) then
            _RowStyle := 'Subordinate'
        else
            _RowStyle := 'Standard';
    end;

    /// <summary>
    /// Clears the temp buffer. Called by the parent page before enqueueing a background task
    /// or on task error.
    /// </summary>
    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        CurrPage.Update(false);
    end;

    /// <summary>
    /// Populates the temp buffer from a JSON array payload produced by the parent's background
    /// task. Insert(false, true): preserve SystemId for the Open action, skip OnInsert which
    /// would error because the reference already exists in the real table.
    /// </summary>
    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        VouchersJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and VouchersJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(VouchersJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(VouchersJson: JsonArray)
    var
        VoucherToken: JsonToken;
        VoucherObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
    begin
        foreach VoucherToken in VouchersJson do begin
            VoucherObj := VoucherToken.AsObject();
            Rec.Init();
            if VoucherObj.Get('No', FieldToken) then
                Rec."No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."No."));
            if VoucherObj.Get('Ref', FieldToken) then
                Rec."Reference No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Reference No."));
            if VoucherObj.Get('Type', FieldToken) then
                Rec."Voucher Type" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Voucher Type"));
            if VoucherObj.Get('Desc', FieldToken) then
                Rec.Description := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.Description));
            if VoucherObj.Get('Start', FieldToken) then
                Rec."Starting Date" := FieldToken.AsValue().AsDateTime();
            if VoucherObj.Get('End', FieldToken) then
                Rec."Ending Date" := FieldToken.AsValue().AsDateTime();
            if VoucherObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            Rec.Insert(false, true);
        end;
    end;

    var
        _RowStyle: Text;
}
#endif
