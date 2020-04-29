page 6150666 "NPRE Tmp POS Waiter Pad Lines"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Add lines to ticket';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "NPRE Waiter Pad Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6014408)
            {
                ShowCaption = false;
                field(Marked;Marked)
                {
                }
                field("Waiter Pad No.";"Waiter Pad No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Line No.";"Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Type;Type)
                {
                    Editable = false;
                    Visible = false;
                }
                field("No.";"No.")
                {
                    Editable = false;
                    StyleExpr = StyleTxt;
                    Visible = false;
                }
                field(Description;Description)
                {
                    Editable = false;
                    StyleExpr = StyleTxt;
                }
                field(Quantity;Quantity)
                {
                    StyleExpr = StyleTxt;
                }
                field("Marked Qty";"Marked Qty")
                {
                    StyleExpr = StyleTxt;
                }
                field("Variant Code";"Variant Code")
                {
                    StyleExpr = StyleTxt;
                    Visible = false;
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
          if ( (Quantity <> 1) and (Quantity > 0) ) then begin
            if not WaiterPadPOSManagement.GetQtyUI(Quantity, Description, ChosenQty) then begin
              Marked := false;
              StyleTxt := '';
              exit;
            end;
            if ChosenQty = 0 then Error(ERRQTYZERO);
            if ChosenQty > Quantity then Error(ERRQTYTOHIGH, Quantity);
            "Marked Qty" := ChosenQty;
          end else begin
            "Marked Qty" := Quantity;
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
        WaiterPadPOSManagement: Codeunit "NPRE Waiter Pad POS Management";
        ERRQTYZERO: Label 'Quantity must be zero or higher.';
        ERRQTYTOHIGH: Label 'Quantity can not be more than %1.';

    local procedure ActionOKLine()
    begin
        OKLines := true;
        CurrPage.Close;
    end;

    procedure fnSetLines(var TMPWaiterPadLine: Record "NPRE Waiter Pad Line" temporary)
    begin
        Rec.DeleteAll;

        TMPWaiterPadLine.FindSet;

        repeat
          Rec.Init;
          Rec.TransferFields(TMPWaiterPadLine);
          Rec.Insert;
        until (0 = TMPWaiterPadLine.Next);
    end;

    procedure fnGetLines(var TMPWaiterPadLine: Record "NPRE Waiter Pad Line" temporary)
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

