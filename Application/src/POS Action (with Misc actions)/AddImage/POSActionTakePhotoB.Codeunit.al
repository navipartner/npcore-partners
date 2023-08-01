codeunit 6151393 "NPR POS Action Take Photo B"
{
    Access = Internal;
    procedure TakePhoto(POSSaleCU: Codeunit "NPR POS Sale"): JsonObject
    var
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
        POSSale: Record "NPR POS Sale";
    begin
        POSSaleCU.GetCurrentSale(POSSale);
        POSSaleMediaInfo.CreateNewEntry(POSSale, 1);
    end;

    procedure CheckIfPhotoIsTaken(POSSaleCU: Codeunit "NPR POS Sale")
    var
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
        POSSale: Record "NPR POS Sale";
        PhotoErr: Label 'The photo has to be taken.';
    begin
        POSSaleCU.GetCurrentSale(POSSale);
        POSSaleMediaInfo.SetCurrentKey("Register No.", "Sales Ticket No.");
        POSSaleMediaInfo.SetRange("Register No.", POSSale."Register No.");
        POSSaleMediaInfo.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        if POSSaleMediaInfo.IsEmpty() then
            Error(PhotoErr);
        POSSaleMediaInfo.FindLast();
        if not POSSaleMediaInfo.Image.HasValue then
            Error(PhotoErr);
    end;

    procedure AddImageOnPosEntry(DocumentNo: Text; Setup: Codeunit "NPR POS Setup"; AddPhotoTo: Option ,LastPosEntry,SelectPosEntry,PosEntryByDocumentNo)
    var
        POSUnit: Record "NPR POS Unit";
        POSEntry: Record "NPR POS Entry";
        POSEntryMediaInfo: Record "NPR POS Entry Media Info";
        InvalidDocumentNo: Label 'Entered Document No. %1 is not valid. Please enter valid value.', Comment = '%1-document no.';
    begin
        case AddPhotoTo of
            AddPhotoTo::LastPosEntry, AddPhotoTo::SelectPosEntry:
                begin
                    Setup.GetPOSUnit(POSUnit);
                    if POSUnit."No." = '' then
                        exit;

                    FilterPosEntries(POSUnit, POSEntry);

                    if AddPhotoTo = AddPhotoTo::LastPosEntry then begin
                        if not POSEntry.FindLast() then
                            exit;
                    end
                    else begin
                        if not SelectPOSEntry(POSEntry) then
                            exit;
                    end;
                end;

            AddPhotoTo::PosEntryByDocumentNo:
                begin
                    if (DocumentNo = '') or (StrLen(DocumentNo) > MaxStrLen(POSEntry."Document No.")) then
                        Error(InvalidDocumentNo, DocumentNo);
                    POSEntry.SetCurrentKey("Document No.");
                    POSEntry.SetRange("Document No.", DocumentNo);
                    POSEntry.FindFirst();
                end;
        end;

        POSEntryMediaInfo.CreateNewEntry(POSEntry, 1, false);
    end;

    local procedure SelectPOSEntry(var POSEntry: Record "NPR POS Entry"): Boolean
    var
        EntryCount: Integer;
    begin
        EntryCount := POSEntry.Count;

        case EntryCount of
            0:
                exit(false);
            1:
                begin
                    POSEntry.FindLast();
                    exit(true);
                end;
            else begin
                POSEntry.Ascending(false);
                if POSEntry.FindFirst() then;
                if PAGE.RunModal(0, POSEntry) <> ACTION::LookupOK then
                    exit(false);

                exit(true);
            end;
        end;
    end;

    local procedure FilterPosEntries(POSUnit: Record "NPR POS Unit"; var POSEntry: Record "NPR POS Entry")
    begin
        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
        POSEntry.SetRange("POS Store Code", POSUnit."POS Store Code");
        POSEntry.SetRange("POS Unit No.", POSUnit."No.");
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
    end;

}