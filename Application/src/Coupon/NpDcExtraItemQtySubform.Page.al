page 6151607 "NPR NpDc ExtraItemQty. Subform"
{
    AutoSplitKey = true;
    Caption = 'Coupon List Items';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR NpDc Coupon List Item";
    SourceTableView = SORTING("Coupon Type", "Line No.")
                      WHERE("Line No." = FILTER(>= 0));
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. per Lot"; Rec."Validation Quantity")
                {

                    Caption = 'Qty. per Lot';
                    Visible = (LotValidation);
                    ToolTip = 'Specifies the value of the Qty. per Lot field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Add Items")
            {
                Caption = 'Add Items';
                Image = Add;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Add Items action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    //-NPR5.36 [291016]
                    AddItems();
                    //+NPR5.36 [291016]
                end;
            }
        }
    }

    var
        Text000: Label 'Add Items';
        LotValidation: Boolean;

    local procedure AddItems()
    var
        Item: Record Item;
        NpDcRequestPriority: Report "NPR NpDc Request Priority";
        NewPriority: Integer;
    begin
        if not RunDynamicRequestPage(Item) then
            exit;
        if not NpDcRequestPriority.RequestPriority(NewPriority) then
            exit;

        InsertItems(Item, NewPriority);
        CurrPage.Update(false);
    end;

    local procedure InsertItems(var Item: Record Item; NewPriority: Integer)
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        CouponType: Code[20];
        LineNo: Integer;
    begin
        Rec.FilterGroup(2);
        CouponType := Rec.GetRangeMax("Coupon Type");
        Rec.FilterGroup(0);
        if CouponType = '' then
            exit;

        NpDcCouponListItem.SetRange("Coupon Type", CouponType);
        if NpDcCouponListItem.FindLast() then;
        LineNo := NpDcCouponListItem."Line No.";

        Item.FindSet();
        repeat
            NpDcCouponListItem.SetRange("Coupon Type", CouponType);
            NpDcCouponListItem.SetRange(Type, NpDcCouponListItem.Type::Item);
            NpDcCouponListItem.SetRange("No.", Item."No.");
            if NpDcCouponListItem.IsEmpty then begin
                LineNo += 10000;
                NpDcCouponListItem.Init();
                NpDcCouponListItem."Coupon Type" := CouponType;
                NpDcCouponListItem."Line No." := LineNo;
                NpDcCouponListItem.Type := NpDcCouponListItem.Type::Item;
                NpDcCouponListItem.Validate("No.", Item."No.");
                NpDcCouponListItem.Priority := NewPriority;
                NpDcCouponListItem.Insert(true);
            end;
        until Item.Next() = 0;
    end;

    local procedure RunDynamicRequestPage(var Item: Record Item): Boolean
    var
        RecRef: RecordRef;
        TableMetadata: Record "Table Metadata";
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        OutStream: OutStream;
        ReturnFilters: Text;
        EntityID: Code[20];
    begin
        Clear(Item);
        RecRef.GetTable(Item);
        TableMetadata.Get(RecRef.Number);
        EntityID := CopyStr(Text000, 1, 20);
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number) then
            exit(false);

        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("No."));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Vendor No."));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Item Category Code"));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Item Disc. Group"));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Search Description"));
        FilterPageBuilder.PageCaption := Text000;
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters := RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number);

        RecRef.Reset();
        if ReturnFilters <> '' then begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(ReturnFilters);
            if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
                exit(false);
        end;

        RecRef.SetTable(Item);
        exit(Item.FindFirst());
    end;

    procedure SetLotValidation(NewLotValidation: Boolean)
    begin
        LotValidation := NewLotValidation;
    end;
}

