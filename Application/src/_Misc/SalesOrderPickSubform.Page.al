page 6014519 "NPR Sales Order Pick Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Sales Line";
    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {

                    Style = Favorable;
                    StyleExpr = QtyToShipColor;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate();
                        NoOnAfterValidate();
                        TypeChosen := Rec.Type <> Rec.Type::" ";
                        SetLocationCodeMandatory();

                        if xRec."No." <> '' then
                            RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("No."; Rec."No.")
                {

                    ShowMandatory = TypeChosen;
                    Style = Favorable;
                    StyleExpr = QtyToShipColor;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate();

                        if xRec."No." <> '' then
                            RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Item Reference No."; Rec."Item Reference No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the referenced item number.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SalesHeader: Record "Sales Header";
                        ItemReferenceMgt: Codeunit "Item Reference Management";
                    begin
                        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                        ItemReferenceMgt.SalesReferenceNoLookup(Rec, SalesHeader);
                        InsertExtendedText(false);
                        NoOnAfterValidate();
                    end;

                    trigger OnValidate()
                    begin
                        ItemReferenceNoOnAfterValidat();
                        NoOnAfterValidate();
                    end;
                }
                field("IC Partner Code"; Rec."IC Partner Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the IC Partner Code field';
                    ApplicationArea = NPRRetail;
                }
                field("IC Partner Ref. Type"; Rec."IC Partner Ref. Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the IC Partner Ref. Type field';
                    ApplicationArea = NPRRetail;
                }
                field("IC Item Reference No."; Rec."IC Item Reference No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the IC Partner Reference field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        VariantCodeOnAfterValidate();
                    end;
                }
                field("Substitution Available"; Rec."Substitution Available")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Substitution Available field';
                    ApplicationArea = NPRRetail;
                }
                field("Purchasing Code"; Rec."Purchasing Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Purchasing Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Nonstock; Rec.Nonstock)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Nonstock field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field(Description; Rec.Description)
                {

                    QuickEntry = false;
                    Style = Favorable;
                    StyleExpr = QtyToShipColor;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Drop Shipment"; Rec."Drop Shipment")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Drop Shipment field';
                    ApplicationArea = NPRRetail;
                }
                field("Special Order"; Rec."Special Order")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Special Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Reason Code"; Rec."Return Reason Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Reason Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    QuickEntry = false;
                    ShowMandatory = LocationCodeMandatory;
                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        LocationCodeOnAfterValidate();
                    end;
                }
                field("Bin Code"; Rec."Bin Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Bin Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Reserve; Rec.Reserve)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Reserve field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ReserveOnAfterValidate();
                    end;
                }
                field(Quantity; Rec.Quantity)
                {

                    BlankZero = true;
                    ShowMandatory = TypeChosen;
                    Style = Favorable;
                    StyleExpr = QtyToShipColor;
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate();
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Qty. to Assemble to Order"; Rec."Qty. to Assemble to Order")
                {

                    BlankZero = true;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. to Assemble to Order field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowAsmToOrderLines();
                    end;

                    trigger OnValidate()
                    begin
                        QtyToAsmToOrderOnAfterValidate();
                    end;
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
                {

                    BlankZero = true;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Reserved Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        UnitofMeasureCodeOnAfterValida();
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit of Measure field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field(SalesPriceExist; Rec.PriceExists())
                {

                    Caption = 'Sales Price Exists';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Price Exists field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    BlankZero = true;
                    ShowMandatory = TypeChosen;
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Line Amount"; Rec."Line Amount")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Line Amount field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field(SalesLineDiscExists; Rec.LineDiscExists())
                {

                    Caption = 'Sales Line Disc. Exists';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Line Disc. Exists field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Prepayment %"; Rec."Prepayment %")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepayment % field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Prepmt. Line Amount"; Rec."Prepmt. Line Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepmt. Line Amount field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Prepmt. Amt. Inv."; Rec."Prepmt. Amt. Inv.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepmt. Amt. Inv. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RedistributeTotalsOnAfterValidate();
                    end;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Allow Invoice Disc. field';
                    ApplicationArea = NPRRetail;
                }
                field("Inv. Discount Amount"; Rec."Inv. Discount Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Inv. Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {

                    BlankZero = true;
                    Style = Favorable;
                    StyleExpr = QtyToShipColor;
                    ToolTip = 'Specifies the value of the Qty. to Ship field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec."Qty. to Asm. to Order (Base)" <> 0 then begin
                            CurrPage.SaveRecord();
                            CurrPage.Update(false);
                        end;
                    end;
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {

                    BlankZero = true;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Quantity Shipped field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Qty. to Invoice field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity Invoiced"; Rec."Quantity Invoiced")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Quantity Invoiced field';
                    ApplicationArea = NPRRetail;
                }
                field("Prepmt Amt to Deduct"; Rec."Prepmt Amt to Deduct")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepmt Amt to Deduct field';
                    ApplicationArea = NPRRetail;
                }
                field("Prepmt Amt Deducted"; Rec."Prepmt Amt Deducted")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepmt Amt Deducted field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Item Charge Assignment"; Rec."Allow Item Charge Assignment")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Allow Item Charge Assignment field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. to Assign"; Rec."Qty. to Assign")
                {

                    BlankZero = true;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Qty. to Assign field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.ShowItemChargeAssgnt();
                        UpdateForm(false);
                    end;
                }
                field("Qty. Assigned"; Rec."Qty. Assigned")
                {

                    BlankZero = true;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Qty. Assigned field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.ShowItemChargeAssgnt();
                        CurrPage.Update(false);
                    end;
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Requested Delivery Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Promised Delivery Date"; Rec."Promised Delivery Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Promised Delivery Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Planned Delivery Date"; Rec."Planned Delivery Date")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Planned Delivery Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Planned Shipment Date"; Rec."Planned Shipment Date")
                {

                    ToolTip = 'Specifies the value of the Planned Shipment Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {

                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Shipment Date field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ShipmentDateOnAfterValidate();
                    end;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Time"; Rec."Shipping Time")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shipping Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Work Type Code"; Rec."Work Type Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Work Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Whse. Outstanding Qty."; Rec."Whse. Outstanding Qty.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Whse. Outstanding Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field("Whse. Outstanding Qty. (Base)"; Rec."Whse. Outstanding Qty. (Base)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Whse. Outstanding Qty. (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("ATO Whse. Outstanding Qty."; Rec."ATO Whse. Outstanding Qty.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the ATO Whse. Outstanding Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field("ATO Whse. Outstd. Qty. (Base)"; Rec."ATO Whse. Outstd. Qty. (Base)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the ATO Whse. Outstd. Qty. (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Outbound Whse. Handling Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Blanket Order No."; Rec."Blanket Order No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Blanket Order No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Blanket Order Line No."; Rec."Blanket Order Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Blanket Order Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("FA Posting Date"; Rec."FA Posting Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the FA Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Depr. until FA Posting Date"; Rec."Depr. until FA Posting Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Depr. until FA Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Depreciation Book Code"; Rec."Depreciation Book Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Depreciation Book Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Duplication List"; Rec."Use Duplication List")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Duplication List field';
                    ApplicationArea = NPRRetail;
                }
                field("Duplicate in Depreciation Book"; Rec."Duplicate in Depreciation Book")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Duplicate in Depreciation Book field';
                    ApplicationArea = NPRRetail;
                }
                field("Appl.-from Item Entry"; Rec."Appl.-from Item Entry")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Appl.-from Item Entry field';
                    ApplicationArea = NPRRetail;
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Appl.-to Item Entry field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {

                    CaptionClass = '1,2,3';
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[3] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(3, ShortcutDimCode[3]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {

                    CaptionClass = '1,2,4';
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[4] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(4, ShortcutDimCode[4]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {

                    CaptionClass = '1,2,5';
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[5] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(5, ShortcutDimCode[5]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {

                    CaptionClass = '1,2,6';
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[6] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(6, ShortcutDimCode[6]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {

                    CaptionClass = '1,2,7';
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[7] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(7, ShortcutDimCode[7]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {

                    CaptionClass = '1,2,8';
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ShortcutDimCode[8] field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(8, ShortcutDimCode[8]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Document No."; Rec."Document No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Control51)
            {
                ShowCaption = false;
                group(Control45)
                {
                    ShowCaption = false;
                    field("Invoice Discount Amount"; TotalSalesLine."Inv. Discount Amount")
                    {

                        AutoFormatType = 1;
                        Caption = 'Invoice Discount Amount';
                        Editable = InvDiscAmountEditable;
                        Style = Subordinate;
                        StyleExpr = RefreshMessageEnabled;
                        ToolTip = 'Specifies the value of the Invoice Discount Amount field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        var
                            SalesHeader: Record "Sales Header";
                        begin
                            SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                            SalesCalcDiscByType.ApplyInvDiscBasedOnAmt(TotalSalesLine."Inv. Discount Amount", SalesHeader);
                            CurrPage.Update(false);
                        end;
                    }
                    field("Invoice Disc. Pct."; SalesCalcDiscByType.GetCustInvoiceDiscountPct(Rec))
                    {

                        Caption = 'Invoice Discount %';
                        DecimalPlaces = 0 : 2;
                        Editable = false;
                        Style = Subordinate;
                        StyleExpr = RefreshMessageEnabled;
                        Visible = true;
                        ToolTip = 'Specifies the value of the Invoice Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control28)
                {
                    ShowCaption = false;
                    field("Total Amount Excl. VAT"; TotalSalesLine.Amount)
                    {

                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalExclVATCaption(SalesHeader."Currency Code");
                        Caption = 'Total Amount Excl. VAT';
                        DrillDown = false;
                        Editable = false;
                        Style = Subordinate;
                        StyleExpr = RefreshMessageEnabled;
                        ToolTip = 'Specifies the value of the Total Amount Excl. VAT field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Total VAT Amount"; VATAmount)
                    {

                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalVATCaption(SalesHeader."Currency Code");
                        Caption = 'Total VAT';
                        Editable = false;
                        Style = Subordinate;
                        StyleExpr = RefreshMessageEnabled;
                        ToolTip = 'Specifies the value of the Total VAT field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Total Amount Incl. VAT"; TotalSalesLine."Amount Including VAT")
                    {

                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalInclVATCaption(SalesHeader."Currency Code");
                        Caption = 'Total Amount Incl. VAT';
                        Editable = false;
                        StyleExpr = TotalAmountStyle;
                        ToolTip = 'Specifies the value of the Total Amount Incl. VAT field';
                        ApplicationArea = NPRRetail;
                    }
                    field(RefreshTotals; RefreshMessageText)
                    {

                        DrillDown = true;
                        Editable = false;
                        Enabled = RefreshMessageEnabled;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the RefreshMessageText field';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            DocumentTotals.SalesRedistributeInvoiceDiscountAmounts(Rec, VATAmount, TotalSalesLine);
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("<Action3>")
                    {
                        Caption = 'Event';
                        Image = "Event";

                        ToolTip = 'Executes the Event action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByEvent())
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;

                        ToolTip = 'Executes the Period action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByPeriod())
                        end;
                    }
                    action("Variant")
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;

                        ToolTip = 'Executes the Variant action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByVariant())
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location = R;
                        Caption = 'Location';
                        Image = Warehouse;

                        ToolTip = 'Executes the Location action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByLocation())
                        end;
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;

                        ToolTip = 'Executes the BOM Level action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByBOM())
                        end;
                    }
                }
                action("Reservation Entries")
                {
                    AccessByPermission = TableData Item = R;
                    Caption = 'Reservation Entries';
                    Image = ReservationLedger;

                    ToolTip = 'Executes the Reservation Entries action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowReservationEntries(true);
                    end;
                }
                action(ItemTrackingLines)
                {
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I';

                    ToolTip = 'Executes the Item &Tracking Lines action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.OpenItemTrackingLines();
                    end;
                }
                action("Select Item Substitution")
                {
                    AccessByPermission = TableData "Item Substitution" = R;
                    Caption = 'Select Item Substitution';
                    Image = SelectItemSubstitution;

                    ToolTip = 'Executes the Select Item Substitution action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ItemSubstitutionMgt: Codeunit "Item Subst.";
                    begin
                        Clear(SalesHeader);
                        Rec.TestStatusOpen();
                        ItemSubstitutionMgt.ItemSubstGet(Rec);
                        if TransferExtendedText.SalesCheckIfAnyExtText(Rec, false) then
                            TransferExtendedText.InsertSalesExtText(Rec);
                    end;
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    ToolTip = 'Executes the Dimensions action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    ToolTip = 'Executes the Co&mments action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowLineComments();
                    end;
                }
                action("Item Charge &Assignment")
                {
                    AccessByPermission = TableData "Item Charge" = R;
                    Caption = 'Item Charge &Assignment';

                    ToolTip = 'Record additional direct costs, for example for freight. This action is available only for Charge (item) line types.';
                    Image = ItemCosts;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ItemChargeAssgnt();
                    end;
                }
                action(OrderPromising)
                {
                    AccessByPermission = TableData "Order Promising Line" = R;
                    Caption = 'Order &Promising';
                    Image = OrderPromising;

                    ToolTip = 'Executes the Order &Promising action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ShowOrderPromisingLines();
                    end;
                }
                group("Assemble to Order")
                {
                    Caption = 'Assemble to Order';
                    Image = AssemblyBOM;
                    action(AssembleToOrderLines)
                    {
                        AccessByPermission = TableData "BOM Component" = R;
                        Caption = 'Assemble-to-Order Lines';

                        ToolTip = 'Executes the Assemble-to-Order Lines action';
                        Image = AssemblyOrder;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            Rec.ShowAsmToOrderLines();
                        end;
                    }
                    action("Roll Up &Price")
                    {
                        AccessByPermission = TableData "BOM Component" = R;
                        Caption = 'Roll Up &Price';
                        Ellipsis = true;

                        ToolTip = 'Executes the Roll Up &Price action';
                        Image = RollUpCosts;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            Rec.RollupAsmPrice();
                        end;
                    }
                    action("Roll Up &Cost")
                    {
                        AccessByPermission = TableData "BOM Component" = R;
                        Caption = 'Roll Up &Cost';
                        Ellipsis = true;

                        ToolTip = 'Executes the Roll Up &Cost action';
                        Image = RollUpCosts;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            Rec.RollUpAsmCost();
                        end;
                    }
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(GetPrice)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Get Price';
                    Ellipsis = true;
                    Image = Price;
                    ToolTip = 'Executes the Get Price action';
                    trigger OnAction()
                    begin
                        ShowPrices();
                    end;
                }
                action("Get Li&ne Discount")
                {

                    Caption = 'Get Li&ne Discount';
                    Ellipsis = true;
                    Image = LineDiscount;
                    ToolTip = 'Executes the Get Li&ne Discount action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ShowLineDisc();
                    end;
                }
                action("ExplodeBOM_Functions")
                {
                    AccessByPermission = TableData "BOM Component" = R;
                    Caption = 'E&xplode BOM';
                    Image = ExplodeBOM;

                    ToolTip = 'Executes the E&xplode BOM action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ExplodeBOM();
                    end;
                }
                action("Insert Ext. Texts")
                {
                    AccessByPermission = TableData "Extended Text Header" = R;
                    Caption = 'Insert &Ext. Texts';
                    Image = Text;

                    ToolTip = 'Executes the Insert &Ext. Texts action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        InsertExtendedText(true);
                    end;
                }
                action("&Reserve")
                {
                    Caption = '&Reserve';
                    Ellipsis = true;
                    Image = Reserve;

                    ToolTip = 'Executes the &Reserve action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.Find();
                        Rec.ShowReservation();
                    end;
                }
                action(OrderTracking)
                {
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;

                    ToolTip = 'Executes the Order &Tracking action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ShowTracking();
                    end;
                }
                action("Nonstoc&k Items")
                {
                    AccessByPermission = TableData "Nonstock Item" = R;
                    Caption = 'Nonstoc&k Items';
                    Image = NonStockItem;

                    ToolTip = 'Executes the Nonstoc&k Items action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ShowNonstockItems();
                    end;
                }
            }
            group("O&rder")
            {
                Caption = 'O&rder';
                Image = "Order";
                group("Dr&op Shipment")
                {
                    Caption = 'Dr&op Shipment';
                    Image = Delivery;
                    action("Purchase &Order")
                    {
                        AccessByPermission = TableData "Purch. Rcpt. Header" = R;
                        Caption = 'Purchase &Order';
                        Image = Document;

                        ToolTip = 'Executes the Purchase &Order action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            OpenPurchOrderForm();
                        end;
                    }
                }
                group("Speci&al Order")
                {
                    Caption = 'Speci&al Order';
                    Image = SpecialOrder;
                    action(OpenSpecialPurchaseOrder)
                    {
                        AccessByPermission = TableData "Purch. Rcpt. Header" = R;
                        Caption = 'Purchase &Order';
                        Image = Document;

                        ToolTip = 'Executes the Purchase &Order action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            OpenSpecialPurchOrderForm();
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then;

        DocumentTotals.SalesUpdateTotalsControls(Rec, TotalSalesHeader, TotalSalesLine, RefreshMessageEnabled,
            TotalAmountStyle, RefreshMessageText, InvDiscAmountEditable, false, VATAmount);

        TypeChosen := Rec.Type <> Rec.Type::" ";
        SetLocationCodeMandatory();

        if Rec.Quantity = Rec."Qty. to Ship" then
            QtyToShipColor := true
        else
            QtyToShipColor := false;
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveSalesLine: Codeunit "Sales Line-Reserve";
    begin
        if (Rec.Quantity <> 0) and Rec.ItemExists(Rec."No.") then begin
            Commit();
            if not ReserveSalesLine.DeleteLineConfirm(Rec) then
                exit(false);
            ReserveSalesLine.DeleteLine(Rec);
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.InitType();
        Clear(ShortcutDimCode);
    end;

    var
        SalesHeader: Record "Sales Header";
        TotalSalesHeader: Record "Sales Header";
        TotalSalesLine: Record "Sales Line";
        DocumentTotals: Codeunit "Document Totals";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        SalesCalcDiscByType: Codeunit "Sales - Calc Discount By Type";

        TransferExtendedText: Codeunit "Transfer Extended Text";
        InvDiscAmountEditable: Boolean;
        LocationCodeMandatory: Boolean;
        QtyToShipColor: Boolean;
        RefreshMessageEnabled: Boolean;
        TypeChosen: Boolean;
        ShortcutDimCode: array[8] of Code[20];
        VATAmount: Decimal;
        QtyToShipMsg: Label 'Updated value Qty to Ship on %1 sales line(s)';
        ExpodeBOMErr: Label 'You cannot use the Explode BOM function because a prepayment of the sales order has been invoiced.';
        RefreshMessageText: Text;
        TotalAmountStyle: Text;

    procedure ApproveCalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Disc. (Yes/No)", Rec);
    end;

    procedure ExplodeBOM()
    begin
        if Rec."Prepmt. Amt. Inv." <> 0 then
            Error(ExpodeBOMErr);
        CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
    end;

    procedure OpenPurchOrderForm()
    var
        PurchHeader: Record "Purchase Header";
        PurchOrder: Page "Purchase Order";
    begin
        Rec.TestField("Purchase Order No.");
        PurchHeader.SetRange("No.", Rec."Purchase Order No.");
        PurchOrder.SetTableView(PurchHeader);
        PurchOrder.Editable := false;
        PurchOrder.Run();
    end;

    procedure OpenSpecialPurchOrderForm()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchHeader: Record "Purchase Header";
        PurchOrder: Page "Purchase Order";
    begin
        Rec.TestField("Special Order Purchase No.");
        PurchHeader.SetRange("No.", Rec."Special Order Purchase No.");
        if not PurchHeader.IsEmpty then begin
            PurchOrder.SetTableView(PurchHeader);
            PurchOrder.Editable := false;
            PurchOrder.Run();
        end else begin
            PurchRcptHeader.SetRange("Order No.", Rec."Special Order Purchase No.");
            if PurchRcptHeader.Count() = 1 then
                PAGE.Run(PAGE::"Posted Purchase Receipt", PurchRcptHeader)
            else
                PAGE.Run(PAGE::"Posted Purchase Receipts", PurchRcptHeader);
        end;
    end;

    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord();
            Commit();
            TransferExtendedText.InsertSalesExtText(Rec);
        end;
        if TransferExtendedText.MakeUpdate() then
            UpdateForm(true);
    end;

    procedure ShowNonstockItems()
    begin
        Rec.ShowNonstock();
    end;

    procedure ShowTracking()
    var
        TrackingForm: Page "Order Tracking";
    begin
        TrackingForm.SetSalesLine(Rec);
        TrackingForm.RunModal();
    end;

    procedure ItemChargeAssgnt()
    begin
        Rec.ShowItemChargeAssgnt();
    end;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    procedure ShowPrices()
    begin
        Rec.PickPrice();
        CurrPage.Update();
    end;

    procedure ShowLineDisc()
    begin
        Rec.PickDiscount();
        CurrPage.Update();

    end;

    procedure ShowOrderPromisingLines()
    var
        OrderPromisingLine: Record "Order Promising Line";
        OrderPromisingLines: Page "Order Promising Lines";
    begin
        OrderPromisingLine.SetRange("Source Type", Rec."Document Type");
        OrderPromisingLine.SetRange("Source ID", Rec."Document No.");
        OrderPromisingLine.SetRange("Source Line No.", Rec."Line No.");

        OrderPromisingLines.SetSourceType(OrderPromisingLine."Source Type"::Sales.AsInteger());
        OrderPromisingLines.SetTableView(OrderPromisingLine);
        OrderPromisingLines.RunModal();
    end;

    local procedure TypeOnAfterValidate()
    begin
    end;

    local procedure NoOnAfterValidate()
    begin
        InsertExtendedText(false);
        if (Rec.Type = Rec.Type::"Charge (Item)") and (Rec."No." <> xRec."No.") and
           (xRec."No." <> '')
        then
            CurrPage.SaveRecord();

        SaveAndAutoAsmToOrder();

        if (Rec.Reserve = Rec.Reserve::Always) and
           (Rec."Outstanding Qty. (Base)" <> 0) and
           (Rec."No." <> xRec."No.")
        then begin
            CurrPage.SaveRecord();
            Rec.AutoReserve();
            CurrPage.Update(false);
        end;
    end;

    local procedure ItemReferenceNoOnAfterValidat()
    begin
        InsertExtendedText(false);
    end;

    local procedure VariantCodeOnAfterValidate()
    begin
        SaveAndAutoAsmToOrder();
    end;

    local procedure LocationCodeOnAfterValidate()
    begin
        SaveAndAutoAsmToOrder();

        if (Rec.Reserve = Rec.Reserve::Always) and
           (Rec."Outstanding Qty. (Base)" <> 0) and
           (Rec."Location Code" <> xRec."Location Code")
        then begin
            CurrPage.SaveRecord();
            Rec.AutoReserve();
            CurrPage.Update(false);
        end;
    end;

    local procedure ReserveOnAfterValidate()
    begin
        if (Rec.Reserve = Rec.Reserve::Always) and (Rec."Outstanding Qty. (Base)" <> 0) then begin
            CurrPage.SaveRecord();
            Rec.AutoReserve();
            CurrPage.Update(false);
        end;
    end;

    local procedure QuantityOnAfterValidate()
    var
        UpdateIsDone: Boolean;
    begin
        if Rec.Type = Rec.Type::Item then
            case Rec.Reserve of
                Rec.Reserve::Always:
                    begin
                        CurrPage.SaveRecord();
                        Rec.AutoReserve();
                        CurrPage.Update(false);
                        UpdateIsDone := true;
                    end;
                Rec.Reserve::Optional:
                    if (Rec.Quantity < xRec.Quantity) and (xRec.Quantity > 0) then begin
                        CurrPage.SaveRecord();
                        CurrPage.Update(false);
                        UpdateIsDone := true;
                    end;
            end;

        if (Rec.Type = Rec.Type::Item) and
           (Rec.Quantity <> xRec.Quantity) and
           not UpdateIsDone
        then
            CurrPage.Update(true);
    end;

    local procedure QtyToAsmToOrderOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        if Rec.Reserve = Rec.Reserve::Always then
            Rec.AutoReserve();
        CurrPage.Update(true);
    end;

    local procedure UnitofMeasureCodeOnAfterValida()
    begin
        if Rec.Reserve = Rec.Reserve::Always then begin
            CurrPage.SaveRecord();
            Rec.AutoReserve();
            CurrPage.Update(false);
        end;
    end;

    local procedure ShipmentDateOnAfterValidate()
    begin
        if (Rec.Reserve = Rec.Reserve::Always) and
           (Rec."Outstanding Qty. (Base)" <> 0) and
           (Rec."Shipment Date" <> xRec."Shipment Date")
        then begin
            CurrPage.SaveRecord();
            Rec.AutoReserve();
            CurrPage.Update(false);
        end;
    end;

    local procedure SaveAndAutoAsmToOrder()
    begin
        if (Rec.Type = Rec.Type::Item) and Rec.IsAsmToOrderRequired() then begin
            CurrPage.SaveRecord();
            Rec.AutoAsmToOrder();
            CurrPage.Update(false);
        end;
    end;

    local procedure SetLocationCodeMandatory()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        LocationCodeMandatory := InventorySetup."Location Mandatory" and (Rec.Type = Rec.Type::Item);
    end;

    local procedure RedistributeTotalsOnAfterValidate()
    begin
        CurrPage.SaveRecord();

        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
        if DocumentTotals.SalesCheckNumberOfLinesLimit(SalesHeader) then
            DocumentTotals.SalesRedistributeInvoiceDiscountAmounts(Rec, VATAmount, TotalSalesLine);
        CurrPage.Update();
    end;

    procedure UpdateQtyToShipOnLines(ItemNo: Code[20]; VariantCode: Code[10]; QtyToShip: Decimal)
    begin
        Rec.SetRange(Type, Rec.Type::Item);
        if ItemNo <> '' then
            Rec.SetRange("No.", ItemNo);
        if VariantCode <> '' then
            Rec.SetRange("Variant Code", VariantCode);
        if QtyToShip > 0 then begin
            if Rec.FindSet() then
                repeat
                    Rec.Validate("Qty. to Ship", Rec."Qty. to Ship" + QtyToShip);
                    Rec.Modify(true);
                until Rec.Next() = 0;
        end else
            Rec.ModifyAll("Qty. to Ship", QtyToShip, true);

        Message(StrSubstNo(QtyToShipMsg, Rec.Count()));

        Rec.SetRange(Type);
        Rec.SetRange("No.");
        Rec.SetRange("Variant Code");
    end;
}
