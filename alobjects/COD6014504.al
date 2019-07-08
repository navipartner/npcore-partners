codeunit 6014504 "Retail Contract Mgt."
{
    // NPR5.27/MHA /20161025  CASE 255580 Codeunit Renamed from Retail Photo Code, Removed redundant and unused functions, Renamed remaining functions from Danish to English, Customer Repair Functions added
    // NPR5.29/MMV /20170110  CASE 260033 Added report interface support for better webclient printing.


    trigger OnRun()
    begin
    end;

    var
        GlobalInsuranceProfit: Decimal;
        GlobalInsuranceCost: Decimal;
        Text000: Label 'Serial No. is not applied to Item No. %1';
        GlobalInsuranceCombination: Record "Insurance Combination";
        Text001: Label 'Sms Template does not exist\\Create Sms Template?';
        Text002: Label 'Status Sms Sent to %1';

    procedure "--- Insurrance"()
    begin
    end;

    procedure CalcInsCost(var SalePos: Record "Sale POS";InsuranceCompanyName: Code[50]) Total: Decimal
    var
        PhotoSetup: Record "Retail Contract Setup";
        SaleLinePos: Record "Sale Line POS";
        InsuranceCategory: Record "Insurance Category";
        InsuranceCombination: Record "Insurance Combination";
        InsuranceCompany: Record "Insurance Companies";
        SubTotal: Decimal;
    begin
        //-NPR5.27 [255580]
        GlobalInsuranceCost := 0;
        GlobalInsuranceProfit := 0;

        PhotoSetup.Get;

        if InsuranceCompanyName = '*' then begin
          if InsuranceCompany.Count = 1 then
            InsuranceCompany.FindFirst
          else if PAGE.RunModal(0,InsuranceCompany) <> ACTION::LookupOK then
            exit(0);
          InsuranceCompanyName := InsuranceCompany.Code;
        end;

        if InsuranceCompanyName = '' then begin
          if PhotoSetup."Default Insurance Company" = '' then
            exit(0);

          InsuranceCompanyName := PhotoSetup."Default Insurance Company";
        end;

        Total := 0;
        SaleLinePos.SetRange("Register No.",SaleLinePos."Register No.");
        SaleLinePos.SetRange("Sales Ticket No.",SaleLinePos."Sales Ticket No.");
        SaleLinePos.SetRange(Date,Today);
        SaleLinePos.SetRange("Sale Type",SaleLinePos."Sale Type"::Sale);
        SaleLinePos.SetRange(Type,SaleLinePos.Type::Item);
        SaleLinePos.SetCurrentKey("Insurance Category","Register No.","Sales Ticket No.",Date,"Sale Type",Type);
        if InsuranceCategory.FindSet then
          exit(0);

        repeat
          SaleLinePos.SetRange("Insurance Category",InsuranceCategory.Kategori);
          case InsuranceCategory."Calculation Type" of
            InsuranceCategory."Calculation Type"::"Amount incl. VAT":
              begin
                SaleLinePos.CalcSums("Amount Including VAT");
                SubTotal := Round(SaleLinePos."Amount Including VAT",1,'<');
              end;
            InsuranceCategory."Calculation Type"::"Unit Price":
              begin
                SubTotal := 0;
                if SaleLinePos.FindSet then
                  repeat
                    SubTotal += SaleLinePos."Unit Price" * SaleLinePos.Quantity;
                  until SaleLinePos.Next = 0;
                SubTotal := Round(SubTotal,1,'<');
              end;
          end;

          InsuranceCombination.SetRange(Company,InsuranceCompanyName);
          InsuranceCombination.SetRange(Type,InsuranceCategory.Kategori);
          InsuranceCombination.SetFilter("Amount From",'<=%1',SubTotal);
          InsuranceCombination.SetFilter("To Amount",'>=%1',SubTotal);
          GlobalInsuranceCombination.CopyFilters(InsuranceCombination);
          if InsuranceCombination.FindFirst then begin
            if InsuranceCombination."Amount as Percentage" then
              Total += InsuranceCombination."Insurance Amount" * SubTotal / 100
            else
              Total += InsuranceCombination."Insurance Amount";
            GlobalInsuranceProfit += InsuranceCombination."Insurance Amount" * InsuranceCombination."Profit %" / 100;
            GlobalInsuranceCost += InsuranceCombination."Insurance Amount" * (1 - InsuranceCombination."Profit %"/100);
          end;
        until InsuranceCategory.Next = 0;
        //+NPR5.27 [255580]
    end;

    procedure CheckInsurance(var SalePos: Record "Sale POS"): Boolean
    var
        PhotoSetup: Record "Retail Contract Setup";
        SaleLinePos: Record "Sale Line POS";
    begin
        //-NPR5.27 [255580]
        with SalePos do begin
          PhotoSetup.Get;
          SaleLinePos.SetRange("Register No.","Register No.");
          SaleLinePos.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePos.SetFilter("Insurance Category",'<>%1','');
          if not SaleLinePos.FindFirst then
            exit(true);

          SaleLinePos.SetRange("Insurance Category");
          SaleLinePos.SetRange("No.",PhotoSetup."Insurance Item No.");
          SaleLinePos.SetFilter(Quantity,'>%1',0);
          exit(SaleLinePos.FindFirst);
        end;
        //+NPR5.27 [255580]
    end;

    procedure GetInsuranceProfit(): Decimal
    begin
        //-NPR5.27 [255580]
        exit(GlobalInsuranceProfit);
        //+NPR5.27 [255580]
    end;

    procedure InsertInsurance(var SalePos: Record "Sale POS")
    var
        PhotoSetup: Record "Retail Contract Setup";
        SaleLinePos: Record "Sale Line POS";
        LineNo: Integer;
        Cost: Decimal;
    begin
        //-NPR5.27 [255580]
        PhotoSetup.Get;

        if SalePos.Parameters = '' then
          Cost := CalcInsCost(SalePos,'*')
        else
          Cost := CalcInsCost(SalePos,SalePos.Parameters);

        if PhotoSetup."Check Serial No." then begin
          SaleLinePos.SetRange("Register No.",SalePos."Register No.");
          SaleLinePos.SetRange("Sales Ticket No.",SalePos."Sales Ticket No.");
          SaleLinePos.SetRange(Date,Today);
          SaleLinePos.SetRange("Sale Type",SaleLinePos."Sale Type"::Sale);
          SaleLinePos.SetRange(Type,SaleLinePos.Type::Item);
          SaleLinePos.SetRange(Forsikring,false);
          SaleLinePos.SetFilter(SaleLinePos."Insurance Category",'<>%1','');

          if SaleLinePos.FindSet then
            repeat
              if (SaleLinePos."Serial No." = '') and (SaleLinePos."Serial No. not Created" = '') then
                Error(Text000,SaleLinePos."No.");
            until SaleLinePos.Next = 0;
        end;

        Clear(SaleLinePos);
        SaleLinePos.SetRange("Register No.",SalePos."Register No.");
        SaleLinePos.SetRange("Sales Ticket No.",SalePos."Sales Ticket No.");
        if SaleLinePos.FindLast then;
        LineNo := Round(SaleLinePos."Line No.",10000,'<') + 10000;

        SaleLinePos.Reset;
        SaleLinePos.Init;
        SaleLinePos."Register No." := SalePos."Register No.";
        SaleLinePos."Sales Ticket No." := SalePos."Sales Ticket No.";
        SaleLinePos.Date := SalePos.Date;
        SaleLinePos."Sale Type" := SaleLinePos."Sale Type"::Sale;
        SaleLinePos."Line No." := LineNo;
        SaleLinePos.Type := SaleLinePos.Type::Item;
        SaleLinePos.Insert(true);
        SaleLinePos.Validate("No.",PhotoSetup."Insurance Item No.");
        SaleLinePos.Validate(Quantity,1);
        SaleLinePos.Validate("Unit Price",Cost);
        SaleLinePos.Validate("Unit Cost",GlobalInsuranceCost / (1 + SaleLinePos."VAT %"));
        if (GlobalInsuranceCombination.FindFirst) and (GlobalInsuranceCombination."Ticket tekst" <> '') then
          SaleLinePos.Description := GlobalInsuranceCombination."Ticket tekst";
        SaleLinePos.Forsikring := true;
        SaleLinePos."Insurance Category" := GlobalInsuranceCombination.Type;
        SaleLinePos.Modify;
        //+NPR5.27 [255580]
    end;

    procedure PrintInsurance(RegisterNo: Code[10];SalesTicketNo: Code[20];Force: Boolean)
    var
        AuditRoll: Record "Audit Roll";
        PhotoSetup: Record "Retail Contract Setup";
        ReportSelectionPhoto: Record "Report Selection - Contract";
        ReportPrinterInterface: Codeunit "Report Printer Interface";
    begin
        //-NPR5.27 [255580]
        PhotoSetup.Get;
        if not (PhotoSetup."Print Insurance Policy" or Force) then
          exit;

        AuditRoll.SetRange("Register No.",RegisterNo);
        AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);

        ReportSelectionPhoto.SetRange("Report Type",ReportSelectionPhoto."Report Type"::"Insurance Offer");
        ReportSelectionPhoto.SetFilter("Report ID",'>0');
        ReportSelectionPhoto.SetRange("Register No.",RegisterNo);

        if not ReportSelectionPhoto.FindFirst then
          ReportSelectionPhoto.SetRange("Register No.",'');

        if not ReportSelectionPhoto.FindSet then
          exit;

        repeat
          //-NPR5.29 [260033]
          ReportPrinterInterface.RunReport(ReportSelectionPhoto."Report ID", true, true, AuditRoll);
          //REPORT.RUNMODAL(ReportSelectionPhoto."Report ID",TRUE,TRUE,AuditRoll);
          //+NPR5.29 [260033]
        until ReportSelectionPhoto.Next = 0;
        //+NPR5.27 [255580]
    end;

    procedure "--- Warranty"()
    begin
    end;

    procedure PosSaleToWarranty(var SalePos: Record "Sale POS"): Code[20]
    var
        Item: Record Item;
        PhotoSetup: Record "Retail Contract Setup";
        Register: Record Register;
        SaleLinePos: Record "Sale Line POS";
        WarrantyDirectory: Record "Warranty Directory";
        WarrantyLine: Record "Warranty Line";
        txtDescr: Label 'Certificate of warranty generated from ticket no. %1';
        LineNo: Integer;
    begin
        //-NPR5.27 [255580]
        Register.Get(SalePos."Register No.");
        PhotoSetup.Get;
        if PhotoSetup."Check Customer No." then
          SalePos.TestField("Customer No.");

        WarrantyDirectory.Init;
        WarrantyDirectory.Insert(true);
        WarrantyDirectory.Description := StrSubstNo(txtDescr,SaleLinePos."Sales Ticket No.");
        WarrantyDirectory.Debitortype := SalePos."Customer Type";
        WarrantyDirectory.Validate("Customer No.",SalePos."Customer No.");
        WarrantyDirectory."Salesperson Code" := SalePos."Salesperson Code";
        WarrantyDirectory."Rettet den" := Today;
        WarrantyDirectory.Bonnummer := SaleLinePos."Sales Ticket No.";
        WarrantyDirectory.Kassenummer := SaleLinePos."Register No.";
        WarrantyDirectory."Posting Date" := SaleLinePos.Date;
        WarrantyDirectory."Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
        WarrantyDirectory."Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
        WarrantyDirectory.Modify;

        SaleLinePos.SetRange("Register No.",SaleLinePos."Register No.");
        SaleLinePos.SetRange("Sales Ticket No.",SaleLinePos."Sales Ticket No.");
        SaleLinePos.SetRange(Date,Today);
        SaleLinePos.SetFilter("Sale Type",'%1|%2' ,SaleLinePos."Sale Type"::Sale,SaleLinePos."Sale Type"::Comment);
        SaleLinePos.SetFilter(Type,'%1|%2', SaleLinePos.Type::Item,SaleLinePos.Type::Comment);
        if not SaleLinePos.FindSet then
          exit(WarrantyDirectory."No.");

        LineNo := 0;
        repeat
          if Item.Get(SaleLinePos."No.") then
           if (Item."Guarantee Index" = Item."Guarantee Index"::"Flyt til garanti kar.") then begin
            LineNo += 10000;
            WarrantyLine.Init;
            WarrantyLine."Warranty No." := WarrantyDirectory."No.";
            WarrantyLine."Line No." := LineNo;
            if SaleLinePos."No." = '*' then begin
              WarrantyLine.Description := SaleLinePos.Description;
              WarrantyLine."Item No." := '*';
            end else
              WarrantyLine.Validate("Item No.",SaleLinePos."No.");
            WarrantyLine.Validate(Quantity,SaleLinePos.Quantity);
            WarrantyLine."Unit Price" := SaleLinePos."Unit Price";
            WarrantyLine.Amount := SaleLinePos.Amount;
            WarrantyLine."Amount incl. VAT" := SaleLinePos."Amount Including VAT";
            WarrantyLine."Serial No. not Created" := SaleLinePos."Serial No. not Created";
            WarrantyLine."Discount %" := SaleLinePos."Discount %";
            WarrantyLine."Serial No." := SaleLinePos."Serial No.";
            WarrantyLine."Lock Code" := SaleLinePos."Lock Code";
            WarrantyLine.InsuranceType := SaleLinePos."Insurance Category";
            WarrantyLine."Label No." := SaleLinePos."Label No.";
            if SaleLinePos."No." = PhotoSetup."Insurance Item No." then
              WarrantyLine.Insurance := true;
            WarrantyLine.Insert;

            if WarrantyLine.Insurance and not WarrantyDirectory."Insurance sold" then begin
              WarrantyDirectory."Insurance sold" := true;
              WarrantyDirectory.Modify;
            end;
          end;
        until SaleLinePos.Next = 0;

        exit(WarrantyDirectory."No.");
        //+NPR5.27 [255580]
    end;

    procedure "--- Customer Repair"()
    begin
    end;

    procedure SendStatusSms(CustomerRepair: Record "Customer Repair")
    var
        SmsTemplateHeader: Record "SMS Template Header";
        SmsMgt: Codeunit "SMS Management";
        SmsContent: Text;
    begin
        //-NPR5.27 [255580]
        CustomerRepair.TestField("Mobile Phone No.");
        if not SmsMgt.FindTemplate(CustomerRepair,SmsTemplateHeader) then begin
          if not CreateSmsTemplate('REPAIR',CustomerRepair,SmsTemplateHeader) then
            exit;
        end;

        SmsContent := SmsMgt.MakeMessage(SmsTemplateHeader,CustomerRepair);
        SmsMgt.SendSMS(CustomerRepair."Mobile Phone No.",SmsTemplateHeader."Alt. Sender",SmsContent);

        Message(Text002,CustomerRepair."Mobile Phone No.");
        //+NPR5.27 [255580]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CreateSmsTemplate(TemplateCode: Code[10];RecVariant: Variant;var SmsTemplateHeader: Record "SMS Template Header"): Boolean
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        //-NPR5.27 [255580]
        if not GuiAllowed then
          exit(false);
        if not RecVariant.IsRecord then
          exit(false);
        if not Confirm(Text001,true) then
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
        PAGE.RunModal(PageMgt.GetDefaultCardPageID(DATABASE::"SMS Template Header"),SmsTemplateHeader);
        if SmsTemplateHeader.Code = '' then
          exit(false);
        SmsTemplateHeader.TestField("Table No.",RecRef.Number);

        exit(true);
        //+NPR5.27 [255580]
    end;
}

