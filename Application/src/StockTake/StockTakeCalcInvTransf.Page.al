page 6014669 "NPR StockTake Calc.Inv.Transf."
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created
    // NPR5.29/TJ/20170123 CASE 263879 Changed dimension selection to use new report 6014663

    Caption = 'Stock-Take Calc. Inv. Transfer';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Stock-Take Worksheet";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Stock-Take Config Code"; "Stock-Take Config Code")
                {
                    ApplicationArea = All;
                }
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                }
                field("Conf Calc. Date"; "Conf Calc. Date")
                {
                    ApplicationArea = All;
                }
                field(TransferAction; TransferAction)
                {
                    ApplicationArea = All;
                    Caption = 'Transfer Action';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        PhysInvJournal: Record "NPR Stock-Take Configuration";
    begin

        PostingDate := PhysInvJournal."Inventory Calc. Date";
        //-NPR5.29 [263879]
        //ColumnDim := DimSelectionBuf.GetDimSelectionText(3,REPORT::"Calculate Inventory",'');
        ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"NPR Retail Calc. Inv.", '');
        //+NPR5.29 [263879]
        TransferAction := PhysInvJournal."Transfer Action";
    end;

    var
        ColumnDim: Text[200];
        DimSelectionBuf: Record "Dimension Selection Buffer";
        TransferAction: Option TRANSFER,TRANSFER_POST,TRANSFER_POST_PRINT;
        PostingDate: Date;
        PreviewAutoAdjustments: Boolean;

    procedure GetUserTransferAction() rTransferAction: Integer
    begin
        exit(TransferAction);
    end;

    procedure GetPostingDate() rPostingDate: Date
    begin
        exit(PostingDate);
    end;
}

