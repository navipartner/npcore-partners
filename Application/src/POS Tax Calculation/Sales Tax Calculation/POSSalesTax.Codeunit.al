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
            TaxCountry::US:
                begin
                    POSActiveTaxAmount."Tax Group Type" := POSActiveTaxAmount."Tax Group Type"::"Tax Jurisdiction";
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
                POSSalesTaxForward.FilterSalesTaxDetails(TaxDetailSalesTax, TaxAreaLine, TaxJurisdictionFilter, Rec."Tax Group Code", EffectiveDate);
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
            repeat
                InitPostTaxCalculation(POSEntryTaxLine, POSSaleTaxLine, EntryNo, POSSaleTax);
            until POSSaleTaxLine.Next() = 0;
        end;
    end;

    procedure PostPOSTaxAmountCalculationReverseSign(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax")
    var
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        Sign: Integer;
    begin
        POSEntrySalesLine.GetBySystemId(SystemId);
        Sign := 1;
        if POSEntrySalesLine."Amount Incl. VAT" <> 0 then
            Sign := POSEntrySalesLine."Amount Incl. VAT" / Abs(POSEntrySalesLine."Amount Incl. VAT");

        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        if POSSaleTaxLine.FindSet() then begin
            repeat
                InitPostTaxCalculation(POSEntryTaxLine, POSSaleTaxLine, EntryNo, POSSaleTax, Sign);
            until POSSaleTaxLine.Next() = 0;
        end;
    end;

    procedure PostTaxCalculationAmounts(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        POSEntryTaxLine.Quantity += POSSaleTaxLine.Quantity;
        POSEntryTaxLine."Tax Base Amount" += POSSaleTaxLine."Amount Excl. Tax";
        POSEntryTaxLine."Tax Base Amount FCY" += POSSaleTaxLine."Amount Excl. Tax";
        POSEntryTaxLine."Line Amount" += POSSaleTaxLine."Line Amount";
        POSEntryTaxLine."Amount Including Tax" += POSSaleTaxLine."Amount Incl. Tax";
        POSEntryTaxLine."Tax Amount" += POSSaleTaxLine."Tax Amount";
        POSEntryTaxLine."Calculated Tax Amount" += POSSaleTaxLine."Tax Amount";
    end;

    procedure PostTaxCalculationAmountsReverseSign(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax"; Sign: Integer)
    begin
        POSEntryTaxLine.Quantity += Sign * ABS(POSSaleTaxLine.Quantity);
        POSEntryTaxLine."Tax Base Amount" += Sign * ABS(POSSaleTaxLine."Amount Excl. Tax");
        POSEntryTaxLine."Tax Base Amount FCY" += Sign * ABS(POSSaleTaxLine."Amount Excl. Tax");
        POSEntryTaxLine."Line Amount" += Sign * ABS(POSSaleTaxLine."Line Amount");
        POSEntryTaxLine."Amount Including Tax" += Sign * ABS(POSSaleTaxLine."Amount Incl. Tax");
        POSEntryTaxLine."Tax Amount" += Sign * ABS(POSSaleTaxLine."Tax Amount");
        POSEntryTaxLine."Calculated Tax Amount" += Sign * ABS(POSSaleTaxLine."Tax Amount");
    end;

    procedure InitPostTaxCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSEntryNo: Integer; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        POSEntryTaxLine.Setrange("POS Entry No.", POSEntryNo);
        POSEntryTaxLine.SetRange("Tax Jurisdiction Code", POSSaleTaxLine."Tax Jurisdiction Code");
        POSEntryTaxLine.Setrange("Tax Group Code", POSSaleTaxLine."Tax Group Code");
        case POSSaleTaxLine."Tax Type" of
            POSSaleTaxLine."Tax Type"::"Excise Tax":
                POSEntryTaxLine.Setrange("Tax Type", POSEntryTaxLine."Tax Type"::"Excise Tax");
            POSSaleTaxLine."Tax Type"::"Sales Tax":
                POSEntryTaxLine.Setrange("Tax Type", POSEntryTaxLine."Tax Type"::"Sales and Use Tax");
        end;
        POSEntryTaxLine.Setrange("Tax Area Code for Key", POSSaleTaxLine."Tax Area Code for Key");
        POSEntryTaxLine.Setrange("Entry Date", POSSaleTaxLine."Posting Date");
        POSEntryTaxLine.Setrange("Tax Liable", POSSaleTaxLine."Tax Liable");
        if not POSEntryTaxLine.FindFirst() then begin
            Clear(POSEntryTaxLine);

            POSEntryTaxLine."POS Entry No." := POSEntryNo;
            POSEntryTaxLine."Tax Jurisdiction Code" := POSSaleTaxLine."Tax Jurisdiction Code";
            POSEntryTaxLine."Tax Group Code" := POSSaleTaxLine."Tax Group Code";
            case POSSaleTaxLine."Tax Type" of
                POSSaleTaxLine."Tax Type"::"Excise Tax":
                    POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Excise Tax";
                POSSaleTaxLine."Tax Type"::"Sales Tax":
                    POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Sales and Use Tax";
            end;
            POSEntryTaxLine."Tax Area Code for Key" := POSSaleTaxLine."Tax Area Code for Key";
            POSEntryTaxLine."Entry Date" := POSSaleTaxLine."Posting Date";
            POSEntryTaxLine."Tax Liable" := POSSaleTaxLine."Tax Liable";
            POSEntryTaxLine."Calc. for Maximum Amount/Qty." := POSSaleTaxLine."Calc. for Maximum Amount/Qty.";
            POSEntryTaxLine."Tax Calculation Type" := POSSaleTaxLine."Tax Calculation Type";
            POSEntryTaxLine."Tax Area Code" := POSSaleTaxLine."Tax Area Code";
            POSEntryTaxLine."Print Order" := POSSaleTaxLine."Print Order";
            POSEntryTaxLine."Print Description" := POSSaleTaxLine."Print Description";
            POSEntryTaxLine."Calculation Order" := POSSaleTaxLine."Calculation Order";
            POSEntryTaxLine."Round Tax" := POSSaleTaxLine."Round Tax";
            POSEntryTaxLine."Is Report-to Jurisdiction" := POSSaleTaxLine."Is Report-to Jurisdiction";

            OnAfterInitPOSPostedTaxAmtLine(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax);

            POSEntryTaxLine.Insert(true);
        end;
        PostTaxCalculationAmounts(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax);
        POSEntryTaxLine.Modify();
    end;

    procedure InitPostTaxCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSEntryNo: Integer; POSSaleTax: Record "NPR POS Sale Tax"; Sign: Integer)
    begin
        POSEntryTaxLine.Setrange("POS Entry No.", POSEntryNo);
        POSEntryTaxLine.SetRange("Tax Jurisdiction Code", POSSaleTaxLine."Tax Jurisdiction Code");
        POSEntryTaxLine.Setrange("Tax Group Code", POSSaleTaxLine."Tax Group Code");
        case POSSaleTaxLine."Tax Type" of
            POSSaleTaxLine."Tax Type"::"Excise Tax":
                POSEntryTaxLine.Setrange("Tax Type", POSEntryTaxLine."Tax Type"::"Excise Tax");
            POSSaleTaxLine."Tax Type"::"Sales Tax":
                POSEntryTaxLine.Setrange("Tax Type", POSEntryTaxLine."Tax Type"::"Sales and Use Tax");
        end;
        POSEntryTaxLine.Setrange("Tax Area Code for Key", POSSaleTaxLine."Tax Area Code for Key");
        POSEntryTaxLine.Setrange("Entry Date", POSSaleTaxLine."Posting Date");
        POSEntryTaxLine.Setrange("Tax Liable", POSSaleTaxLine."Tax Liable");
        if not POSEntryTaxLine.FindFirst() then begin
            Clear(POSEntryTaxLine);

            POSEntryTaxLine."POS Entry No." := POSEntryNo;
            POSEntryTaxLine."Tax Jurisdiction Code" := POSSaleTaxLine."Tax Jurisdiction Code";
            POSEntryTaxLine."Tax Group Code" := POSSaleTaxLine."Tax Group Code";
            case POSSaleTaxLine."Tax Type" of
                POSSaleTaxLine."Tax Type"::"Excise Tax":
                    POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Excise Tax";
                POSSaleTaxLine."Tax Type"::"Sales Tax":
                    POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Sales and Use Tax";
            end;
            POSEntryTaxLine."Tax Area Code for Key" := POSSaleTaxLine."Tax Area Code for Key";
            POSEntryTaxLine."Entry Date" := POSSaleTaxLine."Posting Date";
            POSEntryTaxLine."Tax Liable" := POSSaleTaxLine."Tax Liable";
            POSEntryTaxLine."Calc. for Maximum Amount/Qty." := POSSaleTaxLine."Calc. for Maximum Amount/Qty.";
            POSEntryTaxLine."Tax Calculation Type" := POSSaleTaxLine."Tax Calculation Type";
            POSEntryTaxLine."Tax Area Code" := POSSaleTaxLine."Tax Area Code";
            POSEntryTaxLine."Print Order" := POSSaleTaxLine."Print Order";
            POSEntryTaxLine."Print Description" := POSSaleTaxLine."Print Description";
            POSEntryTaxLine."Calculation Order" := POSSaleTaxLine."Calculation Order";
            POSEntryTaxLine."Round Tax" := POSSaleTaxLine."Round Tax";
            POSEntryTaxLine."Is Report-to Jurisdiction" := POSSaleTaxLine."Is Report-to Jurisdiction";

            OnAfterInitPOSPostedTaxAmtLine(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax);

            POSEntryTaxLine.Insert(true);
        end;
        PostTaxCalculationAmountsReverseSign(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax, Sign);
        POSEntryTaxLine.Modify();
    end;

    procedure NALocalizationEnabled(): Boolean
    var
        DummyGenJnlLine: Record "Gen. Journal Line";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldReference: FieldRef;
        Enabled: Boolean;
        Handled: Boolean;
    begin
        OnNALocalizationEnabled(DummyGenJnlLine, Handled, Enabled);
        if Handled then
            exit(Enabled);

        DataTypeMgt.GetRecordRef(DummyGenJnlLine, RecRef);
        Exit(DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Tax Jurisdiction Code'));
    end;

    procedure SalesTaxEnabled(POSEntryNo: Integer): Boolean
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        Enabled: Boolean;
        Handled: Boolean;
    begin
        OnSalesTaxEnabled(POSEntryNo, Handled, Enabled);
        if Handled then
            exit(Enabled);

        POSEntryTaxLine.Setrange("POS Entry No.", POSEntryNo);
        POSEntryTaxLine.SetRange("Tax Calculation Type", POSEntryTaxLine."Tax Calculation Type"::"Sales Tax");
        exit(not POSEntryTaxLine.IsEmpty());
    end;

    procedure CreatePostingBufferLinesFromPOSSalesLines(var POSSalesLineToBeCompressed: Record "NPR POS Entry Sales Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer"; POSEntry: Record "NPR POS Entry")
    var
        PostingDescription: Text;
        Compressionmethod: Option Uncompressed,"Per POS Entry","Per POS Period Register";
        PostingDescriptionLbl: Label '%1: %2';
    begin
        POSSalesLineToBeCompressed.SetRange(Type, POSSalesLineToBeCompressed.Type::Item);
        if POSSalesLineToBeCompressed.FindSet() then begin
            repeat
                if POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting"] then begin
                    POSPostingBuffer."Line Type" := POSPostingBuffer."Line Type"::Sales;
                    POSPostingBuffer."POS Entry No." := POSEntry."Entry No.";
                    POSPostingBuffer."Document No." := POSSalesLineToBeCompressed."Document No.";
                    POSPostingBuffer."Line No." := 0;
                    POSPostingBuffer.Type := POSSalesLineToBeCompressed.Type::Item;
                    POSPostingBuffer."No." := '';
                    POSPostingBuffer."Posting Date" := POSEntry."Posting Date";
                    POSPostingBuffer."Gen. Bus. Posting Group" := POSSalesLineToBeCompressed."Gen. Bus. Posting Group";
                    POSPostingBuffer."VAT Bus. Posting Group" := POSSalesLineToBeCompressed."VAT Bus. Posting Group";
                    POSPostingBuffer."Gen. Prod. Posting Group" := POSSalesLineToBeCompressed."Gen. Prod. Posting Group";
                    POSPostingBuffer."VAT Prod. Posting Group" := POSSalesLineToBeCompressed."VAT Prod. Posting Group";
                    POSPostingBuffer."Currency Code" := POSSalesLineToBeCompressed."Currency Code";
                    POSPostingBuffer."POS Payment Bin Code" := '';
                    POSPostingBuffer."Dimension Set ID" := POSSalesLineToBeCompressed."Dimension Set ID";
                    POSPostingBuffer."Tax Area Code" := POSSalesLineToBeCompressed."Tax Area Code";

                    POSPostingBuffer."Applies-to Doc. Type" := POSSalesLineToBeCompressed."Applies-to Doc. Type";
                    POSPostingBuffer."Applies-to Doc. No." := POSSalesLineToBeCompressed."Applies-to Doc. No.";
                    if not POSPostingBuffer.Find() then begin
                        POSPostingBuffer.Init();

                        POSPostingBuffer."VAT Calculation Type" := POSSalesLineToBeCompressed."VAT Calculation Type"::"Sales Tax";
                        POSPostingBuffer."Use Tax" := POSSalesLineToBeCompressed."Use Tax";
                        POSPostingBuffer."Global Dimension 1 Code" := POSSalesLineToBeCompressed."Shortcut Dimension 1 Code";
                        POSPostingBuffer."Global Dimension 2 Code" := POSSalesLineToBeCompressed."Shortcut Dimension 2 Code";
                        POSPostingBuffer."Salesperson Code" := POSSalesLineToBeCompressed."Salesperson Code";
                        POSPostingBuffer."Reason Code" := POSSalesLineToBeCompressed."Reason Code";
                        POSPostingBuffer."POS Store Code" := POSSalesLineToBeCompressed."POS Store Code";
                        POSPostingBuffer."POS Unit No." := POSSalesLineToBeCompressed."POS Unit No.";
                        POSPostingBuffer."POS Period Register" := POSSalesLineToBeCompressed."POS Period Register No.";
                        PostingDescription := StrSubstNo(PostingDescriptionLbl, POSEntry.TableCaption(), POSSalesLineToBeCompressed."POS Entry No.");
                        POSPostingBuffer.Description := CopyStr(PostingDescription, 1, MaxStrLen(POSPostingBuffer.Description));
                        POSPostingBuffer."Tax Liable" := POSSalesLineToBeCompressed."Tax Liable";
                        POSPostingBuffer."Tax Group Code" := POSSalesLineToBeCompressed."Tax Group Code";

                        POSPostingBuffer.Insert();
                    end;

                    POSPostingBuffer."VAT Base Amount" := POSPostingBuffer."VAT Base Amount" - POSSalesLineToBeCompressed."VAT Base Amount";
                    POSPostingBuffer."VAT Amount Discount" := POSPostingBuffer."VAT Amount Discount" - (POSSalesLineToBeCompressed."Line Discount Amount Incl. VAT" - POSSalesLineToBeCompressed."Line Discount Amount Excl. VAT");
                    POSPostingBuffer."VAT Amount Discount (LCY)" := POSPostingBuffer."VAT Amount Discount (LCY)" - (POSSalesLineToBeCompressed."Line Dsc. Amt. Incl. VAT (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Excl. VAT (LCY)");
                    POSPostingBuffer."VAT Amount" := POSPostingBuffer."VAT Amount" - (POSSalesLineToBeCompressed."Amount Incl. VAT" - POSSalesLineToBeCompressed."Amount Excl. VAT");
                    POSPostingBuffer."VAT Amount (LCY)" := POSPostingBuffer."VAT Amount (LCY)" - (POSSalesLineToBeCompressed."Amount Incl. VAT (LCY)" - POSSalesLineToBeCompressed."Amount Excl. VAT (LCY)");

                    POSPostingBuffer.Quantity := POSPostingBuffer.Quantity + POSSalesLineToBeCompressed.Quantity;
                    POSPostingBuffer."Discount Amount" := POSPostingBuffer."Discount Amount" - POSSalesLineToBeCompressed."Line Discount Amount Excl. VAT";
                    POSPostingBuffer."Discount Amount (LCY)" := POSPostingBuffer."Discount Amount (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Excl. VAT (LCY)";
                    POSPostingBuffer.Amount := POSPostingBuffer.Amount - POSSalesLineToBeCompressed."Amount Excl. VAT";
                    POSPostingBuffer."Amount (LCY)" := POSPostingBuffer."Amount (LCY)" - POSSalesLineToBeCompressed."Amount Excl. VAT (LCY)";

                    POSPostingBuffer.Modify();
                end;
            until POSSalesLineToBeCompressed.Next() = 0;
        end;
        POSSalesLineToBeCompressed.SetFilter(Type, '<>%1', POSSalesLineToBeCompressed.Type::Item);
        if POSSalesLineToBeCompressed.FindSet() then
            repeat
                if POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting"] then begin
                    POSPostingBuffer.Init();
                    POSPostingBuffer."Line Type" := POSPostingBuffer."Line Type"::Sales;
                    POSPostingBuffer."POS Entry No." := POSEntry."Entry No.";
                    POSPostingBuffer."Document No." := POSSalesLineToBeCompressed."Document No.";
                    POSPostingBuffer."Line No." := 0;
                    POSPostingBuffer.Type := POSSalesLineToBeCompressed.Type::Item;
                    case POSSalesLineToBeCompressed.Type of
                        POSSalesLineToBeCompressed.Type::Rounding:
                            begin
                                POSPostingBuffer.Type := POSPostingBuffer.Type::"G/L Account";
                                POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                                POSPostingBuffer."Gen. Bus. Posting Group" := POSSalesLineToBeCompressed."Gen. Bus. Posting Group";
                                POSPostingBuffer."VAT Bus. Posting Group" := POSSalesLineToBeCompressed."VAT Bus. Posting Group";
                            end;
                        POSSalesLineToBeCompressed.Type::"G/L Account":
                            begin
                                POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                                POSPostingBuffer."Gen. Bus. Posting Group" := POSSalesLineToBeCompressed."Gen. Bus. Posting Group";
                                POSPostingBuffer."VAT Bus. Posting Group" := POSSalesLineToBeCompressed."VAT Bus. Posting Group";
                            end;
                        POSSalesLineToBeCompressed.Type::Customer:
                            begin
                                POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                            end;
                        POSSalesLineToBeCompressed.Type::Payout,
                        POSSalesLineToBeCompressed.Type::Voucher:
                            begin
                                POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                                Compressionmethod := Compressionmethod::Uncompressed;
                                POSPostingBuffer."Gen. Bus. Posting Group" := POSSalesLineToBeCompressed."Gen. Bus. Posting Group";
                                POSPostingBuffer."VAT Bus. Posting Group" := POSSalesLineToBeCompressed."VAT Bus. Posting Group";
                            end;
                    end;
                    POSPostingBuffer."Gen. Prod. Posting Group" := POSSalesLineToBeCompressed."Gen. Prod. Posting Group";
                    POSPostingBuffer."VAT Prod. Posting Group" := POSSalesLineToBeCompressed."VAT Prod. Posting Group";
                    POSPostingBuffer."Posting Date" := POSEntry."Posting Date";
                    POSPostingBuffer."Currency Code" := POSSalesLineToBeCompressed."Currency Code";
                    POSPostingBuffer."POS Payment Bin Code" := '';
                    POSPostingBuffer."Dimension Set ID" := POSEntry."Dimension Set ID";
                    POSPostingBuffer."Tax Area Code" := POSSalesLineToBeCompressed."Tax Area Code";
                    POSPostingBuffer."Applies-to Doc. Type" := POSSalesLineToBeCompressed."Applies-to Doc. Type";
                    POSPostingBuffer."Applies-to Doc. No." := POSSalesLineToBeCompressed."Applies-to Doc. No.";

                    if not POSPostingBuffer.Find() then begin
                        POSPostingBuffer.Init();

                        POSPostingBuffer."VAT Calculation Type" := POSSalesLineToBeCompressed."VAT Calculation Type"::"Sales Tax";
                        POSPostingBuffer."Use Tax" := POSSalesLineToBeCompressed."Use Tax";
                        POSPostingBuffer."Global Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
                        POSPostingBuffer."Global Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                        POSPostingBuffer."Dimension Set ID" := POSSalesLineToBeCompressed."Dimension Set ID";
                        POSPostingBuffer."Salesperson Code" := POSSalesLineToBeCompressed."Salesperson Code";
                        POSPostingBuffer."Reason Code" := POSSalesLineToBeCompressed."Reason Code";
                        POSPostingBuffer."POS Store Code" := POSSalesLineToBeCompressed."POS Store Code";
                        POSPostingBuffer."POS Unit No." := POSSalesLineToBeCompressed."POS Unit No.";
                        POSPostingBuffer."POS Period Register" := POSSalesLineToBeCompressed."POS Period Register No.";
                        PostingDescription := StrSubstNo(PostingDescriptionLbl, POSEntry.TableCaption(), POSSalesLineToBeCompressed."POS Entry No.");
                        POSPostingBuffer.Description := CopyStr(PostingDescription, 1, MaxStrLen(POSPostingBuffer.Description));
                        POSPostingBuffer."Tax Liable" := POSSalesLineToBeCompressed."Tax Liable";
                        POSPostingBuffer."Tax Group Code" := POSSalesLineToBeCompressed."Tax Group Code";

                        POSPostingBuffer.Insert();
                    end;

                    POSPostingBuffer."VAT Base Amount" := POSPostingBuffer."VAT Base Amount" - POSSalesLineToBeCompressed."VAT Base Amount";
                    POSPostingBuffer."VAT Amount Discount" := POSPostingBuffer."VAT Amount Discount" - (POSSalesLineToBeCompressed."Line Discount Amount Incl. VAT" - POSSalesLineToBeCompressed."Line Discount Amount Excl. VAT");
                    POSPostingBuffer."VAT Amount Discount (LCY)" := POSPostingBuffer."VAT Amount Discount (LCY)" - (POSSalesLineToBeCompressed."Line Dsc. Amt. Incl. VAT (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Excl. VAT (LCY)");
                    POSPostingBuffer."VAT Amount" := POSPostingBuffer."VAT Amount" - (POSSalesLineToBeCompressed."Amount Incl. VAT" - POSSalesLineToBeCompressed."Amount Excl. VAT");
                    POSPostingBuffer."VAT Amount (LCY)" := POSPostingBuffer."VAT Amount (LCY)" - (POSSalesLineToBeCompressed."Amount Incl. VAT (LCY)" - POSSalesLineToBeCompressed."Amount Excl. VAT (LCY)");

                    POSPostingBuffer.Quantity := POSPostingBuffer.Quantity + POSSalesLineToBeCompressed.Quantity;
                    POSPostingBuffer."Discount Amount" := POSPostingBuffer."Discount Amount" - POSSalesLineToBeCompressed."Line Discount Amount Excl. VAT";
                    POSPostingBuffer."Discount Amount (LCY)" := POSPostingBuffer."Discount Amount (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Excl. VAT (LCY)";
                    POSPostingBuffer.Amount := POSPostingBuffer.Amount - POSSalesLineToBeCompressed."Amount Excl. VAT";
                    POSPostingBuffer."Amount (LCY)" := POSPostingBuffer."Amount (LCY)" - POSSalesLineToBeCompressed."Amount Excl. VAT (LCY)";

                    if POSSalesLineToBeCompressed.Type = POSSalesLineToBeCompressed.Type::Rounding then begin
                        POSPostingBuffer."Rounding Amount" -= POSSalesLineToBeCompressed."Amount Incl. VAT";
                        POSPostingBuffer."Rounding Amount (LCY)" -= POSSalesLineToBeCompressed."Amount Incl. VAT (LCY)";
                    end;

                    POSPostingBuffer.Modify();
                end;
            until POSSalesLineToBeCompressed.Next() = 0;
        POSPostingBuffer.Reset();
        POSSalesLineToBeCompressed.Reset();
    end;

    procedure CreateGenJournalLinesFromSalesTax(var POSPostingBuffer: Record "NPR POS Posting Buffer"; var GenJnlLine: Record "Gen. Journal Line"; POSEntry: Record "NPR POS Entry"; var LineNumber: Integer)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line" temporary;
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryTaxLine.SetRange("Tax Calculation Type", POSEntryTaxLine."Tax Calculation Type"::"Sales Tax");
        if not POSEntryTaxLine.FindSet() then
            exit;
        GetPOSPostingProfile(POSEntry, POSPostingProfile);
        if not NALocalizationEnabled() then begin
            GroupPOSEntryTaxLine(POSEntryTaxLine, TempPOSEntryTaxLine);
            TempPOSEntryTaxLine.Reset();
            TempPOSEntryTaxLine.FindSet();
            repeat
                repeat
                    CreateGenJournalLinesFromSalesTax(POSEntry, TempPOSEntryTaxLine, GenJnlLine, POSPostingProfile, LineNumber);
                until POSEntryTaxLine.Next() = 0;
            until TempPOSEntryTaxLine.Next() = 0;
        end else begin
            repeat
                CreateGenJournalLinesFromSalesTax(POSEntry, POSEntryTaxLine, GenJnlLine, POSPostingProfile, LineNumber);
            until POSEntryTaxLine.Next() = 0;
        end;
    end;

    local procedure GetPOSPostingProfile(var POSEntry: Record "NPR POS Entry"; var POSPostingProfile: Record "NPR POS Posting Profile")
    var
        POSStore: Record "NPR POS Store";
        POSEntry2: Record "NPR POS Entry";
    begin
        POSEntry2.Copy(POSEntry);
        if POSEntry2."POS Unit No." = '' then
            if not POSEntry2.FindFirst() then
                POSEntry2.Init();
        POSStore.GetProfile(POSEntry2."POS Store Code", POSPostingProfile);
    end;

    local procedure CreateGenJournalLinesFromSalesTax(POSEntry: Record "NPR POS Entry"; var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; var GenJnlLine: Record "Gen. Journal Line"; POSPostingProfile: Record "NPR POS Posting Profile"; var LineNumber: Integer)
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        CurrExchRate: Record "Currency Exchange Rate";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        LineNumber += 10000;

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := POSEntry."Posting Date";
        GenJnlLine."Document Date" := POSEntry."Document Date";
        GenJnlLine.Description := CopyStr(POSEntry.Description, 1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine."Line No." := LineNumber;
        GenJnlLine."Reason Code" := POSEntry."Reason Code";
        GenJnlLine."Document No." := POSEntry."Document No.";
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."Source Currency Code" := POSEntry."Currency Code";

        DataTypeMgt.GetRecordRef(GenJnlLine, RecRef);
        if DataTypeMgt.FindFieldByName(RecRef, FldRef, 'Tax Jurisdiction Code') then
            FldRef.Value := POSEntryTaxLine."Tax Jurisdiction Code";
        if DataTypeMgt.FindFieldByName(RecRef, FldRef, 'Tax Type') then
            FldRef.Value := POSEntryTaxLine."Tax Type";
        RecRef.SetTable(GenJnlLine);

        GenJnlLine.Quantity := POSEntryTaxLine.Quantity;
        GenJnlLine."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := POSEntry."Dimension Set ID";
        GenJnlLine."Source Code" := POSPostingProfile."Source Code";
        GenJnlLine."Bill-to/Pay-to No." := POSEntry."Customer No.";
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := POSEntry."Customer No.";
        GenJnlLine."Source Curr. VAT Base Amount" :=
          CurrExchRate.ExchangeAmtLCYToFCY(
            POSEntry."Posting Date", POSEntry."Currency Code", POSEntryTaxLine."Tax Base Amount", POSEntry."Currency Factor");

        GenJnlLine."VAT Base Amount (LCY)" := POSEntryTaxLine."Tax Base Amount";
        GenJnlLine."VAT Base Amount" := GenJnlLine."VAT Base Amount (LCY)";
        GenJnlLine.Amount := 0;
        GenJnlLine."Amount (LCY)" := 0;
        GenJnlLine."Source Currency Amount" := 0;

        if TaxJurisdiction.Code <> POSEntryTaxLine."Tax Jurisdiction Code" then begin
            TaxJurisdiction.Get(POSEntryTaxLine."Tax Jurisdiction Code");
        end;

        if TaxJurisdiction."Unrealized VAT Type" > 0 then begin
            TaxJurisdiction.TestField("Unreal. Tax Acc. (Sales)");
            GenJnlLine."Account No." := TaxJurisdiction."Unreal. Tax Acc. (Sales)";
        end else begin
            TaxJurisdiction.TestField("Tax Account (Sales)");
            GenJnlLine."Account No." := TaxJurisdiction."Tax Account (Sales)";
        end;

        GenJnlLine."Source Curr. VAT Amount" := POSEntryTaxLine."Tax Amount";
        GenJnlLine."VAT Amount (LCY)" := POSEntryTaxLine."Tax Amount";
        GenJnlLine."VAT Amount" := GenJnlLine."VAT Amount (LCY)";
        GenJnlLine."VAT Difference" := POSEntryTaxLine."Tax Difference";
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Sale;
        GenJnlLine."Tax Group Code" := POSEntryTaxLine."Tax Group Code";
        GenJnlLine."Tax Liable" := POSEntryTaxLine."Tax Liable";
        GenJnlLine."Tax Area Code" := POSEntryTaxLine."Tax Area Code";
        GenJnlLine."VAT Calculation Type" := GenJnlLine."VAT Calculation Type"::"Sales Tax";
        GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";

        GenJnlLine."Source Curr. VAT Base Amount" := -GenJnlLine."Source Curr. VAT Base Amount";
        GenJnlLine."VAT Base Amount (LCY)" := -GenJnlLine."VAT Base Amount (LCY)";
        GenJnlLine."VAT Base Amount" := -GenJnlLine."VAT Base Amount";
        GenJnlLine.Amount := -GenJnlLine.Amount;
        GenJnlLine."Amount (LCY)" := -GenJnlLine."Amount (LCY)";
        GenJnlLine."Source Currency Amount" := -GenJnlLine."Source Currency Amount";
        GenJnlLine."Source Curr. VAT Amount" := -GenJnlLine."Source Curr. VAT Amount";
        GenJnlLine."VAT Amount (LCY)" := -GenJnlLine."VAT Amount (LCY)";
        GenJnlLine."VAT Amount" := -GenJnlLine."VAT Amount";
        GenJnlLine.Quantity := -GenJnlLine.Quantity;
        GenJnlLine."VAT Difference" := -GenJnlLine."VAT Difference";
        GenJnlLine.UpdateLineBalance();
        GenJnlLine.Insert();
    end;

    local procedure GroupPOSEntryTaxLine(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; var TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line")
    begin
        repeat
            TempPOSEntryTaxLine.Reset();
            TempPOSEntryTaxLine.SetRange("Tax Calculation Type", POSEntryTaxLine."Tax Calculation Type");
            TempPOSEntryTaxLine.SetRange("Tax Area Code", POSEntryTaxLine."Tax Area Code");
            TempPOSEntryTaxLine.SetRange("Tax Group Code", POSEntryTaxLine."Tax Group Code");
            TempPOSEntryTaxLine.SetRange("Use Tax", POSEntryTaxLine."Use Tax");
            TempPOSEntryTaxLine.SetRange("Tax Area Code for Key", POSEntryTaxLine."Tax Area Code for Key");
            if not TempPOSEntryTaxLine.FindFirst() then begin
                TempPOSEntryTaxLine := POSEntryTaxLine;
                TempPOSEntryTaxLine.Insert();
            end else begin
                TempPOSEntryTaxLine."Calculated Tax Amount" := TempPOSEntryTaxLine."Calculated Tax Amount" + POSEntryTaxLine."Calculated Tax Amount";
                TempPOSEntryTaxLine."Tax Difference" := TempPOSEntryTaxLine."Tax Difference" + POSEntryTaxLine."Tax Difference";
                TempPOSEntryTaxLine."Tax Amount" := TempPOSEntryTaxLine."Tax Amount" + POSEntryTaxLine."Tax Amount";
                TempPOSEntryTaxLine."Amount Including Tax" := TempPOSEntryTaxLine."Tax Base Amount" + POSEntryTaxLine."Tax Amount";
                TempPOSEntryTaxLine.Modify();
            end;
        until POSEntryTaxLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnNALocalizationEnabled(GenJnlLine: Record "Gen. Journal Line"; var Handled: Boolean; var Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSalesTaxEnabled(POSEntryNo: Integer; var Handled: Boolean; var Enabled: Boolean)
    begin
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

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Tax Line Subpage", 'OnNALocalizationEnabled', '', true, true)]
    local procedure IsNALocalizationEnabled(var _NALocalizationEnabled: Boolean)
    begin
        _NALocalizationEnabled := NALocalizationEnabled();
    end;
}