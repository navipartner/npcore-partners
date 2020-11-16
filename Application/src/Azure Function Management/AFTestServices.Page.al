page 6151572 "NPR AF Test Services"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017
    // NPR5.38/CLVA/20171024 CASE 289636 Changed object name and added Messages Service test functionality
    // NPR5.40/THRO/20180315 CASE 307195 Change SMS Test function to use CreateSMSBody

    Caption = 'AF Test Services';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR AF Args: Spire Barcode";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group("Spire Barcode")
            {
                Caption = 'Spire Barcode';
                field(Value; Value)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Show Checksum"; "Show Checksum")
                {
                    ApplicationArea = All;
                }
                field("Barcode Height"; "Barcode Height")
                {
                    ApplicationArea = All;
                }
                field("Barcode Size"; "Barcode Size")
                {
                    ApplicationArea = All;
                }
                field("Include Text"; "Include Text")
                {
                    ApplicationArea = All;
                }
                field(Border; Border)
                {
                    ApplicationArea = All;
                }
                field("Reverse Colors"; "Reverse Colors")
                {
                    ApplicationArea = All;
                }
                field("Image Type"; "Image Type")
                {
                    ApplicationArea = All;
                }
                field(Image; Image)
                {
                    ApplicationArea = All;
                }
            }
            group("MSG Service")
            {
                Caption = 'MSG Service';
                field(MSGSender; MSGSender)
                {
                    ApplicationArea = All;
                    Caption = 'Sender';
                }
                field(MSGPhoneNumber; MSGPhoneNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Phone Number';
                }
                field(MSGInvoiceNo; MSGInvoiceNo)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice No.';
                    TableRelation = "Sales Invoice Header";
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup6014414)
            {
                Caption = 'Spire Barcode';
                action(GenerateBarcode)
                {
                    Caption = 'Generate Barcode';
                    Image = Task;
                    Promoted = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        AFAPISpireBarcode.GenerateBarcode(Rec);
                        CurrPage.Update;
                    end;
                }
            }
            group("Notification Hub")
            {
                Caption = 'Notification Hub';
                action(Notifications)
                {
                    Caption = 'Notifications';
                    Promoted = true;
                    PromotedIsBig = true;
                    RunObject = Page "NPR AF Notification Hub List";
                    ApplicationArea = All;
                }
            }
            group(ActionGroup6014415)
            {
                Caption = 'MSG Service';
                action(SendSMS)
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                    Promoted = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        SMSManagement: Codeunit "NPR SMS Management";
                        SMSBody: Text;
                        AFAPIMsgService: Codeunit "NPR AF API - Msg Service";
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                        AFSetup: Record "NPR AF Setup";
                    begin
                        if (MSGPhoneNumber <> '') and (MSGSender <> '') and (MSGInvoiceNo <> '') then begin
                            SalesInvoiceHeader.Get(MSGInvoiceNo);
                            //-NPR5.40 [307195]
                            AFSetup.Get;
                            AFSetup.TestField("Msg Service - Report ID");
                            SMSBody := AFAPIMsgService.CreateSMSBody(SalesInvoiceHeader.RecordId, AFSetup."Msg Service - Report ID", '');
                            //+NPR5.40 [307195]
                            SMSManagement.SendSMS(MSGPhoneNumber, MSGSender, SMSBody);
                            Message(SMSSentTxt);
                        end;
                    end;
                }
            }
        }
    }

    var
        AFAPISpireBarcode: Codeunit "NPR AF API - Spire Barcode";
        TempBlob: Codeunit "Temp Blob";
        MSGSender: Text;
        MSGPhoneNumber: Text;
        MSGInvoiceNo: Code[20];
        SMSSentTxt: Label 'Message sent.';
}

