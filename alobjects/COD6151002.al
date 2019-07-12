codeunit 6151002 "POS Proxy - Display"
{
    // NPR5.36/CLVA/20170701 CASE 282851 Changed change calculation
    // NPR5.38/CLVA/20180104 CASE 300172 Closing receipt on endsale
    // NPR5.42/CLVA/20180522 CASE 315824 Updated Bixolon functionality, Added function CalculateTotals, Added CU6150704OnBeforeChangeToPaymentView
    // NPR5.42/CLVA/20180522 CASE 305714 Changed functionality from event subscriber CU6150706OnBeforeSetQuantity to CU6150706OnAfterSetQuantity
    //                                   Changed functionality from event subscriber CU6150706OnBeforeDeletePOSSaleLine to CU6150706OnAfterDeletePOSSaleLine
    // NPR5.43/CLVA/20180606  CASE 300254 Splitting Matrix and 2nd Display activation
    // NPR5.43/MHA /20180619  CASE 319425 Added OnAfterInsertSaleLine POS Sales Workflow
    // NPR5.44/CLVA/20180417  CASE 311568 Changed text constant NEWLINE to hardcoded value.
    // NPR5.44/MMV /20180423  CASE 311309 Made function Update2ndDisplayFromSalePOS global
    // NPR5.44/MHA /20180724  CASE 300254 Deleted Subscriber function CU6150792OnAfterInsertPOSSaleLine()
    // NPR5.44/CLVA/20180606  CASE 318695 Added VAT functionality
    // NPR5.45/CLVA/20180727  CASE 323345 Added error if Bixolon setup is missing
    // NPR5.45/CLVA/20180727  CASE 318695 Added CU6150725OnBeforeActionWorkflow
    // NPR5.50/CLVA/20190513  CASE 352390 Added support for custom display content. Changed CloseReceipt, Closed, EndSale and Payments to local = No


    trigger OnRun()
    begin
    end;

    var
        DisplayHandlerAction: Option OpenDisplay,CloseDisplay,UpdateDisplay,ShowReceipt,UpdateReceipt,CloseReceipt,DownloadFiles,DownloadHtmlFile;
        ReceiptCloseDuration: Integer;
        ReceiptContent: Text;
        DisplaySetup: Record "Display Setup";
        DisplayContent: Record "Display Content";
        MediaDictionary: DotNet npNetDictionary_Of_T_U;
        Base64Dictionary: DotNet npNetDictionary_Of_T_U;
        ContentType: Option Image,Video,Html;
        SecondaryMonitorRequest: DotNet npNetSecondaryMonitorRequest;
        CaptionCancelledSale: Label 'Cancelled sale';
        CaptionPaymentTotal: Label 'Total';
        CaptionChangeTotal: Label 'Total Change';
        CaptionRegisterClosed: Label 'Register closed';
        CaptionTotal: Label 'Grand Total';
        CaptionDeletedSaleline: Label 'Deleted item';
        MatrixIsActivated: Boolean;
        DisplayIsActivated: Boolean;
        Text000: Label 'Update Cash Register Display on Sale Line Insert';
        CaptionTAXTotal: Label 'Tax';
        CaptionSubTotal: Label 'Sub-Total';
        BixolonError: Label 'Display Setup is missing\\Object Output Selection is missing for DisplayBixolon\and will result in the following error\\The value "" can''t be evaluated into type Integer ';
        CaptionBalanceTotal: Label 'Balance';

    local procedure ProtocolName(): Text
    begin
        exit('CUSTOMER_DISPLAY');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAfterInitializeAtLogin', '', true, true)]
    local procedure CU6150705OnAfterInitializeAtLogin(Register: Record Register)
    var
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        SaleHeader: Record "Sale POS";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        //-NPR5.43 [300254]
        //IF NOT Register."Customer Display" THEN
        //  EXIT;
        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        //+NPR5.43 [300254]

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        //-NPR5.43 [300254]
        //IF DisplaySetup.GET(Register."Register No.") THEN
        if DisplayIsActivated then
            //+NPR5.43 [300254]
            Login(FrontEnd, Register."Register No.")
        //-NPR5.42 [315824]
        //-NPR5.43 [300254]
        //ELSE
        else
            if MatrixIsActivated then
                //+NPR5.43 [300254]
                UpdateDisplayFromSalePOS(SaleHeader, Register, Action::Login, '', '');
        //+NPR5.42 [315824]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAfterInitSale', '', true, true)]
    local procedure CU6150705OnAfterInitSale(SaleHeader: Record "Sale POS"; FrontEnd: Codeunit "POS Front End Management")
    var
        Register: Record Register;
        TextValue: Text;
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        if not Register.Get(SaleHeader."Register No.") then
            exit;

        //-NPR5.43 [300254]
        //IF NOT Register."Customer Display" THEN
        //  EXIT;
        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        //+NPR5.43 [300254]

        //-NPR5.43 [300254]
        //IF DisplaySetup.GET(Register."Register No.") THEN
        if DisplayIsActivated then
            //+NPR5.43 [300254]
            Update2ndDisplayFromSalePOS(FrontEnd, SaleHeader, Register, Action::Clear, TextValue, 0)
        //-NPR5.42 [315824]
        //-NPR5.43 [300254]
        //ELSE
        else
            if MatrixIsActivated then
                //+NPR5.43 [300254]
                UpdateDisplayFromSalePOS(SaleHeader, Register, Action::Login, TextValue, '');
        //+NPR5.42 [315824]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterInsertSaleLine', '', true, true)]
    local procedure UpdateDisplayOnSaleLineInsert(POSSalesWorkflowStep: Record "POS Sales Workflow Step"; SaleLinePOS: Record "Sale Line POS")
    var
        Register: Record Register;
        TextValue: Text;
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        //-NPR5.43 [319425]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'UpdateDisplayOnSaleLineInsert' then
            exit;
        //+NPR5.43 [319425]
        if not Register.Get(SaleLinePOS."Register No.") then
            exit;

        //-NPR5.43 [300254]
        //IF NOT Register."Customer Display" THEN
        //  EXIT;
        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        //+NPR5.43 [300254]

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        //-NPR5.43 [300254]
        //IF DisplaySetup.GET(Register."Register No.") THEN
        if DisplayIsActivated then
            //+NPR5.43 [300254]
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::Payment, 0)
        //-NPR5.42 [315824]
        //-NPR5.43 [300254]
        //ELSE
        else
            if MatrixIsActivated then
                //+NPR5.43 [300254]
                UpdateDisplayFromSaleLinePOS(SaleLinePOS);
        //+NPR5.42 [315824]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterDeletePOSSaleLine', '', true, true)]
    local procedure CU6150706OnAfterDeletePOSSaleLine(var Sender: Codeunit "POS Sale Line"; SaleLinePOS: Record "Sale Line POS")
    var
        Register: Record Register;
        TextValue: Text;
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
        SaleHeader: Record "Sale POS";
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
    begin
        //-NPR5.42 [305714]
        if not Register.Get(SaleLinePOS."Register No.") then
            exit;

        //-NPR5.43 [300254]
        //IF NOT Register."Customer Display" THEN
        //  EXIT;
        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        //+NPR5.43 [300254]

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        //-NPR5.43 [300254]
        //IF DisplaySetup.GET(Register."Register No.") THEN BEGIN
        if DisplayIsActivated then
            //+NPR5.43 [300254]
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::DeleteLine, 0)
        //-NPR5.42 [315824]
        //-NPR5.43 [300254]
        //END ELSE BEGIN
        else
            if MatrixIsActivated then begin
                //+NPR5.43 [300254]
                CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
                if SaleLinePOS.Type = SaleLinePOS.Type::Payment then
                    UpdateDisplayFromSalePOS(SaleHeader, Register, Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'))
                else
                    UpdateDisplayFromSalePOS(SaleHeader, Register, Action::DeleteLine, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), '');
            end;
        //+NPR5.42 [305714]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterSetQuantity', '', true, true)]
    local procedure CU6150706OnAfterSetQuantity(var Sender: Codeunit "POS Sale Line"; var SaleLinePOS: Record "Sale Line POS")
    var
        Register: Record Register;
        TextValue: Text;
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        if not Register.Get(SaleLinePOS."Register No.") then
            exit;

        //-NPR5.43 [300254]
        //IF NOT Register."Customer Display" THEN
        //  EXIT;
        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        //+NPR5.43 [300254]

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        //-NPR5.43 [300254]
        //IF DisplaySetup.GET(Register."Register No.") THEN
        if DisplayIsActivated then
            //+NPR5.43 [300254]
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::NewQuantity, SaleLinePOS.Quantity)
        //-NPR5.42 [315824]
        //-NPR5.43 [300254]
        //ELSE
        else
            if MatrixIsActivated then
                //+NPR5.43 [300254]
                UpdateDisplayFromSaleLinePOS(SaleLinePOS);
        //+NPR5.42 [315824]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150707, 'OnAfterDeleteLine', '', true, true)]
    local procedure CU6150707OnAfterDeleteLine(SaleLinePOS: Record "Sale Line POS")
    var
        Register: Record Register;
        TextValue: Text;
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
        SaleHeader: Record "Sale POS";
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
    begin
        if not Register.Get(SaleLinePOS."Register No.") then
            exit;

        //-NPR5.43 [300254]
        //IF NOT Register."Customer Display" THEN
        //  EXIT;
        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        //+NPR5.43 [300254]

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        //-NPR5.43 [300254]
        //IF DisplaySetup.GET(Register."Register No.") THEN BEGIN
        if DisplayIsActivated then
            //+NPR5.43 [300254]
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::Payment, 0)
        //-NPR5.42 [315824]
        //-NPR5.43 [300254]
        //END ELSE BEGIN
        else
            if MatrixIsActivated then begin
                //+NPR5.43 [300254]
                CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
                if SaleLinePOS.Type = SaleLinePOS.Type::Payment then
                    UpdateDisplayFromSalePOS(SaleHeader, Register, Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'))
                else
                    UpdateDisplayFromSalePOS(SaleHeader, Register, Action::DeleteLine, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), '');
            end;
        //+NPR5.42 [305714]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150707, 'OnAfterInsertPaymentLine', '', true, true)]
    local procedure CU6150707OnAfterInsertPaymentLine(SaleLinePOS: Record "Sale Line POS")
    var
        Register: Record Register;
        TextValue: Text;
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleHeader: Record "Sale POS";
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
    begin
        if not Register.Get(SaleLinePOS."Register No.") then
            exit;

        //-NPR5.43 [300254]
        //IF NOT Register."Customer Display" THEN
        //  EXIT;
        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        //+NPR5.43 [300254]

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        //-NPR5.43 [300254]
        //IF DisplaySetup.GET(Register."Register No.") THEN BEGIN
        if DisplayIsActivated then
            //+NPR5.43 [300254]
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::Payment, 0)
        //-NPR5.42 [315824]
        //-NPR5.43 [300254]
        //END ELSE BEGIN
        else
            if MatrixIsActivated then begin
                //+NPR5.43 [300254]
                CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
                UpdateDisplayFromSalePOS(SaleHeader, Register, Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'));
            end;
        //+NPR5.42 [305714]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150704, 'OnBeforeChangeToPaymentView', '', true, true)]
    local procedure CU6150704OnBeforeChangeToPaymentView(var Sender: Codeunit "POS Front End Management"; POSSession: Codeunit "POS Session")
    var
        Register: Record Register;
        FrontEnd: Codeunit "POS Front End Management";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        SaleHeader: Record "Sale POS";
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        //-NPR5.42 [315824]
        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not Register.Get(SaleLinePOS."Register No.") then
            exit;

        //-NPR5.43 [300254]
        //IF NOT Register."Customer Display" THEN
        //  EXIT;
        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        //+NPR5.43 [300254]

        //-NPR5.43 [300254]
        //IF DisplaySetup.GET(Register."Register No.") THEN
        if DisplayIsActivated then
            exit;
        //+NPR5.43 [300254]

        CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
        UpdateDisplayFromSalePOS(SaleHeader, Register, Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'));
        //+NPR5.42 [315824]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150725, 'OnBeforeActionWorkflow', '', true, true)]
    local procedure CU6150725OnBeforeActionWorkflow(PaymentTypePOS: Record "Payment Type POS"; Parameters: DotNet npNetJObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; Context: Codeunit "POS JSON Management"; SubTotal: Decimal; var Handled: Boolean)
    var
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        Register: Record Register;
        POSPaymentLine: Codeunit "POS Payment Line";
        CurrencyAmount: Decimal;
        Line1: Text;
        Line2: Text;
        SaleHeader: Record "Sale POS";
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        //-NPR5.45 [318695]
        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not Register.Get(SaleLinePOS."Register No.") then
            exit;

        CustomerDisplayIsActivated(Register, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) then
            exit;

        if PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::"Foreign Currency" then begin
            CurrencyAmount := POSPaymentLine.RoundAmount(PaymentTypePOS, POSPaymentLine.CalculateForeignAmount(PaymentTypePOS, SubTotal));
            Line1 := PadStr(PaymentTypePOS.Description, 20);
            Line2 := PadStr(' ', 20 - StrLen(Format(CurrencyAmount, 0, '<Precision,2:2><Standard Format,0>'))) + Format(CurrencyAmount, 0, '<Precision,2:2><Standard Format,0>');
            UpdateDisplay(Line1, Line2);
        end else begin
            CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
            UpdateDisplayFromSalePOS(SaleHeader, Register, Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'));
        end;
        //+NPR5.45 [318695]
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure UpdateDisplayFromSaleLinePOS(var Rec: Record "Sale Line POS")
    var
        Sign: Integer;
        Total: Text[30];
        Line1: Text;
        Line2: Text;
    begin
        with Rec do begin
            if not (Type in [Type::"G/L Entry", Type::Item, Type::Customer, Type::"BOM List"]) then
                exit;

            if "No." = '' then
                exit;

            Error('AL-Conversion: TODO #361939 - AL: "Discount Type"::"6" doesn''t exist-TAB6014406');

            Line1 := PadStr(Description, 20);
            Total := ' = ' + Format("Amount Including VAT", 0, '<Precision,0:2><Standard Format,0>');

            if ("Discount Type" <> "Discount Type"::" ") and ("Discount %" <> 0) then begin
                if Amount <> 0 then
                    Sign := (Amount / Abs(Amount))
                else
                    Sign := 1;

                case Sign of
                    1:
                        Line2 := PadStr('x' + Format(Abs(Quantity)) + ' - ' + Format("Discount %", 0, '<Precision,0:2><Standard Format,0>') + '%', 20 - StrLen(Total)) + Total;
                    -1:
                        Line2 := PadStr('x' + Format(Abs(Quantity)) + ' + ' + Format("Discount %", 0, '<Precision,0:2><Standard Format,0>') + '%', 20 - StrLen(Total)) + Total;
                end;
            end else
                Line2 := PadStr('x' + Format(Abs(Quantity)), 20 - StrLen(Total)) + Total;
        end;

        //MESSAGE('UpdateDisplayFromSaleLinePOS:\' + Line1 + '\' + Line2);

        UpdateDisplay(Line1, Line2);
    end;

    local procedure UpdateDisplayFromSalePOS(SalePOS: Record "Sale POS"; Register: Record Register; "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity; TextValue: Text[30]; TextValue2: Text[30]): Boolean
    var
        Line1: Text;
        Line2: Text;
        ObjectOutputSelection: Record "Object Output Selection";
        BixolonSetupFound: Boolean;
    begin
        Clear(Line1);
        Clear(Line2);

        case Action of
            Action::Login:
                begin
                    //-NPR5.45 [323345]
                    Clear(ObjectOutputSelection);
                    ObjectOutputSelection.SetRange("Output Path", 'DisplayBixolon');
                    if ObjectOutputSelection.FindSet then begin
                        repeat
                            if (ObjectOutputSelection."User ID" = UserId) or (ObjectOutputSelection."User ID" = '') then
                                BixolonSetupFound := true;
                        until ObjectOutputSelection.Next = 0;

                        if not BixolonSetupFound then begin
                            Message(BixolonError);
                            exit;
                        end;
                    end else begin
                        Message(BixolonError);
                        exit;
                    end;
                    //+NPR5.45 [323345]

                    Line1 := PadStr(Register."Display 1", 20);
                    Line2 := PadStr(Register."Display 2", 20);
                end;

            Action::Clear:
                begin
                    Line1 := ' ';
                    Line2 := ' ';
                end;

            Action::Cancelled:
                Line1 := CaptionCancelledSale;

            Action::Payment:
                begin
                    Line1 := PadStr(CaptionPaymentTotal, 20 - StrLen(TextValue)) + TextValue + ' ';
                    Line2 := PadStr(CaptionBalanceTotal, 20 - StrLen(TextValue2)) + TextValue2 + ' ';
                end;
            Action::EndSale:
                Line1 := PadStr(CaptionChangeTotal, 20 - StrLen(TextValue)) + TextValue + ' ';

            Action::Closed:
                Line1 := CaptionRegisterClosed;

            Action::DeleteLine:
                begin
                    Line1 := CaptionDeletedSaleline;
                    Line2 := PadStr(CaptionPaymentTotal, 20 - StrLen(TextValue)) + TextValue + ' ';
                end;

        end;

        //MESSAGE('UpdateDisplayFromSalePOS:\' + Line1 + '\' + Line2);

        UpdateDisplay(Line1, Line2);
    end;

    local procedure UpdateDisplay(Line1: Text; Line2: Text)
    var
        PrintToDisplay: Codeunit "Report - Print To Display";
    begin
        PrintToDisplay.SetLine(Line1, Line2);
        PrintToDisplay.Run();
    end;

    procedure Update2ndDisplayFromSalePOS(var FrontEnd: Codeunit "POS Front End Management"; var SalePOS: Record "Sale POS"; var Register: Record Register; "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity; TextValue: Text[30]; NewQuantity: Decimal): Boolean
    var
        Line1: Text;
        Line2: Text;
        SaleLinePOS: Record "Sale Line POS";
    begin
        Clear(Line1);
        Clear(Line2);

        case Action of
            Action::Login:
                begin
                    Login(FrontEnd, Register."Register No.");
                end;
            Action::Clear:
                begin
                    CloseReceipt(FrontEnd);
                end;
            Action::Cancelled:
                begin
                    Clear(FrontEnd);
                end;
            Action::Payment:
                begin
                    SaleLinePOS.Reset;
                    SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                    if SaleLinePOS.FindSet then
                        Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action, NewQuantity)
                    else
                        Clear(FrontEnd);
                end;
            Action::EndSale:
                begin
                    SaleLinePOS.Reset;
                    SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                    if SaleLinePOS.FindSet then
                        Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action, NewQuantity)
                    else
                        Clear(FrontEnd);
                end;
            Action::Closed:
                begin
                    Line1 := CaptionRegisterClosed;
                    Closed(FrontEnd);
                end;
        end;
    end;

    local procedure Update2ndDisplayFromSaleLinePOS(var FrontEnd: Codeunit "POS Front End Management"; var Rec: Record "Sale Line POS"; "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity; NewQuantity: Decimal)
    var
        Sign: Integer;
        Total: Text[30];
        Line1: Text;
        Line2: Text;
        SaleLinePOS: Record "Sale Line POS";
        ShowLine: Boolean;
        ReceiptText: Text;
        GrandTotal: Decimal;
        GrandTotalTxt: Text;
        Payment: Decimal;
        PaymentTxt: Text;
        TextValueDec: Decimal;
        LineCounter: Integer;
        ChangeTxt: Text;
        Change: Decimal;
        TotalTAX: Decimal;
        TotalTAXTxt: Text;
        GrandTotalIncTax: Decimal;
        GrandTotalIncTaxTxt: Text;
        DisplayCustomContent: Record "Display Custom Content" temporary;
    begin
        LineCounter := 0;

        //-NPR5.44 [318695]
        DisplaySetup.Get(Rec."Register No.");
        //+NPR5.44 [318695]

        //-NPR5.50 [352390]
        if DisplaySetup."Custom Display Codeunit" <> 0 then begin
            DisplayCustomContent.RecId := Rec.RecordId;
            DisplayCustomContent.Action := Action;
            DisplayCustomContent.NewQuantity := NewQuantity;
            CODEUNIT.Run(DisplaySetup."Custom Display Codeunit", DisplayCustomContent);
        end else begin
            //+NPR5.50 [352390]
            SaleLinePOS.Reset;
            SaleLinePOS.SetRange("Register No.", Rec."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
            SaleLinePOS.SetRange(Date, Rec.Date);
            if SaleLinePOS.FindSet then begin
                repeat
                    ShowLine := true;

                    if not (SaleLinePOS.Type in [SaleLinePOS.Type::"G/L Entry", SaleLinePOS.Type::Item, SaleLinePOS.Type::Customer, SaleLinePOS.Type::"BOM List", SaleLinePOS.Type::Payment]) then
                        ShowLine := false;

                    if SaleLinePOS."No." = '' then
                        ShowLine := false;

                    if (Action = Action::DeleteLine) then
                        ShowLine := (SaleLinePOS."Line No." <> Rec."Line No.");

                    //-NPR5.42 [305714]
                    //IF (Action = Action::NewQuantity) THEN
                    //  IF (SaleLinePOS."Line No." = Rec."Line No.") THEN
                    //    SaleLinePOS.VALIDATE(Quantity,NewQuantity);
                    //+NPR5.42 [305714]

                    if ShowLine then begin
                        LineCounter += 1;
                        if SaleLinePOS.Type = SaleLinePOS.Type::Payment then begin
                            Payment := Payment + SaleLinePOS."Amount Including VAT"
                        end else begin
                            Line1 := PadStr(SaleLinePOS.Description, DisplaySetup."Receipt Description Padding");

                            //-NPR5.44 [318695]
                            //Total := FORMAT(SaleLinePOS."Amount Including VAT",0,'<Precision,2:2><Standard Format,0>');
                            if DisplaySetup."Prices ex. VAT" then begin
                                Total := Format(SaleLinePOS.Amount, 0, '<Precision,2:2><Standard Format,0>');
                            end else begin
                                Total := Format(SaleLinePOS."Amount Including VAT", 0, '<Precision,2:2><Standard Format,0>');
                            end;
                            //+NPR5.44 [318695]

                            if (SaleLinePOS."Discount Type" <> SaleLinePOS."Discount Type"::" ") and (SaleLinePOS."Discount %" <> 0) then begin
                                if SaleLinePOS.Amount <> 0 then
                                    Sign := (SaleLinePOS.Amount / Abs(SaleLinePOS.Amount))
                                else
                                    Sign := 1;

                                case Sign of
                                    1:
                                        Line2 := Line1 + ' ' + PadStr('x' + Format(Abs(SaleLinePOS.Quantity)) + ' - ' + Format(SaleLinePOS."Discount %", 0, '<Precision,0:2><Standard Format,0>') + '%', DisplaySetup."Receipt Discount Padding" - StrLen(Total)) + Total;
                                    -1:
                                        Line2 := Line1 + ' ' + PadStr('x' + Format(Abs(SaleLinePOS.Quantity)) + ' + ' + Format(SaleLinePOS."Discount %", 0, '<Precision,0:2><Standard Format,0>') + '%', DisplaySetup."Receipt Discount Padding" - StrLen(Total)) + Total;
                                end;
                            end else
                                Line2 := Line1 + ' ' + PadStr('x' + Format(Abs(SaleLinePOS.Quantity)), DisplaySetup."Receipt Total Padding" - StrLen(Total)) + Total;

                            ReceiptText := ReceiptText + Line2 + '#NEWLINE#';

                            //-NPR5.44 [318695]
                            //GrandTotal := GrandTotal + SaleLinePOS."Amount Including VAT";
                            if DisplaySetup."Prices ex. VAT" then begin
                                GrandTotal := GrandTotal + SaleLinePOS.Amount;
                                TotalTAX := TotalTAX + (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
                                GrandTotalIncTax := GrandTotal + TotalTAX;
                            end else begin
                                GrandTotal := GrandTotal + SaleLinePOS."Amount Including VAT";
                            end;
                            //+NPR5.44 [318695]

                        end;
                    end;
                until SaleLinePOS.Next = 0;
            end;

            GrandTotalTxt := Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>');
            //-NPR5.44 [318695]
            GrandTotalIncTaxTxt := Format(GrandTotalIncTax, 0, '<Precision,2:2><Standard Format,0>');
            //+NPR5.44 [318695]
            PaymentTxt := Format(Payment, 0, '<Precision,2:2><Standard Format,0>');

            //-NPR5.36
            Change := 0;
            ChangeTxt := Format(Change, 0, '<Precision,2:2><Standard Format,0>');
            //-NPR5.44 [318695]
            if DisplaySetup."Prices ex. VAT" then begin
                if (Payment > GrandTotalIncTax) then
                    ChangeTxt := Format(Round((Payment - GrandTotalIncTax) * -1, 0.01, '='), 0, '<Precision,2:2><Standard Format,0>');
            end else begin
                //+NPR5.44 [318695]
                if (Payment > GrandTotal) then
                    ChangeTxt := Format(Round((Payment - GrandTotal) * -1, 0.01, '='), 0, '<Precision,2:2><Standard Format,0>');
                //-NPR5.44 [318695]
            end;
            //+NPR5.44 [318695]
            //+NPR5.36

            //-NPR5.44 [318695]
            if DisplaySetup."Prices ex. VAT" then begin
                TotalTAXTxt := Format(TotalTAX, 0, '<Precision,2:2><Standard Format,0>');

                ReceiptText := ReceiptText +
                             '#NEWLINE#' +
                             PadStr(CaptionSubTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(GrandTotalTxt)) + GrandTotalTxt +
                             '#NEWLINE#' +
                             PadStr(CaptionTAXTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(TotalTAXTxt)) + TotalTAXTxt +
                             '#NEWLINE#' +
                             PadStr(CaptionTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(GrandTotalIncTaxTxt)) + GrandTotalIncTaxTxt +
                             '#NEWLINE#' +
                             '#NEWLINE#' +
                             PadStr(CaptionPaymentTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(PaymentTxt)) + PaymentTxt +
                             '#NEWLINE#' +
                             PadStr(CaptionChangeTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(ChangeTxt)) + ChangeTxt;

            end else begin
                //+NPR5.44 [318695]
                ReceiptText := ReceiptText +
                             '#NEWLINE#' +
                             '#NEWLINE#' +
                             PadStr(CaptionTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(GrandTotalTxt)) + GrandTotalTxt +
                             '#NEWLINE#' +
                             PadStr(CaptionPaymentTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(PaymentTxt)) + PaymentTxt +
                             '#NEWLINE#' +
                             PadStr(CaptionChangeTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(ChangeTxt)) + ChangeTxt;
                //-NPR5.44 [318695]
            end;
            //+NPR5.44 [318695]

            if LineCounter = 0 then begin
                Closed(FrontEnd);
            end else begin
                case Action of
                    Action::Cancelled:
                        ;
                    Action::Clear:
                        CloseReceipt(FrontEnd);
                    Action::Closed:
                        Closed(FrontEnd);
                    Action::EndSale:
                        EndSale(FrontEnd, ReceiptText, SaleLinePOS."Register No.");
                    Action::Payment:
                        Payments(FrontEnd, ReceiptText);
                    Action::DeleteLine:
                        Payments(FrontEnd, ReceiptText);
                    Action::NewQuantity:
                        Payments(FrontEnd, ReceiptText);
                end
            end;
            //-NPR5.50 [352390]
        end;
        //+NPR5.50 [352390]
    end;

    local procedure CalculateTotals(var Rec: Record "Sale Line POS"; var GrandTotal: Decimal; var Payment: Decimal; var Change: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.", Rec."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, Rec.Date);
        if SaleLinePOS.FindSet then begin
            repeat
                if SaleLinePOS.Type = SaleLinePOS.Type::Payment then begin
                    Payment := Payment + SaleLinePOS."Amount Including VAT"
                end else begin
                    GrandTotal := GrandTotal + SaleLinePOS."Amount Including VAT";
                end;
            until SaleLinePOS.Next = 0;
        end;

        Change := 0;
        if (Payment > GrandTotal) then
            Change := (Payment - GrandTotal) * -1;
    end;

    local procedure Login(var FrontEnd: Codeunit "POS Front End Management"; RegisterNo: Code[10])
    var
        POSSession: Codeunit "POS Session";
    begin
        if DisplaySetup."Media Downloaded" then
            SetAction(0)
        else
            SetAction(6);

        SetRegister(RegisterNo);
        SetReceiptCloseDuration(0);
        DisplayHandler();
        if (POSSession.IsActiveSession(FrontEnd)) then
            FrontEnd.InvokeDevice(SecondaryMonitorRequest, ProtocolName, 'LOGIN');

        case DisplayHandlerAction of
            //NPR5.38-
            DisplayHandlerAction::OpenDisplay:
                begin
                    Closed(FrontEnd);
                end;
            //NPR5.38+
            DisplayHandlerAction::DownloadFiles:
                begin
                    DisplaySetup."Media Downloaded" := true;
                    DisplaySetup.Modify(true);
                end;
        end;
    end;

    procedure Closed(var FrontEnd: Codeunit "POS Front End Management")
    begin
        SetAction(5);
        DisplayHandler();

        FrontEnd.InvokeDevice(SecondaryMonitorRequest, ProtocolName, 'CLOSED');
    end;

    procedure EndSale(var FrontEnd: Codeunit "POS Front End Management"; EndSaleDescription: Text; RegisterNo: Code[10])
    begin
        SetRegister(RegisterNo);
        SetAction(4);
        SetReceiptContent(EndSaleDescription);
        DisplayHandler();

        FrontEnd.InvokeDevice(SecondaryMonitorRequest, ProtocolName, 'ENDSALE');

        SetReceiptCloseDuration(DisplaySetup."Receipt Duration");
        DisplayHandler();

        FrontEnd.InvokeDevice(SecondaryMonitorRequest, ProtocolName, 'RECEIPTCLOSEDURATION');
    end;

    procedure Payments(var FrontEnd: Codeunit "POS Front End Management"; PaymentDescription: Text)
    begin
        SetAction(4);
        SetReceiptContent(PaymentDescription);
        DisplayHandler();

        FrontEnd.InvokeDevice(SecondaryMonitorRequest, ProtocolName, 'PAYMENT');
    end;

    procedure CloseReceipt(var FrontEnd: Codeunit "POS Front End Management")
    begin
        SetAction(5);
        DisplayHandler();

        FrontEnd.InvokeDevice(SecondaryMonitorRequest, ProtocolName, 'CLEAR');
    end;

    local procedure SetAction(ActionIn: Option OpenDisplay,CloseDisplay,UpdateDisplay,ShowReceipt,UpdateReceipt,CloseReceipt,DownloadFiles,DownloadHtmlFile)
    begin
        DisplayHandlerAction := ActionIn;
    end;

    local procedure SetRegister(RegisterNoIn: Code[10])
    begin
        DisplayContent.Get(DisplaySetup."Display Content Code");
        ContentType := DisplayContent.Type;
    end;

    local procedure SetReceiptCloseDuration(ReceiptCloseDurationIn: Integer)
    begin
        ReceiptCloseDuration := ReceiptCloseDurationIn;
    end;

    procedure SetReceiptContent(ReceiptContentIn: Text)
    begin
        ReceiptContent := ReceiptContentIn;
    end;

    local procedure DisplayHandler()
    begin
        CreateDotNetDict(MediaDictionary);
        CreateDotNetDict(Base64Dictionary);

        SecondaryMonitorRequest := SecondaryMonitorRequest.SecondaryMonitorRequest();

        SecondaryMonitorRequest.DisplayAction := DisplayHandlerAction;
        SecondaryMonitorRequest.ReceiptDuration := ReceiptCloseDuration;
        SecondaryMonitorRequest.ScreenNo := DisplaySetup."Screen No.";
        SecondaryMonitorRequest.ReceiptWidthPct := DisplaySetup."Receipt Width Pct.";
        SecondaryMonitorRequest.ReceiptContent := ReceiptContent;
        SecondaryMonitorRequest.ReceiptPlacement := DisplaySetup."Receipt Placement";
        SecondaryMonitorRequest.DisplayContentUrl := '';
        SecondaryMonitorRequest.ContentType := ContentType;

        case DisplayHandlerAction of
            DisplayHandlerAction::DownloadFiles:
                SecondaryMonitorRequest.DisplayContentHtml := SetContentHtml;
        end;

        SecondaryMonitorRequest.MediaDictionary := MediaDictionary;
        SecondaryMonitorRequest.Base64Dictionary := Base64Dictionary;

        //MESSAGE(JsonConvert.SerializeObject(SecondaryMonitorRequest));
    end;

    local procedure SetMediaDictionary(MediaDictionaryIn: DotNet npNetDictionary_Of_T_U)
    begin
        MediaDictionary := MediaDictionaryIn;
    end;

    local procedure SetContentHtml(): Text
    begin
        case DisplayContent.Type of
            DisplayContent.Type::Html:
                exit(CreateWebContent(DisplayContent.Code));
            DisplayContent.Type::Image:
                exit(CreateImageContent(DisplayContent.Code));
            DisplayContent.Type::Video:
                exit(CreateVideoContent(DisplayContent.Code));
        end;
    end;

    local procedure CreateWebContent(ContentCode: Code[10]): Text
    var
        DisplayContentLines: Record "Display Content Lines";
        ContentHtml: Text;
    begin
        DisplayContentLines.SetRange("Content Code", ContentCode);
        if DisplayContentLines.FindFirst then begin
            ContentHtml += '<!DOCTYPE html>';
            ContentHtml += '<html>';
            ContentHtml += '<head>';
            ContentHtml += '    <meta http-equiv="Content-Type" content="text/html; charset=unicode" />';
            ContentHtml += '    <meta http-equiv="X-UA-Compatible" content="IE=9" />';
            ContentHtml += '</head>';
            ContentHtml += '<body style="margin:0px;padding:0px;overflow:hidden">';
            ContentHtml += '    <iframe src="' + DisplayContentLines.Url + '" frameborder="0" style="position: absolute; height: 100%; border: none; width: 100%; overflow:hidden" scrolling="no"></iframe>';
            ContentHtml += '</body>';
            ContentHtml += '</html>';
        end;
        exit(ContentHtml);
    end;

    local procedure CreateImageContent(ContentCode: Code[10]): Text
    var
        ContentHtml: Text;
        DisplayContentLines: Record "Display Content Lines";
        ImageCounter: Integer;
        CurrBase64: Text;
        CurrExtension: Text[10];
    begin
        if DisplaySetup."Image Rotation Interval" = 0 then
            DisplaySetup."Image Rotation Interval" := 3000;

        DisplayContentLines.SetRange("Content Code", ContentCode);
        if DisplayContentLines.FindSet then begin
            ContentHtml += '<!DOCTYPE html>';
            ContentHtml += '<html>';
            ContentHtml += '<head>';
            ContentHtml += '  <meta http-equiv="Content-Type" content="text/html; charset=unicode" />';
            ContentHtml += '  <meta http-equiv="X-UA-Compatible" content="IE=9" />';
            ContentHtml += '  <style type="text/css">';
            ContentHtml += '      body { overflow: hidden; margin: 0px; padding: 0px; border: 0px }';
            ContentHtml += '      .imageCarousel {display:none;}';
            ContentHtml += '  </style>';
            ContentHtml += '</head>';
            ContentHtml += '<body>';
            ContentHtml += '  <div style="width: 100%; height: 100%;">';
            ImageCounter := 1;
            repeat
                GetImageContentAndExtension(DisplayContentLines, CurrBase64, CurrExtension);
                ContentHtml += '    <img class="imageCarousel" src="' + Format(ImageCounter) + '.' + CurrExtension + '" style="width:100%; height: 100%;">';
                MediaDictionary.Add(ImageCounter, Format(ImageCounter) + '.' + CurrExtension);
                Base64Dictionary.Add(ImageCounter, CurrBase64);
                ImageCounter += 1;
            until DisplayContentLines.Next = 0;
            ContentHtml += '  </div>';
            ContentHtml += '  <script>';
            ContentHtml += '    var myIndex = 0;';
            ContentHtml += '    carousel();';
            ContentHtml += '    function carousel() {';
            ContentHtml += '      var i;';
            ContentHtml += '      var x = document.getElementsByClassName("imageCarousel");';
            ContentHtml += '      for (i = 0; i < x.length; i++) {';
            ContentHtml += '             x[i].style.display = "none";';
            ContentHtml += '      }';
            ContentHtml += '      myIndex++;';
            ContentHtml += '      if (myIndex > x.length) {myIndex = 1}';
            ContentHtml += '        x[myIndex-1].style.display = "block";';
            //ContentHtml += '        setTimeout(carousel, 3000);'; //Move to setup
            ContentHtml += '        setTimeout(carousel, ' + Format(DisplaySetup."Image Rotation Interval") + ');';
            ContentHtml += '    }';
            ContentHtml += '  </script>';
            ContentHtml += '</body>';
            ContentHtml += '</html>';
        end;
        exit(ContentHtml);
    end;

    local procedure CreateVideoContent(ContentCode: Code[10]): Text
    var
        ContentHtml: Text;
        DisplayContentLines: Record "Display Content Lines";
        VideoCounter: Integer;
    begin
        DisplayContentLines.SetRange("Content Code", ContentCode);
        if DisplayContentLines.FindSet then begin
            ContentHtml += '<!DOCTYPE html>';
            ContentHtml += '<html>';
            ContentHtml += '<head>';
            ContentHtml += '  <meta http-equiv="Content-Type" content="text/html; charset=unicode" />';
            ContentHtml += '  <meta http-equiv="X-UA-Compatible" content="IE=9" />';
            ContentHtml += '  <style type="text/css">';
            ContentHtml += '    body { overflow: hidden; margin: 0px; padding: 0px; border: 0px; }';
            ContentHtml += '    .fullscreen { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }';
            ContentHtml += '  </style>';
            ContentHtml += '</head>';
            ContentHtml += '<body>';
            ContentHtml += '  <video muted autoplay class="fullscreen" onended="run()" id="fullscreenVideo">';
            VideoCounter := 1;
            repeat
                ContentHtml += '    <source src="video' + Format(VideoCounter) + '.mp4" type="video/mp4">';
                MediaDictionary.Add(VideoCounter, DisplayContentLines.Url);
                VideoCounter += 1;
            until DisplayContentLines.Next = 0;
            ContentHtml += '  </video>';
            ContentHtml += '  <script>';
            ContentHtml += '    video_count = 1;';
            ContentHtml += '    var videoPlayer = document.getElementById("fullscreenVideo");';
            ContentHtml += '    function run() {';
            ContentHtml += '      video_count++;';
            ContentHtml += '      if (video_count == 3) video_count = 1;';
            ContentHtml += '      var nextVideo = "video" + video_count + ".mp4";';
            ContentHtml += '      videoPlayer.src = nextVideo;';
            ContentHtml += '      videoPlayer.play();';
            ContentHtml += '    };';
            ContentHtml += '  </script>';
            ContentHtml += '</body>';
            ContentHtml += '</html>';
        end;
        exit(ContentHtml);
    end;

    local procedure CreateDotNetDict(Dict: DotNet npNetDictionary_Of_T_U)
    var
        Type: DotNet npNetType;
        Activator: DotNet npNetActivator;
        Arr: DotNet npNetArray;
        String: DotNet npNetString;
        Int: Integer;
    begin
        Arr := Arr.CreateInstance(GetDotNetType(Type), 2);
        Arr.SetValue(GetDotNetType(Int), 0);
        Arr.SetValue(GetDotNetType(String), 1);

        Type := GetDotNetType(Dict);
        Type := Type.MakeGenericType(Arr);

        Dict := Activator.CreateInstance(Type);
    end;

    local procedure GetImageContentAndExtension(DisplayContentLines: Record "Display Content Lines"; var Base64: Text; var Extension: Text[10])
    var
        Convert: DotNet npNetConvert;
        Bytes: DotNet npNetArray;
        InS: InStream;
        MemoryStream: DotNet npNetMemoryStream;
        Image: DotNet npNetImage;
        ImageFormat: DotNet npNetImageFormat;
        Converter: DotNet npNetImageConverter;
    begin
        DisplayContentLines.CalcFields(Image);
        if DisplayContentLines.Image.HasValue then begin
            DisplayContentLines.Image.CreateInStream(InS);

            MemoryStream := MemoryStream.MemoryStream();
            CopyStream(MemoryStream, InS);

            Bytes := MemoryStream.ToArray();

            Converter := Converter.ImageConverter;
            Image := Converter.ConvertFrom(Bytes);

            //Image.FromStream(MemoryStream);

            if (ImageFormat.Jpeg.Equals(Image.RawFormat)) then
                Extension := 'jpeg'
            else
                if (ImageFormat.Png.Equals(Image.RawFormat)) then
                    Extension := 'png'
                else
                    if (ImageFormat.Gif.Equals(Image.RawFormat)) then
                        Extension := 'gif'
                    else
                        if (ImageFormat.Bmp.Equals(Image.RawFormat)) then
                            Extension := 'bmp'
                        else
                            if (ImageFormat.Tiff.Equals(Image.RawFormat)) then
                                Extension := 'tiff'
                            else
                                if (ImageFormat.Emf.Equals(Image.RawFormat)) then
                                    Extension := 'emf'
                                else
                                    if (ImageFormat.Icon.Equals(Image.RawFormat)) then
                                        Extension := 'icon'
                                    else
                                        if (ImageFormat.Exif.Equals(Image.RawFormat)) then
                                            Extension := 'exif'
                                        else
                                            if (ImageFormat.Wmf.Equals(Image.RawFormat)) then
                                                Extension := 'wmf';

            Base64 := Convert.ToBase64String(Bytes);
        end;
    end;

    local procedure CustomerDisplayIsActivated(Register: Record Register; var MatrixIsActivated: Boolean; var DisplayIsActivated: Boolean)
    begin
        MatrixIsActivated := Register."Customer Display";
        if not MatrixIsActivated then
            if DisplaySetup.Get(Register."Register No.") then
                DisplayIsActivated := DisplaySetup.Activate;
    end;

    local procedure "--- OnAfterInsertSaleLine Workflow"()
    begin
        //-NPR5.43 [319425]
        //+NPR5.43 [319425]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        //-NPR5.43 [319425]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'UpdateDisplayOnSaleLineInsert':
                begin
                    Rec.Description := Text000;
                    Rec."Sequence No." := 10;
                end;
        end;
        //+NPR5.43 [319425]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.43 [319425]
        exit(CODEUNIT::"POS Proxy - Display");
        //+NPR5.43 [319425]
    end;
}

