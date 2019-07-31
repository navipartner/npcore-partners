// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6014480 "Retail Document Handling"
{
    // Retail Document Handling.
    // (Partially) By Nicolai Esbensen.
    // 
    // "Sale2RetailDocument(VAR Sale : Record "Sale POS") : Boolean"
    //   Transfers the given "Sale" to a Retail Document of the Type specified in
    //   "Sale"."Retail Document Type". Forms are run modal in this function.
    // 
    // "RetailDocument2Sale(VAR Sale : Record "Sale POS";VAR PermS�lger : Code[20])"
    //   Transfers a document of type "Sale"."Retail Document Type" to the sale indicated
    //   by the "Sale" Forms are run modal in this function.
    // 
    // "CashRetailDocument("Retail Document Type" : Integer;"Retail Document No." : Code[20])"
    //   Marks the document as cashed. Should be called when the document is processed.
    // 
    // NPR4.000.004, 11-06-09, MH, Tilf�jet overf�rsel af feltet "Lock Code" i forbindelse med RetailDocument2Sale (sag 65422).
    // 
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPRx.xx/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX Solution
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.36/TJ  /20170809  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.48/ZESO/20181119  CASE 336337 Change Sale Type as as Comment instaed of Sale.
    // NPR5.48/TS  /20190125  CASE 335677 Description was not being inserted and it resulted in an error.
    // NPR5.49/MMV /20190410 CASE 351475 Calculate amounts correctly on deposit line.
    //                                   Validate qty & UoM in same way as latest transcendence wrapper.


    trigger OnRun()
    begin
    end;

    var
        RetailDocLinesRec: Record "Retail Document Lines";

    procedure Sale2RetailDocument(var SalePOS: Record "Sale POS"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        RetailSetup: Record "Retail Setup";
        RetailDocumentHeader: Record "Retail Document Header";
        RetailDocumentLines: Record "Retail Document Lines";
        RetailComment: Record "Retail Comment";
        RetailComments2: Record "Retail Comment";
        Txt000: Label 'Error';
        Txt001: Label 'No lines to transfer!';
        Txt003: Label 'Deposit';
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //POSEventMarshaller: Codeunit "POS Event Marshaller";
        LastDocumentNo: Code[20];
        CustomerNo: Code[20];
        NextSalesLine: Integer;
        Txt005: Label 'You have to specify document type. Contact your solution center!';
        nLines: Integer;
        DocumentCreated: Boolean;
        DeleteExisting: Boolean;
        Txt012: Label 'No lines to transfer.';
        Txt011: Label 'Set deposit amount?';
        Txt014: Label 'Deposit Relation for Cash Customers isn''t set';
        Txt018: Label 'Deposit is typically used if the items are to be booked in advance or ordered as a special delivery, but you want assurance that the customer returns. If the items are paid for now then deposit is not used.';
    begin
        //Sale2RetailDocument
        if not RetailSalesLineCode.LineExists(SalePOS) then begin
            if SalePOS.TouchScreen then
                Error(Txt012)
            else
                Message(Txt012);
            exit;
        end;

        SalePOS.Deposit := 0;

        RetailSetup.Get;

        /*--- Filter Sales Lines According to sales Header ---*/
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        /*--- Check If A unique document is Already Created ---*/
        SaleLinePOS.SetRange("Retail Document Type", 1, 10);
        SaleLinePOS.SetFilter("Retail Document No.", '<>%1', '');
        if SaleLinePOS.FindSet then
            repeat
                if (LastDocumentNo <> '') and
                   (LastDocumentNo <> SaleLinePOS."Retail Document No.") then begin
                    DeleteExisting := true;
                    DocumentCreated := false; // As we cannot reuse document
                    SaleLinePOS.FindLast;
                end else begin
                    RetailDocumentHeader.Get(SaleLinePOS."Retail Document Type", SaleLinePOS."Retail Document No.");
                    DocumentCreated := true;
                end;
                LastDocumentNo := SaleLinePOS."Retail Document No."
            until SaleLinePOS.Next = 0;

        if DocumentCreated and not DeleteExisting then begin
            SaleLinePOS.SetRange("Retail Document Type", 0);
            SaleLinePOS.SetFilter("Retail Document No.", '%1', '');
        end else begin
            SaleLinePOS.SetRange("Retail Document Type");
            SaleLinePOS.SetRange("Retail Document No.");
        end;

        if (SalePOS."Retail Document Type" in [SalePOS."Retail Document Type"::"Retail Order",
                                  SalePOS."Retail Document Type"::Customization]) and
                                  RetailSetup."Use deposit in Retail Doc"
                                  then begin
            if Confirm(Txt011, false, Txt018) then
                // TODO: CTRLUPGRADE - must be refactored to not use Marshaller
                ERROR('CTRLUPGRADE');
            //  POSEventMarshaller.NumPad(Txt011, SalePOS.Deposit, false, false);
        end;

        if (SalePOS.Parameters <> '') and
           (RetailSetup."Cash Customer Deposit rel." = '') and
           (SalePOS."Customer Type" = SalePOS."Customer Type"::Cash) then
            Error(Txt014);

        Commit;

        if SalePOS."Retail Document Type" = 0 then
            Error(Txt005);

        RetailSetup.Get;

        /* NEW HEADER ----------------------------------------------------- */
        if not DocumentCreated then begin
            RetailDocumentHeader.Init;
            RetailDocumentHeader."Document Type" := SalePOS."Retail Document Type";
            RetailDocumentHeader."Customer Type" := SalePOS."Customer Type";
            RetailDocumentHeader."No." := '';
            RetailDocumentHeader.Insert(true);

            if RetailDocumentHeader."Customer Type" = 0 then begin
                CustomerNo := SalePOS."Customer No.";
            end else begin
                CustomerNo := RetailSetup."Cash Customer Deposit rel.";
            end;

            if RetailSetup."Customer type" = RetailSetup."Customer type"::Cash then
                RetailDocumentHeader."Customer Type" := RetailDocumentHeader."Customer Type"::Kontant
            else
                RetailDocumentHeader."Customer Type" := RetailDocumentHeader."Customer Type"::Alm;


            /* SALES HEADING ------------------------------------------------------------ */
            RetailDocumentHeader."Rent Register" := SalePOS."Register No.";
            RetailDocumentHeader."Rent Sales Ticket" := SalePOS."Sales Ticket No.";
            RetailDocumentHeader."Rent Salesperson" := SalePOS."Salesperson Code";
            RetailDocumentHeader."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
            RetailDocumentHeader."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
            RetailDocumentHeader."Salesperson Code" := SalePOS."Salesperson Code";
            RetailDocumentHeader.Via := RetailDocumentHeader.Via::POS;

            /* CUSTOMER INFO ------------------------------------------------------ */
            if SalePOS."Customer No." <> '' then
                RetailDocumentHeader.Validate("Customer No.", SalePOS."Customer No.")
            else
                RetailDocumentHeader."Prices Including VAT" := SalePOS."Price including VAT";

            RetailDocumentHeader."Salesperson Code" := SalePOS."Salesperson Code";
            RetailDocumentHeader.Date := Today;
            RetailDocumentHeader.Deposit := SalePOS.Deposit;
            RetailDocumentHeader."Time of Day" := Time;
            RetailDocumentHeader."Document Date" := Today;
            RetailDocumentHeader."Location Code" := SalePOS."Location Code";
            RetailDocumentHeader."Shipping Type" := RetailDocumentHeader."Shipping Type"::Normal;
            RetailDocumentHeader.Delivery := RetailDocumentHeader.Delivery::Shipped;
            RetailDocumentHeader.Modify;
        end;

        /* TRANSFER SALES LINES ------------------------------------------------------- */
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        nLines := SaleLinePOS.Count;
        if SaleLinePOS.Find('-') then begin
            repeat
                Clear(RetailDocumentLines);
                RetailDocumentLines.Init;
                RetailDocumentLines."Document Type" := RetailDocumentHeader."Document Type";
                RetailDocumentLines."Document No." := RetailDocumentHeader."No.";
                RetailDocumentLines.TransferFromSaleLinePOS(SaleLinePOS);
                RetailDocumentLines."Line No." := SaleLinePOS."Line No.";
                RetailDocumentLines."Serial No. not Created" := SaleLinePOS."Serial No. not Created";
                RetailDocumentLines.Insert;
            until SaleLinePOS.Next = 0;
        end else
            Error(Txt001);

        /* COMMENT LINES ------------------------------------------------------------ */
        //-NPR5.48 [336337]
        //SaleLinePOS.SETRANGE("Sale Type",SaleLinePOS."Sale Type"::Comment);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        //+NPR5.48 [336337]
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Comment);
        if SaleLinePOS.Find('-') then
            repeat
                RetailDocumentLines.Init;
                RetailDocumentLines."Document Type" := RetailDocumentHeader."Document Type";
                RetailDocumentLines."Document No." := RetailDocumentHeader."No.";
                RetailDocumentLines."Line No." := SaleLinePOS."Line No.";
                RetailDocumentLines.Insert;
                RetailDocumentLines."No." := SaleLinePOS."No.";
                RetailDocumentLines.Description := SaleLinePOS.Description;
                RetailDocumentLines."Sales Type" := SaleLinePOS."Sale Type";
                RetailDocumentLines.Type := RetailDocumentLines.Type::" ";
                RetailDocumentLines.Modify;
            until SaleLinePOS.Next() = 0;

        /* Register Comments */

        RetailComment.SetRange("Table ID", DATABASE::"Sale POS");
        RetailComment.SetRange("No.", SalePOS."Register No.");
        RetailComment.SetRange("No. 2", SalePOS."Sales Ticket No.");
        if RetailComment.Find('-') then
            repeat
                RetailComments2.Init;
                RetailComments2.Copy(RetailComment);
                RetailComments2."Table ID" := DATABASE::"Retail Document Header";
                RetailComments2."No." := RetailDocumentHeader."No.";
                RetailComments2.Option := RetailDocumentHeader."Document Type";
                if not RetailComments2.Insert then
                    RetailComments2.Modify;
            until RetailComment.Next = 0;

        /* ADD DELIVERY ITEM ---------------------------------------------------- */
        if SalePOS.Deposit <> 0 then
            RetailDocumentHeader.AddDeposit(SalePOS.Deposit);

        RetailDocumentHeader.Validate(Outstanding);
        RetailDocumentHeader.Modify;

        /* OPEN FOR EDITING -------------------------------------------------------- */
        Commit;

        /* ONLY EDIT THIS ONE */
        RetailDocumentHeader.SetRecFilter;

        /* CONTRACT */
        begin
            if PAGE.RunModal(PAGE::"Retail Document Header", RetailDocumentHeader) <> ACTION::LookupOK then begin
                RetailDocumentHeader.Get(RetailDocumentHeader."Document Type", RetailDocumentHeader."No.");
                RetailDocumentHeader.Delete(true);
                Commit;
                exit(false);
            end;
        end;

        if DeleteExisting then begin
            if SaleLinePOS.FindFirst then
                repeat
                    RetailDocumentHeader.Get(SaleLinePOS."Retail Document Type", SaleLinePOS."Retail Document No.");
                    RetailDocumentHeader.Delete;
                    SaleLinePOS.SetRange("Retail Document No.", SaleLinePOS."Retail Document No.");
                    SaleLinePOS.FindLast;
                    SaleLinePOS.SetRange("Retail Document No.");
                until SaleLinePOS.Next = 0;
        end;

        RetailDocumentHeader.PrintRetailDocument(false);

        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        /* DEPOSIT => PAY LATER ------------------------------------------------------ */

        if (RetailDocumentHeader.Deposit > 0) and
           (RetailDocumentHeader."Document Type" in [
              RetailDocumentHeader."Document Type"::"Selection Contract",
              RetailDocumentHeader."Document Type"::"Retail Order",
              RetailDocumentHeader."Document Type"::Customization]) then begin
            SaleLinePOS.DeleteAll(true);
        end;

        if SaleLinePOS.Find('+') then
            NextSalesLine := SaleLinePOS."Line No." + 10000
        else
            NextSalesLine := 10000;

        RetailDocumentLines.Reset;
        RetailDocumentLines.SetRange("Document Type", RetailDocumentHeader."Document Type");
        RetailDocumentLines.SetRange("Document No.", RetailDocumentHeader."No.");

        /* HANDLE DEPOSIT ------------------------------------------------------------- */

        if RetailDocumentHeader.Deposit > 0 then begin
            SaleLinePOS.Init;
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Type := SaleLinePOS.Type::Customer;
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
            SaleLinePOS."Line No." := NextSalesLine;
            SaleLinePOS.Validate("No.", RetailDocumentHeader."Customer No.");
            SaleLinePOS."Location Code" := SalePOS."Location Code";
            SaleLinePOS."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
            SaleLinePOS."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
            SaleLinePOS."Price Includes VAT" := true;   //always VAT?
            SaleLinePOS.Validate(Quantity, 1);
            SaleLinePOS.Validate("Unit Price", RetailDocumentHeader.Deposit);
            SaleLinePOS.Description := Txt003;
            //-NPR5.49 [351475]
            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            //+NPR5.49 [351475]
            SaleLinePOS.Insert(true);
            NextSalesLine += 10000;
        end;

        /* Return some variables to the current sale */

        SalePOS."Customer Type" := RetailDocumentHeader."Customer Type";
        SalePOS."Customer No." := RetailDocumentHeader."Customer No.";
        SalePOS.Deposit := RetailDocumentHeader.Deposit;
        SalePOS."Payment Terms Code" := RetailDocumentHeader."Payment Terms Code";

        SalePOS.Name := RetailDocumentHeader."Ship-to Name";
        SalePOS.Address := RetailDocumentHeader."Ship-to Address";
        SalePOS."Address 2" := RetailDocumentHeader."Ship-to Address 2";
        SalePOS."Post Code" := RetailDocumentHeader."Ship-to Post Code";
        SalePOS.City := RetailDocumentHeader."Ship-to City";
        SalePOS."Contact No." := RetailDocumentHeader."Ship-to Attention";
        SalePOS."Country Code" := RetailDocumentHeader."Country Code";

        exit(true);

    end;

    procedure RetailDocument2Sale(var SalePOS: Record "Sale POS"; var SalesCode: Code[20])
    var
        Customer: Record Customer;
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOS2: Record "Sale Line POS";
        RetailDocumentHeader: Record "Retail Document Header";
        RetailDocumentLines: Record "Retail Document Lines";
        RetailDocumentList: Page "Retail Document List";
        RetailSetup: Record "Retail Setup";
        LineNo: Integer;
    begin
        //RetailContract2Sale
        RetailSetup.Get();

        with SalePOS do begin
            RetailDocumentList.Editable(false);
            RetailDocumentList.LookupMode(true);
            RetailDocumentHeader.SetRange(Cashed, false);
            RetailDocumentHeader.SetRange("Document Type", SalePOS."Retail Document Type");
            RetailDocumentList.SetTableView(RetailDocumentHeader);
            // "Retail Document List".SetVisLinier;
            if not (RetailDocumentList.RunModal = ACTION::LookupOK) then
                exit;
            RetailDocumentList.GetRecord(RetailDocumentHeader);

            Validate("Customer Type", RetailDocumentHeader."Customer Type");
            Validate("Customer No.", RetailDocumentHeader."Customer No.");
            Validate("Retail Document No.", RetailDocumentHeader."No.");
            Modify;

            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange(Date, Date);
            if SaleLinePOS.Find('+') then
                LineNo := Round(SaleLinePOS."Line No.", 10000, '<') + 20000
            else
                LineNo := 20000;

            RetailDocumentLines.SetRange("Document Type", RetailDocumentHeader."Document Type");
            RetailDocumentLines.SetRange("Document No.", RetailDocumentHeader."No.");
            if RetailDocumentLines.Find('-') then
                repeat
                    SaleLinePOS.Init;
                    SaleLinePOS.Silent := true;
                    SaleLinePOS."Register No." := "Register No.";
                    SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
                    SaleLinePOS.Date := Date;
                    SaleLinePOS."Sale Type" := RetailDocumentLines."Sales Type";
                    SaleLinePOS."Line No." := LineNo;
                    //Ekspeditionslinier.ForceApris := TRUE;
                    //( TRUE );
                    SaleLinePOS."From Selection" := true;
                    //+MultiSelection
                    SaleLinePOS."Retail Document Type" := RetailDocumentLines."Document Type";
                    SaleLinePOS."Retail Document No." := RetailDocumentLines."Document No.";
                    //-MultiSelection
                    case RetailDocumentLines.Type of
                        RetailDocumentLines.Type::" ":
                            SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                        RetailDocumentLines.Type::"G/L Account":
                            SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
                        RetailDocumentLines.Type::Item:
                            SaleLinePOS.Type := SaleLinePOS.Type::Item;
                        else
                            ;
                    end;
                    SaleLinePOS."Location Code" := "Location Code";
                    SaleLinePOS."Variant Code" := RetailDocumentLines."Variant Code";
                    // Varesalg
                    if (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale) and
                       (SaleLinePOS.Type = SaleLinePOS.Type::Item) then begin
                        SaleLinePOS.Validate("No.", RetailDocumentLines."No.");
                        //-NPR5.49 [351475]
                        //        SaleLinePOS.VALIDATE(Quantity,RetailDocumentLines.Quantity);
                        //        SaleLinePOS.VALIDATE("Unit of Measure Code",RetailDocumentLines."Unit of measure");
                        //        SaleLinePOS.VALIDATE("Quantity (Base)",RetailDocumentLines."Std. quantity");
                        SaleLinePOS.Validate("Unit of Measure Code", RetailDocumentLines."Unit of measure");
                        SaleLinePOS.Validate(Quantity, RetailDocumentLines.Quantity);
                        //+NPR5.49 [351475]
                        if RetailDocumentLines."Serial No." <> '' then
                            SaleLinePOS.Validate("Serial No.", RetailDocumentLines."Serial No.");

                        //-NPR5.23 [240916]
                        //      //-NPR3.01t
                        //      IF (("Retail Document Lines".Size <> '') OR ("Retail Document Lines".Color <> '')) THEN BEGIN
                        //        Variation.RESET();
                        //        Variation.SETRANGE("Item Code", "Retail Document Lines"."No.");
                        //        Variation.SETRANGE(Color,"Retail Document Lines".Color);
                        //        Variation.SETRANGE(Size, "Retail Document Lines".Size );
                        //        IF (Variation.FIND('-')) THEN
                        //        BEGIN
                        //          Ekspeditionslinier.Size := Variation.Size;
                        //          Ekspeditionslinier.Color := Variation.Color ;
                        //        END;
                        //      END;
                        //+NPR5.23 [240916]

                        SaleLinePOS."Price Includes VAT" := RetailDocumentLines."Price including VAT";
                        SaleLinePOS.Validate("Unit Price", RetailDocumentLines."Unit price");
                        SaleLinePOS.Validate("Discount %", RetailDocumentLines."Line discount %");

                        SaleLinePOS.Description := RetailDocumentLines.Description;
                        SaleLinePOS."Variant Code" := RetailDocumentLines."Variant Code";
                    end;

                    // Bem�rkninger
                    //-NPR5.48
                    //IF //(SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Comment) AND
                    if (SaleLinePOS.Type = SaleLinePOS.Type::Comment) then begin
                        //+NPR5.48
                        SaleLinePOS.Validate("No.", RetailDocumentLines."No.");
                        SaleLinePOS.Description := RetailDocumentLines.Description;
                    end;

                    //-NPR4.002.004a
                    SaleLinePOS."Lock Code" := RetailDocumentLines."Lock Code";
                    //+NPR4.002.004a
                    SaleLinePOS."Serial No. not Created" := RetailDocumentLines."Serial No. not Created";
                    //-NPR5.48
                    //SaleLinePOS.MODIFY;
                    //+NPR5.48
                    SaleLinePOS.Silent := false;
                    //-NPR5.49 [351475]
                    SaleLinePOS.UpdateAmounts(SaleLinePOS);
                    //+NPR5.49 [351475]
                    SaleLinePOS.Insert;
                    LineNo := LineNo + 10000;
                until RetailDocumentLines.Next = 0;

            RetailDocumentHeader."Return Salesperson" := "Salesperson Code";
            RetailDocumentHeader."Return Register" := "Register No.";
            RetailDocumentHeader."Return Sales Ticket" := "Sales Ticket No.";
            RetailDocumentHeader."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            RetailDocumentHeader."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            RetailDocumentHeader."Return Date 2" := Today;
            RetailDocumentHeader."Return Time 2" := "Start Time";
            RetailDocumentHeader.Modify;

            SaleLinePOS2.SetRange("Register No.", "Register No.");
            SaleLinePOS2.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS2.SetRange(Date, Date);
            SaleLinePOS2.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);

            if RetailDocumentHeader.Deposit <> 0 then begin
                SaleLinePOS.Init;
                SaleLinePOS."Register No." := "Register No.";
                SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
                SaleLinePOS.Date := Date;
                SaleLinePOS.Type := SaleLinePOS.Type::Customer;
                SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
                if RetailDocumentHeader."Customer Type" = RetailDocumentHeader."Customer Type"::Alm then
                    SaleLinePOS.Validate("No.", RetailDocumentHeader."Customer No.")
                else begin
                    RetailSetup.TestField("Cash Customer Deposit rel.");
                    SaleLinePOS.Validate("No.", RetailSetup."Cash Customer Deposit rel.");
                end;

                SaleLinePOS."Location Code" := "Location Code";
                if SaleLinePOS2.Find('+') then
                    SaleLinePOS."Line No." := SaleLinePOS2."Line No." + 10000
                else
                    SaleLinePOS."Line No." := 10000;
                SaleLinePOS.Quantity := 1;
                SaleLinePOS."Unit Price" := -RetailDocumentHeader.Deposit;
                SaleLinePOS.Amount := -RetailDocumentHeader.Deposit;
                SaleLinePOS."Amount Including VAT" := -RetailDocumentHeader.Deposit;
                if Customer.Get(RetailDocumentHeader."Customer No.") then
                    SaleLinePOS.Internal := Customer."Internal y/n";
                if (SalePOS."Retail Document Type" in [SalePOS."Retail Document Type"::Customization]) then
                    SaleLinePOS."From Selection" := true;
                //-NPR5.49 [351475]
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                //+NPR5.49 [351475]
                SaleLinePOS.Insert;
            end;

            SalePOS.Name := RetailDocumentHeader."Ship-to Name";
            SalePOS.Address := RetailDocumentHeader."Ship-to Address";
            SalePOS."Address 2" := RetailDocumentHeader."Ship-to Address 2";
            SalePOS."Post Code" := RetailDocumentHeader."Ship-to Post Code";
            SalePOS.City := RetailDocumentHeader."Ship-to City";
            SalePOS."Country Code" := RetailDocumentHeader."Ship-to Country Code";
        end;
    end;

    procedure CashRetailDocument(RetailDocumentType: Integer; RetailDocumentNo: Code[20])
    var
        RetailDocumentHeader: Record "Retail Document Header";
    begin
        if RetailDocumentHeader.Get(RetailDocumentType, RetailDocumentNo) then begin
            RetailDocumentHeader.Validate(Cashed, true);
            RetailDocumentHeader.Modify(true);
        end;
    end;

    procedure UnfoldBOM(RetailDocumentLines: Record "Retail Document Lines"; ItemNo: Code[20])
    var
        LineNo: Integer;
        BOMComponent: Record "BOM Component";
    begin
        RetailDocLinesRec.Reset;
        RetailDocLinesRec.SetRange("Document Type", RetailDocumentLines."Document Type");
        RetailDocLinesRec.SetRange("Document No.", RetailDocumentLines."Document No.");
        if RetailDocLinesRec.Find('+') then
            LineNo := RetailDocLinesRec."Line No.";

        if ItemNo = '' then begin
            BOMComponent.SetRange("Parent Item No.", RetailDocumentLines."No.");
            LineNo := LineNo + 20000;
        end else begin
            BOMComponent.SetRange("Parent Item No.", ItemNo);
            LineNo := LineNo + 1000;
        end;

        if BOMComponent.Find('-') then
            repeat
                BOMComponent.CalcFields("Assembly BOM");
                if BOMComponent."Assembly BOM" then begin
                    UnfoldBOM(RetailDocumentLines, BOMComponent."No.");
                end else begin
                    RetailDocLinesRec.Init;
                    RetailDocLinesRec."Document Type" := RetailDocumentLines."Document Type";
                    RetailDocLinesRec."Document No." := RetailDocumentLines."Document No.";
                    RetailDocLinesRec.Type := RetailDocLinesRec.Type::Item;
                    RetailDocLinesRec."Line No." := LineNo;
                    RetailDocLinesRec."Belongs to Item" := BOMComponent."Parent Item No.";
                    RetailDocLinesRec.Validate("No.", BOMComponent."No.");
                    RetailDocLinesRec.Validate(Quantity, BOMComponent."Quantity per" * RetailDocumentLines.Quantity);
                    RetailDocLinesRec.Insert(true);
                    LineNo := LineNo + 100;
                end;
            until BOMComponent.Next = 0;
    end;

    procedure UnfoldAccessories(RetailDocumentLines: Record "Retail Document Lines")
    var
        InputDialog: Page "Input Dialog";
        Force: Boolean;
        Quantity2: Decimal;
        LineNo: Integer;
        AccessorySparePart: Record "Accessory/Spare Part";
        TxtQuantity: Label 'Quantity of Item %1';
    begin
        RetailDocLinesRec.Reset;
        RetailDocLinesRec.SetRange("Document Type", RetailDocumentLines."Document Type");
        RetailDocLinesRec.SetRange("Document No.", RetailDocumentLines."Document No.");
        if RetailDocLinesRec.Find('+') then
            LineNo := RetailDocLinesRec."Line No.";

        LineNo := LineNo + 20000;

        AccessorySparePart.SetRange(Type, AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetRange(Code, RetailDocumentLines."No.");
        if AccessorySparePart.Find('-') then
            repeat
                if AccessorySparePart."Add Extra Line Automatically" or Force then begin
                    RetailDocLinesRec.Init;
                    RetailDocLinesRec."Document Type" := RetailDocumentLines."Document Type";
                    RetailDocLinesRec."Document No." := RetailDocumentLines."Document No.";
                    RetailDocLinesRec.Type := RetailDocLinesRec.Type::Item;
                    RetailDocLinesRec."Line No." := LineNo;
                    RetailDocLinesRec.Accessory := true;
                    RetailDocLinesRec."Belongs to Item" := RetailDocumentLines."No.";
                    RetailDocLinesRec.Validate("No.", AccessorySparePart."Item No.");
                    RetailDocLinesRec.Insert(true);

                    if AccessorySparePart."Quantity in Dialogue" then begin
                        InputDialog.SetInput(1, Quantity2, StrSubstNo(TxtQuantity, AccessorySparePart."Item No."));
                        if InputDialog.RunModal = ACTION::OK then
                            InputDialog.InputDecimal(1, Quantity2)
                        else
                            Quantity2 := AccessorySparePart.Quantity;

                        RetailDocLinesRec.Validate(Quantity, Quantity2);
                    end else begin
                        if AccessorySparePart."Per unit" then
                            RetailDocLinesRec.Validate(Quantity, AccessorySparePart.Quantity * RetailDocumentLines.Quantity)
                        else
                            RetailDocLinesRec.Validate(Quantity, AccessorySparePart.Quantity);
                    end;

                    if AccessorySparePart."Use Alt. Price" then begin
                        if AccessorySparePart."Show Discount" then begin
                            RetailDocLinesRec.Validate("Amount Including VAT", AccessorySparePart."Alt. Price");
                        end else begin
                            if RetailDocLinesRec."Price including VAT" then
                                RetailDocLinesRec.Validate("Unit price", AccessorySparePart."Alt. Price")
                            else
                                RetailDocLinesRec.Validate("Unit price", RetailDocLinesRec."Unit price" / (1 + RetailDocLinesRec."Vat %" / 100));
                        end;
                    end;

                    RetailDocLinesRec.Modify(true);
                    LineNo := LineNo + 100;
                end;
            until AccessorySparePart.Next = 0;
    end;

    procedure UnfoldItemsUpdate(RetailDocumentLines: Record "Retail Document Lines")
    var
        BOMComponent: Record "BOM Component";
        AccessorySparePart: Record "Accessory/Spare Part";
    begin
        RetailDocLinesRec.Reset;
        RetailDocLinesRec.SetRange("Document Type", RetailDocumentLines."Document Type");
        RetailDocLinesRec.SetRange("Document No.", RetailDocumentLines."Document No.");
        RetailDocLinesRec.SetRange("Belongs to Item", RetailDocumentLines."No.");
        if RetailDocLinesRec.Find('-') then
            repeat
                if RetailDocLinesRec.Accessory then begin
                    AccessorySparePart.SetRange(Type, AccessorySparePart.Type::Accessory);
                    AccessorySparePart.SetRange(Code, RetailDocumentLines."No.");
                    AccessorySparePart.SetRange("Item No.", RetailDocLinesRec."No.");
                    if AccessorySparePart.Find('-') then begin
                        if AccessorySparePart."Per unit" then
                            RetailDocLinesRec.Validate(Quantity, AccessorySparePart.Quantity * RetailDocumentLines.Quantity);

                        if AccessorySparePart."Use Alt. Price" then begin
                            if AccessorySparePart."Show Discount" then begin
                                RetailDocLinesRec.Validate("Amount Including VAT", AccessorySparePart."Alt. Price");
                            end else begin
                                if RetailDocLinesRec."Price including VAT" then
                                    RetailDocLinesRec.Validate("Unit price", AccessorySparePart."Alt. Price")
                                else
                                    RetailDocLinesRec.Validate("Unit price", RetailDocLinesRec."Unit price" / (1 + RetailDocLinesRec."Vat %" / 100));
                            end;
                        end;
                    end;
                end else begin   // is a BOM
                    BOMComponent.SetRange("Parent Item No.", RetailDocumentLines."No.");
                    BOMComponent.SetRange("No.", RetailDocLinesRec."No.");
                    if BOMComponent.Find('-') then
                        RetailDocLinesRec.Validate(Quantity, BOMComponent."Quantity per" * RetailDocumentLines.Quantity);
                end;
                RetailDocLinesRec.Modify(true);
            until RetailDocLinesRec.Next = 0;
    end;

    procedure UnfoldItemsDelete(RetailDocumentLines: Record "Retail Document Lines")
    begin
        RetailDocLinesRec.Reset;
        RetailDocLinesRec.SetRange("Document Type", RetailDocumentLines."Document Type");
        RetailDocLinesRec.SetRange("Document No.", RetailDocumentLines."Document No.");
        RetailDocLinesRec.SetRange("Belongs to Item", RetailDocumentLines."No.");
        if RetailDocLinesRec.Find('-') then
            repeat
                RetailDocLinesRec.Delete(true);
            until RetailDocLinesRec.Next = 0;
    end;
}

