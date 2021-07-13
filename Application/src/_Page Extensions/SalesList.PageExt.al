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
                ToolTip = 'Specifies the value of the Amount field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Amount Including VAT"; Rec."Amount Including VAT")
            {

                ToolTip = 'Specifies the value of the Amount Including VAT field';
                ApplicationArea = NPRRetail;
            }
            field("NPR PrepmtAmtInclVAT"; PrepmtAmtInclVAT)
            {

                AutoFormatExpression = Rec."Currency Code";
                AutoFormatType = 1;
                Caption = 'Invoiced Prepmt. Amt. Incl. VAT';
                ToolTip = 'Specifies the value of the Invoiced Prepmt. Amt. Incl. VAT field';
                ApplicationArea = NPRRetail;

                trigger OnDrillDown()
                begin
                    if Rec."Document Type" = Rec."Document Type"::Order then
                        TempPostedPrepmtDocumentBuffer.ShowPostedDocumentList(Rec.RecordId);
                end;
            }
            field("NPR RemainingAmtInclVAT"; RemainingAmtInclVAT)
            {

                AutoFormatExpression = Rec."Currency Code";
                AutoFormatType = 1;
                Caption = 'Remaining Amount Incl. VAT';
                Editable = false;
                ToolTip = 'Specifies the value of the Remaining Amount Incl. VAT field';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        TempPostedPrepmtDocumentBuffer: Record "NPR Posted Doc. Buffer" temporary;
        PrepmtAmtInclVAT: Decimal;
        RemainingAmtInclVAT: Decimal;


    trigger OnAfterGetRecord()
    begin
        if Rec."Document Type" = Rec."Document Type"::Order then begin
            TempPostedPrepmtDocumentBuffer.Generate(Rec.RecordId, true);
            PrepmtAmtInclVAT := TempPostedPrepmtDocumentBuffer.TotalAmtInclVAT(Rec.RecordId);
        end else
            PrepmtAmtInclVAT := 0;
        RemainingAmtInclVAT := Rec."Amount Including VAT" - PrepmtAmtInclVAT;
    end;


    trigger OnOpenPage()
    begin
        Rec.CopySellToCustomerFilter();

        TempPostedPrepmtDocumentBuffer.Reset();
        TempPostedPrepmtDocumentBuffer.DeleteAll();
    end;
}