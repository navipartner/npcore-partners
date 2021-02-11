codeunit 6014504 "NPR Retail Contract Mgt."
{
    var
        GlobalInsuranceProfit: Decimal;
        GlobalInsuranceCost: Decimal;
        Text000: Label 'Serial No. is not applied to Item No. %1';
        GlobalInsuranceCombination: Record "NPR Insurance Combination";
        Text001: Label 'Sms Template does not exist\\Create Sms Template?';
        Text002: Label 'Status Sms Sent to %1';

    procedure "--- Insurrance"()
    begin
    end;

    procedure CalcInsCost(var SalePos: Record "NPR Sale POS"; InsuranceCompanyName: Code[50]) Total: Decimal
    var
        PhotoSetup: Record "NPR Retail Contr. Setup";
        SaleLinePos: Record "NPR Sale Line POS";
        InsuranceCategory: Record "NPR Insurance Category";
        InsuranceCombination: Record "NPR Insurance Combination";
        InsuranceCompany: Record "NPR Insurance Companies";
        SubTotal: Decimal;
    begin
        //-NPR5.27 [255580]
        GlobalInsuranceCost := 0;
        GlobalInsuranceProfit := 0;

        PhotoSetup.Get;

        if InsuranceCompanyName = '*' then begin
            if InsuranceCompany.Count = 1 then
                InsuranceCompany.FindFirst
            else
                if PAGE.RunModal(0, InsuranceCompany) <> ACTION::LookupOK then
                    exit(0);
            InsuranceCompanyName := InsuranceCompany.Code;
        end;

        if InsuranceCompanyName = '' then begin
            if PhotoSetup."Default Insurance Company" = '' then
                exit(0);

            InsuranceCompanyName := PhotoSetup."Default Insurance Company";
        end;

        Total := 0;
        SaleLinePos.SetRange("Register No.", SaleLinePos."Register No.");
        SaleLinePos.SetRange("Sales Ticket No.", SaleLinePos."Sales Ticket No.");
        SaleLinePos.SetRange(Date, Today);
        SaleLinePos.SetRange("Sale Type", SaleLinePos."Sale Type"::Sale);
        SaleLinePos.SetRange(Type, SaleLinePos.Type::Item);
        SaleLinePos.SetCurrentKey("Insurance Category", "Register No.", "Sales Ticket No.", Date, "Sale Type", Type);
        if InsuranceCategory.FindSet then
            exit(0);

        repeat
            SaleLinePos.SetRange("Insurance Category", InsuranceCategory.Kategori);
            case InsuranceCategory."Calculation Type" of
                InsuranceCategory."Calculation Type"::"Amount incl. VAT":
                    begin
                        SaleLinePos.CalcSums("Amount Including VAT");
                        SubTotal := Round(SaleLinePos."Amount Including VAT", 1, '<');
                    end;
                InsuranceCategory."Calculation Type"::"Unit Price":
                    begin
                        SubTotal := 0;
                        if SaleLinePos.FindSet then
                            repeat
                                SubTotal += SaleLinePos."Unit Price" * SaleLinePos.Quantity;
                            until SaleLinePos.Next = 0;
                        SubTotal := Round(SubTotal, 1, '<');
                    end;
            end;

            InsuranceCombination.SetRange(Company, InsuranceCompanyName);
            InsuranceCombination.SetRange(Type, InsuranceCategory.Kategori);
            InsuranceCombination.SetFilter("Amount From", '<=%1', SubTotal);
            InsuranceCombination.SetFilter("To Amount", '>=%1', SubTotal);
            GlobalInsuranceCombination.CopyFilters(InsuranceCombination);
            if InsuranceCombination.FindFirst then begin
                if InsuranceCombination."Amount as Percentage" then
                    Total += InsuranceCombination."Insurance Amount" * SubTotal / 100
                else
                    Total += InsuranceCombination."Insurance Amount";
                GlobalInsuranceProfit += InsuranceCombination."Insurance Amount" * InsuranceCombination."Profit %" / 100;
                GlobalInsuranceCost += InsuranceCombination."Insurance Amount" * (1 - InsuranceCombination."Profit %" / 100);
            end;
        until InsuranceCategory.Next = 0;
        //+NPR5.27 [255580]
    end;

    procedure SendStatusSms(CustomerRepair: Record "NPR Customer Repair")
    var
        SmsTemplateHeader: Record "NPR SMS Template Header";
        SmsMgt: Codeunit "NPR SMS Management";
        SmsContent: Text;
    begin
        //-NPR5.27 [255580]
        CustomerRepair.TestField("Mobile Phone No.");
        if not SmsMgt.FindTemplate(CustomerRepair, SmsTemplateHeader) then begin
            if not CreateSmsTemplate('REPAIR', CustomerRepair, SmsTemplateHeader) then
                exit;
        end;

        SmsContent := SmsMgt.MakeMessage(SmsTemplateHeader, CustomerRepair);
        SmsMgt.SendSMS(CustomerRepair."Mobile Phone No.", SmsTemplateHeader."Alt. Sender", SmsContent);

        Message(Text002, CustomerRepair."Mobile Phone No.");
        //+NPR5.27 [255580]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CreateSmsTemplate(TemplateCode: Code[10]; RecVariant: Variant; var SmsTemplateHeader: Record "NPR SMS Template Header"): Boolean
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        //-NPR5.27 [255580]
        if not GuiAllowed then
            exit(false);
        if not RecVariant.IsRecord then
            exit(false);
        if not Confirm(Text001, true) then
            exit(false);
        RecRef.GetTable(RecVariant);

        if SmsTemplateHeader.Get(TemplateCode) then begin
            TemplateCode += '1';
            while SmsTemplateHeader.Get(TemplateCode) do
                TemplateCode := IncStr(TemplateCode);
        end;

        SmsTemplateHeader.Init;
        SmsTemplateHeader.Code := TemplateCode;
        SmsTemplateHeader."Table No." := RecRef.Number;
        SmsTemplateHeader.Insert(true);
        Commit;
        PAGE.RunModal(PageMgt.GetDefaultCardPageID(DATABASE::"NPR SMS Template Header"), SmsTemplateHeader);
        if SmsTemplateHeader.Code = '' then
            exit(false);
        SmsTemplateHeader.TestField("Table No.", RecRef.Number);

        exit(true);
        //+NPR5.27 [255580]
    end;
}

