codeunit 6151002 "NPR POS Proxy - Display"
{
    trigger OnRun()
    begin
    end;

    var
        DisplayHandlerAction: Option OpenDisplay,CloseDisplay,UpdateDisplay,ShowReceipt,UpdateReceipt,CloseReceipt,DownloadFiles,DownloadHtmlFile;
        ReceiptCloseDuration: Integer;
        ReceiptContent: Text;
        DisplaySetup: Record "NPR Display Setup";
        DisplayContent: Record "NPR Display Content";
        MediaDictionary: JsonObject;
        Base64Dictionary: JsonObject;
        ContentType: Option Image,Video,Html;
        SecondaryMonitorRequest: JsonObject;
        CaptionCancelledSale: Label 'Cancelled sale';
        CaptionPaymentTotal: Label 'Total Paid';
        CaptionChangeTotal: Label 'Total Change';
        CaptionRegisterClosed: Label 'Register closed';
        CaptionTotal: Label 'Grand Total';
        CaptionDeletedSaleline: Label 'Deleted item';
        MatrixIsActivated: Boolean;
        DisplayIsActivated: Boolean;
        Text000: Label 'Update POS Unit Display on Sale Line Insert';
        CaptionTAXTotal: Label 'Tax';
        CaptionSubTotal: Label 'Sub-Total';
        BixolonError: Label 'Display Setup is missing\\Object Output Selection is missing for DisplayBixolon\and will result in the following error\\The value "" can''t be evaluated into type Integer ';
        CaptionBalanceTotal: Label 'Balance';
        HideReceiptIsActivated: Boolean;
        CaptionPaymentsDetails: Label 'Payment Details:';
        CaptionRemaningAmt: Label 'Remaining Amount';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterInitializeAtLogin', '', true, true)]
    local procedure CU6150705OnAfterInitializeAtLogin(POSUnit: Record "NPR POS Unit")
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        if not POSSession.IsActiveSession(FrontEnd) then
            exit;
        if DisplayIsActivated then
            Login(FrontEnd)
        else
            if MatrixIsActivated then
                UpdateDisplayFromSalePOS(Action::Login, '', '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterInitSale', '', true, true)]
    local procedure CU6150705OnAfterInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        TextValue: Text;
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        if not POSUnit.Get(SaleHeader."Register No.") then
            exit;
        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;

        if DisplayIsActivated then
            Update2ndDisplayFromSalePOS(FrontEnd, SaleHeader, POSUnit, Action::Clear, TextValue, 0)
        else
            if MatrixIsActivated then
                UpdateDisplayFromSalePOS(Action::Login, TextValue, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterInsertSaleLine', '', true, true)]
    local procedure UpdateDisplayOnSaleLineInsert(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin

        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'UpdateDisplayOnSaleLineInsert' then
            exit;
        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;
        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;
        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        if DisplayIsActivated then
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::Payment, 0)
        else
            if MatrixIsActivated then
                UpdateDisplayFromSaleLinePOS(SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterDeletePOSSaleLine', '', true, true)]
    local procedure CU6150706OnAfterDeletePOSSaleLine(var Sender: Codeunit "NPR POS Sale Line"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
    begin
        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;
        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        if DisplayIsActivated then
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::DeleteLine, 0)
        else
            if MatrixIsActivated then begin
                CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
                if SaleLinePOS.Type = SaleLinePOS.Type::Payment then
                    UpdateDisplayFromSalePOS(Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'))
                else
                    UpdateDisplayFromSalePOS(Action::DeleteLine, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnUpdateLine', '', true, true)]
    local procedure CU6150706OnUpdateLine(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;

        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        if DisplayIsActivated then
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::NewQuantity, SaleLinePOS.Quantity)
        else
            if MatrixIsActivated then
                UpdateDisplayFromSaleLinePOS(SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterSetQuantity', '', true, true)]
    local procedure CU6150706OnAfterSetQuantity(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;

        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        if DisplayIsActivated then
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::NewQuantity, SaleLinePOS.Quantity)
        else
            if MatrixIsActivated then
                UpdateDisplayFromSaleLinePOS(SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Line", 'OnAfterDeleteLine', '', true, true)]
    local procedure CU6150707OnAfterDeleteLine(SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
    begin
        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;

        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        if DisplayIsActivated then
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::Payment, 0)
        else
            if MatrixIsActivated then begin
                CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
                if SaleLinePOS.Type = SaleLinePOS.Type::Payment then
                    UpdateDisplayFromSalePOS(Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'))
                else
                    UpdateDisplayFromSalePOS(Action::DeleteLine, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Line", 'OnAfterInsertPaymentLine', '', true, true)]
    local procedure CU6150707OnAfterInsertPaymentLine(SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
    begin
        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;

        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;

        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        if DisplayIsActivated then
            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action::Payment, 0)
        else
            if MatrixIsActivated then begin
                CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
                UpdateDisplayFromSalePOS(Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'));
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Front End Management", 'OnBeforeChangeToPaymentView', '', true, true)]
    local procedure CU6150704OnBeforeChangeToPaymentView(var Sender: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSUnit: Record "NPR POS Unit";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;

        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) and (not DisplayIsActivated) then
            exit;

        if DisplayIsActivated then
            exit;

        CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
        UpdateDisplayFromSalePOS(Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Payment", 'OnBeforeActionWorkflow', '', true, true)]
    local procedure CU6150725OnBeforeActionWorkflow(POSPaymentMethod: Record "NPR POS Payment Method"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: Codeunit "NPR POS JSON Management"; SubTotal: Decimal; var Handled: Boolean)
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        CurrencyAmount: Decimal;
        Line1: Text;
        Line2: Text;
        GrandTotal: Decimal;
        Payment: Decimal;
        Change: Decimal;
        "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity;
    begin
        if not POSSession.IsActiveSession(FrontEnd) then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;

        CustomerDisplayIsActivated(POSUnit, MatrixIsActivated, DisplayIsActivated);
        if (not MatrixIsActivated) then
            exit;

        if POSPaymentMethod."Currency Code" <> '' then begin
            CurrencyAmount := POSPaymentLine.RoundAmount(POSPaymentMethod, POSPaymentLine.CalculateForeignAmount(POSPaymentMethod, SubTotal));
            Line1 := PadStr(POSPaymentMethod.Description, 20);
            Line2 := PadStr(' ', 20 - StrLen(Format(CurrencyAmount, 0, '<Precision,2:2><Standard Format,0>'))) + Format(CurrencyAmount, 0, '<Precision,2:2><Standard Format,0>');
            UpdateDisplay(Line1, Line2);
        end else begin
            CalculateTotals(SaleLinePOS, GrandTotal, Payment, Change);
            UpdateDisplayFromSalePOS(Action::Payment, Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>'), Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>'));
        end;
    end;

    local procedure UpdateDisplayFromSaleLinePOS(var Rec: Record "NPR POS Sale Line")
    var
        Sign: Integer;
        Total: Text[30];
        Line1: Text;
        Line2: Text;
    begin
        if not (Rec.Type in [Rec.Type::"G/L Entry", Rec.Type::Item, Rec.Type::Customer, Rec.Type::"BOM List"]) then
            exit;

        if Rec."No." = '' then
            exit;

        if (Rec.Type = Rec.Type::Item) and (Rec."Discount Type" = Rec."Discount Type"::"BOM List") then
            exit;

        Line1 := PadStr(Rec.Description, 20);
        Total := ' = ' + Format(Rec."Amount Including VAT", 0, '<Precision,0:2><Standard Format,0>');

        if (Rec."Discount Type" <> Rec."Discount Type"::" ") and (Rec."Discount %" <> 0) then begin
            if Rec.Amount <> 0 then
                Sign := (Rec.Amount / Abs(Rec.Amount))
            else
                Sign := 1;

            case Sign of
                1:
                    Line2 := PadStr('x' + Format(Abs(Rec.Quantity)) + ' - ' + Format(Rec."Discount %", 0, '<Precision,0:2><Standard Format,0>') + '%', 20 - StrLen(Total)) + Total;
                -1:
                    Line2 := PadStr('x' + Format(Abs(Rec.Quantity)) + ' + ' + Format(Rec."Discount %", 0, '<Precision,0:2><Standard Format,0>') + '%', 20 - StrLen(Total)) + Total;
            end;
        end else
            Line2 := PadStr('x' + Format(Abs(Rec.Quantity)), 20 - StrLen(Total)) + Total;

        UpdateDisplay(Line1, Line2);
    end;

    local procedure UpdateDisplayFromSalePOS("Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity; TextValue: Text[30]; TextValue2: Text[30]): Boolean
    var
        Line1: Text;
        Line2: Text;
        ObjectOutputSelection: Record "NPR Object Output Selection";
        BixolonSetupFound: Boolean;
    begin
        Clear(Line1);
        Clear(Line2);

        case Action of
            Action::Login:
                begin
                    Clear(ObjectOutputSelection);
                    ObjectOutputSelection.SetRange("Output Path", 'DisplayBixolon');
                    if ObjectOutputSelection.FindSet() then begin
                        repeat
                            if (ObjectOutputSelection."User ID" = UserId) or (ObjectOutputSelection."User ID" = '') then
                                BixolonSetupFound := true;
                        until ObjectOutputSelection.Next() = 0;

                        if not BixolonSetupFound then begin
                            Message(BixolonError);
                            exit;
                        end;
                    end else begin
                        Message(BixolonError);
                        exit;
                    end;
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

        UpdateDisplay(Line1, Line2);
    end;

    local procedure UpdateDisplay(Line1: Text; Line2: Text)
    var
        PrintToDisplay: Codeunit "NPR Print To Display";
    begin

        PrintToDisplay.SetLine(Line1, Line2);
        PrintToDisplay.Run();
    end;

    procedure Update2ndDisplayFromSalePOS(var FrontEnd: Codeunit "NPR POS Front End Management"; var SalePOS: Record "NPR POS Sale"; var POSUnit: Record "NPR POS Unit"; "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity; TextValue: Text[30]; NewQuantity: Decimal): Boolean
    var
        Line1: Text;
        Line2: Text;
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if not HideReceiptIsActivated then begin
            Clear(Line1);
            Clear(Line2);

            case Action of
                Action::Login:
                    begin
                        Login(FrontEnd);
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
                        SaleLinePOS.Reset();
                        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                        if SaleLinePOS.FindSet() then
                            Update2ndDisplayFromSaleLinePOS(FrontEnd, SaleLinePOS, Action, NewQuantity)
                        else
                            Clear(FrontEnd);
                    end;
                Action::EndSale:
                    begin
                        SaleLinePOS.Reset();
                        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                        if SaleLinePOS.FindSet() then
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
    end;

    local procedure Update2ndDisplayFromSaleLinePOS(var FrontEnd: Codeunit "NPR POS Front End Management"; var Rec: Record "NPR POS Sale Line"; "Action": Option Login,Clear,Cancelled,Payment,EndSale,Closed,DeleteLine,NewQuantity; NewQuantity: Decimal)
    var
        Sign: Integer;
        Total: Text[30];
        Line1: Text;
        Line2: Text;
        SaleLinePOS: Record "NPR POS Sale Line";
        ShowLine: Boolean;
        ReceiptText: Text;
        GrandTotal: Decimal;
        GrandTotalTxt: Text;
        Payment: Decimal;
        PaymentTxt: Text;
        LineCounter: Integer;
        ChangeTxt: Text;
        Change: Decimal;
        TotalTAX: Decimal;
        TotalTAXTxt: Text;
        GrandTotalIncTax: Decimal;
        GrandTotalIncTaxTxt: Text;
        DisplayCustomContent: Record "NPR Display Custom Content" temporary;
        GLSetup: Record "General Ledger Setup";
        PaymentAmountTxt: Text;
        PaymentAmountLCYTxt: Text;
        PaymentDetailsTxt: Text;
        RemainingAmtTxt: Text;
        NoOfFillterChars: Integer;
    begin
        LineCounter := 0;

        DisplaySetup.Get(Rec."Register No.");
        if not DisplaySetup."Hide receipt" then begin
            if DisplaySetup."Custom Display Codeunit" <> 0 then begin
                DisplayCustomContent.RecId := Rec.RecordId;
                DisplayCustomContent.Action := Action;
                DisplayCustomContent.NewQuantity := NewQuantity;
                CODEUNIT.Run(DisplaySetup."Custom Display Codeunit", DisplayCustomContent);
            end else begin
                SaleLinePOS.Reset();
                SaleLinePOS.SetRange("Register No.", Rec."Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
                SaleLinePOS.SetRange(Date, Rec.Date);
                if SaleLinePOS.FindSet() then begin
                    repeat
                        ShowLine := true;

                        if not (SaleLinePOS.Type in [SaleLinePOS.Type::"G/L Entry", SaleLinePOS.Type::Item, SaleLinePOS.Type::Customer, SaleLinePOS.Type::"BOM List", SaleLinePOS.Type::Payment]) then
                            ShowLine := false;

                        if SaleLinePOS."No." = '' then
                            ShowLine := false;

                        if (Action = Action::DeleteLine) then
                            ShowLine := (SaleLinePOS."Line No." <> Rec."Line No.");

                        if ShowLine then begin
                            LineCounter += 1;
                            if SaleLinePOS.Type = SaleLinePOS.Type::Payment then begin
                                if SaleLinePOS."Amount Including VAT" <> SaleLinePOS."Currency Amount" then
                                    PaymentAmountTxt := ' ' + SaleLinePOS."No." + ' ' + Format(SaleLinePOS."Currency Amount", 0, '<Precision,2:2><Standard Format,0>')
                                else
                                    PaymentAmountTxt := '';
                                PaymentAmountLCYTxt := Format(SaleLinePOS."Amount Including VAT", 0, '<Precision,2:2><Standard Format,0>');
                                NoOfFillterChars := 12 - StrLen(PaymentAmountLCYTxt);
                                if NoOfFillterChars <= 0 then
                                    NoOfFillterChars := 1;
                                PaymentAmountTxt := PaymentAmountTxt + PadStr('', NoOfFillterChars) + PaymentAmountLCYTxt;

                                if PaymentDetailsTxt = '' then
                                    PaymentDetailsTxt :=
                                      '#NEWLINE#' +
                                      '#NEWLINE#' +
                                      CaptionPaymentsDetails;
                                PaymentDetailsTxt := PaymentDetailsTxt +
                                  '#NEWLINE#' +
                                  PadStr(SaleLinePOS.Description, DisplaySetup."Receipt GrandTotal Padding" - StrLen(PaymentAmountTxt)) + PaymentAmountTxt;
                                Payment := Payment + SaleLinePOS."Amount Including VAT"
                            end else begin
                                Line1 := PadStr(SaleLinePOS.Description, DisplaySetup."Receipt Description Padding");
                                if DisplaySetup."Prices ex. VAT" then begin
                                    Total := Format(SaleLinePOS.Amount, 0, '<Precision,2:2><Standard Format,0>');
                                end else begin
                                    Total := Format(SaleLinePOS."Amount Including VAT", 0, '<Precision,2:2><Standard Format,0>');
                                end;

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

                                if ReceiptText = '' then begin
                                    GLSetup.Get();
                                    ReceiptText := PadStr('', DisplaySetup."Receipt GrandTotal Padding" - StrLen(GLSetup.GetCurrencyCode('')) - 2) + GLSetup.GetCurrencyCode('') + '#NEWLINE#';
                                end;
                                ReceiptText := ReceiptText + Line2 + '#NEWLINE#';

                                if DisplaySetup."Prices ex. VAT" then begin
                                    GrandTotal := GrandTotal + SaleLinePOS.Amount;
                                    TotalTAX := TotalTAX + (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
                                    GrandTotalIncTax := GrandTotal + TotalTAX;
                                end else begin
                                    GrandTotal := GrandTotal + SaleLinePOS."Amount Including VAT";
                                end;
                            end;
                        end;
                    until SaleLinePOS.Next() = 0;
                end;

                GrandTotalTxt := Format(GrandTotal, 0, '<Precision,2:2><Standard Format,0>');
                GrandTotalIncTaxTxt := Format(GrandTotalIncTax, 0, '<Precision,2:2><Standard Format,0>');
                PaymentTxt := Format(Payment, 0, '<Precision,2:2><Standard Format,0>');

                Change := 0;
                ChangeTxt := Format(Change, 0, '<Precision,2:2><Standard Format,0>');
                if DisplaySetup."Prices ex. VAT" then begin
                    if (Payment > GrandTotalIncTax) then
                        ChangeTxt := Format(Round((Payment - GrandTotalIncTax) * -1, 0.01, '='), 0, '<Precision,2:2><Standard Format,0>')
                    else
                        RemainingAmtTxt := Format(GrandTotalIncTax - Payment, 0, '<Precision,2:2><Standard Format,0>');
                end else begin
                    if (Payment > GrandTotal) then
                        ChangeTxt := Format(Round((Payment - GrandTotal) * -1, 0.01, '='), 0, '<Precision,2:2><Standard Format,0>')
                    else
                        RemainingAmtTxt := Format(GrandTotal - Payment, 0, '<Precision,2:2><Standard Format,0>');
                end;

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
                               PadStr(CaptionRemaningAmt, DisplaySetup."Receipt GrandTotal Padding" - StrLen(RemainingAmtTxt)) + RemainingAmtTxt +
                                 '#NEWLINE#' +
                                 PadStr(CaptionChangeTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(ChangeTxt)) + ChangeTxt;

                end else begin
                    ReceiptText := ReceiptText +
                                 '#NEWLINE#' +
                                 '#NEWLINE#' +
                                PadStr(CaptionTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(GrandTotalTxt)) + GrandTotalTxt +
                                 '#NEWLINE#' +
                                 PadStr(CaptionPaymentTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(PaymentTxt)) + PaymentTxt +
                               '#NEWLINE#' +
                               PadStr(CaptionRemaningAmt, DisplaySetup."Receipt GrandTotal Padding" - StrLen(RemainingAmtTxt)) + RemainingAmtTxt +
                                 '#NEWLINE#' +
                                 PadStr(CaptionChangeTotal, DisplaySetup."Receipt GrandTotal Padding" - StrLen(ChangeTxt)) + ChangeTxt;
                end;
                ReceiptText := ReceiptText + PaymentDetailsTxt;
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
            end;
        end;
    end;

    local procedure CalculateTotals(var Rec: Record "NPR POS Sale Line"; var GrandTotal: Decimal; var Payment: Decimal; var Change: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", Rec."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, Rec.Date);
        if SaleLinePOS.FindSet() then begin
            repeat
                if SaleLinePOS.Type = SaleLinePOS.Type::Payment then begin
                    Payment := Payment + SaleLinePOS."Amount Including VAT"
                end else begin
                    GrandTotal := GrandTotal + SaleLinePOS."Amount Including VAT";
                end;
            until SaleLinePOS.Next() = 0;
        end;

        Change := 0;
        if (Payment > GrandTotal) then
            Change := (Payment - GrandTotal) * -1;
    end;

    local procedure Login(var FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSSession: Codeunit "NPR POS Session";
        Request: Codeunit "NPR Front-End: HWC";
    begin
        if DisplaySetup."Media Downloaded" then
            SetAction(0)
        else
            SetAction(6);
        SetRegister();
        SetReceiptCloseDuration(0);
        DisplayHandler();
        Request.SetHandler('Display');
        Request.SetRequest(SecondaryMonitorRequest);
        if (POSSession.IsActiveSession(FrontEnd)) then
            FrontEnd.InvokeFrontEndMethod(Request);


        case DisplayHandlerAction of
            DisplayHandlerAction::OpenDisplay:
                begin
                    Closed(FrontEnd);
                end;
            DisplayHandlerAction::DownloadFiles:
                begin
                    DisplaySetup."Media Downloaded" := true;
                    DisplaySetup.Modify(true);
                end;
        end;
    end;

    procedure Closed(var FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Request: Codeunit "NPR Front-End: HWC";
    begin
        SetAction(5);
        DisplayHandler();
        Request.SetHandler('Display');
        Request.SetRequest(SecondaryMonitorRequest);
        FrontEnd.InvokeFrontEndMethod(Request);
    end;

    procedure EndSale(var FrontEnd: Codeunit "NPR POS Front End Management"; EndSaleDescription: Text; RegisterNo: Code[10])
    var
        Request: Codeunit "NPR Front-End: HWC";
    begin
        SetRegister();
        SetAction(4);
        SetReceiptContent(EndSaleDescription);
        SetReceiptCloseDuration(DisplaySetup."Receipt Duration");
        DisplayHandler();
        Request.SetHandler('Display');
        Request.SetRequest(SecondaryMonitorRequest);
        FrontEnd.InvokeFrontEndMethod(Request);
    end;

    procedure Payments(var FrontEnd: Codeunit "NPR POS Front End Management"; PaymentDescription: Text)
    var
        Request: Codeunit "NPR Front-End: HWC";
    begin
        SetAction(4);
        SetReceiptContent(PaymentDescription);
        DisplayHandler();

        Request.SetHandler('Display');
        Request.SetRequest(SecondaryMonitorRequest);
        FrontEnd.InvokeFrontEndMethod(Request);

    end;

    procedure CloseReceipt(var FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Request: Codeunit "NPR Front-End: HWC";
    begin
        SetAction(5);
        DisplayHandler();
        Request.SetHandler('Display');
        Request.SetRequest(SecondaryMonitorRequest);
        FrontEnd.InvokeFrontEndMethod(Request);
    end;

    local procedure SetAction(ActionIn: Option OpenDisplay,CloseDisplay,UpdateDisplay,ShowReceipt,UpdateReceipt,CloseReceipt,DownloadFiles,DownloadHtmlFile)
    begin
        DisplayHandlerAction := ActionIn;
    end;

    local procedure SetRegister()
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
    var
        jsonobj: JsonObject;
    begin
        jsonobj.Add('ScreenNo', DisplaySetup."Screen No.");
        jsonobj.Add('ReceiptWidthPct', DisplaySetup."Receipt Width Pct.");
        jsonobj.Add('ReceiptPlacement', DisplaySetup."Receipt Placement");
        jsonobj.Add('DisplayAction', DisplayHandlerAction);
        jsonobj.Add('ReceiptDuration', ReceiptCloseDuration);
        jsonobj.Add('ReceiptContent', ReceiptContent);
        jsonobj.Add('ContentType', ContentType);
        jsonobj.Add('DisplayContentHtml', SetContentHtml());
        jsonobj.Add('MediaDictionary', MediaDictionary);
        jsonobj.Add('Base64Dictionary', Base64Dictionary);
        jsonobj.Add('DisplayContentUrl', '');
        SecondaryMonitorRequest := jsonobj;

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
        DisplayContentLines: Record "NPR Display Content Lines";
        ContentHtml: Text;
    begin
        DisplayContentLines.SetRange("Content Code", ContentCode);
        if DisplayContentLines.FindFirst() then begin
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
        DisplayContentLines: Record "NPR Display Content Lines";
        ImageCounter: Integer;
        CurrBase64: Text;
        CurrExtension: Text[10];
    begin
        if DisplaySetup."Image Rotation Interval" = 0 then
            DisplaySetup."Image Rotation Interval" := 3000;

        DisplayContentLines.SetRange("Content Code", ContentCode);
        if DisplayContentLines.FindSet() then begin
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
                if not MediaDictionary.Contains(Format(ImageCounter)) then
                    MediaDictionary.Add(Format(ImageCounter), Format(ImageCounter) + '.' + CurrExtension);
                if not Base64Dictionary.Contains(Format(ImageCounter)) then
                    Base64Dictionary.Add(Format(ImageCounter), CurrBase64);
                ImageCounter += 1;
            until DisplayContentLines.Next() = 0;
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
        DisplayContentLines: Record "NPR Display Content Lines";
        VideoCounter: Integer;
        ContentIfStmtLbl: Label '      if (video_count == %1) video_count = 1;', Locked = true;
    begin
        DisplayContentLines.SetRange("Content Code", ContentCode);
        if DisplayContentLines.FindSet() then begin
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
                MediaDictionary.Add(Format(VideoCounter), DisplayContentLines.Url);
                VideoCounter += 1;
            until DisplayContentLines.Next() = 0;
            ContentHtml += '  </video>';
            ContentHtml += '  <script>';
            ContentHtml += '    video_count = 1;';
            ContentHtml += '    var videoPlayer = document.getElementById("fullscreenVideo");';
            ContentHtml += '    function run() {';
            ContentHtml += '      video_count++;';
            ContentHtml += StrSubstNo(
                           ContentIfStmtLbl, VideoCounter);
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

    local procedure GetImageContentAndExtension(DisplayContentLines: Record "NPR Display Content Lines"; var Base64: Text; var Extension: Text[10])
    var
        InS: InStream;
        OutS: OutStream;
        base64Convert: Codeunit "Base64 Convert";
        blobber: Codeunit "Temp Blob";
        filenameindex: Integer;
        med: Record "Tenant Media";

    begin
        if DisplayContentLines.Picture.HasValue() then begin
            blobber.CreateOutStream(OutS);
            DisplayContentLines.Picture.ExportStream(OutS);
            blobber.CreateInStream(InS);
            Base64 := base64Convert.ToBase64(InS);
            if (med.Get(DisplayContentLines.Picture.MediaId())) then begin
                filenameindex := med.Description.LastIndexOf('.') + 1;
                Extension := med.Description.Substring(filenameindex);
            end;

        end;
    end;

    local procedure CustomerDisplayIsActivated(POSUnit: Record "NPR POS Unit"; var MatrixIsActivated: Boolean; var DisplayIsActivated: Boolean)
    begin
        MatrixIsActivated := false;
        if not MatrixIsActivated then
            if DisplaySetup.Get(POSUnit."No.") then begin
                DisplayIsActivated := DisplaySetup.Activate;
                HideReceiptIsActivated := DisplaySetup."Hide receipt";
            end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'UpdateDisplayOnSaleLineInsert':
                begin
                    Rec.Description := Text000;
                    Rec."Sequence No." := 10;
                end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Proxy - Display");
    end;
}

