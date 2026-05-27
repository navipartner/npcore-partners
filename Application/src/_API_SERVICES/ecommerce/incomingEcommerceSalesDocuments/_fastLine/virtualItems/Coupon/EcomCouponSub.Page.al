#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150948 "NPR Ecom Coupon Sub"
{
    Caption = 'Coupons';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR NpDc Coupon";
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
                    ToolTip = 'Specifies the coupon number.';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customer-facing reference number.';
                }
                field("Coupon Type"; Rec."Coupon Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the coupon type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the coupon description.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the coupon became valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the coupon expires.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenCoupon)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected coupon to see full details and entries.';

                trigger OnAction()
                var
                    EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
                begin
                    EcomCreateCouponImpl.OpenCouponCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        CurrPage.Update(false);
    end;

    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        CouponsJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and CouponsJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(CouponsJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(CouponsJson: JsonArray)
    var
        CouponToken: JsonToken;
        CouponObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
    begin
        foreach CouponToken in CouponsJson do begin
            CouponObj := CouponToken.AsObject();
            Rec.Init();
            if CouponObj.Get('No', FieldToken) then
                Rec."No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."No."));
            if CouponObj.Get('Ref', FieldToken) then
                Rec."Reference No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Reference No."));
            if CouponObj.Get('Type', FieldToken) then
                Rec."Coupon Type" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Coupon Type"));
            if CouponObj.Get('Desc', FieldToken) then
                Rec.Description := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.Description));
            if CouponObj.Get('Start', FieldToken) then
                Rec."Starting Date" := FieldToken.AsValue().AsDateTime();
            if CouponObj.Get('End', FieldToken) then
                Rec."Ending Date" := FieldToken.AsValue().AsDateTime();
            if CouponObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            Rec.Insert(false, true);
        end;
    end;
}
#endif
