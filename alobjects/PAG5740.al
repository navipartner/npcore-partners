pageextension 6014462 pageextension6014462 extends "Transfer Order" 
{
    // NPR4.04/TS/20150218 CASE 206013 Added Function Read from Scanner
    // NPR4.18/TS/20151109 CASE 222241 Added Action Import From Text
    // NPR5.22/TJ/20160414 CASE 238601 Moved code from funcions Read From Scanner and Import From Text to NPR Event Subscriber codeunit
    // NPR5.27/MMV /20161024 CASE 256178 Added support for retail prints.
    // NPR5.30/TJ  /20170202 CASE 262533 Removed actions Labels and Invert selection. Instead added actions Retail Print and Price Label
    // NPR5.55/YAHA/20200518 CASE 362312 Added Functionality to use template for printing
    actions
    {
        modify(PostAndPrint)
        {
            Visible = PostingVisibility;
        }
        addafter("&Print")
        {
            action(RetailPrint)
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
            }
            action(PriceLabel)
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
        }
        addfirst("F&unctions")
        {
            action("Import From Scanner File")
            {
                Caption = 'Import From Scanner File';
                Image = Import;
                Promoted = true;
            }
        }
        addafter("Get Bin Content")
        {
            action("&Read from scanner")
            {
                Caption = '&Read from scanner';
                Promoted = true;
                PromotedCategory = Process;
            }
        }
        addafter(PostAndPrint)
        {
            action("NPR PostAndPrint")
            {
                Caption = 'POS Post and &Print';
                Image = PostPrint;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F9';
                Visible = PostingVisibilityPOS;

                trigger OnAction()
                var
                    CodeunitTransferOrderPP: Codeunit "NPR TransferOrder-Post + Print";
                begin
                    //-NPR5.55 [362312]
                    ReportSelectionRetail.Reset;
                    ReportSelectionRetail.SetRange("Report Type",ReportSelectionRetail."Report Type"::"Transfer Order");
                    if ReportSelectionRetail.FindFirst then
                      TemplateN := ReportSelectionRetail."Print Template";
                    if TemplateN <> '' then begin
                      CodeunitTransferOrderPP.SetParameter(TemplateN,Rec);
                      CodeunitTransferOrderPP.Run(Rec);
                    end;
                    //+NPR5.55 [362312]
                end;
            }
        }
    }

    var
        TemplateN: Text;
        TransferHdr: Record "Transfer Header";
        PostingVisibility: Boolean;
        PostingVisibilityPOS: Boolean;
        ReportSelectionRetail: Record "Report Selection Retail";
        Codeunit6059823: Codeunit "NPR TransferOrder-Post + Print";
        Visiblitycheck: Boolean;


    //Unsupported feature: Code Modification on "OnOpenPage".

    //trigger OnOpenPage()
    //>>>> ORIGINAL CODE:
    //begin
        /*
        SetDocNoVisible;
        EnableTransferFields := not IsPartiallyShipped;
        ActivateFields;
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        #1..3

        //-NPR5.55 [362312]
        Visiblitycheck := Codeunit6059823.GetValues;
        if Visiblitycheck then begin
          PostingVisibility := false;
          PostingVisibilityPOS := true;
        end else begin
          PostingVisibility := true;
          PostingVisibilityPOS := false;
        end;
        //+NPR5.55 [362312]
        */
    //end;
}

