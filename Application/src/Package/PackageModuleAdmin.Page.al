page 6014648 "NPR Package Module Admin"
{
    // 
    // NPR-Package1.0, NPK, DL, 04-04-08, Form created
    //                      DL, 02-05-08, Added some fields
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Package Module Admin';
    SourceTable = "NPR Package Module Config.";
    UsageCategory = Administration;

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
                    field("Normal No. Series"; "Normal No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("DHL No. Series"; "DHL No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("DHL AWB No. Series"; "DHL AWB No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("DHL Customer No"; "DHL Customer No")
                    {
                        ApplicationArea = All;
                    }
                    field("COD No. Series"; "COD No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("CV No. Series"; "CV No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("Barcode39 Path"; "Barcode39 Path")
                    {
                        ApplicationArea = All;
                    }
                    field("Has EDI contract"; "Has EDI contract")
                    {
                        ApplicationArea = All;
                    }
                    field("Business Service Code"; "Business Service Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Private Service Code"; "Private Service Code")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150626)
                {
                    ShowCaption = false;
                    field("DHL ftp address"; "DHL ftp address")
                    {
                        ApplicationArea = All;
                    }
                    field("DHL ftp username"; "DHL ftp username")
                    {
                        ApplicationArea = All;
                    }
                    field("DHL ftp password"; "DHL ftp password")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            grid(EDI)
            {
                Caption = 'EDI';
                group(Control6150630)
                {
                    ShowCaption = false;
                    field("EDI Sender Identifier"; "EDI Sender Identifier")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Sender SMS"; "EDI Sender SMS")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Recipient SMS"; "EDI Recipient SMS")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Sender Email"; "EDI Sender Email")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Recipient Email"; "EDI Recipient Email")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI FTP username"; "EDI FTP username")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI FTP password"; "EDI FTP password")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
    }
}

