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
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Show Checksum"; Rec."Show Checksum")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Checksum field';
                }
                field("Barcode Height"; Rec."Barcode Height")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode Height field';
                }
                field("Barcode Size"; Rec."Barcode Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode Size field';
                }
                field("Include Text"; Rec."Include Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include Text field';
                }
                field(Border; Rec.Border)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Border field';
                }
                field("Reverse Colors"; Rec."Reverse Colors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reverse Colors field';
                }
                field("Image Type"; Rec."Image Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image Type field';
                }
                field(Image; Rec.Image)
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

