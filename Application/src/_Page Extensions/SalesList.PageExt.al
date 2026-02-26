pageextension 6014445 "NPR Sales List" extends "Sales List"
{
    layout
    {
        modify("Assigned User ID")
        {
            Visible = false;
        }
        addafter("Document Date")
        {
            field("NPR Amount"; Rec.Amount)
            {

                Visible = false;
                ToolTip = 'Specifies the total amount on the sales invoice excluding VAT.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Amount Including VAT"; Rec."Amount Including VAT")
            {

                ToolTip = 'Specifies the total amount on the sales invoice including VAT.';
                ApplicationArea = NPRRetail;
            }
            field("NPR PrepmtAmtInclVAT"; PrepmtAmtInclVAT)
            {

                AutoFormatExpression = Rec."Currency Code";
                AutoFormatType = 1;
                Caption = 'Invoiced Prepmt. Amt. Incl. VAT';
                ToolTip = 'Specifies the total prepayment amount that has been invoiced including VAT.';
                ApplicationArea = NPRRetail;

                trigger OnDrillDown()
                begin
                    if Rec."Document Type" = Rec."Document Type"::Order then begin
                        TempPostedPrepmtDocumentBuffer.Generate(Rec.RecordId, true);
                        TempPostedPrepmtDocumentBuffer.ShowPostedDocumentList(Rec.RecordId);
                    end;
                end;
            }
            field("NPR RemainingAmtInclVAT"; RemainingAmtInclVAT)
            {

                AutoFormatExpression = Rec."Currency Code";
                AutoFormatType = 1;
                Caption = 'Remaining Amount Incl. VAT';
                Editable = false;
                ToolTip = 'Specifies the value of the Open / Due Amount. field including VAT.';
                ApplicationArea = NPRRetail;
            }

            field("NPR Group Code"; Rec."NPR Group Code")
            {
                Caption = 'Group Code';
                Editable = false;
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
        }
    }

    var
        TempPostedPrepmtDocumentBuffer: Record "NPR Posted Doc. Buffer" temporary;
        PrepmtAmtCache: Dictionary of [Code[20], Decimal];
        PrepmtAmtInclVAT: Decimal;
        RemainingAmtInclVAT: Decimal;

    trigger OnAfterGetRecord()
    begin
        PrepmtAmtInclVAT := 0;
        if (Rec."Document Type" = Rec."Document Type"::Order) and PrepmtAmtCache.ContainsKey(Rec."No.") then
            PrepmtAmtInclVAT := PrepmtAmtCache.Get(Rec."No.");
        RemainingAmtInclVAT := Rec."Amount Including VAT" - PrepmtAmtInclVAT;
    end;

    trigger OnOpenPage()
    begin
        Rec.CopySellToCustomerFilter();

        TempPostedPrepmtDocumentBuffer.Reset();
        TempPostedPrepmtDocumentBuffer.DeleteAll();

        LoadPrepaymentAmounts();
    end;

    local procedure LoadPrepaymentAmounts()
    var
        PrepmtInvQuery: Query "NPR Prepmt. Inv. Amt. Query";
        PrepmtCrMemoQuery: Query "NPR Prepmt. CrM. Amt. Query";
        CurrentAmt: Decimal;
    begin
        Clear(PrepmtAmtCache);

        PrepmtInvQuery.Open();
        while PrepmtInvQuery.Read() do
            PrepmtAmtCache.Set(PrepmtInvQuery.PrepmtOrderNo, PrepmtInvQuery.AmtInclVAT);
        PrepmtInvQuery.Close();

        PrepmtCrMemoQuery.Open();
        while PrepmtCrMemoQuery.Read() do begin
            CurrentAmt := 0;
            if PrepmtAmtCache.ContainsKey(PrepmtCrMemoQuery.PrepmtOrderNo) then
                CurrentAmt := PrepmtAmtCache.Get(PrepmtCrMemoQuery.PrepmtOrderNo);
            PrepmtAmtCache.Set(PrepmtCrMemoQuery.PrepmtOrderNo, CurrentAmt - PrepmtCrMemoQuery.AmtInclVAT);
        end;
        PrepmtCrMemoQuery.Close();
    end;

}