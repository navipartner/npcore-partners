page 6150666 "NPR NPRE Tmp POSWaiterPadLines"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Add lines to ticket';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR NPRE Waiter Pad Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6014408)
            {
                ShowCaption = false;
                field(Marked; Marked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Marked field';
                }
                field("Waiter Pad No."; "Waiter Pad No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quanity; RemainingQtyToBill)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Marked Qty"; "Marked Qty")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Qty. to ticket field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Line Actions")
            {
                action(AOKLines)
                {
                    Caption = 'OK';
                    Image = Add;
                    InFooterBar = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the OK action';

                    trigger OnAction()
                    begin
                        ActionOKLine;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        ChosenQty: Decimal;
    begin

        if FirstOpen then begin
            FirstOpen := false;
            Marked := false;
        end else begin
            Marked := not Marked;
            //-NPR5.55 [399170]-revoked
            //IF ( (Quantity <> 1) AND (Quantity > 0) ) THEN BEGIN
            //  IF NOT WaiterPadPOSManagement.GetQtyUI(Quantity, Description, ChosenQty) THEN BEGIN
            //+NPR5.55 [399170]-revoked
            //-NPR5.55 [399170]
            if RemainingQtyToBill() > 1 then begin
                if not WaiterPadPOSManagement.GetQtyUI(RemainingQtyToBill(), Description, ChosenQty) then begin
                    //+NPR5.55 [399170]
                    Marked := false;
                    StyleTxt := '';
                    exit;
                end;
                if ChosenQty = 0 then Error(ERRQTYZERO);
                //IF ChosenQty > Quantity THEN ERROR(ERRQTYTOHIGH, Quantity);  //NPR5.55 [399170]-revoked
                if ChosenQty > RemainingQtyToBill() then Error(ERRQTYTOHIGH, RemainingQtyToBill());  //NPR5.55 [399170]
                "Marked Qty" := ChosenQty;
            end else begin
                //"Marked Qty" := Quantity;  //NPR5.55 [399170]-revoked
                "Marked Qty" := RemainingQtyToBill();  //NPR5.55 [399170]
            end;
        end;

        if not Marked then "Marked Qty" := 0;

        Modify;

        StyleTxt := GetStyle;
    end;

    trigger OnOpenPage()
    begin
        OKLines := false;
        FirstOpen := true;
        FindFirst;
    end;

    var
        OKLines: Boolean;
        StyleTxt: Text;
        FirstOpen: Boolean;
        WaiterPadPOSManagement: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ERRQTYZERO: Label 'Quantity must be zero or higher.';
        ERRQTYTOHIGH: Label 'Quantity can not be more than %1.';

    local procedure ActionOKLine()
    begin
        OKLines := true;
        CurrPage.Close;
    end;

    procedure fnSetLines(var TMPWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary)
    begin
        Copy(TMPWaiterPadLine, true);
        //-NPR5.55 [399170]-revoked
        /*
        Rec.DELETEALL;
        TMPWaiterPadLine.FINDSET;
        
        REPEAT
          Rec.INIT;
          Rec.TRANSFERFIELDS(TMPWaiterPadLine);
          Rec.INSERT;
        UNTIL (0 = TMPWaiterPadLine.NEXT);
        */
        //+NPR5.55 [399170]-revoked

    end;

    procedure fnGetLines(var TMPWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary)
    begin
        TMPWaiterPadLine.DeleteAll;

        Rec.FindFirst;

        repeat
            TMPWaiterPadLine.Init;
            TMPWaiterPadLine.TransferFields(Rec);
            TMPWaiterPadLine.Insert;
        until (0 = Rec.Next);
    end;

    procedure isOKLines(): Boolean
    begin
        exit(OKLines);
    end;

    local procedure GetStyle(): Text
    begin
        if Marked then begin
            exit('Attention');
        end else begin
            exit('');
        end;
    end;
}

