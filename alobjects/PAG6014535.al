page 6014535 "Scanner - Setup"
{
    // NPR4.14/TS/20150820 CASE221150 Changed caption
    // NPR5.27/TJ/20160826 CASE 248276 Removed unused fields
    // NPR5.29/CLVA/20161122 CASE 252352 Added Group: FTP
    // NPR5.38/NPKNAV/20180126  CASE 299271 Transport NPR5.38 - 26 January 2018

    Caption = 'Scanner Card';
    SourceTable = "Scanner - Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                grid(Control6150615)
                {
                    ShowCaption = false;
                    group(Control6150616)
                    {
                        ShowCaption = false;
                        field(ID;ID)
                        {
                        }
                        field(Description;Description)
                        {
                            Importance = Promoted;
                        }
                    }
                    group(Control6150619)
                    {
                        ShowCaption = false;
                        field(Type;Type)
                        {
                        }
                        field(Port;Port)
                        {
                        }
                        field("Clear Scanner Option";"Clear Scanner Option")
                        {
                        }
                        field(Debug;Debug)
                        {
                        }
                    }
                }
            }
            group(Files)
            {
                Caption = 'Files';
                grid(Control6150626)
                {
                    ShowCaption = false;
                    group(Control6150627)
                    {
                        ShowCaption = false;
                        field("Path - EXE / DLL Directory";"Path - EXE / DLL Directory")
                        {
                        }
                        field("EXE - In";"EXE - In")
                        {
                        }
                        field("EXE - Out";"EXE - Out")
                        {
                        }
                        field("EXE - Update Scanner";"EXE - Update Scanner")
                        {
                        }
                        field("Path - Drop Directory";"Path - Drop Directory")
                        {
                        }
                        field("Path - Pickup Directory";"Path - Pickup Directory")
                        {
                        }
                        field("File - Name Type";"File - Name Type")
                        {
                        }
                        field("File - Name/Prefix";"File - Name/Prefix")
                        {
                        }
                        field("Import to Server Folder First";"Import to Server Folder First")
                        {
                        }
                        field("Local Client Scanner Folder";"Local Client Scanner Folder")
                        {
                        }
                        field("File - After";"File - After")
                        {
                        }
                        field("File - Backup Directory";"File - Backup Directory")
                        {
                        }
                        field("Backup Filename";"Backup Filename")
                        {
                            ToolTip = '%1 = CurrentDatetime';
                        }
                    }
                }
            }
            group(Format)
            {
                Caption = 'Format';
                grid(Control6150642)
                {
                    ShowCaption = false;
                    group("Number Format")
                    {
                        Caption = 'Number Format';
                        field("Decimal Point";"Decimal Point")
                        {
                        }
                        field("Leading Decimals";"Leading Decimals")
                        {
                        }
                        group("Before Communication")
                        {
                            Caption = 'Before Communication';
                            field("File - Line Skip Pre";"File - Line Skip Pre")
                            {
                            }
                            field("Placement Popup";"Placement Popup")
                            {
                            }
                            field("Alt. Import Codeunit";"Alt. Import Codeunit")
                            {
                                Caption = 'Alt. Import Codeunit';
                            }
                        }
                    }
                    group("Field Format")
                    {
                        Caption = 'Field Format';
                        field("Field Type";"Field Type")
                        {
                        }
                        field("Line Type";"Line Type")
                        {
                        }
                        field("Record Field Sep.";"Record Field Sep.")
                        {
                        }
                        field("Prefix Length";"Prefix Length")
                        {
                        }
                        field("Scanning End String";"Scanning End String")
                        {
                        }
                        group("Weight Integration")
                        {
                            Caption = 'Weight Integration';
                            field("Weight - No. of MA Samples";"Weight - No. of MA Samples")
                            {
                            }
                        }
                    }
                }
            }
            group(FTP)
            {
                grid(Control6014401)
                {
                    ShowCaption = false;
                    group(Control6014402)
                    {
                        ShowCaption = false;
                        field("FTP Download to Server Folder";"FTP Download to Server Folder")
                        {
                        }
                        field("FTP Site address";"FTP Site address")
                        {
                        }
                        field("FTP Filename";"FTP Filename")
                        {
                        }
                        field("FTP Username";"FTP Username")
                        {
                        }
                        field("FTP Password";"FTP Password")
                        {
                        }
                    }
                }
            }
            group("Input Format")
            {
                Caption = 'Input Format';
                part(Control6150662;"Scanner - Field Setup")
                {
                    SubPageLink = ID=FIELD(ID),
                                  "Where To"=CONST(Input);
                    SubPageView = SORTING(Order);
                }
            }
            group("Output Format")
            {
                Caption = 'Output Format';
                part(Control6150664;"Scanner - Field Setup")
                {
                    SubPageLink = ID=FIELD(ID),
                                  "Where To"=CONST(Output);
                    SubPageView = SORTING(Order);
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action(List)
                {
                    Caption = 'List';
                    Image = List;
                    RunObject = Page "Scanner - List";
                }
                action("Upload Program to Scanner")
                {
                    Caption = 'Upload Program to Scanner';
                    Image = "Action";

                    trigger OnAction()
                    begin
                        cu.UploadProgram2Scanner(Rec);
                    end;
                }
            }
        }
    }

    var
        cu: Codeunit "Scanner - Functions";
}

