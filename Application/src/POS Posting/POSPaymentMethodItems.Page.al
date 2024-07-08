page 6150716 "NPR POS Payment Method Items"
{
    AutoSplitKey = true;
    Caption = 'POS Payment Method Items';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/create_payment_method/';
    DelayedInsert = true;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR POS Payment Method Item";
    SourceTableView = sorting("POS Payment Method Code", "Line No.")
                      where("Line No." = filter(>= 0));
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field.';
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Add Items")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Add Items';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Adds item records based on selected criteria.';

                trigger OnAction()
                begin
                    AddItems();
                end;
            }
        }
    }

    local procedure AddItems()
    var
        Item: Record Item;
    begin
        if not RunDynamicRequestPage(Item) then
            exit;

        InsertItems(Item);
        CurrPage.Update(false);
    end;

    local procedure RunDynamicRequestPage(var Item: Record Item): Boolean
    var
        TableMetadata: Record "Table Metadata";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        FilterPageBuilder: FilterPageBuilder;
        EntityID: Code[20];
        AddItemsTxt: Label 'Add Items';
        OutStream: OutStream;
        ReturnFilters: Text;
    begin
        RecRef.GetTable(Item);
        TableMetadata.Get(RecRef.Number);
        EntityID := CopyStr(AddItemsTxt, 1, 20);
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number) then
            exit(false);

        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("No."));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Vendor No."));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Item Category Code"));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Item Disc. Group"));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Search Description"));
        FilterPageBuilder.PageCaption := AddItemsTxt;
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters := RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number);

        RecRef.Reset();
        if ReturnFilters <> '' then begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(ReturnFilters);
            if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
                exit(false);
        end;

        RecRef.SetTable(Item);
        exit(not Item.IsEmpty());
    end;

    local procedure InsertItems(var Item: Record Item)
    var
        POSPaymentMethodItem: Record "NPR POS Payment Method Item";
        PaymentMethodCode: Code[10];
        LineNo: Integer;
    begin
        PaymentMethodCode := Rec.GetRangeMax("POS Payment Method Code");
        if PaymentMethodCode = '' then
            exit;

        POSPaymentMethodItem.SetRange("POS Payment Method Code", PaymentMethodCode);
        if POSPaymentMethodItem.FindLast() then
            LineNo := POSPaymentMethodItem."Line No.";

        Item.FindSet();
        repeat
            POSPaymentMethodItem.SetRange("POS Payment Method Code", PaymentMethodCode);
            POSPaymentMethodItem.SetRange(Type, POSPaymentMethodItem.Type::Item);
            POSPaymentMethodItem.SetRange("No.", Item."No.");
            if POSPaymentMethodItem.IsEmpty() then begin
                LineNo += 10000;
                POSPaymentMethodItem.Init();
                POSPaymentMethodItem."POS Payment Method Code" := PaymentMethodCode;
                POSPaymentMethodItem."Line No." := LineNo;
                POSPaymentMethodItem.Type := POSPaymentMethodItem.Type::Item;
                POSPaymentMethodItem.Validate("No.", Item."No.");
                POSPaymentMethodItem.Insert(true);
            end;
        until Item.Next() = 0;
    end;
}

