page 6014440 "NPR Pacsoft Shipment Documents"
{
    Caption = 'Pacsoft Shipment Documents';
    CardPageID = "NPR Pacsoft Shipment Document";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pacsoft Shipment Document";
    SourceTableView = SORTING("Export Time");
    UsageCategory = Documents;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("RecordID"; Rec.RecordID)
                {

                    ToolTip = 'Specifies the value of the RecordID field';
                    ApplicationArea = NPRRetail;
                }
                field("Creation Time"; Rec."Creation Time")
                {

                    ToolTip = 'Specifies the value of the Creation Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Export Time"; Rec."Export Time")
                {

                    ToolTip = 'Specifies the value of the Export Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Message"; Rec."Return Message")
                {

                    ToolTip = 'Specifies the value of the Return Message field';
                    ApplicationArea = NPRRetail;
                }
                field(Session; Rec.Session)
                {

                    ToolTip = 'Specifies the value of the Session field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Package Code"; Rec."Package Code")
                {

                    ToolTip = 'Specifies the value of the Package Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Reference; Rec.Reference)
                {

                    ToolTip = 'Specifies the value of the Reference field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {

                    ToolTip = 'Specifies the value of the Shipment Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Method Code"; Rec."Shipping Method Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Shipment ID"; Rec."Response Shipment ID")
                {

                    ToolTip = 'Specifies the value of the Response Shipment ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Package No."; Rec."Response Package No.")
                {

                    ToolTip = 'Specifies the value of the Response Package No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Return Label"; Rec."Print Return Label")
                {

                    ToolTip = 'Specifies the value of the Print Return Label field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Response Shipment ID"; Rec."Return Response Shipment ID")
                {

                    ToolTip = 'Specifies the value of the Return Response Shipment ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Response Package No."; Rec."Return Response Package No.")
                {

                    ToolTip = 'Specifies the value of the Return Response Package No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Shipping Agent Code"; Rec."Return Shipping Agent Code")
                {

                    ToolTip = 'Specifies the value of the Return Shipping Agent Code field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ShipmentDocumentForm: Page "NPR Pacsoft Shipment Document";
                begin
                    Clear(ShipmentDocumentForm);
                    ShipmentDocumentForm.SetRecord(Rec);
                    ShipmentDocumentForm.Editable(false);
                    ShipmentDocumentForm.RunModal();
                end;
            }
            action(TrackTrace)
            {
                Caption = 'Track''n''Trace';
                Image = Track;
                ShortCutKey = 'Ctrl+F9';

                ToolTip = 'Executes the Track''n''Trace action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowTrackAndTrace(Rec);
                end;
            }
            action(SendDocument)
            {
                Caption = 'Send Document';
                Image = SendTo;
                ShortCutKey = 'F9';

                ToolTip = 'Executes the Send Document action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PacsoftMgt: Codeunit "NPR Pacsoft Management";
                    PacsoftSetup: Record "NPR Pacsoft Setup";
                    ShipmondoMgnt: Codeunit "NPR Shipmondo Mgnt.";
                begin
                    if Confirm(StrSubstNo(TextConfirm, Rec.FieldCaption("Entry No."), Rec."Entry No."), true) then begin
                        PacsoftSetup.Get();
                        if PacsoftSetup."Use Pacsoft integration" then begin
                            PacsoftMgt.SendDocument(Rec, true);
                            Clear(Rec);
                            CurrPage.Update(false);
                        end;

                        ShipmondoMgnt.SendDocument(Rec);
                    end;
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

                ToolTip = 'Executes the Setup action';
                ApplicationArea = NPRRetail;
            }
            action(PrintDocument)
            {
                Caption = 'Print Document';
                Image = PrintDocument;

                ToolTip = 'Executes the Print Document action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ShipmondoMgnt: Codeunit "NPR Shipmondo Mgnt.";
                begin
                    ShipmondoMgnt.PrintDocument(Rec);
                end;
            }
        }
    }

    var
        TextConfirm: Label 'Do you want to send %1 %2 ?';
}

