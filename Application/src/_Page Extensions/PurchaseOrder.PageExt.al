pageextension 6014451 "NPR Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter("Job Queue Status")
        {
            field("NPR PostingDescription"; Rec."Posting Description")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Posting Description field';
            }
        }

    }
    actions
    {
        addafter(MoveNegativeLines)
        {
            action("NPR InsertLineVendorItem")
            {
                Caption = 'Insert Line with Vendor Item';
                Image = CoupledOrderList;
                ShortCutKey = 'Ctrl+I';
                ApplicationArea = All;
                ToolTip = 'Executes the Insert Line with Vendor Item action';

                trigger OnAction()
                var
                    Item: Record Item;
                    PurchaseLine: Record "Purchase Line";
                    LastPurchaseLine: Record "Purchase Line";
                    RetailItemList: Page "Item List";
                    InputDialog: Page "NPR Input Dialog";
                    ViewText: Text;
                    InputQuantity: Decimal;
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField("Buy-from Vendor No.");
                    RetailItemList.NPR_SetLocationCode(Rec."Location Code");
                    RetailItemList.NPR_SetVendorNo(Rec."Buy-from Vendor No.");
                    RetailItemList.LookupMode := true;
                    while RetailItemList.RunModal() = ACTION::LookupOK do begin
                        RetailItemList.GetRecord(Item);
                        InputQuantity := 1;
                        InputDialog.SetAutoCloseOnValidate(true);
                        InputDialog.SetInput(1, InputQuantity, PurchaseLine.FieldCaption(Quantity));
                        InputDialog.RunModal();
                        InputDialog.InputDecimal(1, InputQuantity);
                        Clear(InputDialog);

                        LastPurchaseLine.Reset();
                        LastPurchaseLine.SetRange("Document Type", Rec."Document Type");
                        LastPurchaseLine.SetRange("Document No.", Rec."No.");
                        if not LastPurchaseLine.FindLast() then
                            LastPurchaseLine.Init();

                        PurchaseLine.Init();
                        PurchaseLine.Validate("Document Type", Rec."Document Type");
                        PurchaseLine.Validate("Document No.", Rec."No.");
                        PurchaseLine.Validate("Line No.", LastPurchaseLine."Line No." + 10000);
                        PurchaseLine.Insert(true);
                        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
                        PurchaseLine.Validate("No.", Item."No.");
                        PurchaseLine.Validate(Quantity, InputQuantity);
                        PurchaseLine.Modify(true);
                        Commit();
                        ViewText := RetailItemList.NPR_GetViewText;
                        Clear(RetailItemList);
                        RetailItemList.NPR_SetLocationCode(Rec."Location Code");
                        RetailItemList.NPR_SetVendorNo(Rec."Buy-from Vendor No.");
                        Item.SetView(ViewText);
                        RetailItemList.SetTableView(Item);
                        RetailItemList.SetRecord(Item);
                        RetailItemList.LookupMode := true;
                    end;
                end;
            }
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import from scanner action';

                trigger OnAction()
                var
                    ImportfromScannerFilePO: XMLport "NPR Import from ScannerFilePO";
                begin
                    ImportfromScannerFilePO.SelectTable(Rec);
                    ImportfromScannerFilePO.SetTableView(Rec);
                    ImportfromScannerFilePO.Run();
                end;
            }
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
                ShortCutKey = 'Shift+Ctrl+L';
                ApplicationArea = All;
                ToolTip = 'Executes the Price Label action';
            }
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send as PDF action';
                }
            }
        }
    }
}