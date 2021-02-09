page 6151572 "NPR AF Test Services"
{
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
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    RunObject = Page "NPR AF Notification Hub List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Notifications action';
                    Image = View;
                }
            }
        }
    }

    var
        MSGSender: Text;
        MSGPhoneNumber: Text;
        MSGInvoiceNo: Code[20];
}

