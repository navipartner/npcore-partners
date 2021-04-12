page 6014648 "NPR Package Module Admin"
{
    // 
    // NPR-Package1.0, NPK, DL, 04-04-08, Form created
    //                      DL, 02-05-08, Added some fields
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Package Module Admin';
    SourceTable = "NPR Package Module Config.";
    UsageCategory = Administration;
    ApplicationArea = All;

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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Normal package label numbers field';
                    }
                    field("DHL No. Series"; Rec."DHL No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the DHL package label numbers field';
                    }
                    field("DHL AWB No. Series"; Rec."DHL AWB No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the DHL AWB package label numbers field';
                    }
                    field("DHL Customer No"; Rec."DHL Customer No")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the DHL Customer No field';
                    }
                    field("COD No. Series"; Rec."COD No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash on delivery package numbers field';
                    }
                    field("CV No. Series"; Rec."CV No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Recipient receipt package numbers field';
                    }
                    field("Barcode39 Path"; Rec."Barcode39 Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Path to Barcode39 field';
                    }
                    field("Has EDI contract"; Rec."Has EDI contract")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Has EDI contract field';
                    }
                    field("Business Service Code"; Rec."Business Service Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Business shipping agent service code field';
                    }
                    field("Private Service Code"; Rec."Private Service Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Private shipping agent service code field';
                    }
                }
                group(Control6150626)
                {
                    ShowCaption = false;
                    field("DHL ftp address"; Rec."DHL ftp address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the DHL FTP Address field';
                    }
                    field("DHL ftp username"; Rec."DHL ftp username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the DHL FTP Username field';
                    }
                    field("DHL ftp password"; Rec."DHL ftp password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the DHL FTP Password field';
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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Package EDI sender identification field';
                    }
                    field("EDI Sender SMS"; Rec."EDI Sender SMS")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the SMS to sender field';
                    }
                    field("EDI Recipient SMS"; Rec."EDI Recipient SMS")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the SMS to recipient field';
                    }
                    field("EDI Sender Email"; Rec."EDI Sender Email")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Email to sender field';
                    }
                    field("EDI Recipient Email"; Rec."EDI Recipient Email")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Email to recipient field';
                    }
                    field("EDI FTP username"; Rec."EDI FTP username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EDI FTP Username field';
                    }
                    field("EDI FTP password"; Rec."EDI FTP password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EDI FTP Password field';
                    }
                }
            }
        }
    }

    actions
    {
    }
}

