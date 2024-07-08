page 6014648 "NPR Package Module Admin"
{
    Extensible = False;
    // 
    // NPR-Package1.0, NPK, DL, 04-04-08, Form created
    //                      DL, 02-05-08, Added some fields
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Package Module Admin';
    SourceTable = "NPR Package Module Config.";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            grid(General)
            {
                Caption = 'General';
                group(Control6150615)
                {
                    ShowCaption = false;
                    field("Normal No. Series"; Rec."Normal No. Series")
                    {

                        ToolTip = 'Specifies the value of the Normal package label numbers field';
                        ApplicationArea = NPRRetail;
                    }
                    field("DHL No. Series"; Rec."DHL No. Series")
                    {

                        ToolTip = 'Specifies the value of the DHL package label numbers field';
                        ApplicationArea = NPRRetail;
                    }
                    field("DHL AWB No. Series"; Rec."DHL AWB No. Series")
                    {

                        ToolTip = 'Specifies the value of the DHL AWB package label numbers field';
                        ApplicationArea = NPRRetail;
                    }
                    field("DHL Customer No"; Rec."DHL Customer No")
                    {

                        ToolTip = 'Specifies the value of the DHL Customer No field';
                        ApplicationArea = NPRRetail;
                    }
                    field("COD No. Series"; Rec."COD No. Series")
                    {

                        ToolTip = 'Specifies the value of the Cash on delivery package numbers field';
                        ApplicationArea = NPRRetail;
                    }
                    field("CV No. Series"; Rec."CV No. Series")
                    {

                        ToolTip = 'Specifies the value of the Recipient receipt package numbers field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Barcode39 Path"; Rec."Barcode39 Path")
                    {

                        ToolTip = 'Specifies the value of the Path to Barcode39 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Has EDI contract"; Rec."Has EDI contract")
                    {

                        ToolTip = 'Specifies the value of the Has EDI contract field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Business Service Code"; Rec."Business Service Code")
                    {

                        ToolTip = 'Specifies the value of the Business shipping agent service code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Private Service Code"; Rec."Private Service Code")
                    {

                        ToolTip = 'Specifies the value of the Private shipping agent service code field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6150626)
                {
                    ShowCaption = false;
                    field("DHL ftp address"; Rec."DHL ftp address")
                    {

                        ToolTip = 'Specifies the value of the DHL FTP Address field';
                        ApplicationArea = NPRRetail;
                    }
                    field("DHL ftp username"; Rec."DHL ftp username")
                    {

                        ToolTip = 'Specifies the value of the DHL FTP Username field';
                        ApplicationArea = NPRRetail;
                    }
                    field("DHL ftp password"; Rec."DHL ftp password")
                    {

                        ToolTip = 'Specifies the value of the DHL FTP Password field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            grid(EDI)
            {
                Caption = 'EDI';
                group(Control6150630)
                {
                    ShowCaption = false;
                    field("EDI Sender Identifier"; Rec."EDI Sender Identifier")
                    {

                        ToolTip = 'Specifies the value of the Package EDI sender identification field';
                        ApplicationArea = NPRRetail;
                    }
                    field("EDI Sender SMS"; Rec."EDI Sender SMS")
                    {

                        ToolTip = 'Specifies the value of the SMS to sender field';
                        ApplicationArea = NPRRetail;
                    }
                    field("EDI Recipient SMS"; Rec."EDI Recipient SMS")
                    {

                        ToolTip = 'Specifies the value of the SMS to recipient field';
                        ApplicationArea = NPRRetail;
                    }
                    field("EDI Sender Email"; Rec."EDI Sender Email")
                    {

                        ToolTip = 'Specifies the value of the Email to sender field';
                        ApplicationArea = NPRRetail;
                    }
                    field("EDI Recipient Email"; Rec."EDI Recipient Email")
                    {

                        ToolTip = 'Specifies the value of the Email to recipient field';
                        ApplicationArea = NPRRetail;
                    }
                    field("EDI FTP username"; Rec."EDI FTP username")
                    {

                        ToolTip = 'Specifies the value of the EDI FTP Username field';
                        ApplicationArea = NPRRetail;
                    }
                    field("EDI FTP password"; Rec."EDI FTP password")
                    {

                        ToolTip = 'Specifies the value of the EDI FTP Password field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    actions
    {
    }
}

