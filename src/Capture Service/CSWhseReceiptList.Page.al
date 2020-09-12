page 6151390 "NPR CS Whse. Receipt List"
{
    // NPR5.51/CLVA/20190610  CASE 356107 Object created

    Caption = 'CS Whse. Receipt List';
    Editable = false;
    PageType = List;
    SourceTable = "Warehouse Receipt Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    ApplicationArea = All;
                }
                field("Assignment Date"; "Assignment Date")
                {
                    ApplicationArea = All;
                }
                field("Assignment Time"; "Assignment Time")
                {
                    ApplicationArea = All;
                }
                field("Document Status"; "Document Status")
                {
                    ApplicationArea = All;
                }
                field("Tags Scanned"; TagsScanned)
                {
                    ApplicationArea = All;
                    Caption = 'Scanned Tags';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowTagsScanned)
            {
                Caption = 'Tags Scanned';
                Image = DataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Whse. Receipt Data";
                RunPageLink = "Doc. No." = FIELD("No.");
                ApplicationArea = All;
            }
            action("Transfer Data")
            {
                Caption = 'Transfer Data';
                Image = TransferToGeneralJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CSWS: Codeunit "NPR CS WS";
                    Result: Text;
                    WarehouseReceiptHeader: Record "Warehouse Receipt Header";
                begin
                    if not Confirm(Txt001, true) then
                        exit;

                    Result := CSWS.SaveRfidWhseReceiptData("No.");
                    if Result = '' then begin
                        WarehouseReceiptHeader.Get("No.");
                        PAGE.Run(5768, WarehouseReceiptHeader);
                    end else
                        Error(Result);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Clear(CSWhseReceiptData);
        CSWhseReceiptData.SetRange("Doc. No.", "No.");
        TagsScanned := CSWhseReceiptData.Count();
    end;

    var
        TagsScanned: Integer;
        CSWhseReceiptData: Record "NPR CS Whse. Receipt Data";
        Txt001: Label 'Transfer Tags Scanned';
}

