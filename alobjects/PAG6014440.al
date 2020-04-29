page 6014440 "Pacsoft Shipment Documents"
{
    // PS1.00/LS/20140509  CASE 190533 Pacsoft module + Link to Page Pacsoft Setup
    // NPR5.26/BHR/20160919 CASE 248912 Pakkelabels
    // NPR5.29/BHR/20161207 CASE 258936 Action Print Document.
    //                                  Add property cardPageId  to 6014486
    //                                  Hide action 'Card'
    // NPR5.43/BHR /20180508 CASE 304453 Add fields for returns
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Pacsoft Shipment Documents';
    CardPageID = "Pacsoft Shipment Document";
    Editable = false;
    PageType = List;
    SourceTable = "Pacsoft Shipment Document";
    SourceTableView = SORTING("Export Time");
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field(RecordID;RecordID)
                {
                }
                field("Creation Time";"Creation Time")
                {
                }
                field("Export Time";"Export Time")
                {
                }
                field(Status;Status)
                {
                }
                field("Return Message";"Return Message")
                {
                }
                field(Session;Session)
                {
                }
                field(Name;Name)
                {
                }
                field("Shipping Agent Code";"Shipping Agent Code")
                {
                }
                field("Package Code";"Package Code")
                {
                }
                field(Reference;Reference)
                {
                }
                field("Shipment Date";"Shipment Date")
                {
                }
                field("Shipping Method Code";"Shipping Method Code")
                {
                }
                field("Shipping Agent Service Code";"Shipping Agent Service Code")
                {
                }
                field("Response Shipment ID";"Response Shipment ID")
                {
                }
                field("Response Package No.";"Response Package No.")
                {
                }
                field("Print Return Label";"Print Return Label")
                {
                }
                field("Return Response Shipment ID";"Return Response Shipment ID")
                {
                }
                field("Return Response Package No.";"Return Response Package No.")
                {
                }
                field("Return Shipping Agent Code";"Return Shipping Agent Code")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                ShortCutKey = 'Shift+F5';
                Visible = false;

                trigger OnAction()
                var
                    ShipmentDocumentForm: Page "Pacsoft Shipment Document";
                begin
                    Clear(ShipmentDocumentForm);
                    ShipmentDocumentForm.SetRecord(Rec);
                    ShipmentDocumentForm.Editable(false);
                    ShipmentDocumentForm.RunModal;
                end;
            }
            action(TrackTrace)
            {
                Caption = 'Track''n''Trace';
                Image = Track;
                ShortCutKey = 'Ctrl+F9';

                trigger OnAction()
                begin
                    ShowTrackAndTrace(Rec);
                end;
            }
            action(SendDocument)
            {
                Caption = 'Send Document';
                Image = SendTo;
                ShortCutKey = 'F9';

                trigger OnAction()
                var
                    PacsoftMgt: Codeunit "Pacsoft Management";
                    PacsoftSetup: Record "Pacsoft Setup";
                begin
                    if Confirm(StrSubstNo(TextConfirm, FieldCaption("Entry No."), "Entry No."), true) then

                    //-NPR5.26 [248912]
                    //  PacsoftMgt.SendDocument(Rec, TRUE);
                    begin
                      PacsoftSetup.Get;
                      if PacsoftSetup."Use Pacsoft integration" then begin
                        PacsoftMgt.SendDocument(Rec, true);
                        Clear(Rec);
                        CurrPage.Update(false);
                        end;
                    //  ELSE IF PacsoftSetup."Use Pakkelabels" THEN
                    //  PakkelabelsMgnt.CreateShipmentOwnCustomerNo(Rec);
                    end;
                    //-NPR5.26 [248912]
                end;
            }
            separator(Separator6150632)
            {
            }
            action(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                RunObject = Page "Pacsoft Setup";
            }
            action(PrintDocument)
            {
                Caption = 'Print Document';
                Image = PrintDocument;

                trigger OnAction()
                begin
                    //-NPR5.29 [258936]
                end;
            }
        }
    }

    var
        TextConfirm: Label 'Do you want to send %1 %2 ?';
}

