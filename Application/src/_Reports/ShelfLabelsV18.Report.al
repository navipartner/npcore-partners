#if not BC17
report 6014428 "NPR Shelf Labels"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Shelf LabelsV18.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Shelf Labels';
    PreviewMode = PrintLayout;
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Retail_Journal_Line; "NPR Retail Journal Line")
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                if Retail_Journal_Line."Quantity to Print" > 0 then begin
                    for k := 1 to Retail_Journal_Line."Quantity to Print" do begin
                        TMPRetail_Journal_Line_Col1.Init();
                        TMPRetail_Journal_Line_Col1.TransferFields(Retail_Journal_Line);
                        TMPRetail_Journal_Line_Col1."Line No." := LineNo;
                        TMPRetail_Journal_Line_Col1.Insert();
                        LineNo := LineNo + 1;
                    end;
                end;
            end;
        }
        dataitem(TMPRetail_Journal_Line_Col1; "NPR Retail Journal Line")
        {
            DataItemTableView = SORTING("No.", "Line No.");
            UseTemporary = true;
            column(ItemNo_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1.Barcode)
            {
            }
            column(Description_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1.Description)
            {
            }
            column(Description2_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Description 2")
            {
            }
            column(VendorItemNo_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Vend Item No.")
            {
            }
            column(CurrentUnitPrice_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Discount Unit Price")
            {
            }
            column(Unitprice_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat")
            {
            }
            column(Barcode_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1.Barcode)
            {
            }
            column(ItemCategory_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Item group")
            {
            }
            column(BarCodeTempBlobCol1; BarCodeEncodedText)
            {
            }
            column(BarcodeFontFamily; BarcodeFontFamily)
            {
            }
            column(BarcodeFontSize; BarcodeFontSize)
            {
            }
            column(Assortment_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1.Assortment)
            {
            }
            column(NewItemNo_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."New Item No.")
            {
            }
            column(TMPItemCategory; TMPItemCategory)
            {
            }
            column(BeforeCaption; BeforeCaptionTxt)
            {
            }
            column(NowCaption; NowCaptionLbl)
            {
            }
            column(TMPUnitPriceWhole; TMPUnitPriceWhole)
            {
            }
            column(TMPUnitPriceDecimal; TMPUnitPriceDecimal)
            {
            }
            column(NPRAtrributeTextArray1; NPRAtrributeTextArray[1])
            {
            }
            column(NPRAttributeTextArrayText1; NPRAttributeTextArrayText[1])
            {
            }
            column(TMPBeforeUnitPrice; TMPBeforeUnitPrice)
            {
            }
            column(Description_ItemVariant; ItemVariant.Description)
            {
            }

            trigger OnAfterGetRecord()
            begin

                CalculateBarcodeAndFonts(Barcode);

                Clear(ItemVariant);
                if Item.Get("Item No.") then begin
                    GetItemNPRAttr(Item);
                    if ItemVariant.Get(Item."No.", "Variant Code") then;
                end;

                Clear(TMPItemCategory);
                if ItemCategory.Get(TMPRetail_Journal_Line_Col1."Item group") then
                    TMPItemCategory := ItemCategory.Description;

                TMPBeforeUnitPrice := TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat";
                TMPUnitPriceCard := Item."Unit Price";
                TMPRetailLineDiscount := TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat";
                if (TMPRetail_Journal_Line_Col1."Discount Type" = TMPRetail_Journal_Line_Col1."Discount Type"::Campaign) and (TMPRetail_Journal_Line_Col1."Discount Code" <> '') then
                    CalculatePriceCampaign("Item No.", TMPBeforeUnitPrice, TMPUnitPrice)
                else
                    CalculatePrice("Item No.", TMPBeforeUnitPrice, TMPUnitPrice);

                case UnitPriceOption of
                    UnitPriceOption::"Use Retail Journal Line Prices":
                        TMPUnitPrice := TMPRetailLineDiscount;
                    UnitPriceOption::"Use Item Card Unit Prices":
                        TMPUnitPrice := TMPUnitPriceCard;
                end;

                BeforeCaptionTxt := '';
                if TMPUnitPrice <> TMPBeforeUnitPrice then
                    BeforeCaptionTxt := BeforeCaptionLbl;

                if StrPos(Format(TMPUnitPrice, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,,>'), ',') > 1 then begin
                    TMPUnitPriceWhole := SelectStr(1, Format(TMPUnitPrice, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,,>'));
                    TMPUnitPriceDecimal := SelectStr(2, Format(TMPUnitPrice, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,,>'));
                end;
            end;
        }
        dataitem("General Ledger Setup"; "General Ledger Setup")
        {
            DataItemTableView = SORTING("Primary Key");
            column(LCYCode_GeneralLedgerSetup; "General Ledger Setup"."LCY Code")
            {
            }

            trigger OnAfterGetRecord()
            begin
                if "General Ledger Setup"."LCY Code" = 'EUR' then
                    "General Ledger Setup"."LCY Code" := Format(CurrencyChar);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(CampaignUnitPrice; UnitPriceOption)
                {
                    Caption = 'Unit Price';
                    OptionCaption = 'Use Retail Journal Line Prices,Use Item Card Unit Prices,Use Campaign Unit Prices';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        CurrencyChar := 8364;
        BarcodeSimbiology := BarcodeSimbiology::Code128;
        LineNo := 1;
    end;

    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemCategory: Record "Item Category";
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
        BarcodeSimbiology: Enum "Barcode Symbology";
        BarCodeEncodedText: Text;
        BarcodeFontFamily: Text;
        BarcodeFontSize: Text;
        CurrencyChar: Char;
        TMPBeforeUnitPrice: Decimal;
        TMPRetailLineDiscount: Decimal;
        TMPUnitPrice: Decimal;
        TMPUnitPriceCard: Decimal;
        k: Integer;
        LineNo: Integer;
        TextCaptionClass: Label '6014555,27,%1,2';
        TextAttrNotDefined: Label 'Attribute %1 is not defined';
        BeforeCaptionLbl: Label 'Before';
        NowCaptionLbl: Label 'Now';
        UnitPriceOption: Option "Use Retail Journal Line Prices","Use Item Card Unit Prices","Use Campaign Unit Prices";
        BeforeCaptionTxt: Text;
        TMPItemCategory: Text;
        TMPUnitPriceDecimal: Text;
        TMPUnitPriceWhole: Text;
        NPRAtrributeTextArray: array[20] of Text[50];
        NPRAttributeTextArrayText: array[20] of Text[50];

    local procedure GetItemNPRAttr(ItemRec: Record Item)
    var
        NPRAttributeMgr: Codeunit "NPR Attribute Management";
        NPRAttrCount: Integer;
        NPRAttrPosition: Integer;
    begin
        Clear(NPRAtrributeTextArray);
        Clear(NPRAttributeTextArrayText);
        NPRAttributeMgr.GetMasterDataAttributeValue(NPRAtrributeTextArray, DATABASE::Item, ItemRec."No.");
        for NPRAttrCount := 1 to 1 do begin
            NPRAttributeTextArrayText[NPRAttrCount] := CopyStr(CaptionClassTranslate(StrSubstNo(TextCaptionClass, Format(NPRAttrCount))), 1, 50);
            NPRAttrPosition := StrPos(NPRAtrributeTextArray[NPRAttrCount], '-');
            if NPRAttrPosition > 0 then
                NPRAtrributeTextArray[NPRAttrCount] := CopyStr(NPRAtrributeTextArray[NPRAttrCount], NPRAttrPosition + 1, 50);
            if (NPRAttributeTextArrayText[NPRAttrCount] = StrSubstNo(TextAttrNotDefined, Format(NPRAttrCount))) or (NPRAtrributeTextArray[NPRAttrCount] = '') then
                NPRAttributeTextArrayText[NPRAttrCount] := '';
        end;
    end;

    local procedure CalculatePrice(ItemNo: Code[20]; var TMPBeforeUnitPrice: Decimal; var TMPUnitPrice: Decimal)
    var
        PeriodDiscountLine: Record "NPR Period Discount Line";
        StatusOptionString: Option Await,Active,Balanced;
    begin
        PeriodDiscountLine.Reset();
        PeriodDiscountLine.SetRange("Item No.", ItemNo);
        PeriodDiscountLine.SetFilter("Starting Date", '%1|<=%2', 0D, Today);
        PeriodDiscountLine.SetFilter("Ending Date", '%1|>=%2', 0D, Today);
        PeriodDiscountLine.SetAutoCalcFields("Unit Price");
        if PeriodDiscountLine.FindSet() then
            repeat
                if PeriodDiscountLine.Status = StatusOptionString::Active then begin
                    TMPUnitPrice := PeriodDiscountLine."Campaign Unit Price";
                    TMPBeforeUnitPrice := PeriodDiscountLine."Unit Price";
                    exit;
                end;
            until PeriodDiscountLine.Next() = 0;

        TMPUnitPrice := TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat";
        exit;
    end;

    local procedure CalculatePriceCampaign(ItemNo: Code[20]; var TMPBeforeUnitPrice: Decimal; var TMPUnitPrice: Decimal)
    var
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        PeriodDiscountLine.Reset();
        PeriodDiscountLine.SetRange(Code, TMPRetail_Journal_Line_Col1."Discount Code");
        PeriodDiscountLine.SetRange("Item No.", ItemNo);
        PeriodDiscountLine.SetAutoCalcFields("Unit Price");
        if PeriodDiscountLine.FindSet() then
            repeat
                TMPUnitPrice := PeriodDiscountLine."Campaign Unit Price";
                TMPBeforeUnitPrice := PeriodDiscountLine."Unit Price";
                exit;
            until PeriodDiscountLine.Next() = 0;

        TMPUnitPrice := TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat";
        exit;
    end;

    local procedure CalculateBarcodeAndFonts(Barcode: Text[50])
    var
        BarcodeLength: Integer;
        ArialFontLbl: Label 'Arial', locked = true;
        AutomationC128XLFontLbl: Label 'IDAutomationC128XXL', Locked = true;
    begin
        BarcodeLength := StrLen(Barcode);
        BarcodeFontSize := CalculateFontSize(BarcodeLength);

        if (BarcodeLength = 0) or (BarcodeLength > 20) then begin
            BarCodeEncodedText := '***';
            BarcodeFontFamily := ArialFontLbl;
        end
        else begin
            BarCodeEncodedText := BarcodeFontProviderMgt.EncodeText(Barcode, BarcodeSimbiology, BarcodeFontProviderMgt.SetBarcodeSettings(0, true, true, false));
            BarcodeFontFamily := AutomationC128XLFontLbl;
        end;
    end;

    local procedure CalculateFontSize(Length: Integer): Text
    begin
        case Length of
            17 .. 20:
                exit('4pt');
            14 .. 16:
                exit('5pt');
            11 .. 13:
                exit('6pt');
            9, 10:
                exit('7pt');
            8:
                exit('8pt');
            7:
                exit('9pt');
            else
                exit('10pt');
        end;
    end;
}
#endif
