page 6014440 "NPR Pacsoft Shipment Documents"
{
    Caption = 'Pacsoft Shipment Documents';
    CardPageID = "NPR Pacsoft Shipment Document";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pacsoft Shipment Document";
    SourceTableView = SORTING("Export Time");
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("RecordID"; Rec.RecordID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the RecordID field';
                }
                field("Creation Time"; Rec."Creation Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation Time field';
                }
                field("Export Time"; Rec."Export Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Export Time field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Return Message"; Rec."Return Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Message field';
                }
                field(Session; Rec.Session)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                }
                field("Package Code"; Rec."Package Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package Code field';
                }
                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Date field';
                }
                field("Shipping Method Code"; Rec."Shipping Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Method Code field';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                }
                field("Response Shipment ID"; Rec."Response Shipment ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Shipment ID field';
                }
                field("Response Package No."; Rec."Response Package No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Package No. field';
                }
                field("Print Return Label"; Rec."Print Return Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Return Label field';
                }
                field("Return Response Shipment ID"; Rec."Return Response Shipment ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Response Shipment ID field';
                }
                field("Return Response Package No."; Rec."Return Response Package No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Response Package No. field';
                }
                field("Return Shipping Agent Code"; Rec."Return Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Shipping Agent Code field';
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
                ToolTip = 'Executes the Card action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Track''n''Trace action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Send Document action';

                trigger OnAction()
                var
                    PacsoftMgt: Codeunit "NPR Pacsoft Management";
                    PacsoftSetup: Record "NPR Pacsoft Setup";
                begin
                    if Confirm(StrSubstNo(TextConfirm, Rec.FieldCaption("Entry No."), Rec."Entry No."), true) then begin
                        PacsoftSetup.Get();
                        if PacsoftSetup."Use Pacsoft integration" then begin
                            PacsoftMgt.SendDocument(Rec, true);
                            Clear(Rec);
                            CurrPage.Update(false);
                        end;
                        ;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Setup action';
            }
            action(PrintDocument)
            {
                Caption = 'Print Document';
                Image = PrintDocument;
                ApplicationArea = All;
                ToolTip = 'Executes the Print Document action';

                trigger OnAction()
                begin
                end;
            }
        }
    }

    var
        TextConfirm: Label 'Do you want to send %1 %2 ?';
}

