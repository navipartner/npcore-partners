page 6151174 "NpGp User Sale Return"
{
    // NPR5.51/ALST/20190422 CASE 337539 New object

    Caption = 'Choose return quantities';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = StandardDialog;
    SourceTable = "NpGp POS Sales Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control6014408)
            {
                ShowCaption = false;
                field("TempNpGpPOSSalesEntry.""Original Company"""; TempNpGpPOSSalesEntry."Original Company")
                {
                    ApplicationArea = All;
                    Caption = 'Original Company Name';
                    Editable = false;
                }
                field("TempNpGpPOSSalesEntry.""POS Store Code"""; TempNpGpPOSSalesEntry."POS Store Code")
                {
                    ApplicationArea = All;
                    Caption = 'POS Store Code';
                    Editable = false;
                }
                field("TempNpGpPOSSalesEntry.""POS Unit No."""; TempNpGpPOSSalesEntry."POS Unit No.")
                {
                    ApplicationArea = All;
                    Caption = 'POS Unit No.';
                    Editable = false;
                }
                field("TempNpGpPOSSalesEntry.""Document No."""; TempNpGpPOSSalesEntry."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    Editable = false;
                }
                field("TempNpGpPOSSalesEntry.""Posting Date"""; TempNpGpPOSSalesEntry."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = ' Posting Date';
                    Editable = false;
                }
            }
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(OriginalQuantity; OriginalQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Original Quantity';
                    Editable = false;
                }
                field(QuantityReturned; QuantityReturned)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Already Returned';
                    Editable = false;
                }
                field(QuantityToReturn; QuantityToReturn)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity to Return';
                    Importance = Promoted;
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        if QuantityToReturn > OriginalQuantity - QuantityReturned then
                            QuantityToReturn := OriginalQuantity - QuantityReturned;

                        Quantity := -QuantityToReturn;
                    end;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        RetailCrossReference: Record "Retail Cross Reference";
        HasReference: Boolean;
    begin
        if GetLastErrorCode > '' then begin
            ClearMarks;
            ClearLastError;
        end;

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");

        RetailCrossReference.SetRange("Reference No.", "Global Reference");
        if RetailCrossReference.FindSet then
            repeat
                SaleLinePOS.SetRange("Retail ID", RetailCrossReference."Retail ID");
                SaleLinePOS.SetFilter(Quantity, '<0');
                if SaleLinePOS.FindFirst and not SaleLinePOS.Mark then begin
                    Quantity += SaleLinePOS.Quantity;
                    SaleLinePOS.Mark(true);
                end;
            until RetailCrossReference.Next = 0;

        if not Mark then begin
            OriginalQuantity := "Quantity (Base)" / "Qty. per Unit of Measure";
            QuantityReturned := OriginalQuantity - Quantity;
            Mark(true);
        end;

        QuantityToReturn := Abs(Quantity);
        Quantity := -Abs(Quantity);
        Modify;
    end;

    trigger OnOpenPage()
    begin
        ClearLastError;
    end;

    var
        TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary;
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        OriginalQuantity: Integer;
        QuantityReturned: Integer;
        QuantityToReturn: Integer;

    procedure SetTables(pSalePOS: Record "Sale POS"; var pTempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary; var pTempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary)
    begin
        TempNpGpPOSSalesEntry := pTempNpGpPOSSalesEntry;
        SalePOS := pSalePOS;

        if not pTempNpGpPOSSalesLine.IsEmpty then
            repeat
                Rec := pTempNpGpPOSSalesLine;
                Insert;
            until pTempNpGpPOSSalesLine.Next = 0;

        FindSet;
    end;

    procedure GetLines(var pTempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary)
    begin
        pTempNpGpPOSSalesLine.Copy(Rec, true);
        pTempNpGpPOSSalesLine.FindSet;
    end;
}

