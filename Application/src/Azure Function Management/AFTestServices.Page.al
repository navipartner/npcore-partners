page 6151572 "NPR AF Test Services"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017
    // NPR5.38/CLVA/20171024 CASE 289636 Changed object name and added Messages Service test functionality
    // NPR5.40/THRO/20180315 CASE 307195 Change SMS Test function to use CreateSMSBody

    Caption = 'AF Test Services';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Value field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Show Checksum"; "Show Checksum")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Checksum field';
                }
                field("Barcode Height"; "Barcode Height")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode Height field';
                }
                field("Barcode Size"; "Barcode Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode Size field';
                }
                field("Include Text"; "Include Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include Text field';
                }
                field(Border; Border)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Border field';
                }
                field("Reverse Colors"; "Reverse Colors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reverse Colors field';
                }
                field("Image Type"; "Image Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image Type field';
                }
                field(Image; Image)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image field';
                }
            }
            group("MSG Service")
            {
                Caption = 'MSG Service';
                field(MSGSender; MSGSender)
                {
                    ApplicationArea = All;
                    Caption = 'Sender';
                    ToolTip = 'Specifies the value of the Sender field';
                }
                field(MSGPhoneNumber; MSGPhoneNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Phone Number';
                    ToolTip = 'Specifies the value of the Phone Number field';
                }
                field(MSGInvoiceNo; MSGInvoiceNo)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice No.';
                    TableRelation = "Sales Invoice Header";
                    ToolTip = 'Specifies the value of the Invoice No. field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

            group("Notification Hub")
            {
                Caption = 'Notification Hub';
                action(Notifications)
                {
                    Caption = 'Notifications';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    RunObject = Page "NPR AF Notification Hub List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Notifications action';
                    Image = View;
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
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send SMS action';

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
        TempBlob: Codeunit "Temp Blob";
        MSGSender: Text;
        MSGPhoneNumber: Text;
        MSGInvoiceNo: Code[20];
        SMSSentTxt: Label 'Message sent.';
}

