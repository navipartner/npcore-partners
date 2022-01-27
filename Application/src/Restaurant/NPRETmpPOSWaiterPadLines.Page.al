page 6150666 "NPR NPRE Tmp POSWaiterPadLines"
{
    Extensible = False;
    Caption = 'Add lines to ticket';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR NPRE Waiter Pad Line";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6014408)
            {
                ShowCaption = false;
                field(Marked; Rec.Marked)
                {

                    ToolTip = 'Specifies the value of the Marked field';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    Editable = false;
                    StyleExpr = StyleTxt;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Quanity; Rec.RemainingQtyToBill())
                {

                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Marked Qty"; Rec."Marked Qty")
                {

                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Qty. to ticket field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    StyleExpr = StyleTxt;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the OK action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ActionOKLine();
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
            Rec.Marked := false;
        end else begin
            Rec.Marked := not Rec.Marked;
            if Rec.RemainingQtyToBill() > 1 then begin
                if not WaiterPadPOSManagement.GetQtyUI(Rec.RemainingQtyToBill(), Rec.Description, ChosenQty) then begin
                    Rec.Marked := false;
                    StyleTxt := '';
                    exit;
                end;
                if ChosenQty = 0 then Error(ERRQTYZERO);
                if ChosenQty > Rec.RemainingQtyToBill() then Error(ERRQTYTOHIGH, Rec.RemainingQtyToBill());
                Rec."Marked Qty" := ChosenQty;
            end else begin
                Rec."Marked Qty" := Rec.RemainingQtyToBill();
            end;
        end;

        if not Rec.Marked then Rec."Marked Qty" := 0;

        Rec.Modify();

        StyleTxt := GetStyle();
    end;

    trigger OnOpenPage()
    begin
        OKLines := false;
        FirstOpen := true;
        Rec.FindFirst();
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
        CurrPage.Close();
    end;

    procedure fnSetLines(var TMPWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary)
    begin
        Rec.Copy(TMPWaiterPadLine, true);
    end;

    procedure fnGetLines(var TMPWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary)
    begin
        TMPWaiterPadLine.DeleteAll();

        Rec.FindFirst();

        repeat
            TMPWaiterPadLine.Init();
            TMPWaiterPadLine.TransferFields(Rec);
            TMPWaiterPadLine.Insert();
        until (0 = Rec.Next());
    end;

    procedure isOKLines(): Boolean
    begin
        exit(OKLines);
    end;

    local procedure GetStyle(): Text
    begin
        if Rec.Marked then begin
            exit('Attention');
        end else begin
            exit('');
        end;
    end;
}
