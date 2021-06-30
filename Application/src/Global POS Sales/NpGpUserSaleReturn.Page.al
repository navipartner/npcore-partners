page 6151174 "NPR NpGp User Sale Return"
{
    Caption = 'Choose return quantities';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpGp POS Sales Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control6014408)
            {
                ShowCaption = false;
                field("Original Company Name"; TempNpGpPOSSalesEntry."Original Company")
                {
                    ApplicationArea = All;
                    Caption = 'Original Company Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original Company Name field';
                }
                field("POS Store Code"; TempNpGpPOSSalesEntry."POS Store Code")
                {
                    ApplicationArea = All;
                    Caption = 'POS Store Code';
                    Editable = false;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Unit No."; TempNpGpPOSSalesEntry."POS Unit No.")
                {
                    ApplicationArea = All;
                    Caption = 'POS Unit No.';
                    Editable = false;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Document No."; TempNpGpPOSSalesEntry."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Posting Date"; TempNpGpPOSSalesEntry."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = ' Posting Date';
                    Editable = false;
                    ToolTip = 'Specifies the value of the  Posting Date field';
                }
            }
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(OriginalQuantity; OriginalQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Original Quantity';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original Quantity field';
                }
                field(QuantityReturned; QuantityReturned)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Already Returned';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity Already Returned field';
                }
                field(QuantityToReturn; QuantityToReturn)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity to Return';
                    Importance = Promoted;
                    MinValue = 0;
                    ToolTip = 'Specifies the value of the Quantity to Return field';

                    trigger OnValidate()
                    begin
                        if QuantityToReturn > OriginalQuantity - QuantityReturned then
                            QuantityToReturn := OriginalQuantity - QuantityReturned;

                        Rec.Quantity := -QuantityToReturn;
                    end;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        POSCrossReference: Record "NPR POS Cross Reference";
    begin
        if GetLastErrorCode > '' then begin
            Rec.ClearMarks();
            ClearLastError();
        end;

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");

        POSCrossReference.SetRange("Reference No.", Rec."Global Reference");
        if POSCrossReference.FindSet() then
            repeat
                SaleLinePOS.SetRange(SystemId, POSCrossReference.SystemId);
                SaleLinePOS.SetFilter(Quantity, '<0');
                if SaleLinePOS.FindFirst() and not SaleLinePOS.Mark() then begin
                    Rec.Quantity += SaleLinePOS.Quantity;
                    SaleLinePOS.Mark(true);
                end;
            until POSCrossReference.Next() = 0;

        if not Rec.Mark() then begin
            OriginalQuantity := Rec."Quantity (Base)" / Rec."Qty. per Unit of Measure";
            QuantityReturned := OriginalQuantity - Rec.Quantity;
            Rec.Mark(true);
        end;

        QuantityToReturn := Abs(Rec.Quantity);
        Rec.Quantity := -Abs(Rec.Quantity);
        Rec.Modify();
    end;

    trigger OnOpenPage()
    begin
        ClearLastError();
    end;

    var
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        OriginalQuantity: Integer;
        QuantityReturned: Integer;
        QuantityToReturn: Integer;

    procedure SetTables(pSalePOS: Record "NPR POS Sale"; var pTempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var pTempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary)
    begin
        TempNpGpPOSSalesEntry := pTempNpGpPOSSalesEntry;
        SalePOS := pSalePOS;

        if not pTempNpGpPOSSalesLine.IsEmpty then
            repeat
                Rec := pTempNpGpPOSSalesLine;
                Rec.Insert();
            until pTempNpGpPOSSalesLine.Next() = 0;

        Rec.FindSet();
    end;

    procedure GetLines(var pTempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary)
    begin
        pTempNpGpPOSSalesLine.Copy(Rec, true);
        pTempNpGpPOSSalesLine.FindSet();
    end;
}

