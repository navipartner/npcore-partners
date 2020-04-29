pageextension 6014441 pageextension6014441 extends "Sales List" 
{
    // NPR5.53/ALPO/20191010 CASE 360297 Prepayment/layaway functionality additions
    //                                     Control "Assigned User ID": property 'Visible' set to false
    //                                     Added controls: Amount, "Amount Including VAT", PrepmtAmtInclVAT, RemainingAmtInclVAT
    layout
    {
        modify("Assigned User ID")
        {
            Visible = false;
        }
        addafter("Document Date")
        {
            field(Amount;Amount)
            {
                Visible = false;
            }
            field("Amount Including VAT";"Amount Including VAT")
            {
            }
            field(PrepmtAmtInclVAT;PrepmtAmtInclVAT)
            {
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
            field(RemainingAmtInclVAT;RemainingAmtInclVAT)
            {
                AutoFormatExpression = "Currency Code";
                AutoFormatType = 1;
                Caption = 'Remaining Amount Incl. VAT';
                Editable = false;
            }
        }
    }

    var
        PostedPrepmtDocumentBuffer: Record "Posted Document Buffer" temporary;
        PrepmtAmtInclVAT: Decimal;
        RemainingAmtInclVAT: Decimal;


    //Unsupported feature: Code Insertion on "OnAfterGetRecord".

    //trigger OnAfterGetRecord()
    //begin
        /*
        //-NPR5.53 [360297]
        if "Document Type" = "Document Type"::Order then begin
          PostedPrepmtDocumentBuffer.Generate(RecordId,true);
          PrepmtAmtInclVAT := PostedPrepmtDocumentBuffer.TotalAmtInclVAT(RecordId);
        end else
          PrepmtAmtInclVAT := 0;
        RemainingAmtInclVAT := "Amount Including VAT" - PrepmtAmtInclVAT;
        //+NPR5.53 [360297]
        */
    //end;


    //Unsupported feature: Code Modification on "OnOpenPage".

    //trigger OnOpenPage()
    //>>>> ORIGINAL CODE:
    //begin
        /*
        CopySellToCustomerFilter;
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        CopySellToCustomerFilter;
        //-NPR5.53 [360297]
        PostedPrepmtDocumentBuffer.Reset;
        PostedPrepmtDocumentBuffer.DeleteAll;
        //+NPR5.53 [360297]
        */
    //end;
}

