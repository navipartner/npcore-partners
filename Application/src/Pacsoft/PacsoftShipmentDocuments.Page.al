page 6014440 "NPR Pacsoft Shipment Documents"
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
    CardPageID = "NPR Pacsoft Shipment Document";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pacsoft Shipment Document";
    SourceTableView = SORTING("Export Time");
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("RecordID"; RecordID)
                {
                    ApplicationArea = All;
                }
                field("Creation Time"; "Creation Time")
                {
                    ApplicationArea = All;
                }
                field("Export Time"; "Export Time")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Return Message"; "Return Message")
                {
                    ApplicationArea = All;
                }
                field(Session; Session)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Package Code"; "Package Code")
                {
                    ApplicationArea = All;
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("Shipping Method Code"; "Shipping Method Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                }
                field("Response Shipment ID"; "Response Shipment ID")
                {
                    ApplicationArea = All;
                }
                field("Response Package No."; "Response Package No.")
                {
                    ApplicationArea = All;
                }
                field("Print Return Label"; "Print Return Label")
                {
                    ApplicationArea = All;
                }
                field("Return Response Shipment ID"; "Return Response Shipment ID")
                {
                    ApplicationArea = All;
                }
                field("Return Response Package No."; "Return Response Package No.")
                {
                    ApplicationArea = All;
                }
                field("Return Shipping Agent Code"; "Return Shipping Agent Code")
                {
                    ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    ShipmentDocumentForm: Page "NPR Pacsoft Shipment Document";
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
                ApplicationArea = All;

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
                ApplicationArea = All;

                trigger OnAction()
                var
                    PacsoftMgt: Codeunit "NPR Pacsoft Management";
                    PacsoftSetup: Record "NPR Pacsoft Setup";
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
                RunObject = Page "NPR Pacsoft Setup";
                ApplicationArea = All;
            }
            action(PrintDocument)
            {
                Caption = 'Print Document';
                Image = PrintDocument;
                ApplicationArea = All;

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

