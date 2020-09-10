pageextension 6014462 "NPR Transfer Order" extends "Transfer Order"
{
    actions
    {
        modify(PostAndPrint)
        {
            Visible = PostingVisibility;
        }
        addafter("&Print")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
            }
        }
        addfirst("F&unctions")
        {
            action("NPR Import From Scanner File")
            {
                Caption = 'Import From Scanner File';
                Image = Import;
                Promoted = true;
                ApplicationArea = All;
            }
        }
        addafter("Get Bin Content")
        {
            action("NPR &Read from scanner")
            {
                Caption = '&Read from scanner';
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    CodeunitTransferOrderPP: Codeunit "NPR TransferOrder-Post + Print";
                begin
                    //-NPR5.55 [362312]
                    ReportSelectionRetail.Reset;
                    ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Transfer Order");
                    if ReportSelectionRetail.FindFirst then
                        TemplateN := ReportSelectionRetail."Print Template";
                    if TemplateN <> '' then begin
                        CodeunitTransferOrderPP.SetParameter(TemplateN, Rec);
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
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Codeunit6059823: Codeunit "NPR TransferOrder-Post + Print";
        Visiblitycheck: Boolean;


    trigger OnOpenPage()
    begin
        Visiblitycheck := Codeunit6059823.GetValues;
        if Visiblitycheck then begin
            PostingVisibility := false;
            PostingVisibilityPOS := true;
        end else begin
            PostingVisibility := true;
            PostingVisibilityPOS := false;
        end;
    end;
}

