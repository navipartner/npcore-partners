page 6151399 "NPR CS RFID Header Card"
{
    // NPR5.55/CLVA  /20200506  CASE 379709 Object created - NP Capture Service

    Caption = 'CS RFID Header Card';
    DelayedInsert = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "NPR CS Rfid Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field("Document Item Quantity"; "Document Item Quantity")
                {
                    ApplicationArea = All;
                }
                field(Closed; Closed)
                {
                    ApplicationArea = All;
                }
                field("Document Matched"; "Document Matched")
                {
                    ApplicationArea = All;
                }
                field("Import Tags to Shipping Doc."; "Import Tags to Shipping Doc.")
                {
                    ApplicationArea = All;
                }
            }
            group("Tag Info")
            {
                Caption = 'Tag Info';
                group("Tags Shipped")
                {
                    Caption = 'Tags Shipped';
                    field("Total Tags Shipped"; "Total Tags Shipped")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Unknown Tags Shipped"; "Unknown Tags Shipped")
                    {
                        ApplicationArea = All;
                    }
                    field("Valid Tags Shipped"; "Valid Tags Shipped")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Tags Received")
                {
                    Caption = 'Tags Received';
                    field("Total Tags Received"; "Total Tags Received")
                    {
                        ApplicationArea = All;
                    }
                    field("Unknown Tags Received"; "Unknown Tags Received")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Valid Tags Received"; "Valid Tags Received")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Total)
                {
                    Caption = 'Total';
                    field("Total Matched Tags"; "Total Matched Tags")
                    {
                        ApplicationArea = All;
                    }
                    field("Total Valid Matched Tags"; "Total Valid Matched Tags")
                    {
                        ApplicationArea = All;
                    }
                    field("Total Unknown Matched Tags"; "Total Unknown Matched Tags")
                    {
                        ApplicationArea = All;
                    }
                    field("Received not Shipped Tags"; "Received not Shipped Tags")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("To Document Type"; "To Document Type")
                {
                    ApplicationArea = All;
                }
                field("To Document No."; "To Document No.")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Receipt No."; "Warehouse Receipt No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Process)
            {
                Caption = 'Process';
                field("From Company"; "From Company")
                {
                    ApplicationArea = All;
                }
                field("Shipping Closed"; "Shipping Closed")
                {
                    ApplicationArea = All;
                }
                field("Shipping Closed By"; "Shipping Closed By")
                {
                    ApplicationArea = All;
                }
                field("To Company"; "To Company")
                {
                    ApplicationArea = All;
                }
                field("Receiving Closed"; "Receiving Closed")
                {
                    ApplicationArea = All;
                }
                field("Receiving Closed By"; "Receiving Closed By")
                {
                }
            }
            part(Control6014414; "NPR CS RFID Lines Subpage")
            {
                SubPageLink = Id = FIELD(Id);
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
                RunObject = Page "NPR CS Transfer Handling Batch";
                RunPageLink = "Rfid Header Id" = FIELD(Id);
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

                    PAGE.Run(PAGE::"Warehouse Receipt", WarehouseReceiptHeader);
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

