codeunit 6014631 "NPR POS Sales Tax" implements "NPR POS ITaxCalc"
{
    procedure Show(SourceRecSysId: Guid)
    var
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        PageMgt: Codeunit "Page Management";
    begin
        POSActiveTaxAmount.SetRange("Source Rec. System Id", SourceRecSysId);
        PageMgt.PageRun(POSActiveTaxAmount);
    end;

    procedure CalculateTax(var POSActiveTaxAmount: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeFactor: Decimal)
    var
        POSSalesTaxForward: COdeunit "NPR POS Sales Tax Forward";
        POSSalesTaxBackward: COdeunit "NPR POS Sales Tax Backward";
    begin
        CopyFromSource(POSActiveTaxAmount, Rec);
        SetTaxGroupType(POSActiveTaxAmount);

        if POSActiveTaxAmount."Source Prices Including Tax" then begin
            POSSalesTaxBackward.CalculateTax(POSActiveTaxAmount, Rec, Currency, ExchangeFactor);
        end else begin
            POSSalesTaxForward.CalculateTax(POSActiveTaxAmount, Rec, Currency, ExchangeFactor);
        end;
    end;

    local procedure SetTaxGroupType(var POSActiveTaxAmount: Record "NPR POS Sale Tax")
    var
        TaxArea: Record "Tax Area";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldReference: FieldRef;
        TaxCountry: Option US,CA;
    begin
        TaxArea.Get(POSActiveTaxAmount."Source Tax Area Code");
        DataTypeMgt.GetRecordRef(TaxArea, RecRef);
        if not DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Country/Region') then
            exit;

        evaluate(TaxCountry, Format(FieldReference.Value()));
        case TaxCountry of
            TaxCountry::CA:
                begin
                    POSActiveTaxAmount."Tax Group Type" := POSActiveTaxAmount."Tax Group Type"::"Tax Jurisdiction";
                    POSActiveTaxAmount."Tax Area Code for Key" := '';
                end;
            else
                OnSetTaxGroupType(POSActiveTaxAmount);
        end;
    end;

    procedure UpdateTaxSetup(var Rec: Record "NPR POS Sale Line"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        Rec."VAT %" := 0;
    end;

    procedure SkipTaxCalculation(POSActiveTaxAmount: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency): Boolean
    var
        TaxAreaLine: Record "Tax Area Line";
        TaxDetailSalesTax: Record "Tax Detail";
        TaxDetailExciseTax: Record "Tax Detail";
        TaxSetup: Record "Tax Setup";
        POSSalesTaxForward: Codeunit "NPR POS Sales Tax Forward";
        POSSalesTaxBackward: Codeunit "NPR POS Sales Tax Backward";
        TaxJurisdictionFilter: Text;
        DateErrorCptn: Text;
        EffectiveDate: Date;
        Skip: Boolean;
        WorkingDateLbl: Label 'working date';
        ActiveSaleDateLbl: Label 'active sale date';
        TaxAreaLineEmptyErr: Label '"%1" is not set for %2', Comment = '%1=TaxAreaLine.TableCaption;%2="Sale Line POS".FieldCatpion("Tax Area Code")';
        TaxDetailsEmptyErr: Label '"%1" is not set for jurisdiction(s) %2 on the %3 %4', Comment = '%1=TaxDetail.TableCaption;%2=TaxJurisdictionFilter;%3=Effective Date Cptn;%4=Effective Date';
    begin
        if Rec."Price Includes VAT" then
            POSSalesTaxBackward.UpdateSourceBeforeCalculateTax(Rec, Currency)
        else
            POSSalesTaxForward.UpdateSourceBeforeCalculateTax(Rec, Currency);

        OnSkipTaxCalculation(POSActiveTaxAmount, Rec, Currency, Skip);
        if Skip then
            exit(true);

        if Rec."Price Includes VAT" then begin
            if (Rec.Quantity = 0) or (Rec."Unit Price" = 0) then
                exit(true);
            if not Rec."Tax Liable" then begin
                TaxSetup.get();
                TaxSetup.TestField("Tax Account (Sales)");
                exit;
            end;
            Rec.TestField("Tax Area Code");
        end else begin
            if (Rec.Quantity = 0) or (Rec."Unit Price" = 0) then
                exit(true);
            if not Rec."Tax Liable" then begin
                TaxSetup.get();
                TaxSetup.TestField("Tax Account (Sales)");
                CopyFromSource(POSActiveTaxAmount, Rec);
            end else begin
                Rec.TestField("Tax Area Code");

                CopyFromSource(POSActiveTaxAmount, Rec);
                POSSalesTaxForward.FilterTaxAreaLine(TaxAreaLine, POSActiveTaxAmount);
                if TaxAreaLine.IsEmpty() then
                    Error(TaxAreaLineEmptyErr, TaxAreaLine.TableCaption(), Rec.FieldCaption("Tax Area Code"));
                TaxJurisdictionFilter := GetSelectionFilterForTaxJurisdictionCode(TaxAreaLine);

                if Rec.Date = 0D then begin
                    EffectiveDate := WorkDate();
                    DateErrorCptn := WorkingDateLbl;
                end else begin
                    EffectiveDate := Rec.Date;
                    DateErrorCptn := ActiveSaleDateLbl;
                end;
                POSSalesTaxForward.FilterSalesTaxDetails(TaxDetailSalesTax, TaxAreaLine, TaxJurisdictionFilter, EffectiveDate);
                POSSalesTaxForward.FilterExciseTaxDetails(TaxDetailExciseTax, TaxAreaLine, TaxJurisdictionFilter, EffectiveDate);
                if TaxDetailSalesTax.IsEmpty() and TaxDetailExciseTax.IsEmpty() then
                    Error(TaxDetailsEmptyErr, TaxDetailSalesTax.TableCaption(), TaxJurisdictionFilter, DateErrorCptn, EffectiveDate);
            end;
        end;
    end;

    local procedure CopyFromSource(var POSActiveTaxAmount: Record "NPR POS Sale Tax"; POSSaleLine: Record "NPR POS Sale Line")
    begin
        POSActiveTaxAmount."Source Tax Area Code" := POSSaleLine."Tax Area Code";
        POSActiveTaxAmount."Source Tax Group Code" := POSSaleLine."Tax Group Code";
        POSActiveTaxAmount."Source Tax Liable" := POSSaleLine."Tax Liable";
        POSActiveTaxAmount."Tax Area Code for Key" := POSActiveTaxAmount."Source Tax Area Code";
    end;

    local procedure GetSelectionFilterForTaxJurisdictionCode(var TaxAreaLine: Record "Tax Area Line"): Text
    var
        SelectionFilterMgt: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TaxAreaLine);
        exit(SelectionFilterMgt.GetSelectionFilter(RecRef, TaxAreaLine.FieldNo("Tax Jurisdiction Code")));
    end;

    procedure PostPOSTaxAmountCalculation(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax")
    var
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        if POSSaleTaxLine.FindSet() then begin
            InitPostTaxCalculation(POSEntryTaxLine, POSSaleTaxLine, EntryNo, POSSaleTax);
            repeat
                PostTaxCalculationAmounts(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax);
            until POSSaleTaxLine.Next() = 0;
        end;
    end;

    procedure PostPOSTaxAmountCalculationReverseSign(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax")
    var
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        Sign: Integer;
    begin
        POSEntrySalesLine.GetBySystemId(SystemId);
        Sign := 1;
        if POSEntrySalesLine."Amount Incl. VAT" <> 0 then
            Sign := POSEntrySalesLine."Amount Incl. VAT" / Abs(POSEntrySalesLine."Amount Incl. VAT");

        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        if POSSaleTaxLine.FindSet() then begin
            InitPostTaxCalculation(POSEntryTaxLine, POSSaleTaxLine, EntryNo, POSSaleTax);
            repeat
                PostTaxCalculationAmountsReverseSign(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax, Sign);
            until POSSaleTaxLine.Next() = 0;
        end;
    end;

    procedure PostTaxCalculationAmounts(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        if POSEntryTaxLine."Tax Liable" then begin
            POSEntryTaxLine."Tax Amount" += POSSaleTaxLine."Tax Amount";
            POSEntryTaxLine."Calculated Tax Amount" += POSSaleTaxLine."Tax Amount";
            POSEntryTaxLine."Amount Including Tax" += POSSaleTaxLine."Tax Amount";
        end else begin
            POSEntryTaxLine.Quantity += POSSaleTax."Source Quantity";
            POSEntryTaxLine."Tax Base Amount" += POSSaleTax."Calculated Amount Excl. Tax";
            POSEntryTaxLine."Tax Base Amount FCY" += POSSaleTax."Calculated Amount Excl. Tax";
            POSEntryTaxLine."Line Amount" += POSSaleTax."Calculated Line Amount";
            POSEntryTaxLine."Amount Including Tax" += POSSaleTax."Calculated Amount Incl. Tax";
            POSEntryTaxLine."Tax Amount" += POSSaleTaxLine."Tax Amount";
            POSEntryTaxLine."Calculated Tax Amount" += POSSaleTaxLine."Tax Amount";
        end;
        POSEntryTaxLine.Modify();
    end;

    procedure PostTaxCalculationAmountsReverseSign(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax"; Sign: Integer)
    begin
        if POSEntryTaxLine."Tax Liable" then begin
            POSEntryTaxLine."Tax Amount" += Sign * ABS(POSSaleTaxLine."Tax Amount");
            POSEntryTaxLine."Calculated Tax Amount" += Sign * ABS(POSSaleTaxLine."Tax Amount");
            POSEntryTaxLine."Amount Including Tax" += Sign * ABS(POSSaleTaxLine."Tax Amount");
        end else begin
            POSEntryTaxLine.Quantity += Sign * ABS(POSSaleTax."Source Quantity");
            POSEntryTaxLine."Tax Base Amount" += Sign * ABS(POSSaleTax."Calculated Amount Excl. Tax");
            POSEntryTaxLine."Tax Base Amount FCY" += Sign * ABS(POSSaleTax."Calculated Amount Excl. Tax");
            POSEntryTaxLine."Line Amount" += Sign * ABS(POSSaleTax."Calculated Line Amount");
            POSEntryTaxLine."Amount Including Tax" += Sign * ABS(POSSaleTax."Calculated Amount Incl. Tax");
            POSEntryTaxLine."Tax Amount" += Sign * ABS(POSSaleTaxLine."Tax Amount");
            POSEntryTaxLine."Calculated Tax Amount" += Sign * ABS(POSSaleTaxLine."Tax Amount");
        end;
        POSEntryTaxLine.Modify();
    end;

    procedure InitPostTaxCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSEntryNo: Integer; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        POSEntryTaxLine."POS Entry No." := POSEntryNo;
        POSEntryTaxLine."Tax Area Code for Key" := POSSaleTaxLine."Tax Area Code for Key";
        POSEntryTaxLine."Tax Jurisdiction Code" := POSSaleTaxLine."Tax Jurisdiction Code";
        POSEntryTaxLine."VAT Identifier" := POSSaleTaxLine."Tax Identifier";
        POSEntryTaxLine."Tax %" := POSSaleTaxLine."Tax %";
        POSEntryTaxLine."Tax Group Code" := POSSaleTaxLine."Tax Group Code";
        case POSSaleTaxLine."Tax Type" of
            POSSaleTaxLine."Tax Type"::"Excise Tax":
                POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Excise Tax";
            POSSaleTaxLine."Tax Type"::"Sales Tax":
                POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Sales and Use Tax";
        end;
        POSEntryTaxLine.Positive := POSSaleTaxLine.Positive;
        if not POSEntryTaxLine.Find() then begin
            POSEntryTaxLine.Init();

            POSEntryTaxLine."Tax Calculation Type" := POSSaleTaxLine."Tax Calculation Type";
            POSEntryTaxLine."Tax Liable" := POSSaleTaxLine."Tax Liable";
            POSEntryTaxLine."Tax Area Code" := POSSaleTaxLine."Tax Area Code";
            POSEntryTaxLine."Print Order" := POSSaleTaxLine."Print Order";
            POSEntryTaxLine."Print Description" := POSSaleTaxLine."Print Description";
            POSEntryTaxLine."Calculation Order" := POSSaleTaxLine."Calculation Order";
            POSEntryTaxLine."Round Tax" := POSSaleTaxLine."Round Tax";
            POSEntryTaxLine."Is Report-to Jurisdiction" := POSSaleTaxLine."Is Report-to Jurisdiction";

            if POSEntryTaxLine."Tax Liable" then begin
                POSEntryTaxLine.Quantity := POSSaleTax."Source Quantity";
                POSEntryTaxLine."Tax Base Amount" := POSSaleTax."Calculated Amount Excl. Tax";
                POSEntryTaxLine."Tax Base Amount FCY" := POSSaleTax."Calculated Amount Excl. Tax";
                POSEntryTaxLine."Line Amount" := POSSaleTax."Calculated Line Amount";
                POSEntryTaxLine."Amount Including Tax" := POSSaleTax."Calculated Amount Excl. Tax";
            end;

            OnAfterInitPOSPostedTaxAmtLine(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax);

            POSEntryTaxLine.Insert(true);
        end;
    end;


    [IntegrationEvent(false, false)]
    local procedure OnSetTaxGroupType(var POSActiveTaxAmount: Record "NPR POS Sale Tax")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPOSPostedTaxAmtLine(var POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSkipTaxCalculation(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; var SkipCalculation: Boolean)
    begin
    end;
}