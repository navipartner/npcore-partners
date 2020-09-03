page 6151607 "NPR NpDc ExtraItemQty. Subform"
{
    // NPR5.47/MHA /20181026  CASE 332655 Object created

    AutoSplitKey = true;
    Caption = 'Coupon List Items';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR NpDc Coupon List Item";
    SourceTableView = SORTING("Coupon Type", "Line No.")
                      WHERE("Line No." = FILTER(>= 0));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. per Lot"; "Validation Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. per Lot';
                    Visible = (LotValidation);
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
                PromotedCategory = Process;
                PromotedIsBig = true;

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
        MaxDiscountAmt: Decimal;
        MaxQty: Decimal;
        ValidQty: Integer;
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
        FilterGroup(2);
        CouponType := GetRangeMax("Coupon Type");
        FilterGroup(0);
        if CouponType = '' then
            exit;

        NpDcCouponListItem.SetRange("Coupon Type", CouponType);
        if NpDcCouponListItem.FindLast then;
        LineNo := NpDcCouponListItem."Line No.";

        Item.FindSet;
        repeat
            NpDcCouponListItem.SetRange("Coupon Type", CouponType);
            NpDcCouponListItem.SetRange(Type, NpDcCouponListItem.Type::Item);
            NpDcCouponListItem.SetRange("No.", Item."No.");
            if NpDcCouponListItem.IsEmpty then begin
                LineNo += 10000;
                NpDcCouponListItem.Init;
                NpDcCouponListItem."Coupon Type" := CouponType;
                NpDcCouponListItem."Line No." := LineNo;
                NpDcCouponListItem.Type := NpDcCouponListItem.Type::Item;
                NpDcCouponListItem.Validate("No.", Item."No.");
                NpDcCouponListItem.Priority := NewPriority;
                NpDcCouponListItem.Insert(true);
            end;
        until Item.Next = 0;
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
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("NPR Item Group"));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Item Disc. Group"));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Search Description"));
        FilterPageBuilder.PageCaption := Text000;
        if not FilterPageBuilder.RunModal then
            exit(false);

        ReturnFilters := RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number);

        RecRef.Reset;
        if ReturnFilters <> '' then begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(ReturnFilters);
            if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
                exit(false);
        end;

        RecRef.SetTable(Item);
        exit(Item.FindFirst);
    end;

    procedure SetLotValidation(NewLotValidation: Boolean)
    begin
        LotValidation := NewLotValidation;
    end;
}

