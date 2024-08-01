pageextension 6014451 "NPR Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter("Job Queue Status")
        {
            field("NPR PostingDescription"; Rec."Posting Description")
            {
                ToolTip = 'Specifies a posting description to appear on the resulting journal lines.';
                ApplicationArea = NPRRetail;
                Caption = 'Posting Description';
            }
        }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        modify("Vendor Invoice No.")
        {
            Editable = IsDocumentRSEInvoice;
        }
        addlast(content)
        {
            group("NPR RS E-Invoicing")
            {
                Caption = 'RS E-Invoicing';

                field("NPR RS E-Invoice"; RSEIAuxPurchHeader."NPR RS E-Invoice")
                {
                    Caption = 'RS E-Invoice';
                    ToolTip = 'Specifies the value of the RS E-Invoice field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Tax Liability Method"; RSEIAuxPurchHeader."NPR RS EI Tax Liability Method")
                {
                    Caption = 'RS EI Tax Liability Method';
                    ToolTip = 'Specifies the value of the RS EI Tax Liability Method field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sales Invoice Id"; RSEIAuxPurchHeader."NPR RS EI Sales Invoice ID")
                {
                    Caption = 'RS EI Sales Invoice ID';
                    ToolTip = 'Specifies the value of the RS EI Sales Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
                    begin
                        RSEInvoiceDocument.SetRange("Sales Invoice ID", RSEIAuxPurchHeader."NPR RS EI Sales Invoice ID");
                        Page.Run(Page::"NPR RS E-Invoice Documents", RSEInvoiceDocument);
                    end;
                }
                field("NPR RS EI Purchase Invoice Id"; RSEIAuxPurchHeader."NPR RS EI Purchase Invoice ID")
                {
                    Caption = 'RS EI Purchase Invoice ID';
                    ToolTip = 'Specifies the value of the RS EI Purchase Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
                    begin
                        RSEInvoiceDocument.SetRange("Purchase Invoice ID", RSEIAuxPurchHeader."NPR RS EI Purchase Invoice ID");
                        Page.Run(Page::"NPR RS E-Invoice Documents", RSEInvoiceDocument);
                    end;
                }
                field("NPR RS EI Invoice Status"; RSEIAuxPurchHeader."NPR RS EI Invoice Status")
                {
                    Caption = 'RS EI Invoice Status';
                    ToolTip = 'Specifies the value of the RS EI Invoice Status field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Invoice Type Code"; RSEIAuxPurchHeader."NPR RS E-Invoice Type Code")
                {
                    Caption = 'RS EI Invoice Type Code';
                    ToolTip = 'Specifies the value of the RS EI Invoice Type Code field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Total Amount"; RSEIAuxPurchHeader."NPR RS EI Total Amount")
                {
                    Caption = 'RS EI Total Amount';
                    ToolTip = 'Specifies the value of the RS EI Total Amount field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Creation Date"; RSEIAuxPurchHeader."NPR RS EI Creation Date")
                {
                    Caption = 'RS EI Creation Date';
                    ToolTip = 'Specifies the value of the RS EI Creation Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sending Date"; RSEIAuxPurchHeader."NPR RS EI Sending Date")
                {
                    Caption = 'RS EI Sending Date';
                    ToolTip = 'Specifies the value of the RS EI Sending Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Model"; RSEIAuxPurchHeader."NPR RS EI Model")
                {
                    Caption = 'RS EI Model';
                    ToolTip = 'Specifies the value of the RS EI Model field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Reference Number"; RSEIAuxPurchHeader."NPR RS EI Reference Number")
                {
                    Caption = 'RS EI Reference Number';
                    ToolTip = 'Specifies the value of the RS EI Reference Number field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
            }
        }
#endif
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

                ToolTip = 'Enables selection of the item number only, having a Vendor Item specified on the item.';
                ApplicationArea = NPRRetail;

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
                        ViewText := RetailItemList.NPR_GetViewText();
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

                ToolTip = 'Start importing the file from the scanner.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    InventorySetup: Record "Inventory Setup";
                    ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
                    RecRef: RecordRef;
                begin
                    if not InventorySetup.Get() then
                        exit;

                    RecRef.GetTable(Rec);
                    ScannerImportMgt.ImportFromScanner(InventorySetup."NPR Scanner Provider", Enum::"NPR Scanner Import"::PURCHASE, RecRef);
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

                ToolTip = 'Displays the Retail Journal Print page where different labels can be printed.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LabelManagement: Codeunit "NPR Label Management";
                begin
                    LabelManagement.ChooseLabel(Rec);
                end;
            }
        }
    }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    trigger OnAfterGetRecord()
    begin
        RSEIAuxPurchHeader.ReadRSEIAuxPurchHeaderFields(Rec);
        IsDocumentRSEInvoice := not (RSEIAuxPurchHeader."NPR RS E-Invoice");
    end;

    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
        IsDocumentRSEInvoice: Boolean;
#endif
}