page 6151572 "AF Test Services"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017
    // NPR5.38/CLVA/20171024 CASE 289636 Changed object name and added Messages Service test functionality
    // NPR5.40/THRO/20180315 CASE 307195 Change SMS Test function to use CreateSMSBody

    Caption = 'AF Test Services';
    PageType = Card;
    SourceTable = "AF Arguments - Spire Barcode";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group("Spire Barcode")
            {
                Caption = 'Spire Barcode';
                field(Value;Value)
                {
                }
                field(Type;Type)
                {
                }
                field("Show Checksum";"Show Checksum")
                {
                }
                field("Barcode Height";"Barcode Height")
                {
                }
                field("Barcode Size";"Barcode Size")
                {
                }
                field("Include Text";"Include Text")
                {
                }
                field(Border;Border)
                {
                }
                field("Reverse Colors";"Reverse Colors")
                {
                }
                field("Image Type";"Image Type")
                {
                }
                field(Image;Image)
                {
                }
            }
            group("MSG Service")
            {
                Caption = 'MSG Service';
                field(MSGSender;MSGSender)
                {
                    Caption = 'Sender';
                }
                field(MSGPhoneNumber;MSGPhoneNumber)
                {
                    Caption = 'Phone Number';
                }
                field(MSGInvoiceNo;MSGInvoiceNo)
                {
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
                    RunObject = Page "AF Notification Hub List";
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

                    trigger OnAction()
                    var
                        SMSManagement: Codeunit "SMS Management";
                        SMSBody: Text;
                        AFAPIMsgService: Codeunit "AF API - Msg Service";
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                        AFSetup: Record "AF Setup";
                    begin
                        if (MSGPhoneNumber <> '') and (MSGSender <> '') and (MSGInvoiceNo <> '') then begin
                          SalesInvoiceHeader.Get(MSGInvoiceNo);
                        //-NPR5.40 [307195]
                          AFSetup.Get;
                          AFSetup.TestField("Msg Service - Report ID");
                          SMSBody := AFAPIMsgService.CreateSMSBody(SalesInvoiceHeader.RecordId,AFSetup."Msg Service - Report ID",'');
                        //+NPR5.40 [307195]
                          SMSManagement.SendSMS(MSGPhoneNumber,MSGSender,SMSBody);
                          Message(SMSSentTxt);
                        end;
                    end;
                }
            }
        }
    }

    var
        AFAPISpireBarcode: Codeunit "AF API - Spire Barcode";
        TempBlob: Record TempBlob;
        MSGSender: Text;
        MSGPhoneNumber: Text;
        MSGInvoiceNo: Code[20];
        SMSSentTxt: Label 'Message sent.';
}

