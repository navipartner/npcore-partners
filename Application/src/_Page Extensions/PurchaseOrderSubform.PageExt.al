pageextension 6014457 "NPR Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        addafter("No.")
        {
            field("NPR Vendor Item No."; Rec."Vendor Item No.")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Vendor Item No. field';
            }
        }
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Description 2 field';
            }
        }
        addafter("Line No.")
        {
            field("NPR Exchange Label"; ExchangeLabelTableMap.Barcode)
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Exchange Label field';

                trigger OnValidate()
                var
                    ExchangeLabel: Record "NPR Exchange Label";
                    ItemCheck: Record Item;
                    ExchangeLabelMultiple: Record "NPR Exchange Label";
                    PurchaseLineCheck: Record "Purchase Line";
                    PurchaseLineInsrt: Record "Purchase Line";
                    ExchangeLabelTableMapInsrt: Record "NPR Exchange Label Map";
                begin
                    ExchangeLabel.Reset();
                    ExchangeLabel.SetRange(Barcode, ExchangeLabelTableMap.Barcode);
                    if ExchangeLabel.FindFirst() then begin
                        Rec.Validate(Type, Rec.Type::Item);
                        Rec.Validate("No.", ExchangeLabel."Item No.");
                        Rec.Validate("Variant Code", ExchangeLabel."Variant Code");
                        Rec.Validate(Quantity, ExchangeLabel.Quantity);
                        ItemCheck.Reset();
                        if ItemCheck.Get(Rec."No.") then
                            Rec.Validate("Direct Unit Cost", ItemCheck."Unit Cost");

                        CurrPage.Update();
                        ExchangeLabelTableMap.CreateOrUpdateFromPurhaseLine(Rec, ExchangeLabel.Barcode);

                        if ExchangeLabel."Sales Ticket No." <> '' then begin
                            ExchangeLabelMultiple.Reset();
                            ExchangeLabelMultiple.SetFilter(Barcode, '<>%1', ExchangeLabelTableMap.Barcode);
                            ExchangeLabelMultiple.SetFilter("No.", '<>%1', ExchangeLabel."No.");
                            ExchangeLabelMultiple.SetRange("Store ID", ExchangeLabel."Store ID");
                            ExchangeLabelMultiple.SetRange("Sales Ticket No.", ExchangeLabel."Sales Ticket No.");
                            if ExchangeLabelMultiple.Count() > 0 then begin
                                if ExchangeLabelMultiple.FindSet() then
                                    repeat
                                        PurchaseLineCheck.Reset();
                                        PurchaseLineCheck.SetRange("Document Type", Rec."Document Type");
                                        PurchaseLineCheck.SetRange("Document No.", Rec."Document No.");
                                        if PurchaseLineCheck.FindLast() then;

                                        PurchaseLineInsrt.Reset();
                                        PurchaseLineInsrt.Init();
                                        PurchaseLineInsrt.Validate("Document Type", Rec."Document Type");
                                        PurchaseLineInsrt.Validate("Document No.", Rec."Document No.");
                                        PurchaseLineInsrt."Line No." := PurchaseLineCheck."Line No." + 10000;
                                        PurchaseLineInsrt.Validate(Type, PurchaseLineInsrt.Type::Item);
                                        PurchaseLineInsrt.Validate("Buy-from Vendor No.", Rec."Buy-from Vendor No.");
                                        PurchaseLineInsrt.Validate("No.", ExchangeLabelMultiple."Item No.");
                                        PurchaseLineInsrt.Validate("Variant Code", ExchangeLabelMultiple."Variant Code");
                                        PurchaseLineInsrt.Validate(Quantity, ExchangeLabelMultiple.Quantity);
                                        ItemCheck.Reset();
                                        if ItemCheck.Get(ExchangeLabelMultiple."Item No.") then
                                            PurchaseLineInsrt.Validate("Direct Unit Cost", ItemCheck."Unit Cost");
                                        PurchaseLineInsrt.Insert();

                                        ExchangeLabelTableMapInsrt.CreateOrUpdateFromPurhaseLine(PurchaseLineInsrt, ExchangeLabelMultiple.Barcode);

                                        CurrPage.Update();
                                    until ExchangeLabelMultiple.Next() = 0;
                            end;
                        end;
                    end;
                end;
            }
        }
    }
    actions
    {
        addafter(DocAttach)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea = All;
                ToolTip = 'Executes the Variety action';
            }
        }
        addafter(OrderTracking)
        {
            action("NPR Nonstockitems")
            {
                AccessByPermission = TableData "Nonstock Item" = R;
                Caption = 'Nonstoc&k Items';
                Image = NonStockItem;
                ApplicationArea = All;
                ToolTip = 'Executes the Nonstoc&k Items action';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if not ExchangeLabelTableMap.Get(Database::"Purchase Line", Rec.SystemId) then
            Clear(ExchangeLabelTableMap);
    end;

    var
        ExchangeLabelTableMap: Record "NPR Exchange Label Map";
}