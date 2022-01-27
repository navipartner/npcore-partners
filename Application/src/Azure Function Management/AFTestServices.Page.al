page 6151572 "NPR AF Test Services"
{
    Extensible = False;
    Caption = 'AF Test Services';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR AF Args: Spire Barcode";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group("Spire Barcode")
            {
                Caption = 'Spire Barcode';
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Checksum"; Rec."Show Checksum")
                {

                    ToolTip = 'Specifies the value of the Show Checksum field';
                    ApplicationArea = NPRRetail;
                }
                field("Barcode Height"; Rec."Barcode Height")
                {

                    ToolTip = 'Specifies the value of the Barcode Height field';
                    ApplicationArea = NPRRetail;
                }
                field("Barcode Size"; Rec."Barcode Size")
                {

                    ToolTip = 'Specifies the value of the Barcode Size field';
                    ApplicationArea = NPRRetail;
                }
                field("Include Text"; Rec."Include Text")
                {

                    ToolTip = 'Specifies the value of the Include Text field';
                    ApplicationArea = NPRRetail;
                }
                field(Border; Rec.Border)
                {

                    ToolTip = 'Specifies the value of the Border field';
                    ApplicationArea = NPRRetail;
                }
                field("Reverse Colors"; Rec."Reverse Colors")
                {

                    ToolTip = 'Specifies the value of the Reverse Colors field';
                    ApplicationArea = NPRRetail;
                }
                field("Image Type"; Rec."Image Type")
                {

                    ToolTip = 'Specifies the value of the Image Type field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("MSG Service")
            {
                Caption = 'MSG Service';
                field(MSGSender; MSGSender)
                {

                    Caption = 'Sender';
                    ToolTip = 'Specifies the value of the Sender field';
                    ApplicationArea = NPRRetail;
                }
                field(MSGPhoneNumber; MSGPhoneNumber)
                {

                    Caption = 'Phone Number';
                    ToolTip = 'Specifies the value of the Phone Number field';
                    ApplicationArea = NPRRetail;
                }
                field(MSGInvoiceNo; MSGInvoiceNo)
                {

                    Caption = 'Invoice No.';
                    TableRelation = "Sales Invoice Header";
                    ToolTip = 'Specifies the value of the Invoice No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(AFTestServicePicture; "NPR AF Test Service Picture")
            {

                Caption = 'Picture';
                SubPageLink = "Primary Key" = field("Primary Key");
                ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Notifications action';
                    Image = View;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        MSGSender: Text;
        MSGPhoneNumber: Text;
        MSGInvoiceNo: Code[20];
}

