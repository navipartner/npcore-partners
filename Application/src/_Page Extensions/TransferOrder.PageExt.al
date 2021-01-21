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
				PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Print action';
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Price Label action';
            }
        }
        addfirst("F&unctions")
        {
            action("NPR Import From Scanner File")
            {
                Caption = 'Import From Scanner File';
                Image = Import;
                Promoted = true;
				PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import From Scanner File action';
            }
        }
        addafter("Get Bin Content")
        {
            action("NPR &Read from scanner")
            {
                Caption = '&Read from scanner';
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the &Read from scanner action';
                Image = Add; 
            }
        }
        addafter(PostAndPrint)
        {
            action("NPR PostAndPrint")
            {
                Caption = 'POS Post and &Print';
                Image = PostPrint;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F9';
                Visible = PostingVisibilityPOS;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Post and &Print action';

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

