page 6151399 "CS RFID Header Card"
{
    // NPR5.55/CLVA  /20200506  CASE 379709 Object created - NP Capture Service

    Caption = 'CS RFID Header Card';
    DelayedInsert = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "CS Rfid Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Sell-to Customer No.";"Sell-to Customer No.")
                {
                }
                field("Sell-to Customer Name";"Sell-to Customer Name")
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
                field("Document Item Quantity";"Document Item Quantity")
                {
                }
                field(Closed;Closed)
                {
                }
                field("Document Matched";"Document Matched")
                {
                }
                field("Import Tags to Shipping Doc.";"Import Tags to Shipping Doc.")
                {
                }
            }
            group("Tag Info")
            {
                Caption = 'Tag Info';
                group("Tags Shipped")
                {
                    Caption = 'Tags Shipped';
                    field("Total Tags Shipped";"Total Tags Shipped")
                    {
                        Importance = Promoted;
                    }
                    field("Unknown Tags Shipped";"Unknown Tags Shipped")
                    {
                    }
                    field("Valid Tags Shipped";"Valid Tags Shipped")
                    {
                    }
                }
                group("Tags Received")
                {
                    Caption = 'Tags Received';
                    field("Total Tags Received";"Total Tags Received")
                    {
                    }
                    field("Unknown Tags Received";"Unknown Tags Received")
                    {
                        Importance = Promoted;
                    }
                    field("Valid Tags Received";"Valid Tags Received")
                    {
                    }
                }
                group(Total)
                {
                    Caption = 'Total';
                    field("Total Matched Tags";"Total Matched Tags")
                    {
                    }
                    field("Total Valid Matched Tags";"Total Valid Matched Tags")
                    {
                    }
                    field("Total Unknown Matched Tags";"Total Unknown Matched Tags")
                    {
                    }
                    field("Received not Shipped Tags";"Received not Shipped Tags")
                    {
                    }
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("To Document Type";"To Document Type")
                {
                }
                field("To Document No.";"To Document No.")
                {
                }
                field("Warehouse Receipt No.";"Warehouse Receipt No.")
                {
                }
            }
            group(Process)
            {
                Caption = 'Process';
                field("From Company";"From Company")
                {
                }
                field("Shipping Closed";"Shipping Closed")
                {
                }
                field("Shipping Closed By";"Shipping Closed By")
                {
                }
                field("To Company";"To Company")
                {
                }
                field("Receiving Closed";"Receiving Closed")
                {
                }
                field("Receiving Closed By";"Receiving Closed By")
                {
                }
            }
            part(Control6014414;"CS RFID Lines Subpage")
            {
                SubPageLink = Id=FIELD(Id);
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Batch)
            {
                Caption = 'Batch';
                Image = XMLFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "CS Transfer Handling Batch";
                RunPageLink = "Rfid Header Id"=FIELD(Id);
            }
            action("Delete Collected Tags")
            {
                Caption = 'Delete Collected Tags';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    DeleteRfidDocLines();
                end;
            }
            action("Import Lines")
            {
                Caption = 'Import Lines';
                Image = Status;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowCreateSalesLines;

                trigger OnAction()
                begin
                    InsertSalesLineStatus();
                end;
            }
            action("Create Sales Lines")
            {
                Caption = 'Create Sales Lines';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowCreateSalesLines;

                trigger OnAction()
                begin
                    CreateSalesLinesByRfidDocLines();
                end;
            }
            action("Warehouse Receipt")
            {
                Image = WarehouseRegisters;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    WarehouseReceiptHeader: Record "Warehouse Receipt Header";
                begin
                    if not WarehouseReceiptHeader.Get("Warehouse Receipt No.") then
                      exit;

                    PAGE.Run(PAGE::"Warehouse Receipt",WarehouseReceiptHeader);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ShowCreateSalesLines := (("Shipping Closed" <> 0DT) and ("Receiving Closed" = 0DT));
    end;

    var
        ShowCreateSalesLines: Boolean;
}

