codeunit 6014552 "Touch - Sales Line POS"
{
    // NPR4.10/VB/20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629  CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.14/MMV/20150804 CASE 216519 Set correct key to prevent coloring the wrong line on return.
    // NPR4.14/VB/20150909  CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925  CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.15/VB/20150930  CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.16/BHR/20152710 CASE 222136 Discount to be applied only on items.
    // NPR4.18/JC/20150110  CASE 227275 Escaping variant selection on item validate.Error occurs on insert
    // NPR9   /VB/20150104  CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.20/VB/20151221  CASE 229375 Limiting search box to 50 characters
    // NPR5.20/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 229375 NP Retail 2016
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // TM1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // NPR5.20/JDH /20160321  CASE 237255 Modify inserted in function ResetDiscountOnActiveLine
    // NPR5.22/VB  /20160406  CASE 237866 Speed improvement: sending only the delta between last state and new state of sale lines
    // NPR5.23/MMV /20160518  CASE 237189 Added function: UpdateCustomerDisplay()
    // NPR5.23/TTH /20160530  CASE 239528 Any line of type comment caused the system not to find the last line after a comment was added
    // NPR5.26/BHR /20160816  CASE 246712 Prevent discount on returns for total discount %
    // NPR5.28/VB  /20161122  CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.29/MHA /20170110  CASE 262904 Deleted unused variables
    // NPR5.29/TS  /20170116  CASE 244157 Removed reference to field "Pop-up (Color-Size)" (1011)
    // NPR5.33/MHA /20170609  CASE 274176 Added FIND before MODIFY
    // NPR5.33/JDH /20170629 CASE 280329 call to GetDiscountRounding removed - returned 0 always
    // NPR5.36/TJ  /20170905 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.37/TJ  /20171018 CASE 286283 Translated variable with danish specific letters into english
    // NPR5.45/MHA /20180803  CASE 323705 Signature changed on SaleLinePOS.FindItemSalesPrice()
    // NPR5.46/CLVA/20180920 CASE 328581 Removed relation to CU 6014532 Customer Display Mgt.
    // NPR5.48/JDH /20181106 CASE 334584 Function GetSalesLineWeb. Renamed Parameter from Grid to DGrid. Grid is a reserved word in Ext V2
    // NPR5.49/TJ  /20190201 CASE 335739 Using POS View Profile instead Register


    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSGlobal: Record "Sale Line POS";
        RetailFormCode: Codeunit "Retail Form Code";
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        ReverseSignQty: Boolean;
        FindSalesLinePOS: Boolean;
        BalanceAmount: Decimal;
        ReturnSalesType: Option " ","Return Sales to";
        CustomerNo: Code[20];
        Validation: Code[250];
        ReverseSignQtySalesTicketNo: Code[20];
        Text10600014: Label 'Comment';
        Text10600016: Label 'CUSTOMER';
        Text10600020: Label 'DEBIT';
        Text10600021: Label 'Error';
        Text10600022: Label 'Error - Variant Code selection cancelled !';
        SessionMgt: Codeunit "POS Web Session Management";

    procedure CalculateBalance()
    var
        SaleLinePOS2: Record "Sale Line POS";
        VATAmount: Decimal;
        AmountExclVAT: Decimal;
    begin
        // UdregnSaldo
        with SaleLinePOSGlobal do begin
          BalanceAmount := 0;
          VATAmount := 0;

          if ("Register No." <> '') and ("Sales Ticket No." <> '') then begin
            SaleLinePOS2.SetCurrentKey("Discount Type");
            SaleLinePOS2.SetRange(SaleLinePOS2."Register No.","Register No.");
            SaleLinePOS2.SetRange(SaleLinePOS2."Sales Ticket No.","Sales Ticket No.");

            SaleLinePOS2.SetFilter("Sale Type",'%1|%2',"Sale Type"::Sale,"Sale Type"::Deposit); // Indbetaling - Debitor
            SaleLinePOS2.CalcSums(SaleLinePOS2."Amount Including VAT");
            SaleLinePOS2.CalcSums(SaleLinePOS2.Amount);
            AmountExclVAT := SaleLinePOS2.Amount;
            BalanceAmount := SaleLinePOS2."Amount Including VAT";
            VATAmount := BalanceAmount - AmountExclVAT;

            SaleLinePOS2.SetFilter("Sale Type",'%1',SaleLinePOS2."Sale Type"::"Out payment");          // Udbetaling - Finans
            SaleLinePOS2.SetFilter("Discount Type",'<>%1',"Discount Type"::Rounding);
            SaleLinePOS2.CalcSums(SaleLinePOS2."Amount Including VAT");
            BalanceAmount := BalanceAmount - SaleLinePOS2."Amount Including VAT";
            //-NPR5.33 [280329]
            //Saldo -= RetailFormCode.GetDiscountRounding("Sales Ticket No.","Register No.");
            //+NPR5.33 [280329]

          end;
        end;
    end;

    procedure ChangeQuantityOnActiveLine(var SalePOS: Record "Sale POS";var QuantityIn: Decimal)
    var
        Register: Record Register;
        GiftCert: Boolean;
        GiftVoucherQuantity: Integer;
        Txt001: Label 'This will make %1 gift vouchers more. Continue?';
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin
        //RetAntalp�AktivLinie(VAR Ant : Decimal)
        with SaleLinePOSGlobal do begin
          if "Gift Voucher Ref." = '' then begin
            //-NPR5.33 [274176]
            Find;
            //+NPR5.33 [274176]
            case "Sale Type" of
              "Sale Type"::Sale:
                 begin
                   Validate(Quantity,QuantityIn);
                 end;
              "Sale Type"::Deposit:
                 begin
                   Validate("Unit Price","Unit Price" * QuantityIn);
                 end;
              "Sale Type"::"Out payment":
                 begin
                   Validate("Unit Price","Unit Price" * QuantityIn);
                 end;
            end;
            Modify;
          end else begin
            if not Confirm(Txt001,false, QuantityIn - 1) then
              exit;
            for GiftVoucherQuantity := 1 to QuantityIn - 1 do
              RetailFormCode.GiftVoucherPush(SalePOS,Register,GiftCert,true,SaleLinePOSGlobal,false);
            //-NPR5.45 [323705]
            //IF FIND('-') THEN;
            if FindFirst then;
            //+NPR5.45 [323705]
          end;
        end;

        //-TM1.11
        TicketRequestManager.POS_OnModifyQuantity(SaleLinePOSGlobal);
        //+TM1.11
    end;

    procedure ChangeDiscountOnActiveLine(var DiscountPct: Decimal;KeepPrev: Boolean)
    var
        DiscountPct2: Decimal;
    begin
        //RetRabatp�AktivLinie(VAR Rabatpct : Decimal)
        with SaleLinePOSGlobal do begin
          //-NPR5.33 [274176]
          Find;
          //+NPR5.33 [274176]
          if "Custom Disc Blocked" = true then
            exit;

          if (DiscountPct <> 0) and KeepPrev then begin
            DiscountPct2 := (1 - "Discount %" / 100) * (1 - DiscountPct / 100);
            DiscountPct2 := (1 - DiscountPct2) * 100;
            Validate("Discount %",DiscountPct2);
            //"Rabatpct." := Rabatpct;
          end else
            Validate("Discount %",DiscountPct);
            //"Rabatpct." := Rabatpct;

          if Type = Type::Item then begin
            "Discount Amount" := 0;
            Item.Get("No.");
            //-NPR5.45 [323705]
            //GetAmount(SaleLinePOSGlobal,Item,FindItemSalesPrice(SaleLinePOSGlobal));
            GetAmount(SaleLinePOSGlobal,Item,SaleLinePOSGlobal.FindItemSalesPrice());
            //+NPR5.45 [323705]
          end;
          Modify(true);
        end;
    end;

    procedure ChangeDiscountAmountOnActLine(var DiscountAmount: Decimal)
    begin
        //RetRabatbel�bp�AkvivLinie(VAR RabatBel�b : Decimal)
        with SaleLinePOSGlobal do begin
          //-NPR5.33 [274176]
          Find;
          //+NPR5.33 [274176]
          Validate("Discount Amount",DiscountAmount);
          Modify;
          CalculateBalance;
        end;
    end;

    procedure ChangeAmountOnActiveLine(Amount2: Decimal)
    begin
        //RetBel�bp�AktivLinie(Dec : Decimal)
        with SaleLinePOSGlobal do begin
          if Quantity = 0 then
            exit;
          if Quantity < 0 then
            Amount2 := -Amount2;

          if ("Gift Voucher Ref." = '') then begin
            if ("Sale Type" = "Sale Type"::Deposit) and (Type = Type::Customer) then
              ChangeUnitPriceOnActiveLine(Amount2)
            else begin
              //-NPR5.33 [274176]
              Find;
              //+NPR5.33 [274176]
              Validate("Amount Including VAT",Amount2);
              Validate("No.");
              Modify;
            end;
          end else
            ChangeUnitPriceOnActiveLine(Amount2);

          CalculateBalance;
        end;
    end;

    procedure ChangeUnitPriceOnActiveLine(UnitPrice: Decimal)
    var
        Item: Record Item;
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
    begin
        //RetAprisP�AktivLinie(Dec : Decimal)
        with SaleLinePOSGlobal do begin
          //-NPR5.33 [274176]
          Find;
          //+NPR5.33 [274176]
          case Type of
            Type::Item:
              begin
                Validate("Unit Price",UnitPrice);
                if Item.Get("No.") then
                  "Initial Group Sale Price" := UnitPrice;
                if Quantity < 0 then
                  "Discount Type" := "Discount Type"::Manual;
              end;
            Type::Customer,
            Type::"G/L Entry":
              begin
                "Amount Including VAT" := 0;
                Validate("Unit Price",UnitPrice);
              end;
          end;

          UnitPrice := 0;
          if Modify then;
          if "Gift Voucher Ref." <> '' then
            TouchScreenFunctions.ModifyGiftVoucher(SaleLinePOSGlobal);

          CalculateBalance;
        end;
    end;

    procedure ClearReverseQuantity()
    begin
        // ClearReverseQty()
        ReverseSignQty := false;
        ReverseSignQtySalesTicketNo := '';
        ReturnSalesType := ReturnSalesType::" ";
    end;

    procedure DeleteActiveRecord(var Knr: Code[20]): Boolean
    var
        Text001: Label 'You can not delete a Terminal Accepted payment type! Finish the current sale with/without sales linies.';
    begin
        with SaleLinePOSGlobal do begin
          if "Cash Terminal Approved" then
            POSEventMarshaller.DisplayError(Text10600021,Text001,true);

          if "Customer No. Line" then
            CustomerNo := '';

          if Find then
            Delete(true);
        end;
    end;

    procedure DeleteAllLines()
    begin
        //deleteAllLines
        with SaleLinePOSGlobal do begin
          DeleteAll;
        end;
    end;

    procedure GetBalance(): Decimal
    begin
        CalculateBalance;
        exit(BalanceAmount);
    end;

    procedure GetLineNo() Linenr: Integer
    begin
        with SaleLinePOSGlobal do begin
          exit("Line No.");
        end;
    end;

    procedure GetLineItemNumber(): Code[250]
    begin
        with SaleLinePOSGlobal do begin
          if Type = Type::Item then
            exit("No.")
          else
            exit('');
        end;
    end;

    procedure GetLineQuantity(): Decimal
    begin
        //getLineQuantity
        with SaleLinePOSGlobal do
          exit(Quantity);
    end;

    procedure GetSubTotal() SubTotal: Decimal
    begin
        exit(BalanceAmount);
    end;

    procedure InsertItemLine(var ItemNo: Code[20];var SalePOS: Record "Sale POS") Inserted: Boolean
    var
        Contact: Record Contact;
        SaleLinePOS2: Record "Sale Line POS";
        SaleLinePOS3: Record "Sale Line POS";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        LineNo: Integer;
        Cust: Record Customer;
        Text001: Label 'Customer club member does not exist';
        GLAccount: Record "G/L Account";
        Text002: Label 'G/L Account\ "%1 - %2"\ is not prepared for outpayment on register';
        TmpStr: Text[250];
        ItemVariant: Record "Item Variant";
    begin
        //Inds�tVareLinie
        with SaleLinePOSGlobal do begin
          SaleLinePOS2.Reset;
          //-NPR5.23
          SaleLinePOS2.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
          //+NPR5.23
          SaleLinePOS2.SetRange("Register No.",SalePOS."Register No.");
          SaleLinePOS2.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          //-NPR5.22
          //Linie.SETFILTER("Line No.",'>%1',"Line No.");
          //
          //IF Linie.FIND('-') THEN BEGIN
          //  LinieInteger := "Line No." + ROUND(((Linie."Line No." - "Line No.") / 2),1);
          //END ELSE BEGIN
          //  LinieInteger := "Line No." + 10000;
          //END;
          if SaleLinePOS2.FindLast() then;
          LineNo := SaleLinePOS2."Line No." + 10000;
          //+NPR5.22
          if not LineExists then
            LineNo := 10000;

          SaleLinePOS3.Init;
          SaleLinePOS3."Register No." := SalePOS."Register No.";
          SaleLinePOS3."Sales Ticket No." := SalePOS."Sales Ticket No.";
          SaleLinePOS3."Line No." := LineNo;
          SaleLinePOS3.Date := SalePOS.Date;
          SaleLinePOS3."Sale Type" := "Sale Type"::Sale;
          SaleLinePOS3.Type := Type::Item;

          // ------------- KOMMENTAR
          if ItemNo = '*' then begin
            TmpStr := POSEventMarshaller.SearchBox(Text10600014,'',50);
            if TmpStr = '<CANCEL>' then
              exit(false);
            SaleLinePOS3.Description := TmpStr;
            SaleLinePOS3.Validate("No.",'*');
            SaleLinePOS3.Validate(Quantity, 1);
          end;

          // ------------- KONTANTKUNDE
          if ItemNo = '<KONTANT>' then begin
            CustomerNo := Validation;
            Contact.SetCurrentKey("No.");
            if not Contact.Get(CustomerNo) then
              Error(Text001);

            SaleLinePOS3.Description := Contact.Name;
            SaleLinePOS3.Type := SaleLinePOS3.Type::Comment;
            SaleLinePOS3."Sale Type" := SaleLinePOS3."Sale Type"::Comment;
            SaleLinePOS3.Validate("No.",'*');
            SaleLinePOS3.Validate(Quantity,1);
            SaleLinePOS3."Customer No. Line" := true;
            ItemNo := Text10600016;
            if SaleLinePOS3.Insert(true) then
              Inserted := true;
            exit;
          end;

          // -------------- DEBET-KUNDE
          if ItemNo = '<DEBET>' then begin
            CustomerNo := Validation;
            if not Cust.Get(CustomerNo) then
              exit;
            SaleLinePOS3.Description := Cust.Name;

            case SaleLinePOS3."Sale Type" of
              "Sale Type"::Sale,
              "Sale Type"::Comment:
                begin
                  SaleLinePOS3.Type := SaleLinePOS3.Type::Comment;
                  SaleLinePOS3."Sale Type" := SaleLinePOS3."Sale Type"::Comment;
                  SaleLinePOS3.Validate("No.",'*');
                end;
              "Sale Type"::Deposit:
                begin
                  SaleLinePOS3.Type := SaleLinePOS3.Type::Customer;
                  SaleLinePOS3."Sale Type" := SaleLinePOS3."Sale Type"::Deposit;
                  SaleLinePOS3.Validate("No.",CustomerNo);
                end;
              "Sale Type"::"Out payment":
                exit(false);
            end;

            SaleLinePOS3.Validate(Quantity,1);
            SaleLinePOS3."Customer No. Line" := true;
            ItemNo := Text10600020;
            if SaleLinePOS3.Insert(true) then
              Inserted := true;
            exit;
          end;

          //--------------- ACCOUNT -----------------------
          if ItemNo = '<ACCOUNT>' then begin
            GLAccount.Get(Validation);
            if not GLAccount."Retail Payment" then
              POSEventMarshaller.DisplayError(Text10600021,StrSubstNo(Text002,GLAccount."No.",GLAccount.Name),true);

            SaleLinePOS3.Type := SaleLinePOS3.Type::"G/L Entry";
            SaleLinePOS3."Sale Type" := SaleLinePOS3."Sale Type"::"Out payment";
            SaleLinePOS3.Validate("No.",Validation);
            SaleLinePOS3.Validate(Quantity,1);
            if SaleLinePOS3.Insert(true) then
              Inserted := true;
            exit;
          end;

          SaleLinePOS3.Validate("No.",ItemNo);
          //-NPR4.18
          if (SaleLinePOS3.Type = SaleLinePOS3.Type::Item) and (SaleLinePOS3."No." <> '') and  (SaleLinePOS3."Variant Code" = '') then begin
            ItemVariant.SetRange("Item No.",SaleLinePOS3."No.");
            if not ItemVariant.IsEmpty then
              Error(Text10600022);
          end;
          //+NPR4.18

          //IF "Linie 2".Description <> '' THEN BEGIN
          if SaleLinePOS3.Insert(true) then begin
            Inserted := true;
          end else
            exit(false);                 // Insert only if item exists...

          SaleLinePOS := SaleLinePOS3;
          FindSalesLinePOS := true;

          SaleLinePOS3.Reset;
          //-NPR5.29
          //IF ("Variant Code" = '') AND RetailSetup."Pop-up (Color-Size)" THEN
          if ("Variant Code" = '') then
          //+NPR5.29
            TouchScreenFunctions.VariationLookup(SaleLinePOSGlobal);

          CalculateBalance;
          JumpEnd;
        end;
    end;

    procedure IsGroupSale(): Boolean
    var
        Item2: Record Item;
    begin
        with SaleLinePOSGlobal do begin
          if Item2.Get("No.") then;
          exit(Item2."Group sale");
        end;
    end;

    procedure IsLineZero(): Boolean
    begin
        with SaleLinePOSGlobal do begin
          if "Unit Price" = 0 then
            exit(true)
          else
            exit(false);
        end;
    end;

    procedure JumpEnd()
    begin
        //jumpend
        with SaleLinePOSGlobal do begin
          if FindLast then; // CurrForm.UPDATE(FALSE);
        end;
    end;

    procedure LineExists(): Boolean
    var
        SaleLinePOS2: Record "Sale Line POS";
    begin
        //LineExists
        SaleLinePOS2.CopyFilters(SaleLinePOSGlobal);
        //-NPR5.45 [323705]
        //EXIT(SaleLinePOS2.FIND('-'));
        exit(SaleLinePOS2.FindFirst);
        //+NPR5.45 [323705]
    end;

    procedure ResetDiscountOnActiveLine()
    begin
        with SaleLinePOSGlobal do begin
          //-NPR5.33 [274176]
          Find;
          //+NPR5.33 [274176]
          "Discount Type" := "Discount Type"::" ";
          "Discount Code" := '';
          Validate("Discount %", 0);
          "Discount Amount" := 0;
          "Custom Disc Blocked" := false;
          //-NPR5.20
          Modify;
          //+NPR5.20
        end;
    end;

    procedure ReverseQtySignFactor(): Boolean
    begin
        //ReverseQtySignFkt
        with SaleLinePOSGlobal do begin
          if ReverseSignQty and (ReverseSignQtySalesTicketNo = "Sales Ticket No.") then
            exit(true)
          else
            exit(false);
        end;
    end;

    procedure SetDiscountCode(DiscountCode: Code[10])
    begin
        //setDiscountCode
        with SaleLinePOSGlobal do begin
          //-NPR5.33 [274176]
          Find;
          //+NPR5.33 [274176]
          "Discount Type" := "Discount Type"::Manual;
          "Discount Code" := DiscountCode;
          Modify;
        end;
    end;

    procedure SetDescription(Desc: Text[50])
    begin
        with SaleLinePOSGlobal do begin
          //-NPR5.33 [274176]
          Find;
          //+NPR5.33 [274176]
          Description := Desc;
          if Modify then;
        end;
    end;

    procedure SetLine(SaleLinePOS2: Record "Sale Line POS")
    begin
        //setLine
        with SaleLinePOSGlobal do begin
          Get(SaleLinePOS2."Register No.",
              SaleLinePOS2."Sales Ticket No.",
              SaleLinePOS2.Date,
              SaleLinePOS2."Sale Type",
              SaleLinePOS2."Line No.");
        end;
    end;

    procedure SetReasonCode(ReasonCode: Code[10])
    begin
        //setReasonCode(code1 : Code[10])
        with SaleLinePOSGlobal do begin
          //-NPR5.33 [274176]
          Find;
          //+NPR5.33 [274176]
          "Reason Code" := ReasonCode;
          Modify;
        end;
    end;

    procedure SetReturnReason(ReturnReasonCode: Code[10])
    begin
        //setReturnReason
        with SaleLinePOSGlobal do begin
          //-NPR5.33 [274176]
          Find;
          //+NPR5.33 [274176]
          "Return Reason Code" := ReturnReasonCode;
          if Modify then;
        end;
    end;

    procedure SetReverseQtySignFactor()
    begin
        //SetReverseQtySignFkt
        with SaleLinePOSGlobal do begin
          if ReverseSignQty and (ReverseSignQtySalesTicketNo = "Sales Ticket No.") then begin
            ReverseSignQty := false;
            ReverseSignQtySalesTicketNo := '';
            ReturnSalesType := ReturnSalesType::" ";
          end else begin
            ReverseSignQty := true;
            ReverseSignQtySalesTicketNo := "Sales Ticket No.";
            ReturnSalesType := ReturnSalesType::"Return Sales to";
          end;
        end;
    end;

    procedure SetTableView(RegisterNo: Code[20];SalesTicketNo: Code[20])
    begin
        SaleLinePOSGlobal.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
        SaleLinePOSGlobal.SetRange("Register No.",RegisterNo);
        SaleLinePOSGlobal.SetRange("Sales Ticket No.",SalesTicketNo);
        SaleLinePOSGlobal.SetFilter(Type,'<>%1',SaleLinePOSGlobal.Type::Payment);
        SaleLinePOSGlobal."Register No." := RegisterNo;
    end;

    procedure SetValidation(ValidationIn: Code[250])
    begin
        Validation := ValidationIn
    end;

    procedure TotalDiscountPercent(DiscountPct: Decimal;keepprev: Boolean)
    begin
        //TotalPctRabat
        with SaleLinePOSGlobal do begin
          //-NPR5.45 [323705]
          //IF FIND('-') THEN REPEAT
          if FindSet then repeat
          //+NPR5.45 [323705]
            //-NPR4.16
            //-NPR5.26 [246712]
            //IF Type = Type::Item THEN
            if (Type = Type::Item) and (Quantity > 0)  then
            //+NPR5.26 [246712]
            //+NPR4.16
              ChangeDiscountOnActiveLine(DiscountPct,keepprev);
          until Next = 0;
        end;
    end;

    procedure UpdateCustomerDisplay()
    var
        Register: Record Register;
    begin
        //-NPR5.23
        if Register.Get(SaleLinePOSGlobal."Register No.") then
          //-NPR5.46 [328581]
          //CustomerDisplayMgt.OnSaleLineAction(SaleLinePOSGlobal,Register);
          //+NPR5.46 [328581]
        //+NPR5.23
    end;

    procedure ValidateVendorItemNoOnLine(VendorItemNo: Code[20];var SalePOS: Record "Sale POS") SaleLinePOSInserted: Boolean
    var
        Item: Record Item;
        SaleLinePOS2: Record "Sale Line POS";
        SaleLinePOS3: Record "Sale Line POS";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        LineNo: Integer;
    begin
        //ValidateVendorItemNoOnLine
        with SaleLinePOSGlobal do begin
          SaleLinePOS2.Reset;
          SaleLinePOS2.SetRange("Register No.",SalePOS."Register No.");
          SaleLinePOS2.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          //Linie.SETRANGE(Date, Eksp.Date);
          SaleLinePOS2.SetFilter("Line No.",'>%1',"Line No.");

          //-NPR5.45 [323705]
          //IF SaleLinePOS2.FIND('-') THEN BEGIN
          if SaleLinePOS2.FindFirst then begin
          //+NPR5.45 [323705]
            LineNo := "Line No." + Round(((SaleLinePOS2."Line No." - "Line No.") / 2),1);
          end else begin
            LineNo := "Line No." + 10000;
          end;

          if not LineExists then
            LineNo := 10000;

          SaleLinePOS3.Init;
          SaleLinePOS3."Register No." := SalePOS."Register No.";
          SaleLinePOS3."Sales Ticket No." := SalePOS."Sales Ticket No.";
          SaleLinePOS3."Line No." := LineNo;
          SaleLinePOS3.Date := SalePOS.Date;
          SaleLinePOS3."Sale Type" := "Sale Type"::Sale;
          SaleLinePOS3.Type := Type::Item;

          Item.SetRange("Vendor Item No.",VendorItemNo);
          //-NPR5.45 [323705]
          //Item.FIND('-');
          Item.FindFirst;
          //+NPR5.45 [323705]

          SaleLinePOS3.Validate("No.",Item."No.");

          if SaleLinePOS3.Insert(true) then begin
            SaleLinePOSInserted := true;
          end else
            exit(false);

          SaleLinePOS := SaleLinePOS3;
          FindSalesLinePOS := true;

          SaleLinePOS3.Reset;
          //-NPR5.29
          //IF ("Variant Code" = '') AND RetailSetup."Pop-up (Color-Size)" THEN
          if ("Variant Code" = '') then
          //+NPR5.29
            TouchScreenFunctions.VariationLookup(SaleLinePOSGlobal);

          CalculateBalance;
          JumpEnd;
        end;
    end;

    procedure GETRECORD(var SaleLinePOS: Record "Sale Line POS")
    begin
        SaleLinePOS := SaleLinePOSGlobal;
    end;

    procedure SETPOSITION(Position: Text[250])
    begin
        if (SaleLinePOSGlobal.Count = 0) or (Position = '') then
          exit;
        SaleLinePOSGlobal.SetPosition(Position);
        SaleLinePOSGlobal.Find;
    end;

    procedure GETPOSITION(): Text
    begin
        //-NPR4.11
        if SaleLinePOSGlobal.Find then
          exit(SaleLinePOSGlobal.GetPosition())
        else
          exit('');
        //+NPR4.11
    end;

    procedure GetRecordReference(var RecRef: RecordRef)
    begin
        RecRef.GetTable(SaleLinePOSGlobal);
    end;

    procedure GetSalesLines(var DotNetDataTable: DotNet DataTable)
    var
        RefSalesLinePOS: RecordRef;
        DotNetTableToolkit: Codeunit "NavTable To DotNet Table Tool";
        SaleLinePOSColumns: array [40] of Integer;
        Itt: Integer;
        SaleLinePOS: Record "Sale Line POS";
    begin
        GetDescriptorArray(SaleLinePOSColumns);
        GetRecordReference(RefSalesLinePOS);
        DotNetTableToolkit.AddCustomColumn('LineColor','LineColor');
        DotNetTableToolkit.SetColumnDataDescription(SaleLinePOSColumns);
        DotNetTableToolkit.SetRecordRef(RefSalesLinePOS);
        DotNetTableToolkit.FillTable;
        SaleLinePOS := SaleLinePOSGlobal;
        SaleLinePOS.CopyFilters(SaleLinePOSGlobal);
        //-NPR4.14
        SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
        //+NPR4.14

        if SaleLinePOS.FindSet then
          repeat
            if SaleLinePOS.Quantity < 0 then
              DotNetTableToolkit.SetCustomColumnValue(SaleLinePOS.GetPosition(false),Itt,'LineColor','Red');
            Itt += 1;
          until SaleLinePOS.Next = 0;

        DotNetTableToolkit.GetDotNetDataTable(DotNetDataTable);
    end;

    procedure GetDescriptorArray(var FieldArray: array [40] of Integer)
    var
        Index: Integer;
    begin
        with SaleLinePOSGlobal do begin
          TestAndSetColumn(Index,FieldArray[Index],FieldName("No."),FieldNo("No."));
          TestAndSetColumn(Index,FieldArray[Index],FieldName(Type),FieldNo(Type));
          TestAndSetColumn(Index,FieldArray[Index],FieldName(Description),FieldNo(Description));
          TestAndSetColumn(Index,FieldArray[Index],FieldName("Item Group"),FieldNo("Item Group"));
          TestAndSetColumn(Index,FieldArray[Index],FieldName(Color),FieldNo(Color));
          TestAndSetColumn(Index,FieldArray[Index],FieldName(Size),FieldNo(Size));
          TestAndSetColumn(Index,FieldArray[Index],FieldName("Label No."),FieldNo("Label No."));
          TestAndSetColumn(Index,FieldArray[Index],FieldName("Unit Price"),FieldNo("Unit Price"));
          TestAndSetColumn(Index,FieldArray[Index],FieldName(Quantity),FieldNo(Quantity));
          TestAndSetColumn(Index,FieldArray[Index],FieldName("Discount Amount"),FieldNo("Discount Amount"));
          TestAndSetColumn(Index,FieldArray[Index],FieldName("Discount %"),FieldNo("Discount %"));
          TestAndSetColumn(Index,FieldArray[Index],FieldName("Amount Including VAT"),FieldNo("Amount Including VAT"));
        end;
    end;

    procedure TestAndSetColumn(var Index: Integer;var VarToSet: Integer;FieldName: Text[30];FieldNumber: Integer): Boolean
    begin
        if not IncludeField(FieldName) then
          exit;
        Index += 1;
        VarToSet := FieldNumber;
        exit(true);
    end;

    procedure IncludeField(FieldName: Text[30]): Boolean
    var
        RetailSetup: Record "Retail Setup";
    begin
        RetailSetup.Get;
        case FieldName of
          'No.'         : exit(false);
          'Type'        : exit(false);
          'Description' : exit(true);
          'Belongs to Item Group' : exit(false);
          'Color'       : exit(false);
          'Size'        : exit(false);
          'Label No.'   : exit(false);
          'Quantity'    : exit(true);
          'Unit Price'  : exit(true);
          'Discount Amount' :  exit(RetailSetup."POS - Show discount fields");
          'Discount %'      :  exit(RetailSetup."POS - Show discount fields");
          'Amount Including VAT' : exit(true);
        end;
    end;

    procedure GetSalesLinesWeb(DGrid: DotNet DataGrid;var LastLineTemp: Record "Sale Line POS" temporary)
    var
        Register: Record Register;
        SaleLinePOS: Record "Sale Line POS";
        CurrentLineTemp: Record "Sale Line POS" temporary;
        SaleLinePOSNewTemp: Record "Sale Line POS" temporary;
        RecRef: RecordRef;
        POSWebUtilities: Codeunit "POS Web Utilities";
        DeletedGrid: DotNet DataGrid;
        Row: DotNet Dictionary_Of_T_U;
        Direction: Text;
        POSViewProfile: Record "POS View Profile";
    begin
        SaleLinePOS := SaleLinePOSGlobal;
        SaleLinePOS.CopyFilters(SaleLinePOSGlobal);

        //-NPR5.22
        //RecRef.GETTABLE(SaleLinePOS);
        //Util.NavRecordToRows(RecRef,Grid);
        if SaleLinePOS.FindSet() then
          repeat
            LastLineTemp := SaleLinePOS;
            if (not LastLineTemp.Find()) or (LastLineTemp."SQL Server Timestamp" <> SaleLinePOS."SQL Server Timestamp") then begin
              SaleLinePOSNewTemp := SaleLinePOS;
              SaleLinePOSNewTemp.Insert();
            end;
            CurrentLineTemp := SaleLinePOS;
            CurrentLineTemp.Insert();
          until SaleLinePOS.Next = 0;

        RecRef.GetTable(SaleLinePOSNewTemp);
        POSWebUtilities.NavRecordToRows(RecRef,DGrid);
        if (SaleLinePOSNewTemp.Count = 1) and (SaleLinePOS.Count > 1) and SaleLinePOSNewTemp.FindFirst() then begin
          //-NPR5.49 [335739]
          //IF SessionMgt.LineOrderOnScreen() = Register."Line Order on Screen"::Normal THEN
          if SessionMgt.LineOrderOnScreen() = POSViewProfile."Line Order on Screen"::Normal then
          //+NPR5.49 [335739]
            Direction := '>'
          else
            Direction := '<';
          SaleLinePOS := SaleLinePOSNewTemp;
          if SaleLinePOS.Find(Direction) then
            foreach Row in DGrid.Rows do
              Row.Add('__afterRow__',SaleLinePOS.GetPosition(false));
        end;

        SaleLinePOSNewTemp.DeleteAll();
        DeletedGrid := DeletedGrid.DataGrid();
        if LastLineTemp.FindSet() then
          repeat
            CurrentLineTemp := LastLineTemp;
            if not CurrentLineTemp.Find() then begin
              SaleLinePOSNewTemp := LastLineTemp;
              SaleLinePOSNewTemp.Insert();
            end;
          until LastLineTemp.Next = 0;

        RecRef.GetTable(SaleLinePOSNewTemp);
        POSWebUtilities.NavRecordToRows(RecRef,DeletedGrid);
        foreach Row in DeletedGrid.Rows do begin
          Row.Add('__deleted__',true);
          DGrid.Rows.Add(Row);
        end;

        LastLineTemp.DeleteAll();
        if SaleLinePOS.FindSet() then
          repeat
            LastLineTemp := SaleLinePOS;
            LastLineTemp.Insert();
          until SaleLinePOS.Next = 0;
        exit;
        //+NPR5.22
    end;
}

