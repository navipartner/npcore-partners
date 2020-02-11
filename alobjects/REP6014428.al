report 6014428 "Shelf Labels"
{
    // NPR5.40 /JLK /20180307  CASE 307145 Object created
    //                                     Report copied from Vaersgo NPK1.03
    // NPR5.41/BHR /20180410 CASE 302733 Remove field Status from Autocalcfields
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/ZESO/201905006 CASE 353382 Remove Reference to Wrapper Codeunit
    // NPR5.53/ANPA/20191029  CASE 374286 Made the report able to print more than one of each label
    DefaultLayout = RDLC;
    RDLCLayout = './Shelf Labels.rdlc';

    Caption = 'Shelf Labels';
    PreviewMode = PrintLayout;
    UseSystemPrinter = true;

    dataset
    {
        dataitem(Retail_Journal_Line;"Retail Journal Line")
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                j: Integer;
            begin
                if Retail_Journal_Line."Quantity to Print" > 0 then begin
                  //-NPR5.53 [374286]
                  for k := 1 to Retail_Journal_Line."Quantity to Print" do begin
                  //+NPR5.53 [374286]
                    TMPRetail_Journal_Line_Col1.Init;
                    TMPRetail_Journal_Line_Col1.TransferFields(Retail_Journal_Line);
                    TMPRetail_Journal_Line_Col1."Line No." := LineNo;
                    TMPRetail_Journal_Line_Col1.Insert;
                    LineNo := LineNo + 1;
                  //-NPR5.53 [374286]
                  end;
                  //+NPR5.53 [374286]
                end;
            end;
        }
        dataitem(TMPRetail_Journal_Line_Col1;"Retail Journal Line")
        {
            DataItemTableView = SORTING("No.","Line No.");
            UseTemporary = true;
            column(ItemNo_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1.Barcode)
            {
            }
            column(Description_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1.Description)
            {
            }
            column(Description2_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1."Description 2")
            {
            }
            column(VendorItemNo_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1."Vendor Item No.")
            {
            }
            column(CurrentUnitPrice_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1."Discount Unit Price")
            {
            }
            column(Unitprice_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat")
            {
            }
            column(Barcode_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1.Barcode)
            {
            }
            column(Itemgroup_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1."Item group")
            {
            }
            column(BarCodeTempBlobCol1;TempBlobCol1.Blob)
            {
            }
            column(Assortment_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1.Assortment)
            {
            }
            column(NewItemNo_TMPRetailJournalLineCol1;TMPRetail_Journal_Line_Col1."New Item No.")
            {
            }
            column(TMPItemGroup;TMPItemGroup)
            {
            }
            column(BeforeCaption;BeforeCaptionTxt)
            {
            }
            column(NowCaption;NowCaptionLbl)
            {
            }
            column(TMPUnitPriceWhole;TMPUnitPriceWhole)
            {
            }
            column(TMPUnitPriceDecimal;TMPUnitPriceDecimal)
            {
            }
            column(NPRAtrributeTextArray1;NPRAtrributeTextArray[1])
            {
            }
            column(NPRAttributeTextArrayText1;NPRAttributeTextArrayText[1])
            {
            }
            column(TMPBeforeUnitPrice;TMPBeforeUnitPrice)
            {
            }
            column(Description_ItemVariant;ItemVariant.Description)
            {
            }

            trigger OnAfterGetRecord()
            begin
                BarcodeLib.GenerateBarcode(Barcode, TempBlobCol1);

                Clear(ItemVariant);
                if Item.Get("Item No.") then begin
                  TMPRetail_Journal_Line_Col1."New Item No." := Item.Season;
                  GetItemNPRAttr(Item);
                  if ItemVariant.Get(Item."No.","Variant Code") then;
                end;

                Clear(TMPItemGroup);
                if ItemGroup.Get(TMPRetail_Journal_Line_Col1."Item group") then
                  TMPItemGroup := ItemGroup.Description;

                TMPBeforeUnitPrice := TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat";
                if (TMPRetail_Journal_Line_Col1."Discount Type" = TMPRetail_Journal_Line_Col1."Discount Type"::Campaign) and (TMPRetail_Journal_Line_Col1."Discount Code" <> '') then
                  CalculatePriceCampaign("Item No.",TMPBeforeUnitPrice,TMPUnitPrice)
                else
                  CalculatePrice("Item No.",TMPBeforeUnitPrice,TMPUnitPrice);

                BeforeCaptionTxt := '';
                if TMPUnitPrice <> TMPBeforeUnitPrice then
                  BeforeCaptionTxt := BeforeCaptionLbl;

                if StrPos(Format(TMPUnitPrice,0,'<Precision,2:2><Sign><Integer><Decimals><Comma,,>'), ',') > 1 then begin
                  TMPUnitPriceWhole := SelectStr(1, Format(TMPUnitPrice,0,'<Precision,2:2><Sign><Integer><Decimals><Comma,,>'));
                  TMPUnitPriceDecimal := SelectStr(2, Format(TMPUnitPrice,0,'<Precision,2:2><Sign><Integer><Decimals><Comma,,>'));
                end;
            end;
        }
        dataitem("General Ledger Setup";"General Ledger Setup")
        {
            DataItemTableView = SORTING("Primary Key");
            column(LCYCode_GeneralLedgerSetup;"General Ledger Setup"."LCY Code")
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

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        i := 1;
        CurrencyChar := 8364;
        BarcodeLib.SetBarcodeType('CODE128');
        BarcodeLib.SetShowText(false);
        BarcodeLib.SetAntiAliasing(false);
        LineNo := 1;
    end;

    var
        BarcodeLib: Codeunit "Barcode Library";
        TempBlobCol1: Record TempBlob;
        i: Integer;
        Item: Record Item;
        ItemGroup: Record "Item Group";
        CurrencyChar: Char;
        LineNo: Integer;
        TMPItemGroup: Text;
        BeforeCaptionLbl: Label 'Before';
        NowCaptionLbl: Label 'Now';
        TMPUnitPriceWhole: Text;
        TMPUnitPriceDecimal: Text;
        TMPUnitPrice: Decimal;
        StringLibrary: Codeunit "String Library";
        NPRAtrributeTextArray: array [20] of Text[50];
        NPRAttributeTextArrayText: array [20] of Text[50];
        TextAttrNotDefined: Label 'Attribute %1 is not defined';
        TextCaptionClass: Label '6014555,27,%1,2';
        TMPBeforeUnitPrice: Decimal;
        BeforeCaptionTxt: Text;
        ItemVariant: Record "Item Variant";
        k: Integer;

    local procedure GetItemNPRAttr(ItemRec: Record Item)
    var
        NPRAttrCount: Integer;
        NPRAttrPosition: Integer;
        NPRAttributeMgr: Codeunit "NPR Attribute Management";
        CaptionMgr: Codeunit CaptionManagement;
    begin
        Clear(NPRAtrributeTextArray);
        Clear(NPRAttributeTextArrayText);
        NPRAttributeMgr.GetMasterDataAttributeValue(NPRAtrributeTextArray,DATABASE::Item,ItemRec."No.");
        for NPRAttrCount := 1 to 1 do begin
          //-#[353382] [353382]
          //-TM1.39 [334644]
          //NPRAttributeTextArrayText[NPRAttrCount] := SystemEventWrapper.CaptionClassTranslate(CurrReport.LANGUAGE,STRSUBSTNO(TextCaptionClass,FORMAT(NPRAttrCount)));
          //-TM1.39 [334644]
          NPRAttributeTextArrayText[NPRAttrCount] := CaptionClassTranslate(StrSubstNo(TextCaptionClass,Format(NPRAttrCount)));
          //+#[353382] [353382]
          NPRAttrPosition := StrPos(NPRAtrributeTextArray[NPRAttrCount],'-');
          if NPRAttrPosition > 0 then
            NPRAtrributeTextArray[NPRAttrCount] := CopyStr(NPRAtrributeTextArray[NPRAttrCount],NPRAttrPosition+1);
          if (NPRAttributeTextArrayText[NPRAttrCount] = StrSubstNo(TextAttrNotDefined,Format(NPRAttrCount))) or (NPRAtrributeTextArray[NPRAttrCount] = '') then
            NPRAttributeTextArrayText[NPRAttrCount] := '';
        end;
    end;

    local procedure CalculatePrice(ItemNo: Code[20];var TMPBeforeUnitPrice: Decimal;var TMPUnitPrice: Decimal)
    var
        PeriodDiscountLine: Record "Period Discount Line";
        StatusOptionString: Option Await,Active,Balanced;
        PeriodDisc: Record "Period Discount";
    begin
        PeriodDiscountLine.Reset;
        PeriodDiscountLine.SetRange("Item No.",ItemNo);
        PeriodDiscountLine.SetFilter("Starting Date",'%1|<=%2',0D,Today);
        PeriodDiscountLine.SetFilter("Ending Date",'%1|>=%2',0D,Today);
        //-NPR5.41 [302733]
        //PeriodDiscountLine.SETAUTOCALCFIELDS(Status, "Unit Price");
        PeriodDiscountLine.SetAutoCalcFields("Unit Price");
        //+NPR5.41 [302733]
        if PeriodDiscountLine.FindSet then repeat
        if PeriodDiscountLine.Status = StatusOptionString::Active then begin
            TMPUnitPrice := PeriodDiscountLine."Campaign Unit Price";
            TMPBeforeUnitPrice := PeriodDiscountLine."Unit Price";
            exit;
          end;
        until PeriodDiscountLine.Next = 0;

        TMPUnitPrice := TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat";
        exit;
    end;

    local procedure CalculatePriceCampaign(ItemNo: Code[20];var TMPBeforeUnitPrice: Decimal;var TMPUnitPrice: Decimal)
    var
        PeriodDiscountLine: Record "Period Discount Line";
        StatusOptionString: Option Await,Active,Balanced;
        PeriodDisc: Record "Period Discount";
    begin
        PeriodDiscountLine.Reset;
        PeriodDiscountLine.SetRange(Code,TMPRetail_Journal_Line_Col1."Discount Code");
        PeriodDiscountLine.SetRange("Item No.",ItemNo);
        //-NPR5.41 [302733]
        //PeriodDiscountLine.SETAUTOCALCFIELDS(Status, "Unit Price");
        PeriodDiscountLine.SetAutoCalcFields("Unit Price");
        //+NPR5.41 [302733]
        if PeriodDiscountLine.FindSet then repeat
            TMPUnitPrice := PeriodDiscountLine."Campaign Unit Price";
            TMPBeforeUnitPrice := PeriodDiscountLine."Unit Price";
            exit;
        until PeriodDiscountLine.Next = 0;

        TMPUnitPrice := TMPRetail_Journal_Line_Col1."Discount Price Incl. Vat";
        exit;
    end;
}

