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
            field("NPR Amount"; Amount)
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("NPR Amount Including VAT"; "Amount Including VAT")
            {
                ApplicationArea = All;
            }
            field("NPR PrepmtAmtInclVAT"; PrepmtAmtInclVAT)
            {
                ApplicationArea = All;
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
                Caption = 'Invoiced Prepmt. Amt. Incl. VAT';

                trigger OnDrillDown()
                begin
                    //-NPR5.53 [360297]
                    if "Document Type" = "Document Type"::Order then
                        PostedPrepmtDocumentBuffer.ShowPostedDocumentList(RecordId);
                    //+NPR5.53 [360297]
                end;
            }
            field("NPR RemainingAmtInclVAT"; RemainingAmtInclVAT)
            {
                ApplicationArea = All;
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
                Caption = 'Remaining Amount Incl. VAT';
                Editable = false;
            }
        }
    }

    var
        PostedPrepmtDocumentBuffer: Record "NPR Posted Doc. Buffer" temporary;
        PrepmtAmtInclVAT: Decimal;
        RemainingAmtInclVAT: Decimal;


    trigger OnAfterGetRecord()
    begin
        if "Document Type" = "Document Type"::Order then begin
            PostedPrepmtDocumentBuffer.Generate(RecordId, true);
            PrepmtAmtInclVAT := PostedPrepmtDocumentBuffer.TotalAmtInclVAT(RecordId);
        end else
            PrepmtAmtInclVAT := 0;
        RemainingAmtInclVAT := "Amount Including VAT" - PrepmtAmtInclVAT;
    end;


    trigger OnOpenPage()
    begin
        CopySellToCustomerFilter;

        PostedPrepmtDocumentBuffer.Reset;
        PostedPrepmtDocumentBuffer.DeleteAll;
    end;
}

