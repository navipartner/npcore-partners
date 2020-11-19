codeunit 6014568 "NPR Rental Contract S.Ticket"
{
    TableNo = "NPR Retail Document Header";

    trigger OnRun()
    begin
        RPLinePrintMgt.SetAutoLineBreak(true);
        RetailDocumentHeader.CopyFilters(Rec);
        GetRecords;
        RPLinePrintMgt.SetFourColumnDistribution(0.25, 0.35, 0.2, 0.2);

        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.SetBold(false);

        for CurrPageNo := 1 to 1 do begin
            PrintRetailDocumentHeader;
            PrintSalesTicketText;

        end;

        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetFont('Control');
        RPLinePrintMgt.AddLine('P');
    end;

    var
        RPLinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        CurrPageNo: Integer;
        RetailDocumentHeader: Record "NPR Retail Document Header";
        RetailDocumentLines: Record "NPR Retail Document Lines";
        SalesTicketTextCounter: Record "Integer";
        CompanyInformation: Record "Company Information";
        TotaltAmount: Decimal;
        AfleveringTXT: Text[50];
        Salesperson: Record "Salesperson/Purchaser";
        SalespersonTxt: Text[50];
        RetailSetup: Record "NPR Retail Setup";
        Register: Record "NPR Register";
        BonInfo: Text[30];
        BonInfo2: Text[30];
        Utility: Codeunit "NPR Utility";
        RetailComment: Record "NPR Retail Comment" temporary;
        RetailComment2: Record "NPR Retail Comment";
        CommitteeBillTxt: Label 'Committee Bill';
        CommitteeNumberTxt: Label 'Committee Number';
        ServedbyTxt: Label 'Served by';
        CustomerTelTxt: Label 'Customer no. / Tel';
        PostCodeCityTxt: Label 'Post Code/City';
        DeliveryInfoTxt: Label 'Delivery Info';
        TotalAmountTxt: Label 'Total Amount:';
        DateTxt: Label 'Date';
        TimeTxt: Label 'Time';
        IssuedTxt: Label 'Issued';
        ReturnedTxt: Label 'Returned';
        FooterNote1_1Txt: Label 'I acknowledge to owe the ';
        FooterNote1_2Txt: Label 'amounts due to be paid no later than ';
        FooterNote1_3Txt: Label 'about 4 days from dd In the opposite case,';
        FooterNote1_4Txt: Label 'this document is used for ';
        FooterNote1_5Txt: Label 'enforcement, cf Agreements.';
        FooterNote2Txt: Label 'For reception of the above is confirmed:';
        SignatureTxt: Label 'Signature';

    procedure PrintRetailDocumentHeader()
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        RetailDocHeaderOnPreDataItem;

        RPLinePrintMgt.SetFont('Control');
        RPLinePrintMgt.AddLine('A');
        if RetailSetup.Get() then;
        if RetailSetup."Logo on Sales Ticket" then begin
            RPLinePrintMgt.AddLine('G');
        end;

        // Retail Document Header, Header (3) - OnPreSection()
        if RetailSetup."Name on Sales Ticket" then begin
            RPLinePrintMgt.SetFont('A11');
            if POSSession.IsActiveSession(POSFrontEnd) then begin
                POSFrontEnd.GetSession(POSSession);
                POSSession.GetSetup(POSSetup);
                POSSetup.GetPOSStore(POSStore);
            end else begin
                if POSUnit.get(Register."Register No.") then
                    POSStore.get(POSUnit."POS Store Code");
            end;
            RPLinePrintMgt.AddTextField(1, 0, POSStore.Name);
            RPLinePrintMgt.AddTextField(1, 0, POSStore.Address);
            RPLinePrintMgt.AddTextField(1, 0, POSStore."Post Code" + ' ' + POSStore.City);
            RPLinePrintMgt.AddTextField(1, 0, 'Telefon: ' + Format(POSStore."Phone No."));
            RPLinePrintMgt.AddTextField(1, 0, 'Fax: ' + Format(POSStore."Fax No."));
            RPLinePrintMgt.AddTextField(1, 0, 'CVR: ' + Format(Register."VAT No."));
        end;

        // Retail Document Header, Header (4) - OnPreSection()
        if Salesperson.Get(RetailDocumentHeader."Salesperson Code") then
            SalespersonTxt := Salesperson.Name
        else
            SalespersonTxt := '';

        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(true);
        RPLinePrintMgt.AddTextField(1, 0, CommitteeBillTxt);
        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.SetBold(false);
        RPLinePrintMgt.AddTextField(1, 0, Format(Today, 0, 4));
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.AddTextField(1, 0, CommitteeNumberTxt);
        RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."No.");
        RPLinePrintMgt.AddTextField(1, 0, ServedbyTxt);
        RPLinePrintMgt.AddTextField(2, 0, SalespersonTxt);
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');
        RPLinePrintMgt.AddLine('');

        // Retail Document Header, Header (5) - OnPreSection()
        if Salesperson.Get(RetailDocumentHeader."Salesperson Code") then
            SalespersonTxt := Salesperson.Name
        else
            SalespersonTxt := '';

        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.SetBold(false);
        RPLinePrintMgt.AddTextField(1, 0, CustomerTelTxt);
        RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."Customer No.");
        RPLinePrintMgt.AddTextField(1, 0, RetailDocumentHeader.FieldCaption(Name));
        RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader.Name);

        // Retail Document Header, Header (6) - OnPreSection()
        if RetailDocumentHeader."First Name" <> '' then begin
            RPLinePrintMgt.AddTextField(1, 0, '');
            RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."First Name");
        end;

        // Retail Document Header, Header (7)
        RPLinePrintMgt.AddTextField(1, 0, RetailDocumentHeader.FieldCaption(Address));
        RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader.Address);

        // Retail Document Header, Header (8) - OnPreSection()
        if RetailDocumentHeader."Address 2" <> '' then begin
            RPLinePrintMgt.AddTextField(1, 0, '');
            RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."Address 2");
        end;

        // Retail Document Header, Header (9) - OnPreSection()
        if RetailDocumentHeader."Ship-to Post Code" <> '' then begin
            RPLinePrintMgt.AddTextField(1, 0, PostCodeCityTxt);
            RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."Post Code" + ' ' + RetailDocumentHeader.City);
        end;

        // Retail Document Header, Header (10) - OnPreSection()
        if RetailDocumentHeader."Ship-to Name" <> '' then begin
            RPLinePrintMgt.AddLine('');
            RPLinePrintMgt.SetBold(true);
            RPLinePrintMgt.AddTextField(1, 0, DeliveryInfoTxt);
            RPLinePrintMgt.SetBold(false);
            RPLinePrintMgt.AddTextField(1, 0, RetailDocumentHeader.FieldCaption("Ship-to Name"));
            RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."Ship-to Name");
        end;

        // Retail Document Header, Header (11) - OnPreSection()
        if RetailDocumentHeader."Ship-to Address" <> '' then begin
            RPLinePrintMgt.AddTextField(1, 0, RetailDocumentHeader.FieldCaption("Ship-to Address"));
            RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."Ship-to Address");
        end;

        // Retail Document Header, Header (12) - OnPreSection()
        if RetailDocumentHeader."Ship-to Address 2" <> '' then begin
            RPLinePrintMgt.AddTextField(1, 0, '');
            RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."Ship-to Address 2");
        end;

        // Retail Document Header, Header (13) - OnPreSection()
        if RetailDocumentHeader."Ship-to Post Code" <> '' then begin
            RPLinePrintMgt.AddTextField(1, 0, PostCodeCityTxt);
            RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."Ship-to Post Code" + ' ' + RetailDocumentHeader."Ship-to City");
        end;

        // Retail Document Header, Header (14)
        RPLinePrintMgt.AddTextField(1, 0, RetailDocumentHeader.FieldCaption("Ship-to Attention"));
        RPLinePrintMgt.AddTextField(2, 0, RetailDocumentHeader."Ship-to Attention");
        RPLinePrintMgt.AddLine('');

        // 1. Retail Document Lines
        PrintRetailDocumentLines;

        // Retail Document Header, Footer (15)
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');

        // Retail Document Header, Footer (16) - OnPreSection()
        if (RetailDocumentHeader."Return Date" <> 0D) and
           (RetailDocumentHeader."Rent Date" <> 0D) then begin

            RPLinePrintMgt.AddLine('');
            RPLinePrintMgt.AddTextField(1, 0, '');
            RPLinePrintMgt.AddTextField(2, 0, DateTxt);
            RPLinePrintMgt.AddTextField(3, 0, TimeTxt);

            RPLinePrintMgt.AddTextField(1, 0, IssuedTxt);
            RPLinePrintMgt.AddDateField(2, 0, RetailDocumentHeader."Rent Date");
            RPLinePrintMgt.AddTextField(3, 0, Format(RetailDocumentHeader."Rent Time"));

            RPLinePrintMgt.AddTextField(1, 0, ReturnedTxt);
            RPLinePrintMgt.AddDateField(2, 0, RetailDocumentHeader."Return Date");
            RPLinePrintMgt.AddTextField(3, 0, Format(RetailDocumentHeader."Return Time"));

            RPLinePrintMgt.SetPadChar('_');
            RPLinePrintMgt.AddTextField(1, 0, '');
            RPLinePrintMgt.AddTextField(2, 0, '');
            RPLinePrintMgt.AddTextField(3, 0, '');
            RPLinePrintMgt.SetPadChar(' ');
        end;

        // Retail Document Header, Footer (17)
        RetailDocumentHeader.CalcFields(Amount);
        RPLinePrintMgt.AddTextField(1, 0, '');
        RPLinePrintMgt.AddTextField(2, 0, TotalAmountTxt);
        RPLinePrintMgt.AddTextField(3, 0, '');
        RPLinePrintMgt.AddDecimalField(4, 0, RetailDocumentHeader.Amount);

        // Retail Document Header, Footer (18) - OnPreSection()
        if RetailSetup."Bar Code on Sales Ticket Print" then begin
            RPLinePrintMgt.SetFont('Control');
            RPLinePrintMgt.AddLine('t');
            RPLinePrintMgt.AddBarcode('Barcode3', RetailDocumentHeader."No.", 4);
        end;


        // Retail Document Header, Footer (19) - OnPreSection()
        AfleveringTXT := 'senest den ' + Format(Today);

        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(false);
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');

        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.AddLine(FooterNote1_1Txt);
        RPLinePrintMgt.AddLine(FooterNote1_2Txt);
        RPLinePrintMgt.AddLine(FooterNote1_3Txt);
        RPLinePrintMgt.AddLine(FooterNote1_4Txt);
        RPLinePrintMgt.AddLine(FooterNote1_5Txt);
        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.AddLine(FooterNote2Txt);
        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.AddDateField(1, 0, Today);

        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(false);
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');

        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.AddTextField(1, 0, DateTxt);
        RPLinePrintMgt.AddTextField(2, 0, SignatureTxt);
        RPLinePrintMgt.AddLine('');
    end;

    procedure PrintRetailDocumentLines()
    begin
        // Retail Document Lines - OnPreDataItem()
        RetailDocumentLines.SetRange("Document No.", RetailDocumentHeader."No.");
        RetailDocumentLines.SetRange("Document Type", RetailDocumentHeader."Document Type");

        RPLinePrintMgt.AddLine('');
        if RetailDocumentLines.FindSet then begin
            //Retail Document Lines, Header (1)
            RPLinePrintMgt.SetFont('A11');
            RPLinePrintMgt.SetBold(true);
            RPLinePrintMgt.AddTextField(1, 0, RetailDocumentLines.FieldCaption("No."));
            RPLinePrintMgt.AddTextField(2, 0, RetailDocumentLines.FieldCaption(Description));
            RPLinePrintMgt.AddTextField(3, 0, RetailDocumentLines.FieldCaption(Quantity));
            RPLinePrintMgt.AddTextField(4, 0, RetailDocumentLines.FieldCaption(Amount));
            RPLinePrintMgt.SetBold(false);
            RPLinePrintMgt.SetPadChar('_');
            RPLinePrintMgt.AddLine('');
            RPLinePrintMgt.SetPadChar(' ');
            RPLinePrintMgt.AddLine('');
            repeat
                // Retail Document Lines, Body (2) - OnPreSection()
                if RetailDocumentLines.Quantity <> 0 then begin
                    TotaltAmount := TotaltAmount + RetailDocumentLines.Amount;
                    RPLinePrintMgt.AddTextField(1, 0, RetailDocumentLines."No.");
                    RPLinePrintMgt.AddTextField(2, 0, RetailDocumentLines.Description);
                    RPLinePrintMgt.AddTextField(3, 0, ' ' + Format(RetailDocumentLines.Quantity, 0, '<Integer>'));
                    RPLinePrintMgt.AddDecimalField(4, 0, RetailDocumentLines.Quantity * RetailDocumentLines."Unit price");
                end;

                //Retail Document Lines, Body (3) - OnPreSection()
                if RetailDocumentLines.Quantity = 0 then begin
                    RPLinePrintMgt.AddTextField(1, 0, RetailDocumentLines."No.");
                    RPLinePrintMgt.AddTextField(2, 0, RetailDocumentLines.Description);
                    RPLinePrintMgt.AddTextField(3, 0, ' ');
                    RPLinePrintMgt.AddTextField(4, 0, '');
                end;

                // Retail Document Lines, Body (4) - OnPreSection()
                if RetailDocumentLines."Line discount amount" <> 0 then begin
                    RPLinePrintMgt.AddTextField(1, 0, '');
                    RPLinePrintMgt.AddTextField(2, 0, ' Rabat:');
                    RPLinePrintMgt.AddTextField(3, 0, '');
                    RPLinePrintMgt.AddDecimalField(4, 0, RetailDocumentLines."Line discount amount");
                end;
            until RetailDocumentLines.Next = 0;
        end;
    end;

    procedure PrintSalesTicketText()
    begin
        // Bontekst - Properties
        SalesTicketTextCounter.SetCurrentKey(Number);
        SalesTicketTextCounter.Ascending(true);
        SalesTicketTextCounter.SetFilter(Number, '1..');

        // Bontekst - OnPreDataItem()
        Utility.GetTicketText(RetailComment, Register);
        RetailComment.SetFilter(Comment, '<>""');
        if RetailComment.Find('-') then;

        RetailComment2.SetRange("No.", RetailDocumentHeader."No.");
        if RetailComment2.Find('-') then begin
        end;

        if SalesTicketTextCounter.FindSet then begin
            repeat
                // Bontekst - OnAfterGetRecord()
                if SalesTicketTextCounter.Number > 1 then
                    //BonLinjer.NEXT;
                    RetailComment2.Next;
                // Bontekst, Body (1)
                RPLinePrintMgt.SetFont('A11');
                RPLinePrintMgt.AddTextField(1, 1, RetailComment2.Comment);
            until (SalesTicketTextCounter.Next = 0) or (SalesTicketTextCounter.Number > RetailComment2.Count);
            // Bontekst, Footer (2)
            RPLinePrintMgt.SetFont('A11');
            RPLinePrintMgt.AddLine(BonInfo);
            RPLinePrintMgt.AddLine(BonInfo2);
        end;
    end;

    procedure RetailDocHeaderOnPreDataItem()
    var
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        // Retail Document Header - OnPreDataItem()
        Register.Get(RetailFormCode.FetchRegisterNumber);
    end;

    procedure GetRecords()
    begin
        RetailDocumentHeader.FindSet;
        // Report - OnInitReport()
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);
        TotaltAmount := 0;
        // Report - OnPreReport()
    end;
}

