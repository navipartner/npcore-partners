pageextension 6014457 "NPR Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
                NPRVarietySetup: Record "NPR Variety Setup";
                VRTWrapper: Codeunit "NPR Variety Wrapper";
            begin
                if not NPRVarietySetup.Get() then
                    exit;
                if not NPRVarietySetup."Pop up Variety Matrix" then
                    exit;
                if (Rec.Type = Rec.Type::Item) and Item.Get(Rec."No.") then begin
                    Item.CalcFields("NPR Has Variants");
                    if Item."NPR Has Variants" then
                        VRTWrapper.PurchLineShowVariety(Rec, 0);
                end;
            end;
        }
        addafter("No.")
        {
            field("NPR Vendor Item No."; Rec."Vendor Item No.")
            {

                Visible = false;
                ToolTip = 'Specifies the number that the vendor uses for this item.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {

                ToolTip = 'Specifies a description of the entry of the product to be purchased. To add a non-transactional text line, fill in the Description field only.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Line No.")
        {
            field("NPR Exchange Label"; ExchangeLabelTableMap.Barcode)
            {

                Visible = false;
                ToolTip = 'Specifies the Exchange Label.';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'View the variety matrix for the item used on the Purchase Order Line.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.PurchLineShowVariety(Rec, 0);
                end;
            }
        }

        addafter(OrderTracking)
        {
            action("NPR Nonstockitems")
            {
                AccessByPermission = TableData "Nonstock Item" = R;
                Caption = 'Nonstoc&k Items';
                Image = NonStockItem;

                ToolTip = 'View the list of non stock items.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NonstockPurchaseMgt: Codeunit "NPR Nonstock Purchase Mgt.";
                begin
                    NonstockPurchaseMgt.ShowNonstock(Rec, '');
                end;
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